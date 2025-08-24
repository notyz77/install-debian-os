#!/bin/sh

dirm="$PWD"
nrelease="$(cat $dirm/nrelease.txt)"

if [ $nrelease = "sid" ]; then
    
    mv /mnt/etc/apt/sources.list /mnt/etc/apt/sources.list.bak
    cat > /mnt/etc/apt/sources.list << EOF
# Debian Sid (Unstable) - Binary and Source Repositories
deb http://deb.debian.org/debian sid main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian sid main contrib non-free non-free-firmware

# Unstable Debug Packages
deb http://deb.debian.org/debian-debug sid-debug main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian-debug sid-debug main contrib non-free non-free-firmware
EOF

elif [ $nrelease = "testing" ]; then
    
    mv /mnt/etc/apt/sources.list /mnt/etc/apt/sources.list.bak
    cat > /mnt/etc/apt/sources.list << EOF
deb http://deb.debian.org/debian testing main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security testing-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security testing-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian testing-backports main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian testing-backports main contrib non-free non-free-firmware
EOF

else
    
    mv /mnt/etc/apt/sources.list /mnt/etc/apt/sources.list.bak
    cat > /mnt/etc/apt/sources.list << EOF
deb http://deb.debian.org/debian $nrelease main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian $nrelease main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security $nrelease-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security $nrelease-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian $nrelease-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian $nrelease-updates main contrib non-free non-free-firmware

deb http://deb.debian.org/debian $nrelease-backports main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian $nrelease-backports main contrib non-free non-free-firmware
EOF

fi