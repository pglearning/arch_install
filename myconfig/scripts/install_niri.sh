#!/bin/bash

# If any command has error, exit script
set -e

# Log File
LOGFILE="install_niri.log"
exec > >(tee -a "./${LOGFILE}") 2>&1

# Output Level
OK="[\e[32m OK \e[0m]"
INPUT="[\e[34m INPUT \e[0m]"
INFO="[\e[36m INFO \e[0m]"
WARN="[\e[33m WARN \e[0m]"
ERROR="[\e[31m ERROR \e[0m]"

# aru_packages=(
#     "noctalia"
#     "noctalia-shell"
#     "linuxqq-nt-bwrap"
#     "catppuccin-sddm-theme"
# )

packages=(
    "ttf-meslo-nerd"                    # Mono font
    "adobe-source-han-serif-cn-fonts"   # Serif font
    "adobe-source-han-sans-cn-fonts"    # Sans font
    "noto-fonts-emoji"                  # emoji font

    "wayland"
    # "xorg-xwayland"               # some need xorg server support
    "xwayland-satellite"            # for steam
    "niri"                          # wayland window manager
    "fuzzel"                        # wayland launcher
    "alacritty"                     # Terminal emulator
    "sddm"                          # login
    "wl-clipboard"                  # like 'xclip' put data in clipboard

    "fcitx5"
    "fcitx5-chinese-addons"
    "fcitx5-configtool"
    "ffmpeg"
    "rocm-smi-lib"                  # for btop show GPU info
    "mesa"                          # OpenGL
    "vulkan-radeon"                 # amd device
    # "vulkan-intel"      # intel device
    # "vulkan-nvidia"     # nvidia device
    "yt-dlp"                        # youtube video downloader
    "transmission-cli"              # for download *.torrent files "transmission-cli archlinux-2026.06.01-x86_64.iso.torrent"
    "chromium"                      # google chrome web browser
    "libreoffice-still"             # fresh office word, excel, etc.
    "libreoffice-still-zh-cn"       # fresh office word, excel, etc.
    # "libreoffice-fresh"             # fresh office word, excel, etc.
    # "libreoffice-fresh-zh-cn"       # fresh office word, excel, etc.
    "obs-studio"                    # record screen
    "mpv"                           # video player, same as be music player
    "mpv-mpris"                     # MPRIS support, noctalia needed.
    # "ncmpcpp"                       # music player, need mpd
    # "rmpc"                          # music player, need mpd
    # "mpd"                           # music player server

    "pipewire-audio"                # Bluetooth audio support, need 'bluez' package
    "pipewire-alsa"                 # alsa support
    "pipewire-jack"
    "realtime-privileges"           # Low latency real-time, Music production, game explosion-proof sound
    "easyeffects"                   # Earphone tuning, microphone noise reduction

    "v2ray"                         # Tun porxy
    "clang"

    # Game
    "steam"
    "lib32-mangohud"
    "mangohud"                      # Game hud for hardware Performance Monitor. steam start_opt add "mangohud %command%"
    "gamescope"                     # Custom game window output like "gamescope -w 2560 -h 1440 -r 144 -- mangohud %command%"
)

sudo pacman -Syu
sudo pacman -S "${packages[@]}" --noconfirm --needed

# Sddm
sudo systemctl enable sddm.service

# Niri
sudo tee /usr/share/wayland-sessions/niri.desktop << EOF
[Desktop Entry]
Name=Niri
Comment=A scrollable-tiling Wayland compositor
Exec=niri-session
Type=Application
DesktopNames=niri
EOF
mkdir -p ~/.config/niri
cp /usr/share/doc/niri/default-config.kdl ~/.config/niri/config.kdl
sed -i 's#Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }#Mod+D hotkey-overlay-title="noctalia launcher" { spawn-sh "noctalia msg panel-toggle launcher"; }#' ~/.config/niri/config.kdl
cat >> ~/.config/niri/config.kdl << EOF
spawn-at-startup "noctalia"
spawn-at-startup "alacritty"
EOF

# Fonts
SANS="Source Han Sans CN"
MONO="MesloLGS Nerd Font"
SERIF="Source Han Serif CN"
mkdir -p ~/.config/fontconfig
cat > ~/.config/fontconfig/fonts.conf << EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <match target="pattern"><test name="family"><string>sans-serif</string></test>
    <edit name="family" mode="prepend"><string>${SANS}</string></edit></match>
  <match target="pattern"><test name="family"><string>monospace</string></test>
    <edit name="family" mode="prepend"><string>${MONO}</string></edit></match>
  <match target="pattern"><test name="family"><string>serif</string></test>
    <edit name="family" mode="prepend"><string>${SERIF}</string></edit></match>
</fontconfig>
EOF
echo "$OK Set: sans=${SANS} | mono=${MONO} | serif=${SERIF}"
echo "$INFO:"
echo "   sans-serif → $(fc-match sans-serif)"
echo "   monospace  → $(fc-match monospace)"
echo "   serif      → $(fc-match serif)"

# hosts
if [ -d "~/myconfig" ]; then
    sudo cp ~/myconfig/_etc/hosts /etc/hosts
fi

# Audio service
systemctl --user enable --now pipewire.socket
systemctl --user enable --now pipewire.service
systemctl --user enable --now wireplumber.service
# status check (both 3 service should be "active (running)")
systemctl --user status pipewire.service wireplumber.service
# should output: Server Name: PulseAudio (on PipeWire x.x.x)
pactl info | grep "Server Name"

# list audio devices
# wpctl status
# pactl list sinks short

# check is muted
# wpctl status
# wpctl set-mute @DEFAULT_AUDIO_SINK@ 0

# Sound test
# pw-play /usr/share/sounds/alsa/Front_Center.wav

# Audio rersistent user service (running without login)
loginctl enable-linger $USER
