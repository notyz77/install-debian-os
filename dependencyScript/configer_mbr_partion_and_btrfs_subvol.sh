#!/bin/sh

dirds="$PWD"
apt install fdisk
clear
echo "This live ISO boot with bios"
echo "Need to use MBR patiation layout,by default this script first check if fdisk is install, if not it will install"
#read -n 1 -s -r -p "Press any key to continue"
# asking debian os release to installed
echo 'Choose the following options to setting up disk for debian installer'
echo '1) open fdisk to create partions'
echo '2) choose this options if already setup disk for mbr with one partions'
echo '3) choose this options if you only have one disk and want to used for debian installer, it will formate disk automatickly create partions for it'

echo 'select number:'
read ndisk

if [ $ndisk = "1" ]; then
 
    lsblk -f
    echo '\nChoose the following disk to edit with fdisk'
    read pcdisk
    echo $pcdisk > $dirds/pcdisk.txt

    lsblk -f
    echo '\nChoose the following disk for grub bootloader'
    read grubDisk

    # If the input is empty, use the default value "John"
        if [ -z "$grubDisk" ]; then
            grubDisk="$pcdisk"
        fi
    echo $grubDisk > $dirds/grubDisk.txt

    fdisk /dev/$pcdisk

    lsblk -f
    echo '\nChoose the following disk partions for setting up btrfs file system with @, @home, @snapshots, @var_log subvolume'
    read partionsDisk
    echo $partionsDisk > $dirds/partionsDisk.txt

    mkfs.btrfs /dev/$partionsDisk

    sleep

    mount /dev/$partionsDisk /mnt

    sleep

    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@@snapshots
    btrfs su cr /mnt/@@var_log

    sleep

    umount /mnt

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$partionsDisk /mnt
    mkdir -p /mnt/{home,.snapshots,/var/log}
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$partionsDisk /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$partionsDisk /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$partionsDisk /mnt/var/log

    lsblk

elif [ $ans = "2" ]; then

    var1/dependencyScript/configer_mbr_partion_and_btrfs_subvol.sh

elif [ $ans = "3" ]; then

    var1/dependencyScript/configer_mbr_partion_and_btrfs_subvol.sh

fi