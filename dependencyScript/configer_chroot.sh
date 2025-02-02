#!/bin/sh

dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"
usname="$(cat $dirm/usname.txt)"
grubDisk="$(cat $dirm/grubDisk.txt)"

chroot /mnt apt install btrfs-progs locales -y

chroot /mnt dpkg-reconfigure locales

chroot /mnt dpkg-reconfigure tzdata

chroot /mnt apt install linux-image-amd64 sudo ntp dhcpcd5 vim -y

clear

echo "Type the root password for this system:"
chroot /mnt passwd

chroot /mnt useradd -mG sudo $usname
echo "Type the password for $usname for this system:"
chroot /mnt passwd $usname

if [ -d /sys/firmware/efi ]; then
    
    chroot /mnt apt install grub-efi-amd64
    chroot /mnt grub-install /dev/$grubDisk
    chroot /mnt update-grub
    chroot /mnt update-grub2

else
    
    chroot /mnt apt install grub-pc
    chroot /mnt grub-install /dev/$grubDisk
    chroot /mnt update-grub
    chroot /mnt update-grub2

fi

chroot /mnt systemctl enable dhcpcd