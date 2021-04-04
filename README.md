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

## Here's What You'll Want to Change

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
   this and many recent Broadcom wifi chipsets.

6. `install_x(){ return 0; }`  Return 0 for yes, 1 for no.  Do you want to install X11 or not (faster if
   you don't, but you'll probably want to install it anyway).  If you're just experimenting in a VM and
   testing your script, perhaps you just want to install a bare bones installation to test with.

7. `VIDEO_DRIVER=xf86-video-vmware`  `install_x(){ return 0; }`  You must be installing X (or else why
   would you care about a accelerated video driver?)  This is your Video chipset driver to run X11.
   This will be one of the _xf86-video-*_ drivers for different video chipsets, such as Radeon, Nvidia,
   Intel, and so forth. I install xf86-video-vmware by default.

8. `DESKTOP=(cinnamon nemo-fileroller)`  Your choice.  Many options are available.  What desktop
   environment to you want (or what Window Manager)? I chose lightdm for display manager and Cinnamon for
   desktop environment by default.  XFCE and Mate and i3gaps are also some favorites of mine and are
   ready to be installed also.

9. Your `LOCALE` and `TIME\_ZONE`:  `en\_US-UTF-8` and `America/New York` by default.  Keyboard is
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
And about a million other little tiny rules that still bite me in the butt every day.
Hope you have fun!

## simplest.sh

This is a starter script for your own script.  It has the bare essentials for installing your own MBR-based
installation.  The same "you'll need to change" fules apply.  But this is a simpler script to start
with.  The purpose here is to build out your own script as your knowledge grows.  Figure out how to do a 
GPT disktable, then try LVM with each of those.  Then RAID or LUKS if you like.  Or maybe you want to
try out some other customizations for your own needs.  Hopefully `simplest.sh` can help with your early 
steps!

## More Notes

If you decide to NOT install X11, there is an additional _install\_x.sh_ script.  The
commands for installing X can be executed after a basic Arch install is running using
this script.

There is a _post\_install.sh_ script.  On my home network, I always have hosts that
contain folders I need on my fresh new installation.  The names of the directories I need
to recursively copy are installed in here.  Also, I install the AUR helper _yay_ in this
script.  I also install _google-chrome_ and a few other things.  Hopefully this script
will give you ideas for your installations.

_farchi\_target.sh_ is in case you want to keep _farchi.sh_ pristine as an example only,
and then you can customize _farchi\_target.sh_ just for your specific installation.

_arch\_linux\_install.txt_ is a basic summary of the tasks needed to install an Arch
system.

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

I'm beginning to look into encryption with Arch.  I'm just beginning to read up on it.
What I've found so far is that it's probably best to first create the encrypted filesystem
and *then* to create LVM onto it.  That way you don't have to create cryptographic keys for
each physical volume and deal with the complexity of that arrangement, and the lack of
protection also.  Your entries in `/dev/mapper` won't be encrypted, etc.  It's better to 
add LVM *after* you first get the filesystem encrypted.

BTW, the boot loader cannot be encrypted.  The EFI partition must be loaded unencrypted,
as I understand it.  Also, extra hooks must be added to `mkinitcpio.conf`.  Also, if you're 
using systemd init, apparently that's different from using GRUB.  Not sure which one is
best for all this yet.  You have to pass some command line params at boot to the kernel.

No released version of GRUB supports LUKS2.  Have to use LUKS1 on partitions that GRUB needs
to access.

## LUKS on LVM vs LVM on LUKS

You cannot span multiple disks if you're using LVM on LUKS.  However, you'll have to use
separate keys for separate physical volumes if you use LUKS on LVM, adding more 
complexity and less security to the mix.  I'm frankly not sure which method I want to use
at this point...

## More on LUKS

I sort of stalled out on learning LUKS.  I keep running out of interest in this department.
I'll have to try to recommit myself!

