alias tmux="TERM=screen-256color tmux -2"
alias vi="vim"
#alias mux="TERM=screen-256color tmuxinator"
# alias cp="cp -i"
# alias df="df -h"
# alias free="free -m"
alias grep="grep --color=auto"
alias e=$EDITOR

alias mci="mvn -e -U clean install"
alias mcp="mvn -U clean package"
alias mvn-purge="mvn dependency:purge-local-repository"

# https://stackoverflow.com/a/15503178/1820217
alias gitlog="git ls-files -z | xargs -0n1 git blame -w --show-email | perl -n -e '/^.*?\((.*?)\s+[\d]{4}/; print $1,"\n"' | sort -f | uniq -c | sort -n"

alias proxy='export http_proxy=http://127.0.0.1:1080 https_proxy=http://127.0.0.1:1080 all_proxy=socks5://127.0.0.1:1080'
alias unproxy='unset http_proxy;unset https_proxy;unset all_proxy'
alias proxy_http='export all_proxy=http://127.0.0.1:1081'

# assh
# https://github.com/moul/assh
if [[ -f ~/.ssh/assh.yml ]]; then
	alias ssh="assh wrapper ssh --"
fi

alias Discord="com.discordapp.Discord" "$HOME/.zshrc"
alias spotify="com.spotify.Client" "$HOME/.zshrc"
alias teams-for-linux="com.github.IsmaelMartinez.teams_for_linux" "$HOME/.zshrc"
if [ "$(command -v batcat)" ]; then
  alias bat="batcat" "$HOME/.zshrc"
  alias cat="batcat --paging=never" "$HOME/.zshrc"
fi
if [ "$(command -v exa)" ]; then
  alias ls="exa --icons --color=always --group-directories-first" "$HOME/.zshrc"
  alias la="exa --icons --color=always --group-directories-first -a" "$HOME/.zshrc"
  alias ll="exa --icons --color=always --group-directories-first -l" "$HOME/.zshrc"
  alias tree="exa --icons --color=always --group-directories-first --tree" "$HOME/.zshrc"
fi
if [ "$(command -v codium)" ]; then
  alias code="codium" "$HOME/.zshrc"
fi