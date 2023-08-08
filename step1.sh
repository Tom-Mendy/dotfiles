#!/usr/bin/bash

if [ -z "$var" ] then
  echo "replace YOUR_USERNAME by your username"
  echo "./ste1.sh YOUR_USERNAME"
  exit 1
fi

su -
usermod -aG sudo $1
exit
echo "reboot and launch step2.sh"
