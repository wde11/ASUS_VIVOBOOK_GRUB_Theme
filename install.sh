#!/bin/bash

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Automatically determine script's location
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
THEME_NAME=$(basename "$SCRIPT_DIR")
GRUB_CONFIG_FILE="/etc/default/grub"

# Destination path for GRUB themes
DEST_PARENT_DIR="/boot/grub/themes"
THEME_DIR="$DEST_PARENT_DIR/$THEME_NAME"

# Create theme directory
echo "Creating theme directory: $THEME_DIR"
mkdir -p "$THEME_DIR"

# Copy theme files
echo "Copying theme files..."
# Using 'cp -a' is the most reliable way to copy all files and directories.
# The '/.' ensures the *contents* of the directory are copied.
cp -a "$SCRIPT_DIR/." "$THEME_DIR/"

# Convert .ttf font to .pf2 for GRUB
echo "Converting font..."
if [ -f "$SCRIPT_DIR/Asus Rog.ttf" ]; then
    grub-mkfont -v -s 12 -o "$THEME_DIR/Asus Rog 12.pf2" "$SCRIPT_DIR/Asus Rog.ttf"
    grub-mkfont -v -s 16 -o "$THEME_DIR/Asus Rog 16.pf2" "$SCRIPT_DIR/Asus Rog.ttf"
    grub-mkfont -v -s 20 -o "$THEME_DIR/Asus Rog 20.pf2" "$SCRIPT_DIR/Asus Rog.ttf"
else
    echo "Warning: Font file 'Asus Rog.ttf' not found. Skipping font conversion."
fi

# --- Configure GRUB settings ---
echo "Configuring GRUB settings in $GRUB_CONFIG_FILE..."

# Set GRUB_THEME
THEME_CONFIG_LINE="GRUB_THEME=\"$THEME_DIR/theme.txt\""
if grep -q "^GRUB_THEME=" "$GRUB_CONFIG_FILE"; then
    sed -i "s|^GRUB_THEME=.*|$THEME_CONFIG_LINE|" "$GRUB_CONFIG_FILE"
else
    echo "$THEME_CONFIG_LINE" >> "$GRUB_CONFIG_FILE"
fi

# Set GRUB_GFXMODE
GFX_MODE_LINE="GRUB_GFXMODE=1920x1080,auto"
if grep -q "^GRUB_GFXMODE=" "$GRUB_CONFIG_FILE"; then
    sed -i "s|^GRUB_GFXMODE=.*|$GFX_MODE_LINE|" "$GRUB_CONFIG_FILE"
else
    echo "$GFX_MODE_LINE" >> "$GRUB_CONFIG_FILE"
fi

# Set GRUB_GFXPAYLOAD_LINUX
GFX_PAYLOAD_LINE="GRUB_GFXPAYLOAD_LINUX=keep"
if grep -q "^GRUB_GFXPAYLOAD_LINUX=" "$GRUB_CONFIG_FILE"; then
    sed -i "s|^GRUB_GFXPAYLOAD_LINUX=.*|$GFX_PAYLOAD_LINE|" "$GRUB_CONFIG_FILE"
else
    echo "$GFX_PAYLOAD_LINE" >> "$GRUB_CONFIG_FILE"
fi
# --- End GRUB config ---

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

echo "GRUB theme '$THEME_NAME' installed successfully! ✨"
echo "Reboot to see the changes."