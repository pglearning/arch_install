#!/bin/bash
#########################################################
# Paru (New AUR Helpers)
#########################################################
printf "$INFO Install paru (AUR helpers) will take a long time download and build. Are you sure? [y/N] "
read -re keep_run; keep_run=${keep_run:-n}
if [[ "$keep_run" =~ ^[Yy]$ ]]; then
    if command -v paru &>/dev/null; then
        echo -e "$INFO Paru already installed."
    else
        if ! command -v git &>/dev/null; then
            echo -e "$ERROR Git not installed."
            exit 11
        fi
        temp_dir=$(mktemp -d)
        cd "$temp_dir" || exit 12
        
        if git clone https://aur.archlinux.org/paru.git; then
            cd paru || exit 13
            if makepkg -si --noconfirm; then        # makepkg not allowed running as root
                echo -e "$OK Paru installed sucessfully!"
            else
                echo -e "$ERROR Paru build/install failed."
                echo -e "$WARN Build directory kept at: $PWD"
                exit 14
            fi
            cd .. && rm -rf "$temp_dir"
        else
            echo -e "$ERROR Failed to clone paru repository."
            exit 15
        fi
    fi
    echo -e "$INFO Initializing paru configuration..."
    paru --gendb
fi