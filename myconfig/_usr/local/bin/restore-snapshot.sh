#!/bin/bash
if [ $# -eq 0 ]; then
    echo "[\e[33m WARN \e[0m] This script must run at live/rescue system!"
    echo "Usage: $0 <snapshot_name>"
    exit 1
fi

printf "[\e[33m WARN \e[0m] This script must run at live/rescue system! Are you sure? (y/N): "
read -re RESTORE_DISK
RESTORE_DISK=${RESTORE_DISK:-n}
if [ "$RESTORE_DISK" == "n" -o "$RESTORE_DISK" == "N" ]; then exit 0; fi

mount /dev/disk/by-partlabel/root /mnt 2>/dev/null || mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/backup

if [ no -eq "yes" ]; then
    mount /dev/disk/by-partlabel/backup /mnt/backup 2>/dev/null || mount  /mnt/backup
fi

rsync -aAXH --info=progress2 --delete --exclude-from=/mnt/backup/exclude.list "/mnt/backup/snapshots/$1/" /mnt/
echo "[\e[32m OK \e[0m] Restore finish, please reboot machine."
