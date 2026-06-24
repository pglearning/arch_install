#!/bin/bash

# Configuration
HOSTNAME="arch"
TIMEZONE="Asia/Shanghai"
DEFAULT_LOCALE="en_US.UTF-8"
LOCALE_1="zh_CN.UTF-8"
LOCALE_2="zh_TW.UTF-8"
# "" disable Create first user
USERNAME="usera"
USERSHELL="/bin/bash"
NET_TEST_ADDRESS="baidu.com"
# NET_TEST_ADDRESS="ping.archlinux.org"
NET_TEST_MAX_ROUND=3

# Rescue System
# archlinux-2026.06.01-x86_64.iso
ISO_DOWNLOAD_URL="https://mirrors.ustc.edu.cn/archlinux/iso/2026.06.01/archlinux-2026.06.01-x86_64.iso"
ISO_FILENAME="archlinux-2026.06.01-x86_64.iso"

MIRRORS=(
    "Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
)
MIRRORS_COUNTRY="CN"

# Grub system option name
GRUB_OPT_NAME="ArchLinux"
GRUB_OPT_RESCUE_NAME="Arch Linux Rescue (ISO Loopback)"

# uefi_gpt_ext4_grub_install
DISK="/dev/nvme0n1"
UNIT="MiB"
EFI_SIZE=512
ROOT_SIZE=100000
# "yes" option create /backup/ at single partition, else /backup/ with root path.
CREATE_PARTITION_FOR_BACKUP="no"
# only CREATE_PARTITION_FOR_BACKUP=yes enable BACKUP_SIZE
BACKUP_SIZE=100000

BOOTLOADER="grub"
FILESYSTEM="ext4"
EFI_LABEL="ESP"
ROOT_LABEL="root"
BACKUP_LABEL="backup"
HOME_LABEL="home"

RESCUE_DIR="/rescue"
SNAPSHOT_BASE="/backup/snapshots"
EXCLUDE="/backup/exclude.list"
SNAPSHOT_BACKUP="/usr/local/bin/snapshot-backup.sh"
SNAPSHOT_RESTORE="/usr/local/bin/restore-snapshot.sh"

SWAP_FILE="/swapfile"
# 16G RAM, need 16G swap for "sudo systemctl hibernate", if not used this func, default 4G should enough.
SWAP_SIZE="4G"

packages=(
    "base"
    "base-devel"
    "linux"
    "linux-headers"
    "linux-firmware"
    "man"
    "man-pages"
    "less"
    "bc"                    # for cpu float math
    # "sudo"                  # arch install by default
    "fastfetch"             # System Info
    "bash-completion"       # git 等子命令bash补全功能包

    "ufw"                   # firewall
    "networkmanager"
    # "iwd"                 #"networkmanager" replace this
    # "dhcpcd"              #"networkmanager" replace this
    # "usbmuxd"             # 通过usb连接手机共享网络，networkmanager对iphone的usb上网不支持时才需要安装这个包
    "bluez"                 # 蓝牙

    "usbutils"              # command 'lsusb' for check usb devices
    "pciutils"              # command 'lspci' for check pci devices
    "smartmontools"         # command 'smartctl' for check disk health
    "strace"                # command 'strace' for trace process
    "lsof"                  # command 'lsof' for trace file/fd occupied by what
    # "dosfstools"            # FAT support, for USB flash drive
    # "ntfs-3g"               # NTFS support, for portable hard drive

    "fontconfig"            # 'fc-match', etc.
    # "ttf-meslo-nerd"
    # "adobe-source-han-serif-cn-fonts"
    # "adobe-source-han-sans-cn-fonts"
    # "nano"                # "vi"
    "neovim"                # "gvim"
    "tmux"
    "curl"
    "git"
    # tar -z (gzip), -j (bzip2), -J (xz)
    "tar"                   # ".tar" ".tar.gz" ".tar.bz2" ".tar.xz", ".tar" default only package the project no zip func, 'tar' command
    "gzip"                  # ".gz" file, for 'tar' support, zip the project, 'gzip', 'gunzip', 'zcat' command
    "zip"                   # ".zip" file, 'zip' and 'unzip' command
    "bzip2"                 # ".bz2" file, 'bzip2', 'bunzip2' command
    "xz"                    # ".xz" file, 'xz', 'unxz' command
    "rsync"                 # for ext4 snapshot backup system
    "openssh"               # remote link
    "fd"                    # modern search tool, replace 'grep/find' (neovim telescope plugin depend)
    "bat"                   # syntax highlight version 'cat'
    "btop"                  # replace 'top'
    # "xdg-utils"             # 'xdg-open' terminal file/url link open support

    # Audio
    "pipewire"
    "pipewire-pulse"
    "wireplumber"

    # !!! only for vmware virtual machines
    # "mesa"
    # "xf86-video-vmware"
    # "open-vm-tools"
)

if [ $BOOTLOADER == "grub" ]; then packages+=( "grub" "efibootmgr" ); fi
if [ $FILESYSTEM == "btrfs" ]; then packages+=( "btrfs-progs" ); fi

if grep -q "GenuineIntel" /proc/cpuinfo; then
    packages+=("intel-ucode")
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    packages+=("amd-ucode")
fi

# Log File
LOGFILE="arch_install_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "/root/${LOGFILE}") 2>&1

# Output Level
OK="[\e[32m OK \e[0m]"
INPUT="[\e[34m INPUT \e[0m]"
INFO="[\e[36m INFO \e[0m]"
WARN="[\e[33m WARN \e[0m]"
ERROR="[\e[31m ERROR \e[0m]"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "\n$ERROR Script has run by root! (at 'sudo' or 'archiso')"
    exit 1
fi

# Check architecture, only support 64bit
if [ $(cat /sys/firmware/efi/fw_platform_size) != "64" ]; then
    echo -e "$ERROR Auto install only support x64 architecture."
    exit 1
fi

# Network Test NET_TEST_MAX_ROUND=3
for i in $(seq 1 $NET_TEST_MAX_ROUND); do
    if ping -c 1 -W 2 "$NET_TEST_ADDRESS" >/dev/null 2>&1; then
        echo -e "$OK Network connection successful"
        break
    elif [ $i -eq $NET_TEST_MAX_ROUND ]; then
        echo -e "$ERROR Network connection failed after $NET_TEST_MAX_ROUND attempts. (try setup 'iwctl' or 'dhcpcd')"
        exit 1
    else
        echo -e "$WARN Network connection failed, retrying in 3s... ($i/$NET_TEST_MAX_ROUND)"
        sleep 3
    fi
done

# Check disk exist
if [[ ! -b "$DISK" ]]; then
    echo -e "$ERROR Disk $DISK not exist. Available disks:"
    lsblk -dno NAME,MODEL,SIZE | grep -E "nvme|sd"
    exit 1
fi

printf "$INPUT Continue will wipe all data from disk [ ${DISK} ]. Are you sure? (y/N): "
read -re WIPE_DISK
WIPE_DISK=${WIPE_DISK:-n}
if [ "$WIPE_DISK" == "n" -o "$WIPE_DISK" == "N" ]; then exit 0; fi

uefi_gpt_ext4_grub_install() {
    # Date & Time
    timedatectl set-ntp true
    timedatectl set-timezone $TIMEZONE
    echo -e "$OK Sync date & time."

    # Mirrorlist
    systemctl stop reflector.service    # reflector will add some shit mirrors in the file
    if [ -n "$MIRRORS" ]; then
        # Custom Pacman Mirrorlist
        echo "##" > /etc/pacman.d/mirrorlist
        echo "## Arch Linux mirrorlist" >> /etc/pacman.d/mirrorlist
        echo "## Generated on $(date '+%Y-%m-%d %H:%M:%S')" >> /etc/pacman.d/mirrorlist
        echo "##" >> /etc/pacman.d/mirrorlist
        echo "" >> /etc/pacman.d/mirrorlist
        printf "%s\n" "${MIRRORS[@]}" >> /etc/pacman.d/mirrorlist
        cat /etc/pacman.d/mirrorlist
    else
        # Arch mirrors download (PS: pacman will auto use random mirror, download speed may slow down.)
        curl -L "https://archlinux.org/mirrorlist/?country=${MIRRORS_COUNTRY}&protocol=https" -o /etc/pacman.d/mirrorlist
        sed -i 's/#Server/Server/' /etc/pacman.d/mirrorlist
    fi
    echo -e "$OK mirrorlist overwrite."

    # Format Disk (gpt + uefi)
    parted $DISK mklabel gpt
    parted -s "$DISK" mkpart "$EFI_LABEL" fat32 0% "${EFI_SIZE}${UNIT}"
    parted "$DISK" set 1 esp on
    parted -s "$DISK" mkpart "$ROOT_LABEL" "$FILESYSTEM" "${EFI_SIZE}${UNIT}" "$((EFI_SIZE + ROOT_SIZE))${UNIT}"
    if [ $CREATE_PARTITION_FOR_BACKUP -eq "yes" ]; then
        parted -s "$DISK" mkpart "$BACKUP_LABEL" "$FILESYSTEM" "$((EFI_SIZE + ROOT_SIZE))${UNIT}" "$((EFI_SIZE + ROOT_SIZE + BACKUP_SIZE))${UNIT}"
        parted -s "$DISK" mkpart "$HOME_LABEL" "$FILESYSTEM" "$((EFI_SIZE + ROOT_SIZE + BACKUP_SIZE))${UNIT}" 100%
    else
        parted -s "$DISK" mkpart "$HOME_LABEL" "$FILESYSTEM" "$((EFI_SIZE + ROOT_SIZE))${UNIT}" 100%
    fi

    # Partitions Name
    # '/dev/nvme0n1p1'  p1 not 1
    if [[ "$DISK" == *nvme* ]]; then
        EFI="${DISK}p1"; ROOT="${DISK}p2";
        if [ $CREATE_PARTITION_FOR_BACKUP -eq "yes" ]; then
            BACKUP="${DISK}p3"; HOME="${DISK}p4"
        else
            HOME="${DISK}p3"
        fi
    else
        EFI="${DISK}1";  ROOT="${DISK}2"
        if [ $CREATE_PARTITION_FOR_BACKUP -eq "yes" ]; then
            BACKUP="${DISK}3"; HOME="${DISK}4"
        else
            HOME="${DISK}3"
        fi
    fi

    # Format Partitions
    mkfs.fat -F32 "$EFI"
    mkfs.ext4 -F "$ROOT"
    if [ $CREATE_PARTITION_FOR_BACKUP -eq "yes" ]; then
        mkfs.ext4 -F "$BACKUP"
    fi
    mkfs.ext4 -F "$HOME"
    # Mount To Root
    mount "$ROOT" /mnt
    mkdir -p /mnt/{boot/efi,home,backup}
    mount "$EFI" /mnt/boot/efi
    mount "$HOME" /mnt/home
    if [ $CREATE_PARTITION_FOR_BACKUP -eq "yes" ]; then
        mount "$BACKUP" /mnt/backup
    else
        mkdir /mnt/backup
    fi

    # Setup Swapfile
    fallocate -l "$SWAP_SIZE" /mnt"$SWAP_FILE"
    chmod 600 /mnt"$SWAP_FILE"
    mkswap /mnt"$SWAP_FILE"
    swapon /mnt"$SWAP_FILE"
    echo -e "$OK Swapfile created and enabled (${SWAP_SIZE})"

    # Keyring update (live pacman download issue)
    pacman -Syy archlinux-keyring --noconfirm
    # Install Base packages, core 'linux' and 'base' etc.
    pacstrap -K /mnt ${packages[@]} --noconfirm --needed
    echo -e "$OK Basic packages install."


    # Generate fstab Partition Table
    mkdir -p /mnt/etc
    genfstab -U /mnt >> /mnt/etc/fstab
    echo -e "$OK Generate fstab Partition Table."

    # Grub
    # arch-chroot /mnt grub-install  # Auto?
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="${GRUB_OPT_NAME}"
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "$OK Setup grub."

    ################################################################################
    # Setup System
    ################################################################################
    ## Enable NetworkManager
    arch-chroot /mnt systemctl enable NetworkManager
    echo -e "$OK Enable NetworkManager"
    ## Enable bluez
    # arch-chroot /mnt systemctl enable bluetooth
    # echo -e "$OK Enable bluetooth"

    ## Timezone & Generate /etc/adjtime
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    arch-chroot /mnt hwclock --systohc
    echo -e "$OK Setup timezone."
    
    ## Language
    arch-chroot /mnt sed -i "s/#${DEFAULT_LOCALE} UTF-8/${DEFAULT_LOCALE} UTF-8/" /etc/locale.gen
    arch-chroot /mnt sed -i "s/#${LOCALE_1} UTF-8/${LOCALE_1} UTF-8/" /etc/locale.gen
    arch-chroot /mnt sed -i "s/#${LOCALE_2} UTF-8/${LOCALE_2} UTF-8/" /etc/locale.gen
    arch-chroot /mnt locale-gen
    # arch-chroot /mnt sh -c "printf 'LANG=%s\nLC_MESSAGES=en_US.UTF-8\n' '${DEFAULT_LOCALE}' > /etc/locale.conf"
    echo -e "$OK Setup system language."

    ## Hostname
    arch-chroot /mnt sh -c "echo $HOSTNAME > /etc/hostname"
    echo -e "$OK Setup hostname."

    ## pacman config
    arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf
    echo -e "$OK Enable pacman color."
    arch-chroot /mnt sed -i '/^#\[\multilib\]$/{s/^#//;n;/^#Include[[:space:]]*=/s/^#//;}' /etc/pacman.conf
    echo -e "$OK Enable pacman multilib for 32 bit packages."

    ## Passwd root
    while true; do
        arch-chroot /mnt echo -e "$INPUT Enter root password: "
        if arch-chroot /mnt passwd root; then
            echo -e "$OK Setup root password."
            break
        fi
    done
    ## Create first user and add to group wheel
    if [ "$USERNAME" != "" ]; then
        arch-chroot /mnt useradd -m -G wheel -s $USERSHELL $USERNAME
        echo -e "$OK Setup $USERNAME (group wheel)."
        while true; do
            arch-chroot /mnt echo -e "$INPUT Enter $USERNAME password: "
            if arch-chroot /mnt passwd $USERNAME; then
                echo -e "$OK Setup $USERNAME password."
                break
            fi
        done
    fi

    ## Group wheel execute any command
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    echo -e "$OK Setup group wheel sudoers."

    ################################################################################
    # myconfig
    ################################################################################
    if [[ -n "$0" && "$0" != "-bash" ]]; then   # /dir/filename
        script_path=$(realpath "$0")
    else
        script_path=$(realpath "${BASH_SOURCE[0]}")
    fi
    if [[ "$script_path" == */* ]]; then        # /dir
        script_path="${script_path%/*}"
    fi
    # myconfig
    if [[ -d "$script_path/myconfig" && -d "/mnt/home/$USERNAME/" ]]; then
        cp -r $script_path/myconfig /mnt/home/$USERNAME/
        arch-chroot /mnt chown -R $USERNAME:$USERNAME "/home/$USERNAME/myconfig"
    fi
    echo -e "$OK Copy myconfig finsh!"

    ################################################################################
    # Rescue System (Minimal Arch)
    ################################################################################
    mkdir -p /mnt"${RESCUE_DIR}"
    AVAIL_MB=$(df -BM /mnt | awk 'NR==2 {print $4}' | tr -d 'M')
    if [ "$AVAIL_MB" -lt 1500 ]; then
        echo -e "$WARN Avail space less 1.5G (${AVAIL_MB}MB), skip download ISO。"
    else
        if [ -f "/root/${ISO_FILENAME}" ]; then
            cp "/root/${ISO_FILENAME}" "/mnt${RESCUE_DIR}/${ISO_FILENAME}"
        else
            echo -e "$INFO Downloading arch linux iso to ${RESCUE_DIR}..."
            curl -fL -C - --retry 3 -# -o "/mnt${RESCUE_DIR}/${ISO_FILENAME}" "${ISO_DOWNLOAD_URL}"
        fi
        echo -e "$INFO Setup arch linux iso to ${RESCUE_DIR}..."
    fi

    ROOT_UUID=$(blkid -s UUID -o value "/dev/disk/by-partlabel/${ROOT_LABEL}")
    ROOT_PARTUUID=$(blkid -s PARTUUID -o value "/dev/disk/by-partlabel/${ROOT_LABEL}")
    if [[ -z "$ROOT_UUID" || -z "$ROOT_PARTUUID" ]]; then
        echo -e "${ERROR} Failed to retrieve UUID/PARTUUID for partition '${ROOT_LABEL}'"
        exit 1
    fi

    # Rescue System (live)
cat > /mnt/boot/grub/custom.cfg <<EOF
menuentry "${GRUB_OPT_RESCUE_NAME}" {
    insmod part_gpt
    insmod ext2
    insmod loopback
    insmod iso9660

    search --no-floppy --fs-uuid --set=root "${ROOT_UUID}"

    loopback loop "${RESCUE_DIR}/${ISO_FILENAME}"

    linux (loop)/arch/boot/x86_64/vmlinuz-linux \
        archisobasedir=arch \
        img_dev="/dev/disk/by-partuuid/${ROOT_PARTUUID}" \
        img_loop="${RESCUE_DIR}/${ISO_FILENAME}" \
        cow_spacesize=4G \
        earlymodules=overlay \
        quiet

    initrd (loop)/arch/boot/x86_64/initramfs-linux.img
}
EOF
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

    cat > "/mnt${EXCLUDE}" <<EOF
/home/*
/var/cache/pacman/pkg/*
/tmp/*
/proc/
/sys/*
/dev/*
/run/*
/mnt/*
/media/*
/backup/
${RESCUE_DIR}/
${SWAP_FILE}
/home/*/.local/share/Steam
/home/*/Games
/home/*/.steam
EOF

    # Backup Script
    cat > /mnt${SNAPSHOT_BACKUP} <<EOF
#!/bin/bash
SNAP_DIR="${SNAPSHOT_BASE}/\$(date +%Y%m%d-%H%M)"

mkdir -p "\$SNAP_DIR"

echo "$INFO Snapshot '\${SNAP_DIR}' saveing..."
rsync -aAXH --info=progress2 --delete --exclude-from="\$EXCLUDE" / "\$SNAP_DIR/"
echo "$OK Snapshot save as '\$SNAP_DIR'"
EOF
    chmod +x /mnt/usr/local/bin/snapshot-backup.sh

    # Restore Script
    cat > /mnt${SNAPSHOT_RESTORE} <<EOF
#!/bin/bash
if [ \$# -eq 0 ]; then
    echo "${WARN} This script must run at live/rescue system!"
    echo "Usage: \$0 <snapshot_name>"
    exit 1
fi

printf "${WARN} This script must run at live/rescue system! Are you sure? (y/N): "
read -re RESTORE_DISK
RESTORE_DISK=\${RESTORE_DISK:-n}
if [ "\$RESTORE_DISK" == "n" -o "\$RESTORE_DISK" == "N" ]; then exit 0; fi

mount /dev/disk/by-partlabel/${ROOT_LABEL} /mnt 2>/dev/null || mount ${ROOT} /mnt
mkdir -p /mnt/backup

if [ ${CREATE_PARTITION_FOR_BACKUP} -eq "yes" ]; then
    mount /dev/disk/by-partlabel/${BACKUP_LABEL} /mnt/backup 2>/dev/null || mount ${BACKUP} /mnt/backup
fi

rsync -aAXH --info=progress2 --delete --exclude-from=/mnt/backup/exclude.list "/mnt${SNAPSHOT_BASE}/\$1/" /mnt/
echo "$OK Restore finish, please reboot machine."
EOF
    chmod +x /mnt/usr/local/bin/restore-snapshot.sh

    ## debug
    cp "/root/${LOGFILE}" "/mnt/backup/${LOGFILE}"
    # debug info
    echo -e "$INFO cat /mnt/etc/fstab"
    cat /mnt/etc/fstab
    echo -e "$INFO blkid"
    blkid
    echo -e "$INFO ls -FA /mnt/boot"
    ls -FA /mnt/boot
    echo -e "$INFO ls -FA /mnt/boot/efi"
    ls -FA /mnt/boot/efi

}

# Timer
start_time=$(date +%s)
uefi_gpt_ext4_grub_install
end_time=$(date +%s)
echo -e "$INFO Installation completed in $((end_time - start_time)) seconds"

# Reboot now
printf "$INPUT Reboot now? [Y/n] "
read -re reboot_now
reboot_now=${reboot_now:-y}
if [ "$reboot_now" == "y" -o "$reboot_now" == "Y" ]; then
    umount -R /mnt
    reboot
fi
