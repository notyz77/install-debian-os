#!/bin/sh

dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"
usname="$(cat $dirm/usname.txt)"

chroot /mnt apt install btrfs-progs locales -y

chroot /mnt dpkg-reconfigure locales

chroot /mnt dpkg-reconfigure tzdata

chroot /mnt apt install linux-image-amd64 sudo ntp dhcpcd5 vim -y

clear

echo "Type the root password for this system:"
chroot /mnt passwd

chroot /mnt chroot /mnt useradd -mG sudo $usname
echo "Type the password for $usname for this system:"
chroot /mnt passwd $usname
