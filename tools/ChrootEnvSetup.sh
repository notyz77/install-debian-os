#!/bin/sh

if [ $(id -u) -ne 0 ]; then
        echo "Only root can do this"
        exit 1
fi

if [ -d /sys/firmware/efi ]; then
    echo "This live ISO boot with UEFI mode, this means chroot system setup need to be mount EFI."

    lsblk -f
    echo '\nType the following EFI partition to setup chroot enviroment'
    read efiPart
    
    echo '\nType the following root partition to setup chroot enviroment'
    read rootPart

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$rootPart /mnt
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var/log
    mkdir -p /mnt/boot/efi
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$rootPart /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$rootPart /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$rootPart /mnt/var/log
    mount /dev/$efiPart /mnt/boot/efi

    echo "\nBTRFS partition and subvolumes with EFI partition are mounted"
else
    echo "This live ISO boot with bios mode."

    lsblk -f
    echo '\nType the following root partition to setup chroot enviroment'
    read rootPart

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$rootPart /mnt
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var/log
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$rootPart /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$rootPart /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$rootPart /mnt/var/log

    echo "\nBTRFS partition and subvolumes are mounted"
fi

# mount sudo folder for chroot system
mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc

echo '\nReady for chroot enviroment'

