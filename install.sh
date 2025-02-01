#!/bin/sh

if [ $(id -u) -ne 0 ]; then
        echo "Only root can do this"
        exit 1
fi

dirm="$PWD"

# asking username
echo "Type the username for this system::"
read usname
echo $usname > $dirm/usname.txt

# asking hostname
echo "Type the hostname for this system:"
read hname
echo $hname > $dirm/hname.txt

# asking debian os release to installed
echo 'Choose the following debian os release you want to install'
echo '1) bookworm (curent stable)'
echo '2) trixie (current testing)'
echo '3) testing' 
echo '4) sid'

echo 'type the name (default it will choose 'bookworm'):'
read nrelease

# If the input is empty, use the default value "John"
if [ -z "$nrelease" ]; then
    nrelease="bookworm"
fi
echo $nrelease > $dirm/nrelease.txt

#uefi="$(cat /sys/firmware/efi/fw_platform_size 2> /dev/null)"

if [ -d /sys/firmware/efi ]; then
    $dirm/dependencyScript/configer_uefi_partion_and_btrfs_subvol.sh
else
    $dirm/dependencyScript/configer_mbr_partion_and_btrfs_subvol.sh
fi

apt install vim debootstrap arch-install-scripts -y

debootstrap $nrelease /mnt

$dirm/dependencyScript/setup_sourceList.sh

#mount sudo folder for chroot system
mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc

genfstab -U /mnt >> /mnt/etc/fstab