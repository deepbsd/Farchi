#!/usr/bin/env bash

# Run this script after system and desktop are already installed

# Make sure systemd-homed is working, or else sudo will not work

systemctl status systemd-homed

[[ "$?" -eq 0 ]] && echo "Be sure to start and enable systemd-homed (as root) or else sudo will not work properly"

echo "Also, reinstall pambase if necessary `pacman -S pambase`"

## PERSONAL DIRECTORIES AND RESOURCES
echo "Making personal subdirectories..."
mkdir tmp repos build 
echo "Download home directory files from what host on network?"; read whathost
scp -o StrictHostKeyChecking=no -r dsj@"$whathost".lan:{adm,dotfiles,.vim,public_html,sounds,.gkrellm2,wallpaper,wallpaper1,bin,.ssh,.gnupg,Music} .

## SYNC PACMAN DBs
sudo pacman -Syy

## INSTALL DVD SUPPORT, GKRELLM, MLOCATE
sudo pacman -S libdvdread libdvdcss libdvdnav gkrellm mlocate fzf

## CHECK FOR OLD FAITHFULS
$(which gkrellm) || sudo pacman -S gkrellm
[[ -f /opt/anaconda/bin/anaconda-navigator ]] || yay -S anaconda

## INSTALL POWERLINE AND DEV STUFF 
sudo pacman -S  ruby nodejs npm npm-check-updates gvim mlocate gkrellm

## DOTFILES
cp ~/.bashrc ~/.bashrc.orig
cp ~/.bash_profile ~/.bash_profile.orig
ln -sf ~/dotfiles/.bashrc .
ln -sf ~/dotfiles/.bash_profile .
ln -sf ~/dotfiles/.vimrc .

# NVM
mkdir $HOME/.nvm
[[ -x $(which git &>/dev/null) ]] && cd && git clone https://github.com/nvm-sh/nvm.git .nvm/.
[[ -d $HOME/.nvm ]] && cd ~/.nvm && source nvm.sh && cd

## INSTALL YAY  ## Do this last because of intermittant errors with yay-git
echo "Installing yay: "
cd ~/build
git clone https://aur.archlinux.org/yay-git.git
cd yay-git
makepkg -si
cd

##  Start using paru...
yay -S paru

## REPLACE GNOME_TERMINAL WITH TRANSPARENCY VERSION (and mate-terminal)
yay -S gnome-terminal-transparency mate-terminal 

## INSTALL CHROME and ORANCHELO ICONS AND BREEZE CURSOR
yay -S google-chrome oranchelo-icon-theme-git xcursor-breeze





