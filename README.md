# ASUS_VIVOBOOK_GRUB_Theme Installation Guide

Hello this is a guide in installing Grub Theme onto your Grub bootloader.

(Be warned this repository is still work in progress, and so far there's nothing inside the theme.txt file)

Make sure you have git installed onto your device.

### Prerequsiites 

* install git
```sh sudo apt-get install git-all ```



1. ```sh 
git clone https://github.com/wde11 ASUS_VIVOBOOK_GRUB_Theme.git ```
2. ```sh 
chmod +x install.sh ```
3. ```
sh sudo ./install.sh ```
4. ```
sh You've successfully installed your Grub theme onto your bootloader! ```

If you want to configure the file, open your terminal ``` sudo nano /etc/default/grub ``` and locate ``` #GRUB_THEME="/boot/grub/themes/theme_name/theme.txt" ```
