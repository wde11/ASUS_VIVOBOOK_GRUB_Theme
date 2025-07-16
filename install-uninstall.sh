#!/bin/bash

# ==============================================================================
#
#          GRUB Theme Installer - A script to safely install GRUB themes
#
#   Author: https://github.com/wde11
#   Version: 1.1
#   Description: This script automates the installation of a GRUB theme.
#                It performs the following steps:
#                1. Checks for root privileges.
#                2. Identifies the correct GRUB directory.
#                3. Backs up the existing GRUB configuration.
#                4. Copies the theme files to the GRUB themes directory.
#                5. Sets the new theme in the GRUB configuration file.
#                6. Updates the GRUB bootloader.
#                7. Includes an uninstall option to revert changes.
#
#   Usage: ./install.sh [theme_folder]
#          ./install.sh --uninstall
#
# ==============================================================================

# --- Configuration & Constants ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Color codes for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper Functions ---

# Function to print a formatted info message
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Function to print a formatted warning message
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to print a formatted error message and exit
error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# --- Pre-flight Checks ---

# 1. Check for Root Privileges
if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root. Please use 'sudo ./install.sh'"
fi

# 2. Check for correct arguments
if [ "$#" -eq 0 ] || [ "$#" -gt 1 ]; then
    echo "Usage: $0 [path_to_theme_folder]"
    echo "   or: $0 --uninstall"
    exit 1
fi

# --- Main Logic ---

# Find the correct GRUB directory and configuration file
GRUB_CFG="/etc/default/grub"
GRUB_DIR=""
if [ -d "/boot/grub/themes" ]; then
    GRUB_DIR="/boot/grub/themes"
elif [ -d "/boot/grub2/themes" ]; then
    GRUB_DIR="/boot/grub2/themes"
else
    # If themes directory doesn't exist, create it
    info "GRUB themes directory not found. Attempting to create it."
    if [ -d "/boot/grub" ]; then
        mkdir -p "/boot/grub/themes"
        GRUB_DIR="/boot/grub/themes"
    elif [ -d "/boot/grub2" ]; then
        mkdir -p "/boot/grub2/themes"
        GRUB_DIR="/boot/grub2/themes"
    else
        error "Could not find a valid GRUB installation directory (/boot/grub or /boot/grub2)."
    fi
fi
info "Found GRUB directory at: $GRUB_DIR"

# --- Uninstall Logic ---
if [ "$1" == "--uninstall" ]; then
    info "Starting uninstallation process..."
    GRUB_CFG_BACKUP="${GRUB_CFG}.bak.theme"
    if [ -f "$GRUB_CFG_BACKUP" ]; then
        info "Restoring GRUB configuration from backup..."
        mv "$GRUB_CFG_BACKUP" "$GRUB_CFG"
    else
        warn "No backup file found. Removing theme line manually."
        # Use sed to comment out the GRUB_THEME line
        sed -i -E 's/^(GRUB_THEME=.*)/#\1/g' "$GRUB_CFG"
    fi

    info "Updating GRUB..."
    # Universal command to update GRUB
    if command -v update-grub &> /dev/null; then
        update-grub
    elif command -v grub-mkconfig &> /dev/null; then
        grub-mkconfig -o /boot/grub/grub.cfg
    elif command -v grub2-mkconfig &> /dev/null; then
        grub2-mkconfig -o /boot/grub2/grub.cfg
    else
        error "Could not find 'update-grub' or 'grub-mkconfig'. Please update GRUB manually."
    fi

    info "${GREEN}Theme uninstalled successfully!${NC} The theme files are still in $GRUB_DIR if you wish to remove them manually."
    exit 0
fi


# --- Installation Logic ---

THEME_SOURCE_DIR=$1

# 3. Check if the theme source directory and theme.txt exist
if [ ! -d "$THEME_SOURCE_DIR" ]; then
    error "Theme source directory not found: $THEME_SOURCE_DIR"
fi

if [ ! -f "$THEME_SOURCE_DIR/theme.txt" ]; then
    warn "The theme directory '$THEME_SOURCE_DIR' does not contain a 'theme.txt' file."
    warn "This might not be a valid GRUB theme. Continuing anyway..."
fi

THEME_NAME=$(basename "$THEME_SOURCE_DIR")
THEME_DEST_DIR="$GRUB_DIR/$THEME_NAME"

info "Starting GRUB theme installation for '$THEME_NAME'"

# 4. Backup the GRUB config file
GRUB_CFG_BACKUP="${GRUB_CFG}.bak.theme"
if [ ! -f "$GRUB_CFG_BACKUP" ]; then
    info "Backing up GRUB configuration to $GRUB_CFG_BACKUP..."
    cp "$GRUB_CFG" "$GRUB_CFG_BACKUP"
else
    warn "Backup file already exists. Skipping backup."
fi

# 5. Copy the theme to the GRUB themes directory
info "Copying theme files to $THEME_DEST_DIR..."
# Use rsync for better copying, or cp as a fallback
if command -v rsync &> /dev/null; then
    rsync -a --delete "$THEME_SOURCE_DIR/" "$THEME_DEST_DIR/"
else
    cp -r "$THEME_SOURCE_DIR" "$GRUB_DIR"
fi

# 6. Set the theme in the GRUB configuration
THEME_CONFIG_LINE="GRUB_THEME=\"$THEME_DEST_DIR/theme.txt\""
info "Setting theme in $GRUB_CFG..."

# Check if GRUB_THEME is already set
if grep -q "^GRUB_THEME=" "$GRUB_CFG"; then
    # It's set, so we replace the line
    info "GRUB_THEME variable found, updating it."
    sed -i -E "s|^GRUB_THEME=.*|$THEME_CONFIG_LINE|" "$GRUB_CFG"
elif grep -q "^#GRUB_THEME=" "$GRUB_CFG"; then
    # It's commented out, so we uncomment and replace
    info "GRUB_THEME variable found but commented, updating it."
    sed -i -E "s|^#GRUB_THEME=.*|$THEME_CONFIG_LINE|" "$GRUB_CFG"
else
    # It's not in the file, so we add it
    info "GRUB_THEME variable not found, adding it."
    echo "" >> "$GRUB_CFG"
    echo "# Added by install.sh" >> "$GRUB_CFG"
    echo "$THEME_CONFIG_LINE" >> "$GRUB_CFG"
fi

# Ensure GRUB_GFXMODE is set for proper display
if ! grep -q "^GRUB_GFXMODE=" "$GRUB_CFG"; then
    info "Setting GRUB_GFXMODE for best results."
    echo "GRUB_GFXMODE=auto" >> "$GRUB_CFG"
fi

# 7. Update GRUB
info "Applying changes by updating GRUB..."
if command -v update-grub &> /dev/null; then
    update-grub
elif command -v grub-mkconfig &> /dev/null; then
    grub-mkconfig -o /boot/grub/grub.cfg
elif command -v grub2-mkconfig &> /dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    error "Could not find 'update-grub' or 'grub-mkconfig'. Please update GRUB manually."
fi

info "${GREEN}Success!${NC} The '$THEME_NAME' GRUB theme has been installed."
info "Reboot your system to see the changes."

exit 0