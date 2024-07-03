#!/bin/sh

# Script to install Nerd Fonts

# Clone the Nerd Fonts repository to /tmp
echo "Cloning Nerd Fonts repository..."
git clone https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts || {
  echo "Error: Failed to clone the Nerd Fonts repository."
  exit 1
}

# Change to the Nerd Fonts directory
cd /tmp/nerd-fonts || {
  echo "Error: Failed to change to the Nerd Fonts directory."
  exit 1
}

# Run the install script
echo "Running the Nerd Fonts install script..."
./install.sh || {
  echo "Error: Failed to run the Nerd Fonts install script."
  exit 1
}

# Change back to the original directory
cd || {
  echo "Error: Failed to change back to the original directory."
  exit 1
}

# Remove the Nerd Fonts directory in /tmp
echo "Cleaning up..."
rm -rf /tmp/nerd-fonts || {
  echo "Error: Failed to remove the Nerd Fonts directory in /tmp."
  exit 1
}

echo "Nerd Fonts installation complete."
