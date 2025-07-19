#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# --- Configuration ---
# The name of the theme folder to uninstall.
THEME_NAME="ASUS_VIVOBOOK_GRUB_Theme"
# ---------------------

THEME_DIR="/boot/grub/themes/$THEME_NAME"
THEME_CONFIG_LINE="GRUB_THEME=\"$THEME_DIR/theme.txt\""

# Disable theme in /etc/default/grub
echo "Disabling GRUB theme in /etc/default/grub..."
# Find the exact line and comment it out. The '|' is used as a separator for sed.
if grep -q "^$THEME_CONFIG_LINE" /etc/default/grub; then
    sed -i "s|^$THEME_CONFIG_LINE|#$THEME_CONFIG_LINE|" /etc/default/grub
    echo "Theme configuration commented out."
else
    echo "Theme configuration not found in /etc/default/grub. Skipping."
fi

# Remove theme directory
if [ -d "$THEME_DIR" ]; then
    echo "Removing theme directory: $THEME_DIR..."
    rm -rf "$THEME_DIR"
else
    echo "Theme directory not found. Skipping."
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
echo "Your system will use the default GRUB look on next reboot."