#!/usr/bin/env bash

##  This is the simplest possible Arch Linux install script I think...
HOSTNAME="marbie1"
VIDEO_DRIVER="xf86-video-vmware"
IN_DEVICE=/dev/sda

BOOT_SIZE=512M
SWAP_SIZE=2G
ROOT_SIZE=13G
HOME_SIZE=    # Take whatever is left over after other partitions
TIME_ZONE="America/New_York"
LOCALE="en_US.UTF-8"
FILESYSTEM=ext4


BASE_SYSTEM=( base base-devel linux linux-headers linux-firmware dkms vim iwd )

devel_stuff=( git nodejs npm npm-check-updates ruby )
printing_stuff=( system-config-printer foomatic-db foomatic-db-engine gutenprint cups cups-pdf cups-filters cups-pk-helper ghostscript gsfonts )
multimedia_stuff=( brasero sox cheese eog shotwell imagemagick sox cmus mpg123 alsa-utils cheese )
