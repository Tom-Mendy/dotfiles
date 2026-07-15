{ self, inputs, ... }:
let
  runtimePkgsFor = pkgs:
    with pkgs; [
      atuin
      bat
      direnv
      eza
      fd
      fzf
      git
      kubectl
      ripgrep
      safe-rm
      sesh
      zoxide
    ];

  promptModule = import ./prompt.nix {
    inherit inputs;
    asWrapperModule = true;
  };

  mainModule =
    { pkgs
    , ...
    }:
    {
      config = {
        hmSessionVariables = null;
        skipGlobalRC = true;

        runtimePkgs = runtimePkgsFor pkgs;

        zshenv.content = ''
          [[ -r /etc/set-environment ]] && source /etc/set-environment

          HELPDIR="${pkgs.zsh}/share/zsh/$ZSH_VERSION/help"
          fpath=(${pkgs.zsh-completions}/share/zsh/site-functions $fpath)

          for p in ''${(z)NIX_PROFILES}; do
            fpath=($p/share/zsh/site-functions $p/share/zsh/$ZSH_VERSION/functions $p/share/zsh/vendor-completions $fpath)
          done
        '';

        zshrc.content = ''
            [[ -z "$TERM" ]] && export TERM=xterm-256color

            ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
            ZSH_COMPLETION_DIR="$ZSH_CACHE_DIR/completions"
            ${pkgs.coreutils}/bin/mkdir -p "$ZSH_COMPLETION_DIR"
            fpath=("$ZSH_COMPLETION_DIR" ${pkgs.zsh-completions}/share/zsh/site-functions $fpath)

            autoload -Uz compinit
            compinit -C -d "$ZSH_CACHE_DIR/.zcompdump-$HOST-$ZSH_VERSION"

            ZSH_AUTOSUGGEST_STRATEGY=(history completion)
            ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

            source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            source ${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh
          source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh

          _load_powerlevel10k_prompt

            eval "$(${pkgs.zoxide}/bin/zoxide init zsh --cmd cd)"

            export FZF_DEFAULT_OPTS="
              --height 40%
              --layout=reverse
              --border
              --preview '${pkgs.bat}/bin/bat --style=numbers --color=always {}'
            "

            zstyle ':completion:*' matcher-list \
              'm:{a-z}={A-Za-z}' \
              'r:|=*' \
              'l:|=*'
            zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
            zstyle ':completion:*' menu no
            zstyle ':completion:*' use-cache on
            zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
            zstyle ':fzf-tab:complete:cd:*' fzf-preview '${pkgs.coreutils}/bin/ls --color $realpath'
            zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${pkgs.coreutils}/bin/ls --color $realpath'

            if (( $+commands[docker] )); then
              zstyle ':completion:*:*:docker:*' menu no
              zstyle ':fzf-tab:complete:docker-*:*' fzf-preview '
                docker inspect $word 2>/dev/null | ${pkgs.jq}/bin/jq . 2>/dev/null || echo $word
              '
            fi

            zstyle ':fzf-tab:complete:kubectl-*:*' fzf-preview '
              ${pkgs.kubectl}/bin/kubectl get pod $word -o name 2>/dev/null || echo $word
            '
            zstyle ':fzf-tab:complete:kubectl-get:*' fzf-preview '
              case $group in
                "pods")
                  ${pkgs.kubectl}/bin/kubectl describe pod $word 2>/dev/null
                ;;
                "services")
                  ${pkgs.kubectl}/bin/kubectl describe svc $word 2>/dev/null
                ;;
                *)
                  echo $word
                ;;
              esac
            '

            export EDITOR=${pkgs.neovim}/bin/nvim

            typeset -U path PATH

            for p in \
              /usr/bin \
              $HOME/.local/bin \
              $HOME/.atuin/bin \
              $HOME/.cargo/bin \
              $HOME/.bun/bin \
              $HOME/.opencode/bin \
              /opt/nvim-linux-x86_64/bin
            do
              [[ -d $p ]] && path=($p $path)
            done

            if (( $+commands[flatpak] )); then
              path+=(/var/lib/flatpak/exports/bin)
            fi
            if (( $+commands[go] )); then
              path+=("$(go env GOPATH)/bin")
            fi
            if (( $+commands[composer] )); then
              path+=("$(composer global config bin-dir --absolute 2> /dev/null)")
            fi
            if [[ -d "$HOME/.bun" ]]; then
              export BUN_INSTALL="$HOME/.bun"
            fi

            if [[ -d "$HOME/Android/Sdk/" ]]; then
              export ANDROID_HOME="$HOME/Android/Sdk/"
              path+=($ANDROID_HOME/emulator)
              path+=($ANDROID_HOME/platform-tools)
            fi

            export PATH

            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyguard-ssh-agent.sock"

            eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
            HISTFILE=~/.zsh_history
            HISTSIZE=10000
            SAVEHIST=10000

            setopt INC_APPEND_HISTORY
            setopt SHARE_HISTORY

            export ATUIN_FILTER_MODE=global
            export ATUIN_SEARCH_MODE=fuzzy
            export ATUIN_STYLE=compact
            export ATUIN_SYNC_ADDRESS="https://atuin.home.tom-mendy.com"
            eval "$(${pkgs.atuin}/bin/atuin init zsh)"

            [[ -f "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"
            [[ -f "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

            alias grep="${pkgs.gnugrep}/bin/grep --color=auto"
            alias e=$EDITOR

            gitlog() {
              ${pkgs.git}/bin/git ls-files -z \
                | ${pkgs.findutils}/bin/xargs -0n1 ${pkgs.git}/bin/git blame -w --show-email \
                | ${pkgs.perl}/bin/perl -n -e '/^.*?\((.*?)\s+[\d]{4}/; print $1,"\n"' \
                | ${pkgs.coreutils}/bin/sort -f \
                | ${pkgs.coreutils}/bin/uniq -c \
                | ${pkgs.coreutils}/bin/sort -n
            }

            alias proxy='export http_proxy=http://127.0.0.1:1080 https_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080'
            alias unproxy='unset http_proxy;unset https_proxy;unset all_proxy'
            alias proxy_http='export all_proxy=http://127.0.0.1:1081'

            alias bat="${pkgs.bat}/bin/bat"
            alias cat="${pkgs.bat}/bin/bat --paging=never"
            alias ls="${pkgs.eza}/bin/eza --icons --color=always --group-directories-first"
            alias la="${pkgs.eza}/bin/eza --icons --color=always --group-directories-first -a"
            alias ll="${pkgs.eza}/bin/eza --icons --color=always --group-directories-first -l"
            alias tree="${pkgs.eza}/bin/eza --icons --color=always --group-directories-first --tree"
            alias k=${pkgs.kubectl}/bin/kubectl
            (( $+functions[_kubectl] )) && compdef k=kubectl
            alias rm="${pkgs.safe-rm}/bin/safe-rm"

            chpwd() {
              ${pkgs.eza}/bin/eza --icons --color=always --group-directories-first --tree -L 1
            }

            function sesh-sessions() {
              {
                exec </dev/tty
                exec <&1
                local session
                local candidates
                candidates=$( {
                  ${pkgs.sesh}/bin/sesh list -t -c -z 2> /dev/null || true
                  ${pkgs.findutils}/bin/find ~/projects ~/work ~/tests -mindepth 1 -maxdepth 1 -type d 2> /dev/null || true
                } | ${pkgs.gawk}/bin/awk '!seen[$0]++')
                session=$(printf '%s\n' "$candidates" | ${pkgs.fzf}/bin/fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '> ')
                zle reset-prompt > /dev/null 2>&1 || true
                [[ -z "$session" ]] && return
                ${pkgs.sesh}/bin/sesh connect "$session"
              }
            }

            zle -N sesh-sessions
            bindkey -M emacs '^F' sesh-sessions
            bindkey -M viins '^F' sesh-sessions

            bindkey -e

            for keymap in emacs viins; do
              bindkey -M "$keymap" '^?' backward-delete-char
              bindkey -M "$keymap" '^H' backward-delete-char
              bindkey -M "$keymap" '^[[3~' delete-char
              bindkey -M "$keymap" '^[[127u' backward-delete-char
              bindkey -M "$keymap" '^[[3u' delete-char
              bindkey -M "$keymap" '^[[1;5D' backward-word
              bindkey -M "$keymap" '^[[1;5C' forward-word
              bindkey -M "$keymap" '^[[5D' backward-word
              bindkey -M "$keymap" '^[[5C' forward-word
              bindkey -M "$keymap" '^[b' backward-word
              bindkey -M "$keymap" '^[f' forward-word
              bindkey -M "$keymap" '^[[H' beginning-of-line
              bindkey -M "$keymap" '^[[F' end-of-line
              bindkey -M "$keymap" '^[[1~' beginning-of-line
              bindkey -M "$keymap" '^[[4~' end-of-line
              bindkey -M "$keymap" '^[OH' beginning-of-line
              bindkey -M "$keymap" '^[OF' end-of-line
              bindkey -M "$keymap" '^[[3;5~' kill-word
              bindkey -M "$keymap" '^[[127;5u' backward-kill-word
            done

            [[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

            if [[ "$TERM" = dumb ]]; then
              unsetopt zle prompt_cr prompt_subst
              unset RPS1 RPROMPT
              PS1='$ '
              PROMPT='$ '
            fi
        '';
      };
    };
in
{
  flake.nixosModules.zsh =
    { pkgs, ... }:
    let
      zshPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.zsh;
    in
    {
      # Required when using a wrapped zsh as a NixOS login shell.
      programs.zsh.enable = true;
      environment.pathsToLink = [ "/share/zsh" ];
      environment.shells = [ zshPackage ];
      environment.systemPackages = [ zshPackage ] ++ runtimePkgsFor pkgs;
      users.users.tmendy.shell = zshPackage;
    };

  perSystem =
    { pkgs, ... }:
    let
      zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        imports = [
          promptModule
          mainModule
        ];
      };

      zshDynamic = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        dynamicMode = true;
        imports = [
          promptModule
          mainModule
        ];
      };
    in
    {
      packages = {
        inherit zsh zshDynamic;

        # Short alias for `nix run .#nzsh`.
        nzsh = zsh;
        nzshDynamic = zshDynamic;
      };
    };
}
