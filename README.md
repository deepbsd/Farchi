# FARCHI    Fast Arch Linux Installer

This started as just a personal script, very very simple way to install 
Arch Linux after booting the archiso ISO image.  

You can download the script to your booted archiso image like this:

`curl -O https://raw.githubusercontent.com/deepbsd/farchi/master/farchi.sh`

If you open the farchi script and start filling in the
variables carefully, you'll be ready to install Arch linux!
Good luck!

You'll need to customize settings for your installation.

## Here's What You'll Want to Change

1. Your hostname

2. Your installation drive

3. Partitions and sizes.  By default it's EFI/BOOT: 512M, ROOT: 100G, SWAP: 2xRam (I like
   to be able to suspend and hibernate), HOME: Rest of disk.  I usually install to _at
   least_ a 500G drive.  For a VM I create a 30G Virtual drive and create 512M for
   EVI/BOOT, ROOT is 12G, SWAP is 2G, and HOME is the rest of the drive.

4. Whether you want LVM or not.  I don't install LUKS by default.  I might change this in
   the future.

5. Whether you want BCM4360 Wifi Drivers or not (or some other drivers of your choosing)

6. Your Video chipset driver to run X11.  This will be one of the _xf86-video-*_ drivers
   for different video chipsets, such as Radeon, Nvidia, Intel, and so forth. I install
   xf86-video-vmware by default.

7. Do you want to install X11 or not (faster if you don't, but you'll probably want to
   install it anyway).  If you're just experimenting in a VM and testing your script,
   perhaps you just want to install a bare bones installation to test with.

8. What desktop environment to you want (or what Window Manager)? I chose lightdm for
   display manager and Cinnamon for desktop environment by default.  XFCE and Mate and
   i3gaps are also some favorites of mine and are ready to be installed also.

9. Your LOCALE and TIME\_ZONE:  en\_US-UTF-8 and America/New York by default.  Keyboard is
   also American English by default.

10. What packages you want.  I chose some default X11 goodies, printing utilities,
    multimedia packages, and some programming utilities.  I don't install Nano by
    default, because I'm a Vim guy.  

The variables are set in the early part of the script.  Sometimes a value is set by
whether a function returns a truthy value or not (0 for true, 1 for false).  Sometimes
you just set the variable equal to the name of the package that you want.  

## Basic BASH Syntax

Variables are set as VARIABLE\_NAME=value

Array names are  `ARRAY=( pkg1 pkg2 pkg3 )`

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


