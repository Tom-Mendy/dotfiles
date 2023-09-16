#!/bin/bash

# Update the system
echo "Updating the system..."
sudo nala update && sudo nala upgrade -y

# Check if the system update was successful
if [ $? -eq 0 ]; then
    echo "System update completed successfully."
else
    echo "System update failed. Exiting."
    exit 1
fi

# Update npm packages
echo "Updating npm packages..."
npm update -g --force

# Check if npm update was successful
if [ $? -eq 0 ]; then
    echo "npm update completed successfully."
else
    echo "npm update failed."
fi

# Update Rust
echo "Updating Rust..."
rustup update

# Check if Rust update was successful
if [ $? -eq 0 ]; then
    echo "Rust update completed successfully."
else
    echo "Rust update failed."
fi

# Update flatpak packages
echo "Updating flatpak packages..."
flatpak update -y

# Check if flatpak update was successful
if [ $? -eq 0 ]; then
    echo "Flatpak update completed successfully."
else
    echo "Flatpak update failed."
fi

echo "Update process finished."
