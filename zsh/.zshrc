# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Check if zinit is already installed, if not, install it
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
  command mkdir -p $HOME/.zinit
  command git clone https://github.com/zdharma-continuum/zinit $HOME/.zinit/bin && \
  print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
  print -P "%F{160}▓▒░ The clone has failed.%F"
fi

# Load zinit
source ~/.zinit/bin/zinit.zsh

autoload -Uz compinit
compinit

zinit ice lucid wait='1'
# Turbo mode with "wait"
zinit light-mode lucid wait for \
  is-snippet OMZ::lib/history.zsh \
  MichaelAquilina/zsh-you-should-use \
  zdharma-continuum/history-search-multi-word

zinit ice from"gh-r" as"program"
zinit light junegunn/fzf
zinit light Aloxaf/fzf-tab

zinit load agkozak/zsh-z
zinit light ajeetdsouza/zoxide

zinit ice lucid wait='0' atinit='zpcompinit'
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice lucid wait="0" atload='_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice lucid wait='0'
zinit light zsh-users/zsh-completions

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
if [ "$(command -v podman)" ]; then
zinit snippet OMZP::podman
fi
# plugin for language
if [ "$(command -v mvn)" ]; then
zinit snippet OMZP::mvn
fi
if [ "$(command -v node)" ]; then
zinit snippet OMZP::node
fi
if [ "$(command -v npm)" ]; then
zinit snippet OMZP::npm
fi
if [ "$(command -v pip)" ]; then
zinit snippet OMZP::pip
fi
if [ "$(command -v go)" ]; then
zinit snippet OMZP::golang
fi
if [ "$(command -v php)" ]; then
zinit snippet OMZP::laravel
fi
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
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load custom snippets if needed
# zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/

# Load Powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k

# Set your preferred theme
ZSH_THEME="powerlevel10k/powerlevel10k"

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

ZSH_DISABLE_COMPFIX=true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
if [ "$(command -v zoxide)" ]; then
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

eval "$(zoxide init --cmd cd zsh)"
fi

# ghcup-env Haskell
[ -f "/home/tmendy/.ghcup/env" ] && source "/home/tmendy/.ghcup/env" # ghcup-env

# Load Angular CLI autocompletion.
if [ "$(command -v ng)" ]; then
  source <(ng completion script)
fi

# TMUX
export PATH="$HOME/.local/bin":"$PATH"
bindkey -s ^f "tmux-sessionizer\n"


### ALIAS ###
alias grep="grep --color=auto"
alias e=$EDITOR

# https://stackoverflow.com/a/15503178/1820217
alias gitlog="git ls-files -z | xargs -0n1 git blame -w --show-email | perl -n -e '/^.*?\((.*?)\s+[\d]{4}/; print $1,"\n"' | sort -f | uniq -c | sort -n"

alias proxy='export http_proxy=http://127.0.0.1:1080 https_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080'
alias unproxy='unset http_proxy;unset https_proxy;unset all_proxy'
alias proxy_http='export all_proxy=http://127.0.0.1:1081'

# Flatpak
if [ "$(command -v com.discordapp.Discord)" ]; then
  alias Discord="com.discordapp.Discord"
fi
if [ "$(command -v com.github.IsmaelMartinez.teams_for_linux)" ]; then
  alias teams-for-linux="com.github.IsmaelMartinez.teams_for_linux"
fi
if [ "$(command -v com.spotify.Client)" ]; then
  alias spotify="com.spotify.Client"
fi

# Fedora & Arch
if [ "$(command -v bat)" ]; then
  alias bat="bat"
  alias cat="bat --paging=never"
fi
# Debian & Ubuntu
if [ "$(command -v batcat)" ]; then
    alias bat="batcat"
    alias cat="batcat --paging=never"
fi

# ls replacement
if [ "$(command -v eza)" ]; then
  alias ls="eza --icons --color=always --group-directories-first"
  alias la="eza --icons --color=always --group-directories-first -a"
  alias ll="eza --icons --color=always --group-directories-first -l"
  alias tree="eza --icons --color=always --group-directories-first --tree"
fi

# trash in terminal
if [ "$(command -v safe-rm)" ]; then
  alias rm="safe-rm"
fi

### ENV ###

# to make nvim default editor
if [ "$(command -v nvim)" ]; then
  export EDITOR=nvim
fi
# language specific paths
if [ "$(command -v cargo)" ]; then
  export PATH="${PATH}":"${HOME}/.cargo/bin"
fi
if [ "$(command -v flatpak)" ]; then
  export PATH="${PATH}":"/var/lib/flatpak/exports/bin"
fi
if [ "$(command -v go)" ]; then
  export PATH=${PATH}:"$(go env GOPATH)/bin"
fi
if [ "$(command -v composer)" ]; then
  export PATH="${PATH}":"$(composer global config bin-dir --absolute 2> /dev/null)"
fi

# Android SDK
if [ -d  "${HOME}/Android/Sdk/" ]; then
  export ANDROID_HOME="${HOME}/Android/Sdk/"
fi

# ssh
export TERM=xterm-256color

# to make bin in $HOME/my_scripts in the PATH
mkdir -p $HOME/my_scripts
export PATH=$HOME/my_scripts:$PATH
# to make bin in /usr/bin in the PATH
export PATH=/usr/bin:$PATH
# to make bin in $HOME/.local/bin in the PATH
export PATH="$HOME/.local/bin":"$PATH"
