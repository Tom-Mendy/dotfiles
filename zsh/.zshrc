# -----------------------------
# ⚡ POWERLEVEL10K INSTANT PROMPT
# -----------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------
# ⚡ ZINIT (NO INSTALL LOGIC HERE)
# -----------------------------
if [[ -f $HOME/.zinit/bin/zinit.zsh ]]; then
  source $HOME/.zinit/bin/zinit.zsh
else
  print "[dotfiles] zinit manquant. Lance ./install_zsh.sh depuis le repo pour le bootstrap."
  return
fi

# -----------------------------
# ⚡ COMPLETIONS (ONLY LOAD)
# -----------------------------
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
ZSH_COMPLETION_DIR="$ZSH_CACHE_DIR/completions"
fpath=($ZSH_COMPLETION_DIR $fpath)
# Defer compinit to zinit helper (zicompinit + zicdreplay) to avoid double runs with Turbo mode.
# Use a dedicated cache dump for this profile to keep startup fast and isolated.
ZINIT[COMPINIT_OPTS]="-C -d $ZSH_CACHE_DIR/.zcompdump"
ZINIT[COMPDUMP_PATH]="$ZSH_CACHE_DIR/.zcompdump-${HOST}-${ZSH_VERSION}"
ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1

# If local completion files are newer than the cache, force a one-time rebuild.
if [[ -f "${ZINIT[COMPDUMP_PATH]}" ]]; then
  for comp_file in "$ZSH_COMPLETION_DIR"/_*(N); do
    if [[ "$comp_file" -nt "${ZINIT[COMPDUMP_PATH]}" ]]; then
      rm -f "${ZINIT[COMPDUMP_PATH]}"
      break
    fi
  done
fi

# -----------------------------
# ⚡ PLUGINS (LAZY)
# -----------------------------
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" compile'(fast-syntax-highlighting.plugin.zsh)' \
    zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" compile'(zsh-autosuggestions.zsh)' \
    zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
    zsh-users/zsh-completions

zinit ice wait'3' lucid
zinit light Aloxaf/fzf-tab

zinit ice wait'3' lucid
zinit light junegunn/fzf

zinit ice wait'4' lucid
zinit light MichaelAquilina/zsh-you-should-use

zinit ice lucid wait
zinit snippet OMZP::git

zinit ice depth=1 compile'(powerlevel10k.zsh-theme)'
zinit light romkatv/powerlevel10k

ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'
ZSH_DISABLE_COMPFIX=true
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# -----------------------------
# ⚡ NAVIGATION (FAST)
# -----------------------------
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# -----------------------------
# ⚡ COMPLETION STYLING
# -----------------------------
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
(( $+commands[zoxide] )) && zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
if (( $+commands[docker] )); then
  zstyle ':completion:*:*:docker:*' menu no
  zstyle ':fzf-tab:complete:docker-*:*' fzf-preview '
  docker inspect $word 2>/dev/null | jq . 2>/dev/null || echo $word
  '
fi
if (( $+commands[kubectl] )); then
  zstyle ':fzf-tab:complete:kubectl-*:*' fzf-preview '
  kubectl get pod $word -o name 2>/dev/null|| echo $word
  '
  zstyle ':fzf-tab:complete:kubectl-get:*' fzf-preview '
  case $group in
    "pods")
      kubectl describe pod $word 2>/dev/null
    ;;
    "services")
      kubectl describe svc $word 2>/dev/null
    ;;
    *)
      echo $word
    ;;
  esac
  '
fi

# -----------------------------
# ⚡ ENV (LIGHT)
# -----------------------------
(( $+commands[nvim] )) && export EDITOR=nvim

typeset -U path PATH

for p in \
  /usr/bin \
  $HOME/.local/bin \
  $HOME/.atuin/bin \
  $HOME/.cargo/bin \
  $HOME/.bun/bin \
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
if [[ -d  "${HOME}/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
fi

if [[ -d  "${HOME}/Android/Sdk/" ]]; then
  export ANDROID_HOME="${HOME}/Android/Sdk/"
  path+=($ANDROID_HOME/emulator)
  path+=($ANDROID_HOME/platform-tools)
fi

export PATH

# -----------------------------
# ⚡ OPTIONAL TOOLS (LAZY SAFE)
# -----------------------------
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
if (( $+commands[atuin] )); then
  export ATUIN_SYNC_ADDRESS="https://atuin.home.tom-mendy.com"
  eval "$(atuin init zsh)"
fi
[[ -f "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"
[[ -f "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# -----------------------------
# ⚡ ALIASES (ESSENTIAL ONLY)
# -----------------------------
alias grep="grep --color=auto"
alias e=$EDITOR

alias gitlog="git ls-files -z | xargs -0n1 git blame -w --show-email | perl -n -e '/^.*?\((.*?)\s+[\d]{4}/; print $1,"\n"' | sort -f | uniq -c | sort -n"

alias proxy='export http_proxy=http://127.0.0.1:1080 https_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080'
alias unproxy='unset http_proxy;unset https_proxy;unset all_proxy'
alias proxy_http='export all_proxy=http://127.0.0.1:1081'

# Fedora & Arch
if (( $+commands[bat] )); then
  alias bat="bat"
  alias cat="bat --paging=never"
fi
# Debian & Ubuntu
if (( $+commands[batcat] )); then
    alias bat="batcat"
    alias cat="batcat --paging=never"
fi

# ls replacement
if (( $+commands[eza] )); then
  alias ls="eza --icons --color=always --group-directories-first"
  alias la="eza --icons --color=always --group-directories-first -a"
  alias ll="eza --icons --color=always --group-directories-first -l"
  alias tree="eza --icons --color=always --group-directories-first --tree"
fi

if (( $+commands[kubectl] )); then
  alias k=kubectl
  (( $+functions[_kubectl] )) && compdef k=kubectl
fi

# trash in terminal
(( $+commands[safe-rm] )) && alias rm="safe-rm"

# -----------------------------
# ⚡ TMUX
# -----------------------------
bindkey -s ^f "tmux-sessionizer\n"

# Ctrl+Arrow word jump (OMZ-like behavior) across common terminal escape sequences
for keymap in emacs viins; do
  bindkey -M "$keymap" '^[[1;5D' backward-word          # Ctrl+Left
  bindkey -M "$keymap" '^[[1;5C' forward-word           # Ctrl+Right
  bindkey -M "$keymap" '^[[5D' backward-word            # Ctrl+Left (alt sequence)
  bindkey -M "$keymap" '^[[5C' forward-word             # Ctrl+Right (alt sequence)

  # Alt+b / Alt+f word navigation (classic shell behavior)
  bindkey -M "$keymap" '^[b' backward-word              # Alt+b
  bindkey -M "$keymap" '^[f' forward-word               # Alt+f

  # Home / End across common terminal sequences
  bindkey -M "$keymap" '^[[H' beginning-of-line         # Home
  bindkey -M "$keymap" '^[[F' end-of-line               # End
  bindkey -M "$keymap" '^[[1~' beginning-of-line        # Home (alt sequence)
  bindkey -M "$keymap" '^[[4~' end-of-line              # End (alt sequence)
  bindkey -M "$keymap" '^[OH' beginning-of-line         # Home (SS3 sequence)
  bindkey -M "$keymap" '^[OF' end-of-line               # End (SS3 sequence)

  # Forward/backward word deletion for terminals supporting CSI-u / modified keys
  bindkey -M "$keymap" '^[[3;5~' kill-word              # Ctrl+Delete
  bindkey -M "$keymap" '^[[127;5u' backward-kill-word   # Ctrl+Backspace (kitty/CSI-u)
done

# -----------------------------
# ⚡ FINAL
# -----------------------------
[[ -z "$TERM" ]] && export TERM=xterm-256color