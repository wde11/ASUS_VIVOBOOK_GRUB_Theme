# ASUS_VIVOBOOK_GRUB_Theme Installation Guide

Hello this is a guide in installing Grub Theme onto your Grub bootloader.

(Be warned this repository is still work in progress, and so far there's nothing inside the theme.txt file)

### Prerequisites

* Install Git:
    ```sh
    sudo apt-get install git-all
    ```

### Installation

1.  Clone this repository to your local machine:
    ```sh
    git clone [https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme.git](https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme.git)
    ```

2.  Navigate into the cloned directory:
    ```sh
    cd ASUS_VIVOBOOK_GRUB_Theme
    ```

3.  Make the installation script executable:
    ```sh
    chmod +x install.sh
    ```

4.  Run the installation script with `sudo`:
    ```sh
    sudo ./install.sh
    ```

You've successfully installed your Grub theme onto your bootloader! Reboot your system to see the changes.

If you want to configure the file, open your terminal ```sh sudo nano /etc/default/grub ``` and locate ``` #GRUB_THEME="/boot/grub/themes/theme_name/theme.txt" ```
