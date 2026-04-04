#!/bin/sh

dirm="$PWD"

cp $dirm/usname.txt $dirm/cable.txt $dirm/wifi.txt /mnt/tmp/

git clone https://gitlab.com/ap3209/dwm_debian_apos.git /mnt/tmp/dwm_debian_apos

chroot /mnt /bin/bash -c "cd /tmp/dwm_debian_apos && ./install.sh"
