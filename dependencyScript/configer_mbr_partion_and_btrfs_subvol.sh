#!/bin/sh

dirm="$PWD"
diskn=1
apt install fdisk -y
clear
echo "This live ISO boot with bios mode"
echo "Need to use MBR partition layout,by default this script first check if fdisk is install, if not it will install"
#read -n 1 -s -r -p "Press any key to continue"
# asking debian os release to installed
echo 'Choose the following options to setting up disk for debian installer'
echo '1) open fdisk to create partions'
echo '2) choose this options if already setup disk for mbr with one partions'
echo '3) choose this options if you only have one disk and want to used for debian installer, it will format disk automatically create partitions for it'

echo 'select number:'
read ndisk

if [ $ndisk = "1" ]; then
 
    lsblk -f
    echo '\nChoose the following disk to edit with fdisk'
    read pcdisk
    echo $pcdisk > $dirm/pcdisk.txt

    fdisk /dev/$pcdisk

    lsblk -f
    echo '\nChoose the following disk for grub bootloader'
    read grubDisk

    # If the input is empty, use the default value "John"
        if [ -z "$grubDisk" ]; then
            grubDisk="$pcdisk"
        fi
    echo $grubDisk > $dirm/grubDisk.txt

    lsblk -f
    echo '\nChoose the following disk partions for setting up btrfs file system with @, @home, @snapshots, @var_log subvolume'
    read partionsDisk
    echo $partionsDisk > $dirm/partionsDisk.txt

    mkfs.btrfs /dev/$partionsDisk

    mount /dev/$partionsDisk /mnt

    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@snapshots
    btrfs su cr /mnt/@var_log

    umount /mnt

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$partionsDisk /mnt
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var/log
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$partionsDisk /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$partionsDisk /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$partionsDisk /mnt/var/log

    lsblk

elif [ $ndisk = "2" ]; then

    lsblk -f
    echo '\nChoose the following disk for grub bootloader'
    read grubDisk
    echo $grubDisk > $dirm/grubDisk.txt

    lsblk -f
    echo '\nChoose the following disk partions for setting up btrfs file system with @, @home, @snapshots, @var_log subvolume'
    read partionsDisk
    echo $partionsDisk > $dirm/partionsDisk.txt

    mkfs.btrfs /dev/$partionsDisk

    mount /dev/$partionsDisk /mnt

    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@snapshots
    btrfs su cr /mnt/@var_log

    umount /mnt

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$partionsDisk /mnt
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var/log
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$partionsDisk /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$partionsDisk /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$partionsDisk /mnt/var/log

    lsblk

elif [ $ndisk = "3" ]; then

    lsblk -f
    echo '\nChoose the following disk so debian can install in it'
    read pcdisk
    echo $pcdisk > $dirm/pcdisk.txt

    lsblk -f
    echo '\nChoose the following disk for grub bootloader'
    read grubDisk

    # If the input is empty, use the default value "John"
        if [ -z "$grubDisk" ]; then
            grubDisk="$pcdisk"
        fi
    echo $grubDisk > $dirm/grubDisk.txt

    echo 'label: dos' | sfdisk /dev/$pcdisk

    sfdisk /dev/$pcdisk << EOF
label: dos
unit: sectors

/dev/$pcdisk$diskn : start=2048, size=, type=83, bootable
EOF

    mkfs.btrfs /dev/$pcdisk$diskn

    mount /dev/$pcdisk$diskn /mnt

    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@snapshots
    btrfs su cr /mnt/@var_log

    umount /mnt

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$pcdisk$diskn /mnt
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var/log
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$pcdisk$diskn /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$pcdisk$diskn /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$pcdisk$diskn /mnt/var/log

    lsblk

fi