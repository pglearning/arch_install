#!/bin/bash

#########################################################
# Output Info
#########################################################
OK="[\e[32m OK \e[0m]"
INPUT="[\e[34m INPUT \e[0m]"
INFO="[\e[36m INFO \e[0m]"
WARN="[\e[33m WARN \e[0m]"
ERROR="[\e[31m ERROR \e[0m]"
ERROR_MSGS=()

#########################################################
# Basic Check
#########################################################
# Check if running as root
# if [ "$(id -u)" -ne 0 ]; then
#     echo -e "$ERROR Please run this script as root"
#     exit 1
# fi

# Network Test, may need iwctl
if ping -c 1 -W 1 "$test_address" &>/dev/null; then
    echo -e "$OK ping success!"
else
    sudo systemctl enable dhcpcd --now
    if ping -c 1 -W 1 "$test_address" &>/dev/null; then
        echo -e "$ERROR ping loss or address invalid! (code: $?)"
        exit 2
    fi
fi

# Check users
if [ "$(id -u)" -eq 0 ]; then
    printf "$INPUT No user in this computer, continue setting will setup root config, Are you sure? [y/N] "
    read -re keep_run; keep_run=${keep_run:-n}
    if [ "$keep_run" == "n" -o "$keep_run" == "N" ]; then exit 3; fi
fi

# Script dir
if [[ -n "$0" && "$0" != "-bash" ]]; then   # /dir/filename
    SCRIPT_DIR=$(realpath "$0")
else
    SCRIPT_DIR=$(realpath "${BASH_SOURCE[0]}")
fi
if [[ "$SCRIPT_DIR" == */* ]]; then        # /dir
    SCRIPT_DIR="${SCRIPT_DIR%/*}"
fi
echo -e "$OK script_dir=$SCRIPT_DIR"

#########################################################
# Install Packages
#########################################################
sudo pacman -Syu --noconfirm
packages=(
    "sway"              # core
    "swaybg"            # backgroud
    "foot"              # wayland support
    # "alacritty"         # vmware no gpu
    "wmenu"             # sway default program launch
    # "rofi-wayland"      # replace wmenu
    "waybar"            # replace swaybar
    "xorg-xwayland"     # xorg support
    "ttf-meslo-nerd"    # nerd font
    # "ttf-font-awesome"  # more icon font, "otf-font-awesome"
    "adobe-source-han-serif-cn-fonts"   # chinese
    "man"
    # "man-db"            # database
    "less"
    "bc"                # float calculation
    "tar"               # .tar
    "gzip"              # .zip
    "curl"              # url download
    "btop"              # a batter top
    "nano"              # size: vi ~= nano << vim ~= gvim(batter)
    "fcitx5-im"         # input method
    "fcitx5-chinese-addons"     # pinyin
    "alsa-utils"        # alsamixer & amixer
    # "alsa-plugins"      # high quality resampling
    # "alsa-firmware"     # include some sound card firmware (如创新SB0400 & Audigy2) 可能需要的固件
    # "noise-suppression-for-voice"   # 语音噪声抑制
    "ffmpeg"            # mpv依赖, FFmpeg 包括 x11grab 和 ALSA 虚拟设备，可以捕获整个用户显示和音频输入。
    "mpv"               # video player
    "mpd"               # music player
    "yt-dlp"            # video download
    "dust"              # dir tree
    "firefox"
    "yazi"              # file manager
    "iwd"               # net, wifi connect
    "neovim"
    "git"                   # neovim dependencies
    "luarocks"              # neovim dependencies
    "lua-language-server"   # neovim dependencies
    "fastfetch"             # replace neofetch
    "bash-completion"
)
# pacman -Syu --noconfirm             # if not update some package may cant be download?

package_install(){
    local package="$1"
    if pacman -Q $package &>/dev/null; then
        echo -e "$INFO $package has being install."
        return 0
    fi

    if sudo pacman -S $package --noconfirm --needed; then
        echo -e "$OK $package install."
        return 0
    else
        ERROR_MSGS+="Packages install failure. [ $package ]"
        return 1
    fi
}

for pkg in "${packages[@]}"; do
    package_install "$pkg"
done

## Microcode package
if lscpu | grep 'Intel' &>/dev/null; then
    package_install "intel-ucode"
elif lscpu | grep 'AMD' &>/dev/null; then
    package_install "amd-ucode"
fi

#########################################################
# Packages Setup
#########################################################
if ! [ -d "$HOME/.config" ]; then mkdir "$HOME/.config"; fi

# iwd
if pacman -Q iwd &>/dev/null; then
    sudo systemctl enable iwd.service --now
    sudo cp -r $SCRIPT_DIR/../iwd /etc/
    echo -e "$OK iwd setup."
else
    ERROR_MSGS+="Packages Setup failure. [ iwd ]"
fi

# nvim
if pacman -Q neovim &>/dev/null; then
    # neovim dependencies
    if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
        package_install "wl-clipboard"
    else
        package_install "xclip"
    fi
    cp -r $SCRIPT_DIR/../nvim $HOME/.config/
    echo -e "$OK neovim setup."
else
    ERROR_MSGS+="Packages Setup failure. [ neovim ]"
fi

# Microcode package
if lscpu | grep 'Intel'; then
    package_install "intel-ucode"
elif lscpu | grep 'AMD'; then
    package_install "amd-ucode"
fi

# alacritty

# foot
# if package_install "foot"; then
#     cp -r $SCRIPT_DIR/../foot $HOME/.config/
#     echo -e "$OK foot setup."
# fi

# sway
if package_install "sway"; then
    sudo systemctl enable seatd --now
    # usermod -aG seat $(whoami)
    mkdir -p $HOME/.config/sway
    cp /etc/sway/config $HOME/.config/sway/config
    echo "if [ -z \"\$WAYLAND_DISPLAY\" ] && [ -n \"\$XDG_VTNR\" ] && [ \"\$XDG_VTNR\" -eq 1 ] ; then" >> $HOME/.bash_profile
    echo "    exec sway" >> $HOME/.bash_profile
    echo "fi" >> $HOME/.bash_profile
    # foot
    # echo "exec foot" >> $HOME/.config/sway/config
    # fcitx5
    if package_install "fcitx5"; then
        echo "exec --no-startup-id fcitx5 -d" >> $HOME/.config/sway/config
    fi
    echo -e "$OK sway setup."
fi

# gtk program dark theme (firefox etc.)
cp -r $SCRIPT_DIR/../gtk-3.0 $HOME/.config/
echo -e "$OK gtk program dark theme setup."

# mpd
mkdir -p $HOME/.config/mpd/playlists
touch $HOME/.config/mpd/{database,log,pid,state,sticker.sql}
cp $SCRIPT_DIR/../mpd/mpd.conf $HOME/.config/mpd/mpd.conf
systemctl enable mpd.service --user --now       # root and user only one can used, must disable other
echo -e "$OK mpd setup."

#########################################################
# Basic Setup
#########################################################
# Github hosts
if sudo cp "$SCRIPT_DIR/../hosts" "/etc/hosts"; then
    echo -e "$OK Github hosts setup."
else
    echo -e "$ERROR hosts copy failure. ($?)"
fi

# Alias .bashrc
if sudo cp "$SCRIPT_DIR/../bash.bashrc" "/etc/bash.bashrc"; then
    echo -e "$OK .bashrc setup."
else
    echo -e "$ERROR .bashrc copy failure. ($?)"
fi

# alsa
if package_install "alsa-utils"; then
    if amixer | grep 'Master'; then
        amixer sset Master unmute
        amixer set Master 50
    fi
    if amixer | grep 'Speaker'; then
        amixer sset Speaker unmute
        amixer set Speaker 50
    fi
    if amixer | grep 'Headphone'; then
        amixer sset Headphone unmute
        amixer set Headphone 50
    fi
    # amixer -c 0 sset "Auto-Mute Mode" Disabled
fi

echo "" > $SCRIPT_DIR/setup_sway.log
echo "${ERROR_MSGS[@]}" >> $SCRIPT_DIR/setup_sway.log
echo -e "$OK All config file setup, some files may need reboot to effect."
