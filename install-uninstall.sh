#!/bin/bash

# ==============================================================================
# ASUS Vivobook GRUB Theme Installer
#
# This script automates the installation of the GRUB theme from:
# https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme
#
# The script will:
# 1. Check for root privileges.
# 2. Clone the theme repository from GitHub.
# 3. Create the necessary theme directory in /boot/grub/themes.
# 4. Copy the theme files to the system directory.
# 5. Configure the /etc/default/grub file to use the new theme.
# 6. Update the GRUB configuration to apply the changes.
# ==============================================================================

# --- Configuration ---
# The URL of the Git repository for the theme.
readonly REPO_URL="https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme.git"
# The name of the repository directory after cloning.
readonly REPO_NAME="ASUS_VIVOBOOK_GRUB_Theme"
# The target directory where GRUB themes are stored.
readonly THEME_TARGET_DIR="/boot/grub/themes/$REPO_NAME"
# The path to the GRUB configuration file.
readonly GRUB_CONFIG_FILE="/etc/default/grub"
# The path to the theme's main file.
readonly THEME_FILE_PATH="$THEME_TARGET_DIR/theme.txt"


# --- Functions ---

#
# Shows an error message and exits the script.
#
# @param $1 - The error message to display.
#
function error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

#
# Checks if the script is being run with root privileges.
#
function check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        error_exit "This script must be run as root. Please use sudo."
    fi
    echo "Root privileges check passed."
}

#
# Clones the theme repository from GitHub.
#
function clone_repo() {
    echo "Cloning theme repository from GitHub..."
    if [ -d "$REPO_NAME" ]; then
        echo "Repository directory already exists. Skipping clone."
    else
        git clone "$REPO_URL" || error_exit "Failed to clone the repository."
    fi
}

#
# Installs the theme files to the system directory.
#
function install_theme() {
    echo "Installing theme to $THEME_TARGET_DIR..."
    mkdir -p "$THEME_TARGET_DIR" || error_exit "Failed to create theme directory."
    cp -r "${REPO_NAME}/"* "$THEME_TARGET_DIR/" || error_exit "Failed to copy theme files."
    echo "Theme files installed."
}

#
# Configures the GRUB settings to apply the new theme.
#
function configure_grub() {
    echo "Configuring GRUB settings in $GRUB_CONFIG_FILE..."
    # Check if the GRUB_THEME line exists and update it, or add it if it doesn't.
    if grep -q "^GRUB_THEME=" "$GRUB_CONFIG_FILE"; then
        sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"$THEME_FILE_PATH\"|" "$GRUB_CONFIG_FILE"
    else
        echo "GRUB_THEME=\"$THEME_FILE_PATH\"" >> "$GRUB_CONFIG_FILE"
    fi
    echo "GRUB configuration file updated."
}

#
# Updates the GRUB bootloader to apply all changes.
#
function update_grub_config() {
    echo "Updating GRUB bootloader..."
    # Use the appropriate command based on the Linux distribution.
    if command -v update-grub &> /dev/null; then
        update-grub || error_exit "Failed to run update-grub."
    elif command -v grub-mkconfig &> /dev/null; then
        grub-mkconfig -o /boot/grub/grub.cfg || error_exit "Failed to run grub-mkconfig."
    else
        error_exit "Could not find 'update-grub' or 'grub-mkconfig'. Please update GRUB manually."
    fi
    echo "GRUB bootloader updated successfully."
}

#
# Cleans up the cloned repository directory.
#
function cleanup() {
    echo "Cleaning up cloned repository..."
    rm -rf "$REPO_NAME"
    echo "Cleanup complete."
}


# --- Main Execution ---

main() {
    check_root
    clone_repo
    install_theme
    configure_grub
    update_grub_config
    cleanup

    echo ""
    echo "-----------------------------------------------------"
    echo " ASUS Vivobook GRUB theme installed successfully!"
    echo " Please reboot your system to see the changes."
    echo "-----------------------------------------------------"
}

# Execute the main function
main
