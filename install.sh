#!/bin/sh

set -e

if [ $(id -u) -ne 0 ]; then
        echo "Only root can do this"
        exit 1
fi

dirm="$PWD"

# ---- Handle optional arguments ----
if [ "$#" -gt 0 ]; then
    echo "Extra options detected:"
    for opt in "$@"; do
        case "$opt" in
            efistub)
                echo "Use efiStub boot"
                touch "$dirm/efistub"
                ;;
            noefi)
                echo "UEFI install with No EFI Partions as use other bootloader"
                touch "$dirm/noefi"
                ;;
            doas)
                echo "replace sudo with doas"
                touch "$dirm/doas"
                ;;
            *)
                echo "Unknown option: $opt"
                exit 1
                ;;
        esac
    done
fi

# asking username
echo "Type the username for the new system:"
read usname
echo $usname > $dirm/usname.txt

echo "Type the password for $usname for new system:"
read usPass
echo $usPass > $dirm/usPass.txt

echo "Type the root password for the new system:"
read rootPass
echo $rootPass > $dirm/rootPass.txt

# asking hostname
echo "Type the hostname for this system:"
read hname
echo $hname > $dirm/hname.txt

# setting up keyboard-configuration
dpkg-reconfigure keyboard-configuration

# Setting up timezone
dpkg-reconfigure tzdata

# Setting up locale
dpkg-reconfigure locales
. /etc/default/locale

# asking debian os release to installed
echo 'Choose the following debian os release you want to install'
echo '1) bookworm'
echo '2) trixie (current stable)'
echo '3) forky (current testing)'
echo '4) testing' 
echo '5) sid'

echo 'type the name (default it will choose 'trixie'):'
read nrelease

# If the input is empty, use the default value "John"
if [ -z "$nrelease" ]; then
    nrelease="trixie"
fi
echo $nrelease > $dirm/nrelease.txt

#uefi="$(cat /sys/firmware/efi/fw_platform_size 2> /dev/null)"

if [ -d /sys/firmware/efi ]; then
    $dirm/dependencyScript/configer_uefi_partion_and_btrfs_subvol.sh
else
    $dirm/dependencyScript/configer_mbr_partion_and_btrfs_subvol.sh
fi

apt install vim debootstrap arch-install-scripts -y

# Installing base system according to debian selected release
debootstrap $nrelease /mnt

# running script to setup sources.list according to debian selected release
$dirm/dependencyScript/setup_sourceList.sh

# mount sudo folder for chroot system
mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc

# generate fstab for new system
genfstab -U /mnt >> /mnt/etc/fstab

# configer hostname for previously set veriable
echo $hname > /mnt/etc/hostname

# Add hostname in /etc/hosts file
sed -i -e "1a127.0.1.1       $hname" /mnt/etc/hosts
sed -i '2a\\' /mnt/etc/hosts

$dirm/dependencyScript/configer_chroot.sh