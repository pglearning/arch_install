#!/bin/bash

## double system not support. (may need check wiki and os-prober)

# source install.conf

# Configuration
# "" disable Create first user
username="usera"
usershell="/bin/bash"

timezone="Asia/Shanghai"
hostname="arch"
test_address="baidu.com"
mirrors=(
    "Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
)
archmirrors_country="CN"

# Only support ext4 and btrfs, default=ext4
filesystem="btrfs"

# "" disable, Disk must formated befor disable
format_disk="/dev/sda"
efi_size=1025
swap_size=4096
unit="MiB"

efi_partition="$format_disk""1"
swap_partition="$format_disk""2"
root_partition="$format_disk""3"

efi_label="EFI"
swap_label="SWAP"
btrfs_label="btrfs"

root_label="root"
grub_label="GRUB"

packages=(
    "base"
    "base-devel"
    "linux"
    "linux-headers"
    "linux-firmware"
    "grub"
    "efibootmgr"
    #"amd-ucode"     #"intel-ucode"
    "iwd"            #"networkmanager"
    "dhcpcd"
    "usbmuxd"       # 通过usb连接手机共享网络
    "man"
    "less"
    "bc"
    "vi"
    "neovim"        #"gvim"
    "adobe-source-han-serif-cn-fonts"
    "bluez"         # 蓝牙
    #"curl"
    #"tar"
    #"gzip"
    #"git"
    #"sudo"
    #"zsh"
)
if [ $filesystem == "btrfs" ]; then packages+=("btrfs-progs"); fi
# -- Configuration

# Output Level
OK="[\e[32m OK \e[0m]"
INPUT="[\e[34m INPUT \e[0m]"
INFO="[\e[36m INFO \e[0m]"
WARN="[\e[33m WARN \e[0m]"
ERROR="[\e[31m ERROR \e[0m]"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\n$ERROR Script has run by root!"
    exit 1
fi
# Check architecture, only support 64bit
if [ $(cat /sys/firmware/efi/fw_platform_size) != "64" ]; then
    echo -e "$ERROR Auto install only support x64 architecture."
    exit 2
fi
# Check disk exist
if ! fdisk -l | grep "$format_disk"; then
    echo -e "$ERROR Disk $format_disk not exist."
    exit 3
fi
# Tip
printf "$INPUT Continue will wipe all data from disk ${format_disk}. Are you sure? [Y/n] "
read -re WIPE_DISK
WIPE_DISK=${WIPE_DISK:-y}
if [ "$WIPE_DISK" == "n" -o "$WIPE_DISK" == "N" ]; then exit 4; fi

# Main Install
default_install() {

    # Network Test
    if ping -c 1 -W 1 "$test_address"; then
        echo -e "$OK ping success!"
    else
        echo -e "$ERROR ping loss or address invalid! (code: $?)"
        exit 11
    fi
    
    # Date & Time
    echo -e "$INFO Sync date & time..."
    timedatectl set-ntp true
    timedatectl set-timezone $timezone
    
    # reflector will add some shit mirrors in the file
    systemctl stop reflector.service
    if [ -n "$mirrors" ]; then
        # Custom Pacman Mirrorlist
        echo -e "$INFO mirrorlist overwrite..."
        echo "##" > /etc/pacman.d/mirrorlist
        echo "## Arch Linux mirrorlist" >> /etc/pacman.d/mirrorlist
        echo "## Generated on $(date '+%Y-%m-%d %H:%M:%S')" >> /etc/pacman.d/mirrorlist
        echo "##" >> /etc/pacman.d/mirrorlist
        echo "" >> /etc/pacman.d/mirrorlist
        printf "%s\n" "${mirrors[@]}" >> /etc/pacman.d/mirrorlist
        cat /etc/pacman.d/mirrorlist
    else
        # Arch mirrors download (PS: pacman will auto use random mirror, download speed may slow down.)
        curl -L "https://archlinux.org/mirrorlist/?country=${archmirrors_country}&protocol=https" -o /etc/pacman.d/mirrorlist
        sed -i 's/#Server/Server/' /etc/pacman.d/mirrorlist
    fi

    # Keyring update (live pacman download issue)
    pacman -Sy archlinux-keyring --noconfirm
    pacman -Sy --noconfirm

    # Format Disk (gpt + uefi)
    if [ "$format_disk" != "" ]; then
        echo -e "$INFO Format disk ${format_disk}."
        ## Create GUID Partition Table(GPT), will wipe all data from disk
        # echo $WIPE_DISK | parted $format_disk mklabel gpt     # (Danger) use first confirm auto format disk
        parted $format_disk mklabel gpt
        ## Create EFI system Partition
        parted $format_disk mkpart $efi_label fat32 0% "$efi_size$unit"
        parted $format_disk set 1 esp on
        ## Create Swap Partition
        parted $format_disk mkpart $swap_label linux-swap "$efi_size$unit" "$(($efi_size+$swap_size))$unit"
        ## Create Root Partition
        if [ "$filesystem" == "btrfs" ]; then
            parted $format_disk mkpart $root_label btrfs "$(($efi_size+$swap_size))$unit" 100%
        else
            parted $format_disk mkpart $root_label ext4 "$(($efi_size+$swap_size))$unit" 100%
        fi
        parted $format_disk type 3 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
    fi
    
    # Format Partition
    echo -e "$INFO Format partition..."
    sleep 1
    mkfs.fat -F32 $efi_partition
    mkswap $swap_partition
    swapon $swap_partition
    # compress= "zstd": forcing compression; "lzo" fast raw compression; autodefrag
    if [ "$filesystem" == "btrfs" ]; then
        ## btrfs, live need package: btrfs-progs
        # pacman -S btrfs-progs --noconfirm --needed
        mkfs.btrfs -fL $btrfs_label $root_partition
        mount --mkdir -t btrfs -o compress=lzo,autodefrag $root_partition /mnt
        btrfs subvolume create /mnt/@
        btrfs subvolume create /mnt/@home
        umount /mnt
        btrfs check $root_partition; result=$?
        if [ "$result" -eq 0 ]; then
            echo -e "$WARN btrfs error. (code: $result) try fixing..."
            btrfs check $root_partition --repair; result=$?
            if [ "$result" -eq 0 ]; then
                echo -e "$ERROR btrfs error exit. (code: $result)"
                exit 12
            fi
        fi
        mount -t btrfs -o subvol=/@,compress=lzo,autodefrag $root_partition /mnt
        mount --mkdir -t btrfs -o subvol=/@home,compress=lzo,autodefrag $root_partition /mnt/home
    else
        # ext4 format
        mkfs.ext4 $root_partition
        mount --mkdir $root_partition /mnt
    fi
    # Mount to live
    mount --mkdir $efi_partition /mnt/boot

    # Generate fstab Partition Table
    mkdir /mnt/etc
    genfstab -U /mnt > /mnt/etc/fstab
    cat /mnt/etc/fstab

    # Install Base packages
    echo -e "$INFO Base packages install..."
    pacstrap -K /mnt ${packages[@]} --noconfirm --needed

    # Setup System 
    ## NOTE: "arch-chroot /mnt echo string > file" not working
    ## NOTE: "arch-chroot /mnt <<EOF" or "<<-EOF" output all line, cant use if []; then
    ## Timezone & Generate /etc/adjtime
    arch-chroot /mnt echo -e "$INFO Setting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
    arch-chroot /mnt hwclock --systohc
    ## Language
    arch-chroot /mnt echo -e "$INFO Setting system language..."
    arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt locale-gen
    arch-chroot /mnt sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"   # may not working
    ## Hostname
    arch-chroot /mnt echo -e "$INFO Setting hostname..."
    arch-chroot /mnt sh -c "echo $hostname > /etc/hostname"   # may not working
    ## Passwd root
    while true; do
        arch-chroot /mnt echo -e "$INPUT Enter root password: "
        if arch-chroot /mnt passwd root; then break; fi
    done
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
    if [ "$username" != "" ]; then
        arch-chroot /mnt useradd -m -G wheel -s $usershell $username
        while true; do
            arch-chroot /mnt echo -e "$INPUT Enter $username password: "
            if arch-chroot /mnt passwd $username; then break; fi
        done
    fi

    # Custom command
    if [ -d "/mnt/home/$username" ]; then
        # Has be same dir with this script
        if [[ -n "$0" && "$0" != "-bash" ]]; then   # /dir/filename
            script_path=$(realpath "$0")
        else
            script_path=$(realpath "${BASH_SOURCE[0]}")
        fi
        if [[ "$script_path" == */* ]]; then        # /dir
            script_path="${script_path%/*}"
        fi
        cp -r $script_path/myconfig /mnt/home/$username/
    fi

    echo -e "$OK Setup finsh!"

    # Reboot now
    printf "$INPUT Reboot now? [Y/n] "
    read -re reboot_now
    reboot_now=${reboot_now:-y}
    if [ "$reboot_now" == "y" -o "$reboot_now" == "Y" ]; then
        umount -R /mnt
        reboot
    fi

}

# Running
default_install
