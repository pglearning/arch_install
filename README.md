# Update
    add btrfs filesystem
    fix script language wrong
# TODO?
    add install.conf && source install.conf
    LINE 118 # btrfs version
    architecture check
    disk check
    config file
    BOOT + MBR support
# ISSUE
    LINE 116 # TODO: What if /dev/sda[1-3] not exist
# NOTE
    "arch-chroot /mnt echo string > file" not working
    "arch-chroot /mnt <<EOF" or "<<-EOF" output all line, cant use if []; then