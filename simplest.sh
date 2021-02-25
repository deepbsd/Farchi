#!/usr/bin/env bash

##  This is the simplest possible Arch Linux install script I think...
HOSTNAME="marbie1"
#VIDEO_DRIVER="xf86-video-vmware"
IN_DEVICE=/dev/sda
BOOT_DEVICE="${IN_DEVICE}1"
ROOT_DEVICE="${IN_DEVICE}2"
SWAP_DEVICE="${IN_DEVICE}3"
HOME_DEVICE="${IN_DEVICE}4"

BOOT_SIZE=512M
SWAP_SIZE=2G
ROOT_SIZE=13G
HOME_SIZE=    # Take whatever is left over after other partitions
TIME_ZONE="America/New_York"
LOCALE="en_US.UTF-8"
#KEYBOARD="us"    # change if you need to
FILESYSTEM=ext4

use_bcm4360(){ return 1; }  # return 0 for "truthy" and 1 for "falsy"

if $(use_bcm4360) ; then
    WIRELESSDRIVERS="broadcom-wl-dkms"
else
    WIRELESSDRIVERS=""
fi

BASE_SYSTEM=( base base-devel linux linux-headers linux-firmware dkms vim iwd )

devel_stuff=( git nodejs npm npm-check-updates ruby )
printing_stuff=( system-config-printer foomatic-db foomatic-db-engine gutenprint cups cups-pdf cups-filters cups-pk-helper ghostscript gsfonts )
multimedia_stuff=( brasero sox eog shotwell imagemagick sox cmus mpg123 alsa-utils cheese )

# VERIFY BOOT MODE
efi_boot_mode(){
    [[ -d /sys/firmware/efi/efivars ]] && return 0
    return 1
}

# All purpose error
error(){ echo "Error: $1" && exit 1; }

###############################
###  START SCRIPT HERE
###############################

### Check of reflector is done
clear
echo "Waiting until reflector has finished updating mirrorlist..."
while true; do
    pgrep -x reflector &>/dev/null || break
    echo -n '.'
    sleep 2
done

### Test internet connection
clear
echo "Testing internet connection..."
$(ping -c 3 archlinux.org &>/dev/null) || (echo "Not Connected to Network!!!" && exit 1)
echo "Good!  We're connected!!!" && sleep 3

## Check time and date before installation
timedatectl set-ntp true
echo && echo "Date/Time service Status is . . . "
timedatectl status
sleep 4

$(efi_boot_mode) && error "You have a UEFI Bios; Please use the Farchi or Darchi script for installation"

####  Could just use cfdisk to partition drive
#cfdisk "$IN_DEVICE"    # for non-EFI VM: /boot 512M; / 13G; Swap 2G; Home Remainder

###  NOTE: Drive partitioning is one of those highly customizable areas where your
###        personal preferences and needs will dictate your choices.  Many options
###        exist here.  An MBR disklabel is very old, limited, and may well inspire
###        you to investigate other options, which is a good exercise.  But, MBR is pretty
###        simple and reliable, within its constraints.  Bon voyage!



# Using sfdisk because we're talking MBR disktable now...
cat > /tmp/sfdisk.cmd << EOF
$BOOT_DEVICE : start= 2048, size=+$BOOT_SIZE, type=83, bootable
$ROOT_DEVICE : size=+$ROOT_SIZE, type=83
$SWAP_DEVICE : size=+$SWAP_SIZE, type=82
$HOME_DEVICE : type=83
EOF

sfdisk "$IN_DEVICE" < /tmp/sfdisk.cmd 

#####  Format filesystems
mkfs.ext4 "$BOOT_DEVICE"    # /boot
mkfs.ext4 "$ROOT_DEVICE"    # /
mkswap "$SWAP_DEVICE"       # swap partition
mkfs.ext4 "$HOME_DEVICE"    # /home

#### Mount filesystems
mount "$ROOT_DEVICE" /mnt
mkdir /mnt/boot && mount "$BOOT_DEVICE" /mnt/boot
swapon "$SWAP_DEVICE"
mkdir /mnt/home && mount "$HOME_DEVICE" /mnt/home

lsblk && echo "Here're your new block devices. (Type any key to continue...)" ; read empty


###  Install base system
clear
echo && echo "Press any key to continue to install BASE SYSTEM..."; read empty
pacstrap /mnt "${BASE_SYSTEM[@]}"
echo && echo "Base system installed.  Press any key to continue..."; read empty

# GENERATE FSTAB
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
echo && echo "Here's your fstab. Type any key to continue..."; read empty

## SET UP TIMEZONE AND LOCALE
clear
echo && echo "setting timezone to $TIME_ZONE..."
arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime
arch-chroot /mnt hwclock --systohc --utc
arch-chroot /mnt date
echo && echo "Here's the date info, hit any key to continue..."; read empty

## SET UP LOCALE
clear
echo && echo "setting locale to $LOCALE ..."
arch-chroot /mnt sed -i "s/#$LOCALE/$LOCALE/g" /etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=$LOCALE" > /mnt/etc/locale.conf
export LANG="$LOCALE"
cat /mnt/etc/locale.conf
echo && echo "Here's your /mnt/etc/locale.conf. Type any key to continue."; read empty

## HOSTNAME
clear
echo && echo "Setting hostname..."; sleep 3
echo "$HOSTNAME" > /mnt/etc/hostname

cat > /mnt/etc/hosts <<HOSTS
127.0.0.1      localhost
::1            localhost
127.0.1.1      $HOSTNAME.localdomain     $HOSTNAME
HOSTS

echo && echo "/etc/hostname and /etc/hosts files configured..."
echo "/etc/hostname . . . "
cat /mnt/etc/hostname 
echo "/etc/hosts . . ."
cat /mnt/etc/hosts
echo && echo "Here are /etc/hostname and /etc/hosts. Type any key to continue "; read empty

## SET ROOT PASSWD
clear
echo "Setting ROOT password..."
arch-chroot /mnt passwd

## INSTALLING MORE ESSENTIALS
clear
echo && echo "Enabling dhcpcd, pambase, sshd and NetworkManager services..." && echo
arch-chroot /mnt pacman -S git openssh networkmanager dhcpcd man-db man-pages pambase
arch-chroot /mnt systemctl enable dhcpcd.service
arch-chroot /mnt systemctl enable sshd.service
arch-chroot /mnt systemctl enable NetworkManager.service
arch-chroot /mnt systemctl enable systemd-homed
echo && echo "Press any key to continue..."; read empty

## ADD USER ACCT
clear
echo && echo "Adding sudo + user acct..."
sleep 2
arch-chroot /mnt pacman -S sudo bash-completion sshpass
arch-chroot /mnt sed -i 's/# %wheel/%wheel/g' /etc/sudoers
arch-chroot /mnt sed -i 's/%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/g' /etc/sudoers
echo && echo "Please provide a username: "; read sudo_user
echo && echo "Creating $sudo_user and adding $sudo_user to sudoers..."
arch-chroot /mnt useradd -m -G wheel "$sudo_user"
echo && echo "Password for $sudo_user?"
arch-chroot /mnt passwd "$sudo_user"

## INSTALL WIFI
$(use_bcm4360) && arch-chroot /mnt pacman -S "$WIRELESSDRIVERS"
[[ "$?" -eq 0 ]] && echo "Wifi Driver successfully installed!"; sleep 5

## Not installing X in this script...

## INSTALL GRUB
clear
echo "Installing grub..." && sleep 4
arch-chroot /mnt pacman -S grub os-prober

## We're not checking for EFI; We're assuming MBR
arch-chroot /mnt grub-install "$IN_DEVICE"

echo "configuring /boot/grub/grub.cfg..."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
[[ "$?" -eq 0 ]] && echo "mbr bootloader installed..."

echo "Your system is installed.  Type shutdown -h now to shutdown system and remove bootable media, then restart"
read empty
