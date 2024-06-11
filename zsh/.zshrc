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
#zinit snippet OMZP::compleat
zinit snippet OMZP::sudo
zinit snippet OMZP::podman
# plugin for language
zinit snippet OMZP::mvn
zinit snippet OMZP::node
zinit snippet OMZP::npm
zinit snippet OMZP::pip
zinit snippet OMZP::golang
# take the distrubution info
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


# Load your custom alias and environment settings
source $HOME/.zsh/env.zsh
source $HOME/.zsh/alias.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

ZSH_DISABLE_COMPFIX=true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

eval "$(zoxide init --cmd cd zsh)"

# ghcup-env Haskell
[ -f "/home/tmendy/.ghcup/env" ] && source "/home/tmendy/.ghcup/env" # ghcup-env

# Load Angular CLI autocompletion.
if [ "$(command -v ng)" ]; then
  source <(ng completion script)
fi

