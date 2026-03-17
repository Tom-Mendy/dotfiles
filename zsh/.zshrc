# -----------------------------
# ⚡ POWERLEVEL10K INSTANT PROMPT
# -----------------------------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------
# ⚡ ZINIT INSTALL (ONE TIME ONLY)
# -----------------------------
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p "$HOME/.zinit"
  git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin"
fi

# -----------------------------
# ⚡ LOAD ZINIT
# -----------------------------
source ~/.zinit/bin/zinit.zsh

# -----------------------------
# ⚡ COMPLETION (CACHED)
# -----------------------------
ZSH_COMPLETION_DIR="$HOME/.zsh/completions"
# ensure directory exists (cheap check)
[[ -d $ZSH_COMPLETION_DIR ]] || mkdir -p $ZSH_COMPLETION_DIR
# -----------------------------
# ⚡ DOCKER COMPLETION (AUTO, ONE-TIME GENERATION)
# -----------------------------
DOCKER_COMPLETION_FILE="$ZSH_COMPLETION_DIR/_docker"
DOCKER_COMPOSE_FILE="$ZSH_COMPLETION_DIR/_docker-compose"
if (( $+commands[docker] )) && [[ ! -f $DOCKER_COMPLETION_FILE ]]; then
  docker completion zsh >! $DOCKER_COMPLETION_FILE 2>/dev/null
  cp $DOCKER_COMPLETION_FILE $DOCKER_COMPOSE_FILE
fi
# -----------------------------
# ⚡ KUBECTL COMPLETION (AUTO, ONE-TIME)
# -----------------------------
KUBE_COMPLETION_FILE="$ZSH_COMPLETION_DIR/_kubectl"
if (( $+commands[kubectl] )) && [[ ! -f $KUBE_COMPLETION_FILE ]]; then
  kubectl completion zsh >! $KUBE_COMPLETION_FILE 2>/dev/null
fi

# add to fpath (only once)
fpath=($ZSH_COMPLETION_DIR $fpath)
autoload -Uz compinit
compinit -C

# -----------------------------
# ⚡ CORE PLUGINS (LAZY)
# ----------------------------
zinit ice wait'0' lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait'0' lucid atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'1' lucid
zinit light Aloxaf/fzf-tab

zinit ice wait'1'
zinit light junegunn/fzf

zinit ice lucid wait='1'
# Turbo mode with "wait"
zinit light-mode lucid wait for \
  MichaelAquilina/zsh-you-should-use \
  zdharma-continuum/history-search-multi-word

zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

# -----------------------------
# ⚡ NAVIGATION (FAST)
# -----------------------------
(( ! $+commands[zoxide] )) && curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# -----------------------------
# ⚡ MINIMAL OMZ (ONLY WHAT MATTERS)
# -----------------------------
zinit ice lucid wait='1'
zinit snippet OMZP::git

# -----------------------------
# ⚡ POWERLEVEL10K (LOAD ONCE)
# -----------------------------
# Load Powerlevel10k theme
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Set your preferred theme
ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'
ZSH_DISABLE_COMPFIX=true
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


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

# to make nvim default editor
if (( $+commands[nvim] )); then
  export EDITOR=nvim
fi
# language specific paths
if (( $+commands[cargo] )); then
  export PATH="${PATH}":"${HOME}/.cargo/bin"
fi
if (( $+commands[flatpak] )); then
  export PATH="${PATH}":"/var/lib/flatpak/exports/bin"
fi
if (( $+commands[go] )); then
  export PATH=${PATH}:"$(go env GOPATH)/bin"
fi
if (( $+commands[composer] )); then
  export PATH="${PATH}":"$(composer global config bin-dir --absolute 2> /dev/null)"
fi

# Android SDK
if [[ -d  "${HOME}/Android/Sdk/" ]]; then
  export ANDROID_HOME="${HOME}/Android/Sdk/"
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# Bun
if [[ -d  "${HOME}/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [[ -d  "${HOME}/.turso" ]]; then
export PATH="${PATH}:${HOME}/.turso"
fi

if [[ -d  "/opt/nvim-linux-x86_64/bin" ]]; then
  export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
fi

# to make bin in /usr/bin in the PATH
export PATH=/usr/bin:$PATH
# to make bin in $HOME/.local/bin in the PATH
export PATH="$HOME/.local/bin":"$PATH"

# -----------------------------
# ⚡ OPTIONAL TOOLS (LAZY SAFE)
# -----------------------------
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
# Load Angular CLI autocompletion.
if (( $+commands[ng] )) then;
  NG_COMPLETION="$ZSH_COMPLETION_DIR/_ng"

  if (( $+commands[ng] )) && [[ ! -f $NG_COMPLETION ]]; then
    ng completion script >! $NG_COMPLETION 2>/dev/null
  fi
fi
# ghcup-env Haskell
[[ -f "/home/tmendy/.ghcup/env" ]] && source "/home/tmendy/.ghcup/env" # ghcup-env
# bun completions
[ -s "/home/tmendy/.bun/_bun" ] && source "/home/tmendy/.bun/_bun"

# -----------------------------
# ⚡ ALIASES (ESSENTIAL ONLY)
# -----------------------------
alias grep="grep --color=auto"
alias e=$EDITOR

# https://stackoverflow.com/a/15503178/1820217
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
  compdef k=kubectl
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
