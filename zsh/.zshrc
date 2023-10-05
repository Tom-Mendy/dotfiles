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

zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/grep.zsh
zinit snippet OMZ::lib/history.zsh
zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/theme-and-appearance.zsh
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh
zinit snippet OMZ::plugins/colorize/colorize.plugin.zsh
zinit snippet OMZ::plugins/command-not-found/command-not-found.plugin.zsh
zinit snippet OMZ::plugins/debian/debian.plugin.zsh
zinit snippet OMZ::plugins/mvn/mvn.plugin.zsh
zinit snippet OMZ::plugins/npm/npm.plugin.zsh
zinit snippet OMZ::plugins/pip/pip.plugin.zsh
zinit snippet OMZ::plugins/rsync/rsync.plugin.zsh
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh

zinit ice lucid wait='1'
zinit snippet OMZ::plugins/git/git.plugin.zsh

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
source $HOME/.zsh/kubectl.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=6'

ZSH_DISABLE_COMPFIX=true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
