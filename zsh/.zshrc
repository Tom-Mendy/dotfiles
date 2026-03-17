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

zinit ice wait'1' lucid
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
if (( ! $+commands[zoxide] )); then
  . /etc/os-release
  case "$ID" in
    ubuntu|debian)
      curl -fsSL https://apt.cli.rs/pubkey.asc | sudo tee -a /usr/share/keyrings/rust-tools.asc
      curl -fsSL https://apt.cli.rs/rust-tools.list | sudo tee /etc/apt/sources.list.d/rust-tools.list
      sudo apt update
      sudo apt install -y zoxide
    ;;
    fedora|centos|rocky)
      sudo dnf install -y zoxide
    ;;
    arch|manjaro)
      sudo pacman -S --noconfirm zoxide
    ;;
    *)
      echo "Unsupported OS: $ID to install zoxide manually visit https://github.com/ajeetdsouza/zoxide#installation"
    ;;
  esac
fi
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# -----------------------------
# ⚡ MINIMAL OMZ (ONLY WHAT MATTERS)
# -----------------------------
#zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/grep.zsh
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/theme-and-appearance.zsh
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::colorize
zinit snippet OMZP::command-not-found
#zinit snippet OMZP::common-aliases
#zinit snippet OMZP::complete
zinit snippet OMZP::sudo
(( $+commands[podman] )) && zinit snippet OMZP::podman
# plugin for language
(( $+commands[mvn] )) &&zinit snippet OMZP::mvn
(( $+commands[node] )) &&zinit snippet OMZP::node
(( $+commands[npm] )) &&zinit snippet OMZP::npm
(( $+commands[pip] )) &&zinit snippet OMZP::pip
(( $+commands[go] )) &&zinit snippet OMZP::golang
(( $+commands[php] )) && zinit snippet OMZP::laravel
# take the distribution info
. /etc/os-release
if [[ $ID == "debian" ]]; then
  zinit snippet OMZP::debian
fi
if [[ $ID == "fedora" ]]; then
  zinit snippet OMZP::dnf
fi
zinit ice lucid wait='1'
zinit snippet OMZP::git

# Gitignore plugin – commands gii and gi
zinit ice wait"2" lucid
zinit load voronkovich/gitignore.plugin.zsh

# zinit light denysdovhan/spaceship-prompt
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load custom snippets if needed
# zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/

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
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# zstyle ':completion:*' menu no

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
if (( $+commands[zoxide] )); then
  zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
  eval "$(zoxide init --cmd cd zsh)"
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

# -----------------------------
# ⚡ OPTIONAL TOOLS (LAZY SAFE)
# -----------------------------
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"
# Load Angular CLI autocompletion.
(( $+commands[ng] )) && source <(ng completion script)
# ghcup-env Haskell
[[ -f "/home/tmendy/.ghcup/env" ]] && source "/home/tmendy/.ghcup/env" # ghcup-env
# bun completions
[ -s "/home/tmendy/.bun/_bun" ] && source "/home/tmendy/.bun/_bun"

# to make bin in $HOME/my_scripts in the PATH
mkdir -p $HOME/my_scripts
export PATH=$HOME/my_scripts:$PATH
# to make bin in /usr/bin in the PATH
export PATH=/usr/bin:$PATH
# to make bin in $HOME/.local/bin in the PATH
export PATH="$HOME/.local/bin":"$PATH"

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

# Flatpak
(( $+commands[com.discordapp.Discord] )) && alias Discord="com.discordapp.Discord"
(( $+commands[com.github.IsmaelMartinez.teams_for_linux] )) && alias teams-for-linux="com.github.IsmaelMartinez.teams_for_linux"
(( $+commands[com.spotify.Client] )) && alias spotify="com.spotify.Client"

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

# trash in terminal
(( $+commands[safe-rm] )) && alias rm="safe-rm"

# -----------------------------
# ⚡ TMUX
# -----------------------------
export PATH="$HOME/.local/bin":"$PATH"
bindkey -s ^f "tmux-sessionizer\n"

# -----------------------------
# ⚡ FINAL
# -----------------------------
export TERM=xterm-256color
