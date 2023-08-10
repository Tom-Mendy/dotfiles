#!/ust/bin/sh

nitrogen --restore
xrandr -s 1920x1080

# Add nix app on dmenu
export XDG_DATA_DIRS=~/.local/share/:~/.nix-profile/share:/usr/share
cp -f ~/.nix-profile/share/applications/*.desktop ~/.local/share/applications/
