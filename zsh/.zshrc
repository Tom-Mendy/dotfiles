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
  print "[dotfiles] zinit manquant. Lance ./install.sh depuis le repo pour le bootstrap."
  return
fi

# -----------------------------
# ⚡ COMPLETIONS (ONLY LOAD)
# -----------------------------
ZSH_COMPLETION_DIR="$HOME/.zsh/completions"
[[ -d $ZSH_COMPLETION_DIR ]] || mkdir -p $ZSH_COMPLETION_DIR
# Prepend our cached completions but keep system fpath so compinit can find its definitions
fpath=($ZSH_COMPLETION_DIR $fpath)
autoload -Uz compinit
compinit -C

# -----------------------------
# ⚡ PLUGINS (LAZY)
# -----------------------------
zinit ice wait'0' lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait'0' lucid atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'1' lucid
zinit light Aloxaf/fzf-tab

# Lazy fzf: only load binary completion/helper when fzf functions are invoked
zfzi() {
  unset -f zfzi
  zinit ice wait'1'
  zinit light junegunn/fzf
  command -v fzf >/dev/null && { fzf --zsh || true; }
}
autoload -Uz zfzi
zle -N zfzi

zinit ice lucid wait='2'
zinit light-mode lucid wait for \
  MichaelAquilina/zsh-you-should-use \
  zdharma-continuum/history-search-multi-word

zinit ice lucid wait='0' atinit='zicompinit; zicdreplay'
zinit light zsh-users/zsh-completions

zinit ice lucid wait='1'
zinit snippet OMZP::git

zinit ice depth=1
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
  kubectl get $word -o yaml 2>/dev/null || echo $word
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
  $HOME/.cargo/bin \
  $HOME/.bun/bin \
  /opt/nvim-linux-x86_64/bin
do
  [[ -d $p ]] && path=($p $path)
done

export PATH

if (( $+commands[flatpak] )); then
  export PATH="${PATH}":"/var/lib/flatpak/exports/bin"
fi
if (( $+commands[go] )); then
  export PATH=${PATH}:"$(go env GOPATH)/bin"
fi
if (( $+commands[composer] )); then
  export PATH="${PATH}":"$(composer global config bin-dir --absolute 2> /dev/null)"
fi
if [[ -d  "${HOME}/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
fi

if [[ -d  "${HOME}/Android/Sdk/" ]]; then
  export ANDROID_HOME="${HOME}/Android/Sdk/"
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# -----------------------------
# ⚡ OPTIONAL TOOLS (LAZY SAFE)
# -----------------------------
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
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

# -----------------------------
# ⚡ FINAL
# -----------------------------
export TERM=xterm-256color
