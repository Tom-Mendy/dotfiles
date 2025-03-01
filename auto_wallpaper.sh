#!/usr/bin/env bash

file="${HOME}/.background-image"
old_file="${HOME}/.background-image_old"

generate_file() {
  #get image url
  curl "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=%sen_US" --output xml_page
  base_url="https://www.bing.com"
  url=$(cat xml_page | cut --delimiter="<" --fields=11 | cut --character=5-)
  url="$base_url$url"
  rm -f xml_page

  #download image
  echo "$url"
  curl "$url" --output wallpaper.jpg
  mv wallpaper.jpg "${file}"
}

# Check if the file exists
if [[ -e ${file} ]]; then
  # Get the modification date of the file
  file_modification_date=$(stat -c %Y "${file}")

  # Get today's date in seconds since the epoch
  today_date=$(date +%s)

  # Calculate the day numbers for the file's modification date and today's date
  file_day_number=$((file_modification_date / 86400)) # 86400 seconds in a day
  today_day_number=$((today_date / 86400))

  # Compare the day numbers
  if [ "$file_day_number" -ne "$today_day_number" ]; then
    cp "${file}" "${old_file}"
    generate_file
  else
    echo "The file's modification date is the same as today's date."
  fi
else
  generate_file
fi

case $(loginctl show-session "$XDG_SESSION_ID" -p Type --value) in
  x11)
    # check if fef is install
    if [ "$(command -v feh)" ]; then
      #use feh to set image as wallpaper
      feh --bg-scale --zoom fill "${file}"
      if [[ $? != 0 && -e ${old_file} ]]; then
        echo "use old file."
        feh --bg-scale --zoom fill "${old_file}"
      fi
    else
      echo "feh is not install"
    fi
    ;;
  wayland)
    if [ "$(command -v hyprpaper)" ]; then
      killall hyprpaper
      hyprpaper &
      # monitors=$(hyprctl monitors | grep Monitor | awk '{print $2}')
      # hyprctl hyprpaper unload all
      # hyprctl hyprpaper preload "${file}"
      # for monitor in $monitors; do
      #   hyprctl hyprpaper wallpaper "$monitor, ${file}"
      # done
    else
      echo "hyprpaper is not install"
    fi
    ;;
  *)
    echo "Unsupported Display Manager"
    ;;
esac
