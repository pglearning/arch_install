# Description
  - The idea of this script was to run automatic. 
  - But may need to input Enter confirm install packages, and input root password, if have first user (username="usera") need to input 'usera' password too.

# How to use
  * Befor u run this script, pls 'vim install.sh' check the Configuration part, make sure u want to set up first user, and the usernamme etc.
  
  ```bash
  vim install.sh        # Set up configuration. what packages u want to install as u like, etc.
  chmod +x install.sh
  ./install.sh
  ```

# Update
  - add btrfs
  - fix script language wrong
  
# TODO?
  - disk check
  - architecture check
  - add systemd-boot (has be uefi. replace grub)
  - BOOT + MBR support
  - add install.conf && source install.conf
  
# ISSUE
  - LINE 116 # TODO: What if /dev/sda[1-3] not exist
  