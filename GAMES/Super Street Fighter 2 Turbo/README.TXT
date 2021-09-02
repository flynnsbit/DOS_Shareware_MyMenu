******************************************************************************

Super Street Fighter II Turbo - demo version
--------------------------------------------

This demo has been released to replace the rather flaky old demo that
inadvertently became available. It is essentially the floppy disk version of
the game minus a few tweaks, but with only one level and two characters
available. The CD-ROM version is the same, but has CD digital-audio tracks
for all the music instead of sound card music. Both versions support a new
six-button joypad that has been specially developed for the game.

Important demo information :-

1. This archive contains sub directorys and must be extracted with the 
   -d option.

2. Run the "INSTALL" program to select sound card options.

3. If you have a Gravis sound card, run the "LOADPATS" program.

4. Run the game with "SSF2T".

5. Use the options menu in the game to select controller & gameplay options.

At the last minute, a problem has been found with Gravis sound support.
Rather than delay this demo any further while the problem is fixed for the
final game, we have decided to release it anyway. If you have a Gravis card,
you may experience effects such as music playing at the wrong speeds or the
game may crash. It seems to vary from system to system. If problems occur, 
select "no effects" and / or "no music" in the install program.

Standard readme.txt follows :-

******************************************************************************


Super Street Fighter II Turbo
-----------------------------

Welcome to PC Super Street Fighter II Turbo.

1) Introduction
2) Installation
3) Control Methods
4) Sound Support
5) Memory Requirements
6) Hard Disk Requirements
7) Running PC Super Street Fighter II Turbo
8) Troubleshooting


1) Introduction
---------------

This file is a guide to installing PC Super Street Fighter II Turbo 
and includes trouble shooting suggestions to help with any
problems you may encounter.


2) Installation
---------------

From the DOS prompt log onto your CD drive and INSTALL.

Follow the on screen prompts to install the game.

Remember to save your settings before leaving the install program
so that PC Super Street Fighter II Turbo will be able to access
your hardware correctly.

The install program will be copied to the install directory on your
hard drive so that you can make changes to your setup after 
installation eg if you change your sound card settings.


3) Control Methods
------------------

PC Super Street Fighter II Turbo supports the following control devices:

 Keyboard (redefinable see below for default setup)
 2 Button Joystick
 4 Button JoyPad (eg Gravis)
 6 Button JoyPad 

Default Keys are:-

Player 1
Left    -       A
Right   -       D
Up      -       W
Down    -       S
Punch   -       T,Y,U 
Kick    -       G,H,J

Player 2
Left    -       L
Right   -       '
Up      -       P
Down    -       ;
Punch   -       Insert,Home,Page Up 
Kick    -       Delete,End,Page Down

Other keys
Quit    -       Alt X to exit current fight
		Exit to DOS on the Menu Screen to return to DOS
Pause   -       Pause Key
UnPause -       Any Key when game is Paused

When selecting controllers, remember that only one 6 button or 
4 button pad can be connected to a PC at any time. If you try
to select two of these controllers, the game will revert one 
back to keyboard.

If using a joystick or joypad remember to calibrate it before 
playing PC Super Street Fighter II Turbo. This is done from the
options menu.

The recommended controller is the PC world's first 6 independent 
button joypad - the 'Phantom 2 Plus'. This has been designed for 
PC Super Street Fighter II Turbo and is also compatible with all 
2, 4 and 6 button games.

For more details:

In the UK and Europe contact Euromax Electronics Ltd.
	Telephone: +44 (0)1262 602541

In the US contact Gametek Inc for details of your nearest supplier.


4) Sound Support
----------------

PC Super Street Fighter II Turbo supports a wide variety of sound cards.

Select your sound card from the install program and the correct settings 
for Port Address, DMA and IRQ.

If you select a sound card that you do not have, or incorrect settings,
PC Super Street Fighter II Turbo will not run correctly and may hang 
your system. If this occurs run install and correct the settings.

If you are unable to get PC Super Street Fighter II Turbo to run, try 
selecting No Sound to identify if there is a problem with your sound 
card.

Typical settings for Sound Blaster are
	
	Port    220
	DMA     1
	IRQ     7

These are normally the same for both Digital and Music settings.

For the Gravis card typical settings will be similar for the digital
sound but for music the Port is normally 388.

Please check your sound card documentation for help in finding and 
changing these settings.


5) Memory Requirements
----------------------

PC Super Street Fighter II Turbo requires a minimum of 4Mb memory,
8Mb is recommended. 

For any machine with less than 16Mb memory, the game will automatically 
create a virtual memory swap file. The size of this file depends on the 
amount of free memory. PC Super Street Fighter II Turbo will 'upgrade' 
your machine to have 16Mb of free memory. 

Eg on a 4Mb machine with 2 Mb free there will be a 14Mb swapfile.

Please ensure that you have the required disk space before running 
PC Super Street Fighter II Turbo.


6) Hard Disk Requirements
-------------------------

PC Super Street Fighter II Turbo requires approximately
15 Mb of space to install, plus space for virtual memory.
(please refer to section 5 Memory Requirements)


7) Running PC Super Street Fighter II Turbo
-------------------------------------------

After the installation is complete, change to the 
drive and directory where PC Super Street Fighter II Turbo
is installed and start with the command 

	SSF2T


Floppy disk version only!
If you have a Gravis Ultrasound, you will need to run Loadpats
before running PC Super Street Fighter II Turbo.

	type LOADPATS at the command prompt followed
	by SSF2T


8) Troubleshooting
------------------

   Q:  MY COMPUTER LOCKS UP WHEN I AM PLAYING PC SUPER STREET FIGHTER II TURBO

   A:  If you are running a disk caching program, there may be conflicts
       when PC Super Street Fighter II Turbo accesses the virtual memory
       file on disk. Trying reducing the size of the disk cache or removing 
       it conmpletely.
       Try turning sound off to identify probelms with the Sound Card.

   Q:  PC SUPER STREET FIGHTER II TURBO KEEPS GIVING OUT OF MEMORY ERRORS

   A:  Try turning sound off, animations off and parallax off.
       Remove memory resident programs.
       Remove any disk caches such as Smartdrv and NCache.
       Remove memory managers such as QEMM386 and EMM386. PC Super Street 
       Fighter II Turbo will run with only HIMEM.SYS installed.  

   Q:  PC SUPER STREET FIGHTER II TURBO RUNS SLOWLY ON MY MACHINE.

   A:  Try turning sound off, animations off and parallax off.
       Check your sound card settings in install.  Incorrect settings
       can cause significant slowdown.

   Q:  MY COMPUTER HAS 4 MEGS OF RAM.  THE GAME IS SLOW AND ACCESSES THE
       HARD DRIVE ALL THE TIME.

   A:  If you have less than 4 megs of RAM, the game will use virtual memory
       on disk. Try turning off Parallax and Animations to reduce the memory
       required. You might consider purchasing a memory upgrade.  Every meg 
       of RAM you add will increase performance. Try turning sound off by 
       selecting No Sound in Install. This will also help free up more memory.

   Q:  MY COMPUTER LOCKS UP WHEN I RUN PC SUPER STREET FIGHTER II TURBO

   A:  You may have the wrong sound card selected, or incorrect port,
       IRQ or DMA settings. If this doesn't help, refer to your sound 
       card manual for troubleshooting instructions.     

   Q:  I CAN'T SELECT THE RIGHT PORT/IRQ/DMA FOR MY SOUNDCARD IN SETUP.

   A:  If the proper selections don't appear in the install, then you can
       always select them manually by typing in the other section

   Q:  WHY DON'T I HEAR ANYTHING WHEN I TEST MY SOUND IN OPTIONS?

   A:  You may have the wrong sound card selected, or incorrect port,
       IRQ or DMA settings.  Volume may be set too low in your sound
       drivers (or the volume slider on the back of your sound card).
       Hardware conflicts or loose cables may be to blame as well.
      
   Q:  MY JOYSTICK ISN'T RESPONDING IN THE GAME.  WHAT'S WRONG?

   A:  Be sure you have JOYSTICK selected in the Options/Controls menu,
       and that it's calibrated.  If your joystick connects to your
       soundcard, make sure the joystick port jumper is ENABLED on the card.
       Some soundcards have this disabled by default.
   
   Q:  CAN I RUN PC SUPER STREET FIGHTER II TURBO UNDER WINDOWS?

   A:  While PC Super Street Fighter II Turbo may run under Windows, 
       it isn't recommended.  You will probably get odd behavior and 
       slowdowns due to timer conflicts. GUS users may get no sound 
       at all under Windows.


Eurocom Developments Ltd.
Gametek (US) Inc.
Capcom Inc.
14 April 1995.
