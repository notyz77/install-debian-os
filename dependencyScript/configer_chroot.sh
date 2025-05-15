#!/bin/sh

dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"
usname="$(cat $dirm/usname.txt)"
usPass="$(cat $dirm/usPass.txt)"
rootPass="$(cat $dirm/rootPass.txt)"
grubDisk="$(cat $dirm/grubDisk.txt)"

chroot /mnt apt install btrfs-progs locales -y

chroot /mnt dpkg-reconfigure locales

chroot /mnt dpkg-reconfigure tzdata

chroot /mnt apt install linux-image-amd64 sudo keyboard-configuration man-db dhcpcd5 vim git -y

clear

#echo "Type the root password for the new system:"
#chroot /mnt passwd

#echo "Type the password for $usname for new system:"
#chroot /mnt passwd $usname

echo "root:$rootPass" | chroot /mnt chpasswd
echo "$usname:$usPass" | chroot /mnt chpasswd

chroot /mnt useradd -mG sudo $usname

chroot /mnt usermod -s /bin/bash $usname

if [ -d /sys/firmware/efi ]; then
    
    chroot /mnt apt install grub-efi-amd64 -y
    chroot /mnt grub-install /dev/$grubDisk
    chroot /mnt update-grub
    chroot /mnt update-grub2

else
    
    chroot /mnt apt install grub-pc -y
    chroot /mnt grub-install /dev/$grubDisk
    chroot /mnt update-grub
    chroot /mnt update-grub2

fi

chroot /mnt systemctl enable dhcpcd