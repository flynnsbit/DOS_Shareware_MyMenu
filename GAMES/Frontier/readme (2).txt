
ELITE CLUB - Frontier and First Encounters readme file

Copyright 2001 Frontier Developments Ltd

www.frontier.co.uk
www.eliteclub.co.uk



Contents

1) Introduction

2) Running Frontier and First Encounters
   i)    Important note on DOS mode
   ii)   Notes for users of Windows 95/98
   iii)  Notes for users of Windows Millenium
   iv)   Notes for users of Windows NT/2000
   v)    Creating a DOS boot disk
   vi)   DOS mode and memory configuration
   vii)  Sound drivers
   viii) Mouse drivers
   ix)   Running the game from a RAM drive

3) Technical support

4) Shareware Notice




1) Introduction

This readme file is for the shareware release of Frontier: Elite II and
Frontier: First Encounters, which were originally released in 1993 and 1995
respectively.

The version of the game contained in the Frontier distribution is the 1994 CD
version, which is the most recent version of the game.

The version of the game contained in the First Encounters distribution is the
original PC floppy disk version with 1.06 patch applied. Therefore, please
note that bugs/issues remaining in this version of the game will still be
present - this means that the very final missions in the storyline
will not work correctly. For information on why these problems were present
in the original game, please refer to the First Encounters page at
www.frontier.co.uk

Note that although the title sequence has been updated to reflect the fact
that the game is no longer owned by the original publishers, this is the
only difference between this version and the version listed above.

Frontier does not have a quit game button on its interface - to exit
to DOS or Windows, press Ctrl-C.



2) Running Frontier and First Encounters

i) Important note on DOS mode

First Encounters must be run in 'Pure' DOS mode (also known as 'real mode
DOS'). This means that it cannot be run from within Windows - you must exit
Windows into DOS mode, or boot straight into DOS without going through
Windows. Some versions of Windows do not directly support pure DOS mode -
refer to the note below relevant to your operating system.

Frontier will run under Windows in some cases, but whether you run it from
DOS or Windows, you need to make sure you have enough free base memory - see
section vi. The advantage of running it under Windows is that you don't
usually have to load DOS mouse or sound drivers.


ii) Notes for users of Windows 95/98

Entering pure DOS mode can be done in two ways - either by selecting
"Restart in MS-DOS Mode" from the shutdown menu, or by repeatedly
pressing F8 just before the point where the Windows loading screen
normally comes up, until the boot menu appears, then choose "Command
Prompt only" (thus booting to DOS without entering Windows at all). On
some systems, it is possible to hold down the Ctrl key while booting
instead of pressing F8 repeatedly.

You should now move forward to section vi.


iii) Notes for users of Windows Millenium

Windows Millenium does not directly support pure DOS mode by default.
Therefore, you must either use a DOS boot disk, or reconfigure your
Windows ME installation to enable access to DOS mode. If you wish to
try the latter, there are guides on the Web which can tell you how
to do it, but we recommend that you only attempt this if you know
what you're doing, as making a mistake could cause Windows to stop
operating correctly. For information on making a boot disk, see
section viii.


iv) Notes for users of Windows NT/2000

Windows NT and 2000 do not support pure DOS mode at all. Some users
have a dual-boot setup, which allows them to choose between Windows
NT/2000 and an alternative operating system such as Windows 95. If
you do have such a setup, boot to Windows 95/98 or DOS, then follow
the relevant instructions for playing the games under that operating
system.
If you don't have a dual-boot setup, you must use a boot disk - see
section v.


v) Creating a DOS boot disk

A boot disk allows you to boot directly to DOS, totally bypassing the
operating system on your hard drive. Using a boot disk allows you to
access DOS when your main operating system does not support DOS. It
also allows Windows 95/98 users to create a custom configuration that
will only be used when the boot disk is used to boot, and thus won't
run the risk of interfering with their normal setup.

To create a boot disk in Windows 95/98, go to Control Panel, go to
Add/Remove Programs, choose Startup Disk, then click Create Disk.
Follow the on-screen prompts to complete the procedure. You should
then write-protect the disk (by sliding the tab on the right to close
the hole) to ensure that it cannot be infected by viruses.

You can then boot from the disk simply by restarting the computer
while the disk is in the drive. If it does not appear to boot from the
disk, and instead continues to load Windows as normal, you'll need to
go into the PC's BIOS Setup and change the configuration so that it
attempts to boot from Drive A before Drive C. For more information
on this, refer to your computer or motherboard manual.

When using a boot disk, you must take into account which file system
it supports. The three most common file systems are FAT16, FAT32 and
NTFS. Boot disks created with DOS or the original version of Win95
only support FAT16. Boot disks created with later versions of Win95,
and all versions of Win98 support both FAT16 and FAT32. If your main
operating system is Windows Millenium, the file system on your hard
drive will almost certainly be FAT32, so you'll need to create the
a boot disk which can operate with FAT32. If you are using Windows
NT or 2000, your hard drive may be using any of the three file
systems, although most likely NTFS. You can find out which file
system your hard drive uses by right-clicking on it in My Computer
and choosing Properties. If your boot disk does not support the file
system used by your hard drive (note that no DOS boot disk will
support NTFS), your hard drive will be inaccessible. In this
eventuality, refer to section ix for instructions on how to run the
game from a RAM disk.

Once you've created your boot disk, you may wish to edit the config.sys
and autoexec.bat files to customize the memory settings, and include
mouse and sound drivers - see the next section for more information.


vi) DOS mode and memory configuration

Frontier and First Encounters require a lot of free conventional memory,
so you may find you have to optimize your config.sys and autoexec.bat files
for this purpose. Some quick tips for doing this:

In config.sys, try the following changes (back up the file first so that
the original version can be restored if there are problems):
DOS=HIGH,UMB,AUTO 
DEVICE=C:\WINDOWS\HIMEM.SYS 
DEVICEHIGH=C:\WINDOWS\EMM386.EXE RAM 
Change all other instances of DEVICE= to DEVICEHIGH= 

In autoexec.bat, in places where executable programs are run (for example,
"mouse", "keyb" and "doskey"), put "loadhigh" (or "lh" for short) in front
(e.g. "lh doskey"). A few programs won't work like this, but most
will.

Reboot after updating the config files, and go back into DOS.
Type "mem /c /p" at the command prompt to find out how much conventional
memory is free. If DOS cannot find the mem command, switch to the directory
C:\WINDOWS\COMMAND and try again.

Also, you may wish to take a look at the file C:\WINDOWS\DOSSTART.BAT - it
contains DOS commands which are executed when "Restart in MS-DOS Mode" is
used. This means you can include your DOS mouse and sound drivers in this
file, so that they execute when you exit Windows, but don't load before
that, unlike programs in autoexec.bat.

For more information on base memory and how to free it, refer to the following
web pages:
http://www.pcguide.com/opt/opt/ram.htm 
http://www.orrtax.com/Support/whitepapers/memory.htm 
http://www.enren.gov.ar/web/Programas/memory.htm 
http://members.home.net/wl75081/LogicalMemoryLayout.html 


vii) Sound drivers

You will need to find DOS drivers for your sound card - refer to the website
of the card's manufacturer if you have difficulty.

Run the file setup.bat to autodetect your sound card's settings before
playing the game. Note that MIDI music settings must be selected manually.
Many sound cards will get excellent results using the MPU-401 MIDI driver,
if this doesn't work for you then find the sound card which seems to be
the closest match for yours. If music still does not play, try each
of the Sound Blaster drivers, starting with the Sound Blaster 16.

Most sound cards should work with the Sound Blaster drivers if there is
no match for them in the driver list, but some modern sound cards may not
work at all due to being released after the setup program was written.



viii) Mouse drivers

You will to find a DOS mouse driver if you do not have one already.

We recommend the free mouse driver "Cute Mouse":

http://www.vein.hu/~nagyd/



ix) Running the game from a RAM drive

If you cannot access your hard drive after booting with a boot disk (due to
the version of DOS on the boot disk not supporting the same file system that
your hard drive uses), you have two options. The first is to attempt to load
the game from another drive, such as a second hard drive or partition (with a
compatible file system), or a removable drive. Frontier: Elite II will fit
onto a high density floppy disk, but First Encounters will not. You may be
able to use a Zip drive or other form of removable media if you have the
hardware and necessary DOS drivers. It may also be possible to run First
Encounters from a CD by burning the appropriate files to it (you will need to
enter the sound configuration settings into HMISET.CFG manually in advance of
burning the disc), and when running the game off CD you can use the floppy
drive to save games. Otherwise, you will have to use a RAM drive.

When Windows 98 creates a boot disk, it includes a command to create a RAM
disk. A RAM disk is a temporary disk drive contained in the PC's memory, the
contents of which are lost when the computer is switched off. First Encounters
will not fit on a floppy disk in its normal form, but you can spread the files
across several disks and then copy them to the RAM drive. You can also zip
the files to reduce the number of disks needed, although you will require a
program which can unzip them in DOS.
You'll need to increase the size of the drive from the default 2048Kb to
around 12000Kb - edit the line devicehigh=ramdrive.sys /E 2048 in config.sys
on the boot disk to achieve this. Once the game has been successfully
unzipped to the RAM drive, you'll be able to run it from there, and save
games to a floppy disk. If you know how, you can also create a batch file to
automatically copy/unzip the files to the RAM disk, so you just have to
insert the correct disks when prompted.



3) Technical support

If you have difficulties configuring DOS mode, do a web search on the topic
(e.g. "Freeing up conventional memory"), and/or post a request for help to
the newsgroup alt.fan.elite (be sure to read the group after subscribing to
see if your question has already been asked by someone else).

Frontier Developments cannot offer tech support beyond what is included
in this document and the tips given on the website.



4) Shareware notice

Frontier: Elite II and Frontier: First Encounters are shareware. If you
continue to play either game more than 30 days after installing them, you
must register the game by sending five pounds to:

Frontier Developments Ltd
Saxon Farm
Longmeadow
Lode
Cambridge
CB5 9HA

Refer to the file licence.txt for detailed licence information.

