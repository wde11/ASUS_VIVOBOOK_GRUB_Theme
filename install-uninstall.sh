#!/bin/bash

#
# ASUS Vivobook GRUB Theme Installer
#
# This script automates the installation of the ASUS Vivobook GRUB theme.
# It checks for root privileges, copies the theme files to the correct
# directory, sets the theme in the GRUB configuration, and updates GRUB.
#
# Created by: Gemini
# Based on the theme by: wde11 (https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme)
#

# --- Configuration ---
THEME_NAME="ASUS_VIVOBOOK_GRUB_Theme"
GRUB_THEMES_DIR="/boot/grub/themes"
GRUB_CONFIG_FILE="/etc/default/grub"
GRUB_CONFIG_BACKUP="/etc/default/grub.bak"
THEME_DIR_URL="https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme.git"

# --- Helper Functions ---

# Print a message in a specific color
# $1: color (e.g., "red", "green", "yellow")
# $2: message
function print_color() {
    case $1 in
        "green") echo -e "\e[32m$2\e[0m" ;;
        "red") echo -e "\e[31m$2\e[0m" ;;
        "yellow") echo -e "\e[33m$2\e[0m" ;;
        *) echo "$2" ;;
    esac
}

# --- Main Script ---

# 1. Check for Root Privileges
print_color "yellow" "Checking for root privileges..."
if [[ $EUID -ne 0 ]]; then
   print_color "red" "This script must be run as root. Please use sudo."
   exit 1
fi
print_color "green" "Root privileges confirmed."
echo

# 2. Check for git
print_color "yellow" "Checking if git is installed..."
if ! command -v git &> /dev/null; then
    print_color "red" "Git is not installed. Please install it to continue."
    print_color "red" "For Debian/Ubuntu: sudo apt-get install git"
    print_color "red" "For Fedora/CentOS: sudo dnf install git"
    print_color "red" "For Arch Linux: sudo pacman -S git"
    exit 1
fi
print_color "green" "Git is installed."
echo

# 3. Clone the theme repository
print_color "yellow" "Cloning the theme repository from GitHub..."
if [ -d "$THEME_NAME" ]; then
    print_color "yellow" "Theme directory already exists. Pulling latest changes..."
    cd "$THEME_NAME" || exit
    git pull
    cd ..
else
    git clone "$THEME_DIR_URL"
    if [ $? -ne 0 ]; then
        print_color "red" "Failed to clone the repository. Please check the URL and your internet connection."
        exit 1
    fi
fi
print_color "green" "Theme repository cloned successfully."
echo

# 4. Create GRUB themes directory if it doesn't exist
print_color "yellow" "Checking for GRUB themes directory..."
if [ ! -d "$GRUB_THEMES_DIR" ]; then
    print_color "yellow" "GRUB themes directory not found. Creating it at $GRUB_THEMES_DIR..."
    mkdir -p "$GRUB_THEMES_DIR"
    print_color "green" "Directory created."
else
    print_color "green" "GRUB themes directory already exists."
fi
echo

# 5. Copy the theme to the GRUB themes directory
print_color "yellow" "Installing the theme..."
cp -r "$THEME_NAME/ASUS_VIVOBOOK" "$GRUB_THEMES_DIR/"
if [ $? -eq 0 ]; then
    print_color "green" "Theme successfully copied to $GRUB_THEMES_DIR."
else
    print_color "red" "Failed to copy the theme. Aborting."
    exit 1
fi
echo

# 6. Configure GRUB to use the theme
print_color "yellow" "Configuring GRUB..."

# Backup the current GRUB config
if [ -f "$GRUB_CONFIG_FILE" ]; then
    print_color "yellow" "Backing up current GRUB configuration to $GRUB_CONFIG_BACKUP..."
    cp "$GRUB_CONFIG_FILE" "$GRUB_CONFIG_BACKUP"
    print_color "green" "Backup successful."
else
    print_color "red" "GRUB configuration file not found at $GRUB_CONFIG_FILE. Aborting."
    exit 1
fi

# Set the theme path in the GRUB config
THEME_PATH_LINE="GRUB_THEME=\"$GRUB_THEMES_DIR/ASUS_VIVOBOOK/theme.txt\""

# Check if GRUB_THEME is already set
if grep -q "^GRUB_THEME=" "$GRUB_CONFIG_FILE"; then
    print_color "yellow" "Updating existing GRUB_THEME setting..."
    sed -i "s|^GRUB_THEME=.*|$THEME_PATH_LINE|" "$GRUB_CONFIG_FILE"
else
    print_color "yellow" "Adding GRUB_THEME setting..."
    echo -e "\n# Set theme for GRUB" >> "$GRUB_CONFIG_FILE"
    echo "$THEME_PATH_LINE" >> "$GRUB_CONFIG_FILE"
fi

# Ensure GRUB_GFXMODE is set for better resolution
if ! grep -q "^GRUB_GFXMODE=" "$GRUB_CONFIG_FILE"; then
    print_color "yellow" "Adding GRUB_GFXMODE setting for better resolution..."
    echo "GRUB_GFXMODE=1920x1080x32,auto" >> "$GRUB_CONFIG_FILE"
else
    print_color "green" "GRUB_GFXMODE is already set."
fi

print_color "green" "GRUB configuration updated."
echo

# 7. Update GRUB
print_color "yellow" "Updating GRUB to apply changes..."
if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub-mkconfig &> /dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif command -v grub2-mkconfig &> /dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    print_color "red" "Could not find a command to update GRUB."
    print_color "red" "Please update GRUB manually."
    print_color "red" "Common commands:"
    print_color "red" "  - sudo update-grub (Debian/Ubuntu)"
    print_color "red" "  - sudo grub-mkconfig -o /boot/grub/grub.cfg (Arch Linux)"
    print_color "red" "  - sudo grub2-mkconfig -o /boot/grub2/grub.cfg (Fedora/CentOS)"
    exit 1
fi

if [ $? -eq 0 ]; then
    print_color "green" "GRUB update successful!"
else
    print_color "red" "GRUB update failed. Please check for errors above."
    exit 1
fi
echo

# --- Final Message ---
print_color "green" "Installation complete! The ASUS Vivobook GRUB theme should now be active."
print_color "yellow" "Reboot your system to see the changes."

