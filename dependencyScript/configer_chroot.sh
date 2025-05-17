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
#cp -r /etc/console-setup /mnt/etc/
cp -r /etc/console-setup /mnt/etc/console-setup

# Extract layout and model from live system
layout=$(grep XKBLAYOUT /etc/default/keyboard | cut -d'"' -f2)
model=$(grep XKBMODEL /etc/default/keyboard | cut -d'"' -f2)

# Fallbacks if empty
layout=${layout:-us}
model=${model:-pc105}

# Preseed debconf values into chroot environment
chroot /mnt /bin/bash -c "echo 'keyboard-configuration keyboard-configuration/layoutcode string $layout' | debconf-set-selections"
chroot /mnt /bin/bash -c "echo 'keyboard-configuration keyboard-configuration/modelcode string $model' | debconf-set-selections"

# Copy config
cp $dirm/dependencyScript/console-setup /mnt/etc/default/console-setup

# Preseed values
chroot /mnt /bin/bash -c "echo 'console-setup console-setup/codeset select Lat15' | debconf-set-selections"
chroot /mnt /bin/bash -c "echo 'console-setup console-setup/charmap select UTF-8' | debconf-set-selections"
chroot /mnt /bin/bash -c "echo 'console-setup console-setup/fontface select Fixed' | debconf-set-selections"
chroot /mnt /bin/bash -c "echo 'console-setup console-setup/fontsizex select 8' | debconf-set-selections"
chroot /mnt /bin/bash -c "echo 'console-setup console-setup/fontsizey select 16' | debconf-set-selections"

# Install without interactive prompts
DEBIAN_FRONTEND=noninteractive chroot /mnt apt-get install -y keyboard-configuration console-setup

chroot /mnt apt install linux-image-amd64 sudo man-db dhcpcd5 vim git -y

clear

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