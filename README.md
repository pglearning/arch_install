# Description
  - The idea of this script was to install a bit custom system for myself. and bit run automatic.
  - Try create a script like command list, clear my step, deciding what i need to install.

# How to use
  * Befor u run this script, pls 'vim install.sh' check the Configuration part, make sure u want to set up first user, and the username etc.
  
  ```bash
  vim install.sh        # Set up configuration. what packages u want to install as u like, etc.
  chmod +x ./arch_install/install.sh
  ./arch_install/install.sh
  ```
# LOG
  - fix wrong script language
  - add btrfs
  - add --noconfirm --needed
  - disk check
  - fix LINE 116 # TODO: What if /dev/sda[1-3] not exist
  - architecture check
  - fix passwd root ignore failure continue running
  - fix cant find program dir ./myconfig
  - add systemd-boot ext4 & btrfs support (has be uefi. replace grub)
  - spilt efi and boot partition (option) '/efi /boot /' or '/boot /'
  
  - split to single version i needed, origin script was a mess

# TODO
  - /@snapshot how the f*king install ? mount to /@? or /snapshot so backup file not include @snapshot and easy to archiso fixed ?
  - fix snapshot problem first, try Full Disk Encryption.
  - 
  - add BOOT + MBR support (Messy)
  - add install.conf && source install.conf (unknow issue for script include other, some value miss?)

# ISSUE
  - double system not support, no os-prober package and relevant content now. (double system may need check wiki and os-prober), I don't really need this (maybe try)