#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# --- Automatically determine script's location ---
# This makes the script runnable from anywhere.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
THEME_NAME=$(basename "$SCRIPT_DIR")
# ------------------------------------------------

# The destination path for GRUB themes.
DEST_PARENT_DIR="/boot/grub/themes"
THEME_DIR="$DEST_PARENT_DIR/$THEME_NAME"

# Create theme directory if it doesn't exist
echo "Creating theme directory: $THEME_DIR"
mkdir -p "$THEME_DIR"

# Copy theme files
echo "Copying theme files from $SCRIPT_DIR..."
# Using '/.' ensures all contents, including hidden files, are copied.
cp -r "$SCRIPT_DIR/." "$THEME_DIR/"

# Set GRUB_THEME in /etc/default/grub
echo "Configuring GRUB..."
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    # If the line exists, replace it
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="'"$THEME_DIR/theme.txt"'"|' /etc/default/grub
else
    # If the line doesn't exist, add it
    echo 'GRUB_THEME="'"$THEME_DIR/theme.txt"'"' >> /etc/default/grub
fi

# Update GRUB configuration
echo "Updating GRUB..."
if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub-mkconfig &> /dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Could not find update-grub or grub-mkconfig. Please update GRUB manually."
    exit 1
fi

echo "GRUB theme '$THEME_NAME' installed successfully! ✨"
echo "Reboot to see the changes."