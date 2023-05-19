# FARCHI    Fast Arch Linux Installer

This started as just a personal script, very very simple way to install 
Arch Linux after booting the archiso ISO image.  

## Installation

You can download the script to your booted archiso image like this:

`curl -O https://raw.githubusercontent.com/deepbsd/farchi/master/farchi.sh`

If you open the farchi script and start filling in the
variables carefully, you'll be ready to install Arch linux!
Good luck!

You'll need to customize settings for your installation.

## Here's What You'll Want to Change:

1. `HOSTNAME=effie1`  Your hostname

2. `IN_DEVICE=/dev/sda`  Your installation drive

3. Partitions and sizes.  `EFI_SIZE=512M` or `BOOT_SIZE=512M` (depending on whether
   you have an EFI or Bios system)  `SWAP_SIZE=4G` `ROOT_SIZE=12G` `HOME_SIZE=` 
   If you're installing to a VM, these sizes should work.  However if you're installing
   to actual hardware, these sizes may vary dramatically.  Currently, the HOME partition
   or LV (logical volume) will occupy whatever space is left over after the ROOT and SWAP 
   and EFI/BOOT partitions are created.  On regular hardware, I like 100G for root.  Many
   people enjoy smaller 50-75G partitions however.  If you hibernate your system, a good
   rule of thumb is 2xRAM size for SWAP.

4. `use_lvm(){ return 0; }`  `use_crypt(){ return 0; }`  Return 0 for yes, 1 for no.  Whether you want
   LVM or not.  I prefer LVM and LUKS (encrypted filesystem) since I'm just used to it.

5. `use_bcm4360(){ return 0; }`  Return 0 for yes, 1 for no.  Whether you want BCM4360 Wifi Drivers or
   not (or some other drivers of your choosing). This is a chipset I often use in my PCI wifi devices.
   It's a good one.  But you should install the driver for your wifi device.  The `wl` driver is used for
   this and many other recent Broadcom wifi chipsets.

6. `install_x(){ return 0; }`  Return 0 for yes, 1 for no.  Do you want to install X11 or not (faster if
   you don't, but you'll probably want to install it anyway).  If you're just experimenting in a VM and
   testing your script, perhaps you just want to install a bare bones installation to test with.

7. `VIDEO_DRIVER=xf86-video-vmware`  `install_x(){ return 0; }`  You must be installing X (or else why
   would you care about a accelerated video driver?)  This is your Video chipset driver to run X11.
   This will be one of the _xf86-video-*_ drivers for different video chipsets, such as Radeon, Nvidia,
   Intel, and so forth. I install xf86-video-vmware by default.
   `declare -A DISPLAY_MGR=( [dm]='lightdm' [service]='lightdm.service' )` This line sets your display
   manager.  This is an associative array in BASH, because the service name can often be different
   from the file name in the Arch repo.  So the display manager contained in `${DISPLAY_MGR[dm]}` while
   the service name is contained in `${DISPLAY_MGR[service]}`

8. `DESKTOP=(cinnamon nemo-fileroller)`  Your choice.  Many options are available.  What desktop
   environment to you want (or what Window Manager)? I chose lightdm for display manager and Cinnamon for
   desktop environment by default.  XFCE and Mate and i3gaps are also some favorites of mine and are
   ready to be installed also.  Feel free to alter your choices in `EXTRA_X` and the other arrays as
   you see fit.

9. Your `LOCALE` and `TIME_ZONE`:  `en_US-UTF-8` and `America/New York` by default.  Keyboard is
   also `us` by default. `FILESYSTEM=ext4` by default.

10. What packages you want.  I chose some default X11 goodies, printing utilities,
    multimedia packages, and some programming utilities.  I don't install Nano by
    default, because I'm a Vim guy.  But you should install what you want.

The variables are set in the early part of the script.  Sometimes a value is set by
whether a function returns a truthy value or not (0 for true, 1 for false).  Sometimes
you just set the variable equal to the name of the package that you want.  

## Basic BASH Syntax

Variables are set as `VARIABLE_NAME=value`

Array names are  

`ARRAY=( pkg1 pkg2 pkg3 )`

Associative arrays are

`ASSOC_ARRAY=( [key1]=value1 [key2]=value2 [key3]=value3 )`

Functions are
```
func_name(){
    do something
    returns 0 if successful or non-zero if unsuccessful
}
```

You'll notice I do loops and if/then branching routinely throughout the script.  Also, I try 
to follow `DRY` (Don't Repeat Yourself) by having functions do redundant tasks.

And about a million other little tiny rules that still bite me in the butt every day.
Hope you have fun!

## simplest.sh

Currently this only works on a non-UEFI bios.  I will have to change this.  Time marches on and
conditions were different when I first wrote this script.

This is a starter script for your own script.  It has the bare essentials for installing your own MBR-based
installation.  The same "you'll need to change" fules apply.  But this is a simpler script to start
with.  The purpose here is to build out your own script as your knowledge grows.  Figure out how to do a 
GPT disktable, then try LVM with each of those.  Then RAID or LUKS if you like.  Or maybe you want to
try out some other customizations for your own needs.  Hopefully `simplest.sh` can help with your early 
steps!  I never have found RAID very useful for my needs, but many people have.  But you'll have to add
that feature yourself, since I don't have it by default.

I think I should just change this over to a UEFI BIOS and GPT disk scheme.  Have to work on this.

## install\_x.sh

If you decide to NOT install X11, there is an additional _install\_x.sh_ script.  The
commands for installing X can be executed after a basic Arch install is running using
this script.

## post\_install.sh

There is a _post\_install.sh_ script.  On my home network, I always have hosts that contain folders I
need on my fresh new installation.  The names of the directories I need to recursively copy are installed
in here.  (Such as my music library or my frequently used scripts of files.)  Also, I install the AUR
helper _yay_ *or paru* in this script.  I also install _google-chrome_ and a few other things.  Hopefully
this script will give you ideas for your installations.

## _farchi\_target.sh_ 

This is in case you want to keep _farchi.sh_ pristine as an example only,
and then you can customize _farchi\_target.sh_ just for your specific installation.

## _arch\_linux\_install.txt_ 

This is a basic summary of the tasks needed to install an Arch system.  It's my step by step
process to do from the Archiso image and a root terminal when you're not running this script.  
This is what I used to do before I wrote any scripts.

## SUDO Problems

I noticed on a recent install that I was getting a lot of strange errors with `sudo`.
I would type the sudo password and would be told that my password was wrong.  It wasn't
wrong.  But for some reason it wasn't being accepted.  I was certain that my username
was added to `/etc/sudoers` and that I was typing my password correctly, without a capslock
problem or any such keyboard-related mishap.  My password was not getting recognized with
my account, apparently.  I started googling, and I found out that there were two problem
that could cause this.  I wasn't sure which to try first, so I did them both, and the 
problem went away instantly.  I installed `pambase` and I enabled `systemd-homed`.  As a
consequence, I added these lines to the end of the farchi scripts and the `simplest.sh` script.
I even started checking for the service in `post_install.sh`.  The lines are

```
pacman -S pambase systemd-homed
systemctl enable sysstemd-homed
```

Wait!  I just took out the `systemd-homed` service!  For some reason, a pacman search
no longer returns it as a package.  Not sure what's going on there!  Probably they
deleted the package!

Obviously, you want to start that service as well, but at least the service should be
started when the machine starts up.  

I'm not sure what change made this addition necessary.  It used to be that I never had to 
think about any of this.  Perhaps pambase was already installed?  Perhaps `homed` was
already started somewhere?  I don't know.  But adding these lines fixed my problem.

Latest note!  I just took out the pambase and systemd-homed lines (except for checking 
for whether the service is running).  This could all be some kind of mistake.  I don't 
know what's going on with pambase and systemd-homed.  Not even sure if I need to change anything
at all.

## On LUKS

Just a reminder that this is simply for when you turn off your PC, if someone tries to access
your files, they will be encrypted.  There is no encryption protecting your files while the
system is running.  
