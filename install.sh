#!/bin/bash

# Configuration
username="usera"     # "" disable Create first user
shell="/bin/bash"
hostname="arch"
test_address="archlinux.org"
mirrors=(
    "Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    "Server = http://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
)
format_disk="/dev/sda"   # "" disable, Disk must formated befor disable
# format_disk=""
efi_size=1
swap_size=4
unit="GiB"

efi_partition="/dev/sda1"
swap_partition="/dev/sda2"
root_partition="/dev/sda3"
btrfs_label="Arch"
efi_label="EFI"
swap_label="Swap"
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

# neovim config
file_options=(
    "vim.opt.number = true                   -- 显示行号"
    "vim.opt.relativenumber = true           -- 相对行号, 显示当前光标位置行号，其他为相对光标位置的行号距离"
    ""
    "vim.opt.tabstop = 4                     -- Tab 显示宽度"
    "vim.opt.shiftwidth = 4                  -- 自动缩进宽度"
    "vim.opt.expandtab = true                -- 将 Tab 转换为空格"
    "vim.opt.autoindent = true               -- 自动缩进"
    "vim.opt.wrap = false                    -- 自动换行"
    "vim.opt.cursorline = true               -- 显示光标"
    ""
    "vim.opt.mouse:append("a")               -- 启用鼠标支持, vim.opt.mouse = 'a'"
    "vim.opt.clipboard:append("unnamedplus") -- 系统剪切板支持, vim 的 d 键附带剪切会把系统剪切板搞乱?"
    ""
    "vim.opt.ignorecase = true               -- 搜索忽略大小写"
    "vim.opt.smartcase = true                -- 智能大小写搜索"

    "vim.opt.splitright = true               -- 默认新窗口为左边"
    "vim.opt.splitbelow = true               -- 默认新窗口为下边"
    "vim.opt.signcolumn = "yes"              -- 左侧多一列，可以方便debug和插件提示"
    "vim.opt.termguicolors = true            -- 启用真彩色，支持外观主题"
)
file_keymaps=(
    "vim.g.mapleader = \" \"                   -- 设置(leader)主键为空格"
    ""
    "local keymap = vim.keymap.set"
    "-- 视觉模式 --"
    "keymap(\"v\", \"J\", \":m \'>+1<CR>gv=gv\")    -- 选中多行后按 shift + j 向上移动代码块"
    "keymap(\"v\", \"K\", \":m \'<-2<CR>gv=gv\")    -- 选中多行后按 shift + K 向下移动代码块"
    ""
    "-- 正常模式 --"
    "keymap(\"n\", \"<leader>sv\", \"<C-w>v\")     -- 原来的Ctrl+w输入v, 改成leader键+sv, 水平新增窗口"
    "keymap(\"n\", \"<leader>sh\", \"<C-w>s\")     -- leader键+sh, 垂直新增窗口"
    "keymap(\"n\", \"<leader>nh\", \":nohl<CR>\")  -- /keymap 搜索词条时会有高亮, 但是取消高亮要输入:nohl, 改成leader键+nh"
)
# -- Configuration


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
    # ping -c 1 -W 1 $test_address > /dev/null 2>&1
    # result=$?
    # if [ $result -eq 0 ]; then echo -e "$OK ping success!"
    # else
    #     echo -e "$ERROR ping loss or address invalid! (code: $result)"
    #     exit 2
    # fi
    
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
        parted $format_disk mkpart $efi_label fat32 1MiB "$efi_size$unit"
        parted $format_disk set 1 esp on
        ## Create Swap Partition
        parted $format_disk mkpart $swap_label linux-swap "$efi_size$unit" "$(($efi_size+$swap_size))$unit"
        ## Create Root Partition
        parted $format_disk mkpart "/" ext4 "$(($efi_size+$swap_size))$unit" 100%
        parted $format_disk type 3 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
    fi
    # TODO: What if /dev/sda[1-3] not exist
    
    # Format Partition
    echo -e "$INFO Format partition..."
    mkfs.fat -F32 $efi_partition
    mount --mkdir $efi_partition /mnt/boot
    mkswap $swap_partition
    swapon $swap_partition

    ## btrfs, live need package: btrfs-progs
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
    echo -e "$INFO Check /mnt/etc/fstab"
    cat /mnt/etc/fstab

    # Install Base packages
    echo -e "$INFO Base packages install..."
    pacman -Sy archlinux-keyring
    pacstrap -K /mnt ${packages[@]} -y

    # Setup System
    #arch-chroot /mnt
    ## Timezone & Generate /etc/adjtime
    echo -e "$INFO Setting timezone..."
    arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    arch-chroot /mnt hwclock --systohc
    ## Language
    echo -e "$INFO Setting system language..."
    arch-chroot /mnt sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt sed -i 's/#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
    arch-chroot /mnt locale-gen
    arch-chroot /mnt echo LANG=en_US.UTF-8 > /etc/locale.conf
    ## Hostname
    echo -e "$INFO Setting hostname..."
    arch-chroot /mnt echo $hostname > /etc/hostname
    ## Passwd root
    echo -e "$INFO Enter root password: "
    arch-chroot /mnt passwd root
    ## Group wheel execute any command
    echo -e "$INFO Setting sudoers..."
    arch-chroot /mnt sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    ## Gurb
    echo -e "$INFO Setting gurb..."
    arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=$grub_label
    arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
    ## dhcpcd
    echo -e "$INFO Enable dhcpcd..."
    arch-chroot /mnt systemctl enable dhcpcd --now

    # (opt)Custom Setting
    ## Enable pacman color
    echo -e "$INFO Enable pacman color..."
    arch-chroot /mnt sed -i 's/#Color/Color/' /etc/pacman.conf
    ## Create first user
    if [ $username != "" ]; then
        arch-chroot /mnt useradd -m -G wheel -s $shell $username
        echo -e "$INFO Enter $username password: "
        arch-chroot /mnt passwd $username
    fi
    ## neovim
    # echo -e "$INFO Setting neovim..."
    # arch-chroot /mnt <<-EOF
    # mkdir /home/$username/.config
    # mkdir /home/$username/.config/nvim
    # printf "require("core.options")\nrequire("core.keymaps")" > /home/$username/.config/nvim/init.lua
    # mkdir /home/$username/.config/nvim/lua
    # mkdir /home/$username/.config/nvim/lua/core
    # printf "%s\n" "${file_options[@]}" > /home/$username/.config/nvim/lua/core/options.lua
    # printf "%s\n" "${file_keymaps[@]}" > /home/$username/.config/nvim/lua/core/keymaps.lua
	# EOF

    echo -e "$OK Setup finsh!"
    # Umount
    echo -e "$INFO umount..."
    umount -R /mnt
    # Reboot now
    reboot

}

# Running
default_install