# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
	mkdir ~/.zinit
	git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

# load zinit
source ~/.zinit/bin/zinit.zsh

# Plugin loaded with investigating.
zinit load zdharma-continuum/history-search-multi-word

# Plugins loaded without investigating.
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search

# Snippet
zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/

# Load powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k

# Set your preferred theme
ZSH_THEME="powerlevel10k/powerlevel10k"

source $HOME/.zsh/alias.zsh
source $HOME/.zsh/env.zsh

# Initialize Powerlevel10k theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
