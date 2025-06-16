#!/bin/bash

# Configuration
username="usera"     # "" disable Create first user
shell="/bin/bash"
hostname="arch"
test_address="archlinux.org"
mirrors=(
    "Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
)
format_disk="/dev/sda"   # "" disable, Disk must formated befor disable
# format_disk=""
efi_size=1025
swap_size=4096
unit="MiB"

efi_partition="/dev/sda1"
swap_partition="/dev/sda2"
root_partition="/dev/sda3"
btrfs_label="Arch"
efi_label="EFI"
swap_label="Swap"
root_label="Root"
grub_label="GRUB"

packages=(
    "base"
    "base-devel"
    "linux"
    "linux-headers"
    "linux-firmware"
    "btrfs-progs"
    "grub"
    "efibootmgr"
    #"sudo"
    #"zsh"
    #"amd-ucode"
    #"intel-ucode"
    #"iwd"
    "dhcpcd"
    "neovim"
    #"curl"
    #"tar"
    #"gzip"
    "wqy-microhei"
    "fcitx5-im"
)
# -- Configuration


## Run script output all to file
# ./install.sh > output.log 2>&1
## Run script output all to terminal & file
# ./install.sh | tee output.log
## Run script output error to file
# ./install.sh 2> errors.log
## Run script output msg & error to file
# ./install.sh > output.log 2> errors.log

# Output Level
OK="[\e[32m OK \e[0m]"
INFO="[\e[36m INFO \e[0m]"
WARN="[\e[33m WARN \e[0m]"
ERROR="[\e[31m ERROR \e[0m]"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$ERROR Script has run by root!"
    exit 1
fi

# Main Install
default_install() {

    # Date & Time
    echo -e "$INFO Sync date & time..."
    timedatectl set-ntp true
    timedatectl set-timezone Asia/Shanghai
    
    # Network Test
    if ping -c 1 -W 1 $test_address; then echo -e "$OK ping success!"
    else
        echo -e "$ERROR ping loss or address invalid! (code: $result)"
        exit 2
    fi
    
    # Pacman Mirrorlist
    echo -e "$INFO mirrorlist overwrite..."
    echo "##" > /etc/pacman.d/mirrorlist
    echo "## Arch Linux custom mirrorlist" >> /etc/pacman.d/mirrorlist
    echo "## Generated on $(date '+%Y-%m-%d %H:%M:%S')" >> /etc/pacman.d/mirrorlist
    echo "##" >> /etc/pacman.d/mirrorlist
    echo "" >> /etc/pacman.d/mirrorlist
    printf "%s\n" "${mirrors[@]}" >> /etc/pacman.d/mirrorlist
    cat /etc/pacman.d/mirrorlist

    # Format Disk (gpt + uefi)
    if [ $format_disk != "" ]; then
        echo -e "$INFO Format disk..."
        ## Create GUID Partition Table(GPT)
        parted $format_disk mklabel gpt
        ## Create EFI system Partition
        parted $format_disk mkpart $efi_label fat32 0% "$efi_size$unit"
        parted $format_disk set 1 esp on
        ## Create Swap Partition
        parted $format_disk mkpart $swap_label linux-swap "$efi_size$unit" "$(($efi_size+$swap_size))$unit"
        ## Create Root Partition
        parted $format_disk mkpart $root_label ext4 "$(($efi_size+$swap_size))$unit" 100%
        parted $format_disk type 3 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
    fi
    # TODO: What if /dev/sda[1-3] not exist
    
    # Format Partition
    echo -e "$INFO Format partition..."
    sleep 1
    mkfs.fat -F32 $efi_partition
    mount --mkdir $efi_partition /mnt/boot
    mkswap $swap_partition
    swapon $swap_partition

    ## btrfs, live need package: btrfs-progs
    ## pacman -Sy archlinux-keyring
    # pacman -S btrfs-progs -y
    # mkfs.btrfs -fL $btrfs_label $root_partition
    # mount -t btrfs -o compress=zstd $root_partition /mnt
    # btrfs subvolume create /mnt/@
    # btrfs subvolume create /mnt/@home
    # btrfs check /dev/sda3; result=$?
    # if [ $result -eq 0 ]; then
    #     echo -e "$WARN btrfs error. (code: $result) try fixing..."
    #     btrfs check /dev/sda3 --repair; result=$?
    #     if [ $result -eq 0 ]; then
    #         echo -e "$ERROR btrfs error exit. (code: $result)"
    #         exit 3
    #     fi
    # fi
    # mount -t btrfs -o subvol=/@,compress=zstd $root_partition /mnt
    # mount --mkdir -t btrfs -o subvol=/@home,compress=zstd $root_partition /mnt/home

    ## ext4
    mkfs.ext4 $root_partition
    mount $root_partition /mnt

    # Generate fstab Partition Table
    mkdir /mnt/etc
    genfstab -U /mnt > /mnt/etc/fstab
    cat /mnt/etc/fstab

    # Install Base packages
    echo -e "$INFO Base packages install..."
    pacman -Sy archlinux-keyring
    pacstrap -K /mnt ${packages[@]} -y

    # Setup System 
    ## Timezone & Generate /etc/adjtime
    arch-chroot /mnt echo -e "$INFO Setting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    arch-chroot /mnt hwclock --systohc
    ## Language
    arch-chroot /mnt echo -e "$INFO Setting system language..."
    arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt locale-gen
    arch-chroot /mnt echo LANG=en_US.UTF-8 > /etc/locale.conf
    ## Hostname
    arch-chroot /mnt echo -e "$INFO Setting hostname..."
    arch-chroot /mnt echo $hostname > /etc/hostname
    ## Passwd root
    arch-chroot /mnt echo -e "$INFO Enter root password: "
    arch-chroot /mnt passwd root
    ## Group wheel execute any command
    arch-chroot /mnt echo -e "$INFO Setting sudoers..."
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    ## Gurb
    arch-chroot /mnt echo -e "$INFO Setting gurb..."
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=$grub_label
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

    # (opt)Custom Setting
    ## Enable pacman color
    arch-chroot /mnt echo -e "$INFO Enable pacman color..."
    arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf

    ## Create first user
    if [ $username != "" ]; then
        arch-chroot /mnt useradd -m -G wheel -s $shell $username
        arch-chroot /mnt echo -e "$INFO Enter $username password: "
        arch-chroot /mnt passwd $username
    fi

    echo -e "$OK Setup finsh!"
    # umount -R /mnt
    # reboot

}

# Running
default_install
