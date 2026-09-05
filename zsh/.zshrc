# -----------------------------
# ⚡ ENVIRONMENT FIXES (EARLY)
# -----------------------------
[[ -z "$TERM" ]] && export TERM=xterm-256color

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
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

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
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# -----------------------------
# ⚡ HISTORY
# -----------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory sharehistory hist_ignore_dups hist_ignore_space hist_verify

# -----------------------------
# ⚡ PATHS
# -----------------------------
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/go/bin"
  "$HOME/.cargo/bin"
  "$HOME/.bun/bin"
  "$HOME/.atuin/bin"
  "/usr/local/go/bin"
  "/opt/homebrew/bin"
  $path
)
export PATH

# -----------------------------
# ⚡ ENVIRONMENT
# -----------------------------
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PNPM_HOME="$HOME/.local/share/pnpm"
export BUN_INSTALL="$HOME/.bun"
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export KUBECONFIG="$HOME/.kube/config"
export KUBE_EDITOR="${EDITOR:-vim}"
export MANPAGER='nvim +Man!'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# -----------------------------
# ⚡ EDITOR
# -----------------------------
if (( $+commands[nvim] )); then
  export EDITOR=nvim
  export VISUAL=nvim
elif (( $+commands[vim] )); then
  export EDITOR=vim
  export VISUAL=vim
else
  export EDITOR=vi
  export VISUAL=vi
fi

# -----------------------------
# ⚡ FZF
# -----------------------------
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# -----------------------------
# ⚡ TOOLS INIT
# -----------------------------
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

# -----------------------------
# ⚡ ATUIN
# -----------------------------
export ATUIN_SEARCH_MODE=fuzzy
export ATUIN_STYLE=compact
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
  autoload -Uz _kubectl
  compdef _kubectl kubectl k
fi

# trash in terminal
(( $+commands[safe-rm] )) && alias rm="safe-rm"

rsyncsafe() {
  local mode="$1"

  case "$mode" in
    check)
      shift
      rsync -avhP --checksum "$@"
      ;;

    mirror)
      shift
      rsync -avhP --partial --checksum --delete "$@"
      ;;

    *)
      rsync -avhP --partial --inplace "$@"
      ;;
  esac
}

# -----------------------------
# ⚡ AUTO FUNCTION
# -----------------------------
chpwd() {
  eza --icons --color=always --group-directories-first --tree -L 1
}

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
