#!/bin/sh

dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"
usname="$(cat $dirm/usname.txt)"
usPass="$(cat $dirm/usPass.txt)"
rootPass="$(cat $dirm/rootPass.txt)"
grubDisk="$(cat $dirm/grubDisk.txt)"

chroot /mnt apt install btrfs-progs locales -y

# Copy locale files from live environment and Setting up locale
cp /etc/locale.gen /mnt/etc/locale.gen
cp /etc/default/locale /mnt/etc/default/locale

chroot /mnt locale-gen
chroot /mnt update-locale

# Read timezone name
TZ="$(cat /etc/timezone)"

# Copy /etc/timezone
echo "$TZ" | tee /mnt/etc/timezone

# Set symlink in chroot required for timezone
ln -sf "/usr/share/zoneinfo/$TZ" /mnt/etc/localtime

# Copy keyboard-configuration files from live environment
cp /etc/default/keyboard /mnt/etc/default/keyboard
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

# Copy config for console-setup
cp $dirm/dependencyScript/console-setup /mnt/etc/default/console-setup

# Preseed values for console-setup
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

if [ -d /sys/firmware/efi ] && [ -f "$dirm/efistub" ]; then
    
    chroot /mnt apt install initramfs-tools efibootmgr -y
    cp $dirm/testing/efiStub/zz-update-efi-with-fallback-kernel /mnt/etc/kernel/postinst.d/
    chmod +x /mnt/etc/kernel/postinst.d/zz-update-efi-with-fallback-kernel

    mkdir -p /mnt/boot/efi/EFI/debian
    cp /mnt/boot/vmlinuz-*-amd64 /mnt/boot/efi/EFI/debian/vmlinuz.efi
    cp /mnt/boot/initrd.img-*-amd64 /mnt/boot/efi/EFI/debian/initrd.img

    chroot export UUDisk=$(mount | awk '/\/ type btrfs/ {print $1}')
    echo $UUDisk > $dirm/UUDisk.txt
    chroot export UUID=$(blkid -s UUID -o value $UUDisk)
    echo $UUID > $dirm/UUID.txt

    chroot efibootmgr --create --disk /dev/$grubDisk --part 1 --label "Debian EFI Stub Old" --loader '\EFI\debian\vmlinuzOld.efi' --unicode 'root=UUID=$UUID ro rootflags=subvol=@ initrd=\EFI\debian\initrdOld.img'

    chroot efibootmgr --create --disk /dev/$grubDisk --part 1 --label "Debian EFI Stub" --loader '\EFI\debian\vmlinuz.efi' --unicode 'root=UUID=$UUID ro rootflags=subvol=@ initrd=\EFI\debian\initrd.img'

    echo efiStub setup is completed

elif [ -d /sys/firmware/efi ]; then
    
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