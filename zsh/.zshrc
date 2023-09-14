# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Check if zinit is already installed, if not, install it
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma/zinit.git ~/.zinit/bin
fi

# Load zinit
source ~/.zinit/bin/zinit.zsh

# Load your favorite plugins
zinit load zsh-users/zsh-autosuggestions
zinit load zsh-users/zsh-syntax-highlighting
zinit load junegunn/fzf, \
    atclone"source install --all" \
    atpull"source install --all"
zinit load zsh-users/zsh-completions
zinit load ohmyzsh/plugins/git
zinit load ohmyzsh/plugins/docker
zinit load ohmyzsh/plugins/kubernetes
zinit load autojump/autojump
zinit load michaeltribes/zsh-autopair
zinit load zsh-users/zsh-history-substring-search
zinit load zdharma/fast-syntax-highlighting
zinit load zdharma/history-search-multi-word

# Load custom snippets if needed
# zinit snippet https://gist.githubusercontent.com/hightemp/5071909/raw/

# Load Powerlevel10k theme
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k

# Set your preferred theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load your custom alias and environment settings
source $HOME/.zsh/alias.zsh
source $HOME/.zsh/env.zsh

# Initialize Powerlevel10k theme (if config file exists)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
