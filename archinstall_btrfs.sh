#!/bin/bash
## Test: archlinux-2025.05.01-x86_64.iso -- VWware 17.6.3 -- UEFI -- NO secure boot

# Configuration
# "" disable Create first user
username="usera"
usershell="/bin/bash"

timezone="Asia/Shanghai"
hostname="archlinux"
test_address="baidu.com"
mirrors=(
    "Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
)
archmirrors_country="CN"

# uefi_gpt_btrfs_grub_install
format_disk="/dev/sda"
efi_size=301
swap_size=16384
unit="MiB"

efi_label="efi"
swap_label="SWAP"
btrfs_label="btrfs"
root_label="arch_os"

filesystem="btrfs"
bootloader="grub"
packages=(
    "base"
    "base-devel"
    "linux"
    "linux-headers"
    "linux-firmware"
    "networkmanager"
    # "iwd"                 #"networkmanager" replace this
    # "dhcpcd"              #"networkmanager" replace this
    # "usbmuxd"             # 通过usb连接手机共享网络，networkmanager对iphone的usb上网不支持时才需要安装这个包
    "man"
    "man-pages"
    "less"
    # "bc"
    # "nano"                # "vi"
    "neovim"                #"gvim"
    "ttf-meslo-nerd"
    "adobe-source-han-serif-cn-fonts"
    "bluez"                 # 蓝牙
    "curl"
    "git"
    "tar"
    "gzip"
    # !!! only for vmware virtual machines
    # "mesa"
    # "xf86-video-vmware"
    # "open-vm-tools"
)
if [ $bootloader == "grub" ]; then packages+=( "grub" "efibootmgr" ); fi
if [ $filesystem == "btrfs" ]; then packages+=( "btrfs-progs" ); fi
if grep -q "GenuineIntel" /proc/cpuinfo; then
    packages+=("intel-ucode")
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    packages+=("amd-ucode")
fi

# Log File
LOGFILE="/root/arch_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOGFILE") 2>&1

# process
# '/dev/nvme0n1p1'  p1 not 1
i1="1"
i2="2"
i3="3"
if echo $format_disk | grep "nvme"; then
    i1="p1"; i2="p2"; i3="p3"
fi
efi_partition="$format_disk$i1"
swap_partition="$format_disk$i2"
root_partition="$format_disk$i3"
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
fdisk -l

printf "$INPUT Continue will wipe all data from disk [ ${format_disk} ]. Are you sure? [Y/n] "
read -re WIPE_DISK
WIPE_DISK=${WIPE_DISK:-y}
if [ "$WIPE_DISK" == "n" -o "$WIPE_DISK" == "N" ]; then exit 4; fi


# EFI system Partition mount /boot/efi, /boot is subvol
uefi_gpt_btrfs_grub_install() {
    # Network Testmax_retries=3
    for i in $(seq 1 $max_retries); do
        if ping -c 1 -W 2 "$test_address" >/dev/null 2>&1; then
            echo -e "$OK Network connection successful"
            break
        elif [ $i -eq $max_retries ]; then
            echo -e "$ERROR Network connection failed after $max_retries attempts"
            exit 11
        else
            echo -e "$WARN Network connection failed, retrying in 3s... ($i/$max_retries)"
            sleep 3
        fi
    done

    # Date & Time
    timedatectl set-ntp true
    timedatectl set-timezone $timezone
    echo -e "$OK Sync date & time."

    # Mirrorlist
    systemctl stop reflector.service    # reflector will add some shit mirrors in the file
    if [ -n "$mirrors" ]; then
        # Custom Pacman Mirrorlist
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
    echo -e "$OK mirrorlist overwrite."
    
    # Format Disk (gpt + uefi)
    efi_end=$efi_size
    swap_end=$((efi_size + swap_size))
    parted $format_disk mklabel gpt
    parted $format_disk mkpart $efi_label fat32 0% ${efi_end}${unit}
    parted $format_disk set 1 esp on
    parted $format_disk mkpart $swap_label linux-swap ${efi_end}${unit} ${swap_end}${unit}
    parted $format_disk mkpart $root_label btrfs ${swap_end}${unit} 100%
    parted $format_disk type 3 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
    echo -e "$OK Format disk ${format_disk} finsh."
    # create btrfs subvolume
    mkfs.btrfs -fL $btrfs_label $root_partition
    mount --mkdir -t btrfs -o compress=zstd $root_partition /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    btrfs property set /mnt/@snapshots ro true
    umount /mnt
    mount -t btrfs -o subvol=/@,compress=zstd $root_partition /mnt
    mount --mkdir -t btrfs -o subvol=/@home,compress=zstd $root_partition /mnt/home
    mount --mkdir -t btrfs -o subvol=/@snapshots,compress=zstd $root_partition /mnt/.snapshots
    # efi mount to /boot/efi
    mkfs.fat -F32 $efi_partition
    mount --mkdir $efi_partition /mnt/boot/efi
    # swap
    mkswap $swap_partition
    swapon $swap_partition
    echo -e "$OK Format partition finsh."
    # Generate fstab Partition Table
    mkdir /mnt/etc
    genfstab -U /mnt > /mnt/etc/fstab
    echo -e "$OK Generate fstab Partition Table."
    
    # Keyring update (live pacman download issue)
    pacman -Syy archlinux-keyring --noconfirm
    # Install Base packages, core 'linux' and 'base' etc.
    pacstrap -K /mnt ${packages[@]} --noconfirm --needed
    echo -e "$OK Basic packages install."

    # Setup System
    ## btrfs hooks fix
    arch-chroot /mnt bash -c "echo 'MODULES=(btrfs)' >> /etc/mkinitcpio.conf"
    arch-chroot /mnt sed -i 's/^HOOKS=.*/HOOKS=(base systemd autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/' /etc/mkinitcpio.conf
    ### for encrypt
    #arch-chroot /mnt sed -i 's/^HOOKS=.*/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt btrfs filesystems fsck)/' /etc/mkinitcpio.conf
    arch-chroot /mnt mkinitcpio -P
    echo -e "$OK mkinitcpio configured for Btrfs"

    ## Enable NetworkManager
    arch-chroot /mnt systemctl enable NetworkManager
    echo -e "$OK Enable NetworkManager"
    ## Enable bluez
    arch-chroot /mnt systemctl enable bluetooth

    ## Timezone & Generate /etc/adjtime
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
    arch-chroot /mnt hwclock --systohc
    echo -e "$OK Setup timezone."
    # Force update core and database
    arch-chroot /mnt pacman -Syy
    ## Language
    arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#zh_TW.UTF-8 UTF-8/zh_TW.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt locale-gen
    arch-chroot /mnt sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
    echo -e "$OK Setup system language."
    ## Hostname
    arch-chroot /mnt sh -c "echo $hostname > /etc/hostname"
    echo -e "$OK Setup hostname."
    ## Passwd root
    while true; do
        arch-chroot /mnt echo -e "$INPUT Enter root password: "
        if arch-chroot /mnt passwd root; then
            echo -e "$OK Setup root password."
            break
        fi
    done
    ## Create first user
    if [ "$username" != "" ]; then
        arch-chroot /mnt useradd -m -G wheel -s $usershell $username
        echo -e "$OK Setup $username (group wheel)."
        while true; do
            arch-chroot /mnt echo -e "$INPUT Enter $username password: "
            if arch-chroot /mnt passwd $username; then
                echo -e "$OK Setup $username password."
                break
            fi
        done
    fi
    ## Grub
    #arch-chroot /mnt grub-install  # Auto?
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "$OK Setup grub."

    ## Group wheel execute any command
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    echo -e "$OK Setup group wheel sudoers."
    ## Enable pacman color
    arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf
    echo -e "$OK Enable pacman color."

    # !!! only for vmware virtual machines
    # arch-chroot /mnt systemctl enable vmtoolsd
    # arch-chroot /mnt systemctl enable vmware-vmblock-fuse

    # script_path
    if [[ -n "$0" && "$0" != "-bash" ]]; then   # /dir/filename
        script_path=$(realpath "$0")
    else
        script_path=$(realpath "${BASH_SOURCE[0]}")
    fi
    if [[ "$script_path" == */* ]]; then        # /dir
        script_path="${script_path%/*}"
    fi
    # myconfig
    if [[ -d "$script_path/myconfig" && -d "/mnt/home/$username/" ]]; then
        cp -r $script_path/myconfig /mnt/home/$username/
        arch-chroot /mnt chown -R $username:$username "/home/$username/myconfig"
    fi
    echo -e "$OK All setup finsh!"

    ## debug
    cat /mnt/etc/fstab
    blkid
    ls -FA /mnt/boot
    ls -FA /mnt/boot/efi

    # Reboot now
    printf "$INPUT Reboot now? [Y/n] "
    read -re reboot_now
    reboot_now=${reboot_now:-y}
    if [ "$reboot_now" == "y" -o "$reboot_now" == "Y" ]; then
        umount -R /mnt
        reboot
    fi
}

start_time=$(date +%s)
uefi_gpt_btrfs_grub_install
end_time=$(date +%s)
echo -e "$INFO Installation completed in $((end_time - start_time)) seconds"