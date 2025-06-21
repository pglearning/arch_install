#!/bin/bash

# Output Level
OK="[\e[32m OK \e[0m]"
INFO="[\e[36m INFO \e[0m]"
WARN="[\e[33m WARN \e[0m]"
ERROR="[\e[31m ERROR \e[0m]"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "$ERROR Please run this script as root"
    exit 1
fi

# System Update
pacman -Syu --noconfirm --needed

# Check users
users=($(users))
if [ -z "$users" ]; then
    read -ep "$INFO No user in this computer, continue setting will setup root config, Are you sure? [y/N] " keep_run
    keep_run=${keep_run:-n}
    if [ "$keep_run" == "n" -o "$keep_run" == "N" ]; then
        exit 2
    fi
    USER_HOME=$HOME
else
    if [ ${#users[@]} -eq 2 ]; then
        USER_HOME="/home/${users[0]}"
    else
        while true; do
            echo "${users[@]}"
            read -ep "$INFO Enter what user you want to setup config: " username
            if printf '%s\n' "${users[@]}" | grep -qxF "$username"; then
                USER_HOME="/home/$username"
                break
            fi
            echo -e "$WARN Please enter the right username."
        done
    fi
fi
echo -e "$WARN home=$USER_HOME"

# Has be same dir with this script
if [[ -n "$0" && "$0" != "-bash" ]]; then   # /dir/filename
    script_path=$(realpath "$0")
else
    script_path=$(realpath "${BASH_SOURCE[0]}")
fi
if [[ "$script_path" == */* ]]; then        # /dir
    SCRIPT_DIR="${script_path%/*}"
else
    SCRIPT_DIR=$script_path
fi

# dhcpcd, need root
if ! pacman -Q dhcpcd; then pacman -S dhcpcd --noconfirm --needed; fi
systemctl enable dhcpcd --now
echo -e "$OK dhcpcd setup."

# Github hosts, need root
cp "${SCRIPT_DIR}/hosts" "/etc/hosts"
echo -e "$OK Github hosts setup."

# Alias .bashrc
cp "${SCRIPT_DIR}/.bashrc" "${USER_HOME}/.bashrc"
echo -e "$OK '.bashrc' setup."

# gvim
# if ! pacman -Q gvim; then pacman -S gvim --noconfirm --needed; fi
# cp "${SCRIPT_DIR}/.vimrc" "${USER_HOME}/.vimrc"
# echo -e "$OK '.vimrc' setup."

# neovim
if ! pacman -Q neovim; then pacman -S neovim --noconfirm --needed; fi
## config
cp -r "${SCRIPT_DIR}/nvim" "${USER_HOME}/.config/"
## auto install dependencies
if ! pacman -Q git; then pacman -S git --noconfirm --needed; fi
if ! pacman -Q luarocks; then pacman -S luarocks --noconfirm --needed; fi
if ! pacman -Q lua-language-server; then pacman -S lua-language-server --noconfirm --needed; fi
if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
    if ! pacman -Q wl-clipboard; then pacman -S wl-clipboard --noconfirm --needed; fi
else
    if ! pacman -Q xclip; then pacman -S xclip --noconfirm --needed; fi
fi
echo -e "$OK nvim setup."

# firefox dark theme (all basic gtk app)
cp -r "${SCRIPT_DIR}/gtk-3.0" "${USER_HOME}/.config/"
echo -e "$OK gtk dark theme setup."

# package dependencies check tool, pactree
if ! pacman -Q pacman-contrib; then pacman -S pacman-contrib --noconfirm --needed; fi
if ! [ -d "${USER_HOME}/tools" ]; then mkdir "${USER_HOME}/tools"; fi
# if ! [ -f "${USER_HOME}/tools/paccdep" ]; then
    cp "${SCRIPT_DIR}/tools/paccdep" "${USER_HOME}/tools/paccdep"
    alias paccdep="${USER_HOME}/tools/paccdep"
# fi
echo -e "$OK tools/paccdep setup."

## Microcode package
if lscpu | grep 'Intel'; then
    if ! pacman -Q intel-ucode; then pacman -S intel-ucode --noconfirm --needed; fi
elif lscpu | grep 'AMD'; then
    if ! pacman -Q amd-ucode; then pacman -S amd-ucode --noconfirm --needed; fi
fi

# Custom packages
packages=(
    #"wqy-microhei"
    "ttf-sourcecodepro-nerd"
    "adobe-source-han-serif-cn-fonts"
    "fcitx5-im"                 # im包组, 包含qt configtool
    "fcitx5-chinese-addons"     # pinyin输入法
    "yazi"              # 文件管理
    "mpv"               # 播放器
    "git"
    "curl"
    "yt-dlp"            # 视频下载
    "tar"
    "gzip"
    "firefox"
    "alsa-utils"        # 核心, alsamixer 、 amixer 等程序
    "alsa-plugins"      # 高质量重采样
    # "alsa-firmware"     # 包含了某些声卡（如创新SB0400 Audigy2）可能需要的固件
    # "noise-suppression-for-voice"   # 语音噪声抑制
    #"zsh"
    #"iwd"          #"networkmanager"
    #"amd-ucode"    #"intel-ucode"
)
for pkg in "${packages[@]}"; do
    if ! pacman -Q "$pkg"; then pacman -S ${packages[@]} --noconfirm --needed; fi
done
## alsa
if amixer | grep 'Master'; then amixer sset Master unmute; fi
if amixer | grep 'Speaker'; then amixer sset Speaker unmute; fi
if amixer | grep 'Headphone'; then amixer sset Headphone unmute; fi
## pipewire
# pipewire_group=(
#     "pipewire"          # 核心音频服务，支持低延迟和 Wayland 环境
#     "pipewire-alsa"     # ALSA 兼容支持, [与pulseaudio-alsa冲突]
#     "pipewire-pulse"    # 提供 PulseAudio 兼容层, 自动处理蓝牙音频设备
#     "pipewire-jack"     # 获取 JACK 支持, pw-jack 可以用来启动 JACK 客户端, [和Jack2冲突]
#     "pipewire-audio"    # 音频服务器, 取代PulseAudio和JACK
#     "rtkit"             # PipeWire 依赖 RTKit 来提升音频线程的实时优先级（避免卡顿）
#     "wireplumber"       # 管理 PipeWire 的会话和策略
# )
# systemctl enable --user --now pipewire pipewire-pulse wireplumber

## Paru 新AUR助手
read -ep "$INFO Install paru (AUR helpers) will take a long time download and build. Are you sure? [y/N] " keep_run
keep_run=${keep_run:-n}
if [ "$keep_run" == "y" -o "$keep_run" == "Y" ]; then
    git clone https://aur.archlinux.org/paru.git
    cd paru && makepkg -si
    cd .. && rm -rf paru
    if [[ -x "$(command -v paru)" ]]; then
        paru
    else
        echo -e "$ERROR Paru install fail."
    fi
fi


echo -e "$INFO All config file setup, some files may need reboot to effect."