#!/bin/sh

dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"
usname="$(cat $dirm/usname.txt)"
usPass="$(cat $dirm/usPass.txt)"
rootPass="$(cat $dirm/rootPass.txt)"
grubDisk="$(cat $dirm/grubDisk.txt)"

chroot /mnt apt install btrfs-progs locales -y

#chroot /mnt dpkg-reconfigure locales

#chroot /mnt dpkg-reconfigure tzdata

# Copy locale files from live environment and Setting up locale
cp /etc/locale.gen /mnt/etc/locale.gen
cp /etc/default/locale /mnt/etc/default/locale

chroot /mnt locale-gen
chroot /mnt update-locale

# Copy timezone files from live environment and Setting up timezone 
#cp /etc/timezone /mnt/etc/timezone
#cp /etc/localtime /mnt/etc/localtime

#chroot /mnt dpkg-reconfigure -f noninteractive tzdata

# Read timezone name
TZ="$(cat /etc/timezone)"

# Copy /etc/timezone
echo "$TZ" | tee /mnt/etc/timezone

# Set symlink in chroot
ln -sf "/usr/share/zoneinfo/$TZ" /mnt/etc/localtime

# Copy keyboard-configuration files from live environment
cp /etc/default/keyboard /mnt/etc/default/keyboard
cp -r /etc/console-setup /mnt/etc/

chroot /mnt apt install linux-image-amd64 sudo keyboard-configuration console-setup man-db dhcpcd5 vim git -y

clear

#echo "Type the root password for the new system:"
#chroot /mnt passwd

#echo "Type the password for $usname for new system:"
#chroot /mnt passwd $usname

chroot /mnt useradd -mG sudo $usname

chroot /mnt usermod -s /bin/bash $usname

echo "root:$rootPass" | chroot /mnt chpasswd
echo "$usname:$usPass" | chroot /mnt chpasswd

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