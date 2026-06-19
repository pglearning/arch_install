#!/bin/bash

# Configuration

HOSTNAME="archlinux"
TIMEZONE="Asia/Shanghai"
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
ISO_SAVE_NAME="archlinux-x86_64.iso"

MIRRORS=(
    "Server = https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
)
MIRRORS_COUNTRY="CN"

# uefi_gpt_ext4_grub_install
DISK="/dev/nvme0n1"
EFI_SIZE=512
ROOT_SIZE=100000
BACKUP_SIZE=100000
UNIT="MiB"

BOOTLOADER="grub"
FILESYSTEM="ext4"
EFI_LABEL="ESP"
ROOT_LABEL="root"
BACKUP_LABEL="backup"
HOME_LABEL="home"

RESCUE_DIR="/rescue"
SNAPSHOT_BASE="/backup/snapshots"
SWAP_FILE="/swapfile"
SWAP_SIZE="4G"          # 16G RAM, 4G for now

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

    "ttf-meslo-nerd"
    "adobe-source-han-serif-cn-fonts"
    # "nano"                # "vi"
    "neovim"                # "gvim"
    "tmux"
    "curl"
    "git"
    "tar"
    "gzip"
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
    parted -s "$DISK" mkpart "$BACKUP_LABEL" "$FILESYSTEM" "$((EFI_SIZE + ROOT_SIZE))${UNIT}" "$((EFI_SIZE + ROOT_SIZE + BACKUP_SIZE))${UNIT}"
    parted -s "$DISK" mkpart "$HOME_LABEL" "$FILESYSTEM" "$((EFI_SIZE + ROOT_SIZE + BACKUP_SIZE))${UNIT}" 100%

    # Partitions Name
    # '/dev/nvme0n1p1'  p1 not 1
    if [[ "$DISK" == *nvme* ]]; then
        EFI="${DISK}p1"; ROOT="${DISK}p2"; BACKUP="${DISK}p3"; HOME="${DISK}p4"
    else
        EFI="${DISK}1";  ROOT="${DISK}2";  BACKUP="${DISK}3";  HOME="${DISK}4"
    fi

    # Format Partitions
    mkfs.fat -F32 "$EFI"
    mkfs.ext4 -F "$ROOT"
    mkfs.ext4 -F "$BACKUP"
    mkfs.ext4 -F "$HOME"
    # Mount To Root
    mount "$ROOT" /mnt
    mkdir -p /mnt/{boot/efi,home,backup}
    mount "$EFI" /mnt/boot/efi
    mount "$HOME" /mnt/home
    mount "$BACKUP" /mnt/backup

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

    # Setup System
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
    arch-chroot /mnt sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
    arch-chroot /mnt sed -i "s/#$LOCALE_1 UTF-8/$LOCALE_1 UTF-8/" /etc/locale.gen
    arch-chroot /mnt sed -i "s/#$LOCALE_2 UTF-8/$LOCALE_2 UTF-8/" /etc/locale.gen
    arch-chroot /mnt locale-gen
    arch-chroot /mnt sh -c "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
    echo -e "$OK Setup system language."

    ## Hostname
    arch-chroot /mnt sh -c "echo $HOSTNAME > /etc/hostname"
    echo -e "$OK Setup hostname."

    ## Enable pacman color
    arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf
    echo -e "$OK Enable pacman color."

    ## Passwd root
    while true; do
        arch-chroot /mnt echo -e "$INPUT Enter root password: "
        if arch-chroot /mnt passwd root; then
            echo -e "$OK Setup root password."
            break
        fi
    done
    ## Create first user
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

    ## Grub
    # arch-chroot /mnt grub-install  # Auto?
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    echo -e "$OK Setup grub."

    # Rescue System (Minimal Arch)
    mkdir -p /mnt"${RESCUE_DIR}"
    AVAIL_MB=$(df -BM /mnt | awk 'NR==2 {print $4}' | tr -d 'M')
    if [ "$AVAIL_MB" -lt 1500 ]; then
        echo -e "$WARN Avail space less 1.5G (${AVAIL_MB}MB), skip download ISO。"
    else
        echo -e "$INFO Downloading arch linux iso to ${RESCUE_DIR}..."
        curl -L -o /mnt"${RESCUE_DIR}/${ISO_SAVE_NAME}" "$ISO_DOWNLOAD_URL"
    fi

    ROOT_UUID=$(blkid -s UUID -o value "/dev/disk/by-partlabel/${ROOT_LABEL}")
    ROOT_PARTUUID=$(blkid -s PARTUUID -o value "/dev/disk/by-partlabel/${ROOT_LABEL}")
    if [[ -z "$ROOT_UUID" || -z "$ROOT_PARTUUID" ]]; then
        echo -e "${ERROR} Failed to retrieve UUID/PARTUUID for partition '${ROOT_LABEL}'"
        exit 1
    fi

cat > /mnt/boot/grub/custom.cfg <<EOF
menuentry "Arch Linux Rescue (ISO Loopback)" {
    insmod part_gpt
    insmod ext2
    insmod loopback
    insmod iso9660

    search --no-floppy --fs-uuid --set=root "${ROOT_UUID}"

    loopback loop "${RESCUE_DIR}/${ISO_SAVE_NAME}"

    linux (loop)/arch/boot/x86_64/vmlinuz-linux \
        archisobasedir=arch \
        img_dev="/dev/disk/by-partuuid/${ROOT_PARTUUID}" \
        img_loop="${RESCUE_DIR}/${ISO_SAVE_NAME}" \
        cow_spacesize=4G \
        earlymodules=overlay \
        quiet

    initrd (loop)/arch/boot/x86_64/initramfs-linux.img
}
EOF
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

    # Backup Script
cat > /mnt/usr/local/bin/snapshot-backup.sh <<EOF
#!/bin/bash
SNAP_DIR="${SNAPSHOT_BASE}/\$(date +%Y%m%d-%H%M)"
EXCLUDE="/backup/exclude.list"

mkdir -p "\$SNAP_DIR"

cat > "$EXCLUDE" <<EXCL
/home/*
/var/cache/pacman/pkg/*
/tmp/*
/proc/*
/sys/*
/dev/*
/run/*
/mnt/*
/media/*
/backup/*
${RESCUE_DIR}/
${SWAP_FILE}
/home/*/.local/share/Steam
/home/*/Games
/home/*/.steam
EXCL

rsync -aAXH --delete --exclude-from="\$EXCLUDE" / "\$SNAP_DIR/"
echo "$INFO Snapshot save as '\$SNAP_DIR'"
EOF
    chmod +x /mnt/usr/local/bin/snapshot-backup.sh

    # Restore Script
cat > /mnt/usr/local/bin/restore-snapshot.sh <<EOF
#!/bin/bash
if [ \$# -eq 0 ]; then
    echo "${WARN} This script must run at live/rescue system!"
    echo "Usage: \$0 <snapshot_name>"
    ls -1 "${SNAPSHOT_BASE}/"
    exit 1
fi

printf "${WARN} This script must run at live/rescue system! Are you sure? (y/N): "
read -re RESTORE_DISK
RESTORE_DISK=\${RESTORE_DISK:-n}
if [ "\$RESTORE_DISK" == "n" -o "\$RESTORE_DISK" == "N" ]; then exit 0; fi

mount /dev/disk/by-partlabel/${ROOT_LABEL} /mnt 2>/dev/null || mount ${ROOT} /mnt
mkdir -p /mnt/backup
mount /dev/disk/by-partlabel/${BACKUP_LABEL} /mnt/backup 2>/dev/null || mount ${BACKUP} /mnt/backup

rsync -aAXH --delete --exclude-from=/backup/exclude.list "${SNAPSHOT_BASE}/\$1/" /mnt/
echo "$OK Restore finish, please reboot machine."
EOF
    chmod +x /mnt/usr/local/bin/restore-snapshot.sh

    ## debug
    cp "/root/${LOGFILE}" "/mnt/backup/${LOGFILE}"
    echo -e "$INFO cat /mnt/etc/fstab"
    cat /mnt/etc/fstab
    echo -e "$INFO blkid"
    blkid
    echo -e "$INFO ls -FA /mnt/boot"
    ls -FA /mnt/boot
    echo -e "$INFO ls -FA /mnt/boot/efi"
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
uefi_gpt_ext4_grub_install
end_time=$(date +%s)
echo -e "$INFO Installation completed in $((end_time - start_time)) seconds"