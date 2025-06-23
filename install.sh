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

# Only support ext4 & btrfs. default=ext4
filesystem="btrfs"
# Only support systemd-boot & grub. default=systemd-boot
bootloader="systemd"
# Spilt EFI & BOOT partition (/efi /boot /).  true & false. default=false (/boot /)
spilt_boot="true"
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

# "" disable, Disk must formated befor disable
format_disk="/dev/sda"
efi_size=101        # spilt_boot=true, efi=efi+boot
boot_size=924
swap_size=4096
unit="MiB"

efi_label="efi"
boot_label="boot"
swap_label="SWAP"
btrfs_label="btrfs"
root_label="arch_os"
grub_label="GRUB"
# process
if [ "$spilt_boot" = "true" ]; then
    root_partition_index="4"
    efi_partition="$format_disk""1"
    boot_partition="$format_disk""2"
    swap_partition="$format_disk""3"
    root_partition="$format_disk""$root_partition_index"

    efi_path="/efi"
    boot_path="/boot"

else
    efi_size=$(($efi_size+$boot_size))
    root_partition_index="3"
    efi_partition="$format_disk""1"
    boot_partition=$efi_partition
    swap_partition="$format_disk""2"
    root_partition="$format_disk""$root_partition_index"
    
    efi_path="/boot"
    boot_path="/boot"
fi

packages=(
    "base"
    "base-devel"
    "linux"
    "linux-headers"
    "linux-firmware"
    #"amd-ucode"     #"intel-ucode"
    "iwd"            #"networkmanager"
    "dhcpcd"
    "usbmuxd"       # 通过usb连接手机共享网络
    "man"
    "less"
    "bc"
    "vi"            # "nano"
    "neovim"        #"gvim"
    "ttf-sourcecodepro-nerd"
    "adobe-source-han-serif-cn-fonts"
    "bluez"         # 蓝牙
    #"curl"
    #"tar"
    #"gzip"
    #"git"
    #"sudo"
    #"zsh"
    # "grub"
    # "efibootmgr"
)
if [ $bootloader == "grub" ]; then packages+=( "grub" "efibootmgr" ); fi
if [ $filesystem == "btrfs" ]; then packages+=( "btrfs-progs" ); fi
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

    # Network Test, may need iwctl
    if ping -c 1 -W 1 "$test_address"; then
        echo -e "$OK ping success!"
    else
        echo -e "$ERROR ping loss or address invalid! (code: $?)"
        exit 11
    fi
    
    # Date & Time
    timedatectl set-ntp true
    timedatectl set-timezone $timezone
    echo -e "$OK Sync date & time."
    
    # reflector will add some shit mirrors in the file
    systemctl stop reflector.service
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

    # Keyring update (live pacman download issue)
    pacman -Sy archlinux-keyring --noconfirm
    pacman -Sy --noconfirm

    # Format Disk (gpt + uefi)
    if [ "$format_disk" != "" ]; then
        ## Create GUID Partition Table(GPT), will wipe all data from disk
        # echo $WIPE_DISK | parted $format_disk mklabel gpt     # (Danger) use first confirm auto format disk
        parted $format_disk mklabel gpt
        ## Create EFI system Partition
        parted $format_disk mkpart $efi_label fat32 0% "$efi_size$unit"
        parted $format_disk set 1 esp on
        if [ "$spilt_boot" = "true" ]; then
            ## Create Linux extended boot
            tempsize1=$(($efi_size+$boot_size))
            ### NOTE: mkfs.ext4 $boot_partition (only fat32. cant use filesystem)
            ### NOTE: /efi/loader/loader.conf , menu loader has be inside efi
            ### NOTE: /mnt/boot/loader/entries/arch.conf has be same dir with /boot/initramfs-linux-fallback.img?
            parted $format_disk mkpart $boot_label fat32 "$efi_size$unit" "$tempsize1$unit"
            parted $format_disk type 2 bc13c2ff-59e6-4262-a352-b275fd6f7172
        else
            tempsize1=$efi_size
        fi
        ## Create Swap Partition
        tempsize2+=$swap_size
        parted $format_disk mkpart $swap_label linux-swap "$tempsize1$unit" "$tempsize2$unit"
        ## Create Root Partition
        if [ "$filesystem" == "btrfs" ]; then
            parted $format_disk mkpart $root_label btrfs "$tempsize2$unit" 100%
        else
            parted $format_disk mkpart $root_label ext4 "$tempsize2$unit" 100%
        fi
        parted $format_disk type $root_partition_index 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
        echo -e "$OK Format disk ${format_disk}."
    fi
    
    # compress= "zstd": forcing compression; "lzo" fast raw compression; autodefrag
    if [ "$filesystem" = "btrfs" ]; then
        ## btrfs, live need package: btrfs-progs
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
    # Format Partition
    sleep 1
    mkfs.fat -F32 $efi_partition
    mount --mkdir $efi_partition /mnt$efi_path  # Mount to live
    if [ "$spilt_boot" = "true" ]; then
        mkfs.fat -F32 $boot_partition
        mount --mkdir $boot_partition /mnt$boot_path    # Mount to live
    fi
    mkswap $swap_partition
    swapon $swap_partition
    echo -e "$OK Format partition."

    # Generate fstab Partition Table
    mkdir /mnt/etc
    genfstab -U /mnt > /mnt/etc/fstab
    echo -e "$OK Generate fstab Partition Table."

    # Install Base packages
    pacstrap -K /mnt ${packages[@]} --noconfirm --needed
    echo -e "$OK Basic packages install."

    # Setup System 
    ## NOTE: "arch-chroot /mnt sh -c "echo 'string' > file"
    ## NOTE: "arch-chroot /mnt <<EOF" or "<<-EOF" output all line, cant use if []; then
    ## Timezone & Generate /etc/adjtime
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
    arch-chroot /mnt hwclock --systohc
    echo -e "$OK Setup timezone."
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

    ## Group wheel execute any command
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    echo -e "$OK Setup group wheel sudoers."
    
    if [ "$bootloader" = "grub" ]; then
        ## Grub
        arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=$efi_path --boot-directory=$boot_path
        arch-chroot /mnt grub-mkconfig -o $boot_path/grub/grub.cfg
        echo -e "$OK Setup grub."
        # cat /mnt$boot_path/grub/grub.cfg
    else
        ## systemd-boot, --esp-path=$efi_path --boot-path=$boot_path 
        arch-chroot /mnt bootctl install     # auto find esp-path (/efi /boot/efi /boot) boot-path (/boot)
        ## systemd-boot-pacman-hook
        if ! [ -d "/mnt/etc/pacman.d/" ]; then mkdir /mnt/etc/pacman.d; fi
        if ! [ -d "/mnt/etc/pacman.d/hooks/" ]; then mkdir /mnt/etc/pacman.d/hooks; fi
        echo "[Trigger]" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "Type = Package" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "Operation = Upgrade" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "Target = systemd" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "[Action]" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "Description = Gracefully upgrading systemd-boot..." >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "When = PostTransaction" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        echo "Exec = /usr/bin/systemctl restart systemd-boot-update.service" >> /mnt/etc/pacman.d/hooks/95-systemd-boot.hook
        arch-chroot /mnt bootctl update
        ### loader menu, console-mode can be set by auto, keep (hardware resolution)
        if ! [ -d "/mnt$efi_path/loader" ]; then mkdir /mnt$efi_path/loader; fi
        echo "default  arch.conf" > /mnt$efi_path/loader/loader.conf        # /efi load loader menu
        echo "timeout  3" >> /mnt$efi_path/loader/loader.conf
        echo "console-mode auto" >> /mnt$efi_path/loader/loader.conf
        echo "editor   1" >> /mnt$efi_path/loader/loader.conf
        ### loadconf
        ROOT_UUID=$(blkid -s UUID -o value $root_partition)
        root_flags=""
        if [ "$filesystem" == "btrfs" ]; then
            root_flags="rootflags=subvol=@"
        fi
        if ! [ -d "/mnt$boot_path/loader/entries" ]; then mkdir /mnt$boot_path/loader/entries; fi
        echo "title   Arch Linux" > /mnt$boot_path/loader/entries/arch.conf
        echo "linux   /vmlinuz-linux" >> /mnt$boot_path/loader/entries/arch.conf
        echo "initrd  /initramfs-linux.img" >> /mnt$boot_path/loader/entries/arch.conf
        echo "options root=UUID=$ROOT_UUID rw $root_flags" >> /mnt$boot_path/loader/entries/arch.conf
        ## options root=UUID=$ROOT_UUID; root=\"LABEL=$root_label\"
        echo "title   Arch Linux (fallback initramfs)" > /mnt$boot_path/loader/entries/arch-fallback.conf
        echo "linux   /vmlinuz-linux" >> /mnt$boot_path/loader/entries/arch-fallback.conf
        echo "initrd  /initramfs-linux-fallback.img" >> /mnt$boot_path/loader/entries/arch-fallback.conf
        echo "options root=UUID=$ROOT_UUID rw $root_flags" >> /mnt$boot_path/loader/entries/arch-fallback.conf
        echo -e "$OK Setup systemd-boot."
        ## debug
        cat /mnt$boot_path/loader/loader.conf
        cat /mnt$boot_path/loader/entries/arch.conf
        cat /mnt$boot_path/loader/entries/arch-fallback.conf
        ### arch-chroot /mnt bootctl
        ### arch-chroot /mnt bootctl list
    fi

    # (opt)Custom Setting
    ## Enable pacman color
    arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf
    echo -e "$OK Enable pacman color."

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
        chmod +x /mnt/home/$username/myconfig/config_setup.sh
        echo -e "$OK Copy to /home/$username/myconfig finsh!"
    fi

    ## debug
    cat /mnt/etc/fstab

    echo -e "$OK All setup finsh!"
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
