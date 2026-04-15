#!/usr/bin/env bash

# Options for the menu
options="Lock\nLogout\nReboot\nShutdown"

# Rofi command
rofi_cmd="rofi -dmenu -i -p 'Power Menu'"

# Show the menu and get the selected option
selected=$(echo -e "$options" | $rofi_cmd)

case "$selected" in
  Lock)
    # Command to lock the screen
    hyprlock
    ;;
  Logout)
    # Command to logout from Hyprland
    hyprctl dispatch exit
    ;;
  Reboot)
    # Command to reboot
    systemctl reboot
    ;;
  Shutdown)
    # Command to shutdown
    systemctl poweroff
    ;;
  *)
    # Do nothing if the user cancels
    exit 0
    ;;
esac
