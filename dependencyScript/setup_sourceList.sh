#!/bin/sh

dirds="$PWD"
cd ..
dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"

if [ $nrelease = "sid" ]; then
    
    cat >> /mnt/etc/apt/sources.list << EOF
    # Debian Sid (Unstable) - Binary and Source Repositories
    deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware
    deb-src http://deb.debian.org/debian sid main contrib non-free non-free-firmware

    # Unstable Debug Packages
    deb http://deb.debian.org/debian-debug sid-debug main contrib non-free non-free-firmware
    deb-src http://deb.debian.org/debian-debug sid-debug main contrib non-free non-free-firmware
    EOF
elif [ $nrelease = "testing" ]; then
    $dirm/dependencyScript/configer_uefi_partion_and_btrfs_subvol.sh
else
    $dirm/dependencyScript/configer_mbr_partion_and_btrfs_subvol.sh
fi