#!/bin/bash

generate_file() {
    #get image url
    wget "https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1&mkt=%sen_US" -O xml_page
    base_url="https://www.bing.com"
    url=$(cat xml_page | cut --delimiter="<" --fields=11 |cut --character=5-)
    url="$base_url$url"
    rm -f xml_page

    #dowload image
    echo "$url"
    curl "$url" --output wallpaper.jpg; 
    mv wallpaper.jpg "$HOME"/.bing_wallpaper.jpg
}


file="$HOME/.bing_wallpaper.jpg"
old_file="$HOME/.bing_wallpaper_old.jpg"

# Check if the file exists
if [[ -e "$file" ]]; then
    # Get the modification date of the file
    file_modification_date=$(stat -c %Y "$file")
    
    # Get today's date in seconds since the epoch
    today_date=$(date +%s)
    
    # Calculate the day numbers for the file's modification date and today's date
    file_day_number=$((file_modification_date / 86400))  # 86400 seconds in a day
    today_day_number=$((today_date / 86400))
    
    # Compare the day numbers
    if [ "$file_day_number" -ne "$today_day_number" ]; then
        cp "$file" "$old_file"
        generate_file
    else
        echo "The file's modification date is the same as today's date."
    fi
else
    generate_file
fi

#use feh to set image as wallpaper
feh --bg-scale --zoom fill "$file"
if [[ $? != 0 && -e "$old_file" ]]; then
    echo "use old file."
    feh --bg-scale --zoom fill "$old_file"
fi
