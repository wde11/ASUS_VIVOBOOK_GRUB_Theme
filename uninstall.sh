#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Configuration
THEME_NAME="ASUS_VIVOBOOK_GRUB_Theme"
THEME_DIR="/boot/grub/themes/$THEME_NAME"
GRUB_CONFIG_FILE="/etc/default/grub"

echo "Uninstalling theme '$THEME_NAME'..."

# Comment out theme settings in /etc/default/grub
sed -i 's|^\(GRUB_THEME="'"$THEME_DIR"'/theme.txt"\)|#\1|' "$GRUB_CONFIG_FILE"
sed -i 's|^\(GRUB_GFXMODE=1920x1080,auto\)|#\1|' "$GRUB_CONFIG_FILE"
sed -i 's|^\(GRUB_GFXPAYLOAD_LINUX=keep\)|#\1|' "$GRUB_CONFIG_FILE"
echo "Theme configuration commented out in $GRUB_CONFIG_FILE."

# Remove theme directory
if [ -d "$THEME_DIR" ]; then
    echo "Removing theme directory: $THEME_DIR..."
    rm -rf "$THEME_DIR"
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

echo "GRUB theme '$THEME_NAME' uninstalled successfully. 🗑️"