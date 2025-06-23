# Description
  - The idea of this script was to run automatic. 
  - But may need to input Enter confirm install packages, and input root password, if have first user (username="usera") need to input 'usera' password too.
  - double system not support, no os-prober package and relevant content now. (double system may need check wiki and os-prober)

# How to use
  * Befor u run this script, pls 'vim install.sh' check the Configuration part, make sure u want to set up first user, and the username etc.
  
  ```bash
  vim install.sh        # Set up configuration. what packages u want to install as u like, etc.
  chmod +x ./arch_install/install.sh
  ./arch_install/install.sh
  ```

  ```bash
  # Only support ext4 & btrfs. default=ext4
  filesystem="btrfs"   # If string is "other_string" then is ext4
  # Only support systemd-boot & grub. default=systemd-boot
  bootloader="grub"    # If string is "other_string" then is systemd-boot
  # Spilt EFI & BOOT partition (/efi /boot /).  true & false. default=false (/boot /)
  spilt_boot="true"    # If string is "other_string" then is false
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
  - spilt efi and boot partition (option) '/efi /boot /' or '/boot /'
  
  ```bash
  ## Test: archlinux-2025.05.01-x86_64.iso -- VWware 17.6.3 -- UEFI -- NO secure boot
  # [PASS] btrfs+grub+true
  # [PASS] btrfs+grub+false
  # [PASS] btrfs+systemd+true
  # [PASS] btrfs+systemd+false
  # [PASS] ext4+grub+true
  # [PASS] ext4+grub+false
  # [PASS] ext4+systemd+true
  # [PASS] ext4+systemd+false
  # It works anyway...
  ```

# TODO?
  - add BOOT + MBR support
  - add install.conf && source install.conf
  
# ISSUE
  