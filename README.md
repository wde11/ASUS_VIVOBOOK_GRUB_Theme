# ASUS_VIVOBOOK_GRUB_Theme Installation Guide

Hello this is a guide in installing Grub Theme onto your Grub bootloader.

(Be warned this repository is still work in progress, and so far there's nothing inside the theme.txt file)

Make sure you have git installed onto your device.

1. git clone https://github.com/wde11/ASUS_VIVOBOOK_GRUB_Theme.git

2. ``` chmod +x uninstall.sh ```
3. ``` sudo ./install.sh ```
4. You've successfully installed your Grub theme onto your bootloader!

If you want to configure the file, open your terminal ``` sudo nano /etc/default/grub ``` and locate #GRUB_THEME="/boot/grub/themes/theme_name/theme.txt".
