alias tmux="TERM=screen-256color tmux -2"
alias vi="vim"
#alias mux="TERM=screen-256color tmuxinator"
# alias cp="cp -i"
# alias df="df -h"
# alias free="free -m"
alias grep="grep --color=auto"
alias e=$EDITOR

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

# Debian
if [ "$(command -v batcat)" ]; then
  alias bat="batcat"
  alias cat="batcat --paging=never"
fi
# Fedora & Arch
if [ "$(command -v bat)" ]; then
  alias bat="bat"
  alias cat="bat --paging=never"
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

# VSCodium
if [ "$(command -v codium)" ]; then
  alias code="codium"
fi

# Electron app hyprland
# if [[ $(loginctl show-session "$XDG_SESSION_ID" -p Desktop --value) == "hyprland" ]]; then
#   alias discord="discord --enable-features=UseOzonePlatform --ozone-platform=wayland"
#   alias teams-for-linux="teams-for-linux --enable-features=UseOzonePlatform --ozone-platform=wayland"
# fi
