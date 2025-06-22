# Description
  - The idea of this script was to run automatic. 
  - But may need to input Enter confirm install packages, and input root password, if have first user (username="usera") need to input 'usera' password too.
  - double system not support. (double system may need check wiki and os-prober)

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
  - fix passwd root set ignore failure continue running
  - fix cant find program dir ./myconfig
  - add systemd-boot ext4 & btrfs support (has be uefi. replace grub)

# TODO?
  - add BOOT + MBR support
  - add install.conf && source install.conf
  
# ISSUE
  