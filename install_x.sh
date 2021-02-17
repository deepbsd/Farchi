#!/usr/bin/env bash

## Use this script if you've not installed X et al previously.

install_x(){ return 0; }     # return 0 if you want to install X

############################################
###########     VARIABLES      #############
############################################

VIDEO_DRIVER="xf86-video-vmware"
DESKTOP=('cinnamon' 'nemo-fileroller' 'lightdm-gtk-greeter')
declare -A DISPLAY_MGR=( [dm]='lightdm' [service]='lightdm.service' )

## These are packages required for a working Xorg desktop (My preferences anyway)
BASIC_X=( xorg-server xorg-xinit mesa xorg-twm xterm gnome-terminal xfce4-terminal xorg-xclock "${DESKTOP[@]}" "${DISPLAY_MGR[dm]}" firefox )

## These are your specific choices for fonts and wallpapers and X-related goodies
EXTRA_X=( adobe-source-code-pro-fonts cantarell-fonts gnu-free-fonts noto-fonts breeze-gtk breeze-icons gtk-engine-murrine oxygen-icons xcursor-themes adapta-gtk-theme )

EXTRA_X1=( arc-gtk-theme elementary-icon-theme faenza-icon-theme gnome-icon-theme-extras arc-icon-theme lightdm-gtk-greeter-settings lightdm-webkit-theme-litarvan  )

EXTRA_X2=( mate-icon-theme materia-gtk-theme papirus-icon-theme xcursor-bluecurve xcursor-premium archlinux-wallpaper deepin-community-wallpapers deepin-wallpapers elementary-wallpapers )

EXTRA_DESKTOPS=( mate mate-extra xfce4 xfce4-goodies i3-gaps i3status i3blocks nitrogen feh rofi dmenu terminator ttf-font-awesome ttf-ionicons )

GOODIES=( htop mlocate neofetch screenfetch powerline powerline-fonts powerline-vim archlinux-wallpaper )

## -----------  Some of these are included, but it's all up to you...
xfce_desktop=( xfce4 xfce4-goodies )

mate_desktop=( mate mate-extra )

i3gaps_desktop=( i3-gaps dmenu feh rofi i3status i3blocks nitrogen i3status ttf-font-awesome ttf-ionicons )

## Python3 should be installed by default
#devel_stuff=( git nodejs npm npm-check-updates ruby )

printing_stuff=( system-config-printer foomatic-db foomatic-db-engine gutenprint cups cups-pdf cups-filters cups-pk-helper ghostscript gsfonts )

multimedia_stuff=( brasero sox cheese eog shotwell imagemagick sox cmus mpg123 alsa-utils cheese )

##########################################
######       FUNCTIONS       #############
##########################################
 
# All purpose error
error(){ echo "Error: $1" && exit 1; }

# FIND GRAPHICS CARD
find_card(){
    card=$(lspci | grep VGA | sed 's/^.*: //g')
    echo "You're using a $card" && echo
}

## UPDATE REPO DATABASE
pacman -Syy

## INSTALL X AND DESKTOP  
if $(install_x); then
    clear && echo "Installing X and X Extras and Video Driver. Type any key to continue"; read empty
    pacman -S "${BASIC_X[@]}"
    pacman -S "${EXTRA_X[@]}"
    pacman -S "${EXTRA_X1[@]}"
    pacman -S "${EXTRA_X2[@]}"
    your_card=$(find_card)
    echo "${your_card} and you're installing the $VIDEO_DRIVER driver... (Type key to continue) "; read blah
    pacman -S "$VIDEO_DRIVER"
    pacman -S "${EXTRA_DESKTOPS[@]}"
    pacman -S "${GOODIES[@]}"

    echo "Enabling display manager service..."
    systemctl enable ${DISPLAY_MGR[service]}
    echo && echo "Your desktop and display manager should now be installed..."
    sleep 5
fi
