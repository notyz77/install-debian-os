#!/bin/sh

dirm="$PWD"
idskn1=1
# idskn2=2
apt install fdisk util-linux gdisk -y
clear
echo "This live ISO boot with UEFI mode"
echo "Need to use GPT partition layout,by default this script first check if fdisk is install, if not it will install"
echo "If you use noefi option mean EFI partion already created in same disk or different disk with other bootloader, like rEFInd or OpenCore"
#read -n 1 -s -r -p "Press any key to continue"
# asking debian os release to installed
echo 'Choose the following options to setting up disk for debian installer'
echo '1) open fdisk to create partions'
echo '2) choose this options if already setup that disk with gpt with one partions for root file system'
echo '3) choose this options if you have two disk and want to used one entire disk as root file system & other disk contain efi partion with other bootloader, it will format disk automatically create root file system & btrfs subvolume for it'

echo 'select number:'
read ndisk

if [ $ndisk = "1" ]; then
 
    lsblk -f
    echo '\nChoose the following disk to edit with fdisk'
    read pcdisk
    echo $pcdisk > $dirm/pcdisk.txt

    fdisk /dev/$pcdisk

    # lsblk -f
    # echo '\nChoose the following disk partions for EFI'
    # read efiPartionsDisk
    # echo $efiPartionsDisk > $dirm/efiPartionsDisk.txt

    lsblk -f
    echo '\nChoose the following disk partions for setting up btrfs file system with @, @home, @snapshots, @var_log subvolume'
    read partionsDisk
    echo $partionsDisk > $dirm/partionsDisk.txt

    # lsblk -f
    # echo '\nChoose the following disk for grub bootloader'
    # read grubDisk

    # # If the input is empty, use the default value "John"
    #     if [ -z "$grubDisk" ]; then
    #         grubDisk="$pcdisk"
    #     fi
    # echo $grubDisk > $dirm/grubDisk.txt

    # mkfs.vfat /dev/$efiPartionsDisk

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
    # mkdir -p /mnt/boot/efi
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$partionsDisk /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$partionsDisk /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$partionsDisk /mnt/var/log
    # mount /dev/$efiPartionsDisk /mnt/boot/efi

    lsblk

elif [ $ndisk = "2" ]; then

    # lsblk -f
    # echo '\nChoose the following disk partions for EFI'
    # read efiPartionsDisk
    # echo $efiPartionsDisk > $dirm/efiPartionsDisk.txt

    lsblk -f
    echo '\nChoose the following disk partions for setting up btrfs file system with @, @home, @snapshots, @var_log subvolume'
    read partionsDisk
    echo $partionsDisk > $dirm/partionsDisk.txt

    # lsblk -f
    # echo '\nChoose the following disk for grub bootloader'
    # read grubDisk
    # echo $grubDisk > $dirm/grubDisk.txt

    # mkfs.vfat /dev/$efiPartionsDisk

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
    # mkdir -p /mnt/boot/efi
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$partionsDisk /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$partionsDisk /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$partionsDisk /mnt/var/log
    # mount /dev/$efiPartionsDisk /mnt/boot/efi

    lsblk

elif [ $ndisk = "3" ]; then

    lsblk -f
    echo '\nChoose the following disk so script can setup gpt for setting up btrfs file system with @, @home, @snapshots, @var_log subvolume'
    read pcdisk
    echo $pcdisk > $dirm/pcdisk.txt

    # lsblk -f
    # echo '\nChoose the following disk for grub bootloader'
    # read grubDisk

    # # If the input is empty, use the default value "John"
    #     if [ -z "$grubDisk" ]; then
    #         grubDisk="$pcdisk"
    #     fi
    # echo $grubDisk > $dirm/grubDisk.txt

    # Wipe existing signatures (disk + any partitions)
    wipefs -a /dev/$pcdisk
    for part in /dev/${pcdisk}?*; do
        [ -b "$part" ] && wipefs -a "$part"
    done

    # Zap all GPT/MBR partition tables and filesystem signatures
    sgdisk --zap-all /dev/$pcdisk

    # Clear beginning of the disk
    #dd if=/dev/zero of=/dev/$pcdisk bs=512 count=2048 status=none
    #dd if=/dev/zero of=/dev/$pcdisk bs=1M seek=$(( $(blockdev --getsz /dev/$pcdisk) / 2048 - 1 )) count=1 status=none

    # Create GPT partitions:
    # - 1: EFI, 512M, type EF00
    # - 2: root, rest of disk, type 8300
    # sgdisk -n 1:2048:+512M -t 1:EF00 -c 1:"EFI System Partition" /dev/$pcdisk
    sgdisk -n 1:0:0       -t 1:8300 -c 1:"Linux Root" /dev/$pcdisk

    # Let kernel refresh partition table
    partprobe /dev/$pcdisk
    udevadm settle
    sleep 1

    # mkfs.vfat /dev/$pcdisk$idskn1

    mkfs.btrfs -f /dev/$pcdisk$idskn1

    mount /dev/$pcdisk$idskn1 /mnt

    btrfs su cr /mnt/@
    btrfs su cr /mnt/@home
    btrfs su cr /mnt/@snapshots
    btrfs su cr /mnt/@var_log

    umount /mnt

    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@ /dev/$pcdisk$idskn1 /mnt
    mkdir -p /mnt/home
    mkdir -p /mnt/.snapshots
    mkdir -p /mnt/var/log
    # mkdir -p /mnt/boot/efi
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@home /dev/$pcdisk$idskn1 /mnt/home
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@snapshots /dev/$pcdisk$idskn1 /mnt/.snapshots
    mount -o ssd,compress=zstd:3,space_cache=v2,discard=async,noatime,subvol=@var_log /dev/$pcdisk$idskn1 /mnt/var/log
    # mount /dev/$pcdisk$idskn1 /mnt/boot/efi

    lsblk

fi