#!/usr/bin/env bash

# Update the system
echo "Updating the system..."
if sudo dnf upgrade -y; then
  echo "System update completed successfully."
else
  echo "System update failed. Exiting."
  exit 1
fi

# Update npm packages
echo "Updating npm packages..."
if sudo npm update -g; then
  echo "npm update completed successfully."
else
  echo "npm update failed."
fi

# Update Rust
echo "Updating Rust..."
if rustup update; then
  echo "Rust update completed successfully."
else
  echo "Rust update failed."
fi

# Update flatpak packages
echo "Updating flatpak packages..."
if flatpak update -y; then
  echo "Flatpak update completed successfully."
else
  echo "Flatpak update failed."
fi

echo "Update process finished."
