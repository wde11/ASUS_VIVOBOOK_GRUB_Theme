#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Define theme directory
THEME_DIR="/boot/grub/themes/ASUS_VIVOBOOK_GRUB_Theme"

# Create theme directory if it doesn't exist
echo "Creating theme directory..."
mkdir -p "$THEME_DIR"

# Copy theme files
echo "Copying theme files..."
cp -r ASUS_VIVOBOOK_GRUB_Theme/* "$THEME_DIR/"

# Set GRUB_THEME in /etc/default/grub
echo "Configuring GRUB..."
if grep -q "^GRUB_THEME=" /etc/default/grub; then
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="'"$THEME_DIR"'/theme.txt"|' /etc/default/grub
else
    echo 'GRUB_THEME="'"$THEME_DIR"'/theme.txt"' >> /etc/default/grub
fi

# Update GRUB
echo "Updating GRUB..."
if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub-mkconfig &> /dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "Could not find update-grub or grub-mkconfig. Please update GRUB manually."
    exit 1
fi

echo "GRUB theme installed successfully!"
echo "Reboot to see the changes."