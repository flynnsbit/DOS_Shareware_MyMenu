SIMCITY 2000 (TM) DEMO Last Minute Info - !!PLEASE READ ME! 

I. INSTALLATION
     Video Selection
II. VIDEO CARDS
     What Is A VESA Driver And How Do I Use It?
     ATI Ultra Pro or Mach 32 Video Cards
     Diamond Viper
     Trident Video Cards
III. MOUSE DRIVERS
     Microsoft Compatible Mouse Required
IV. MISCELLANEOUS
     Memory Issues
     Running with QEMM, EMM386 And Other Memory Managers
     Running SimCity 2000 DEMO Under OS/2
     Creating A Boot Disk With Stacker/DoubleSpace
V. TROUBLESHOOTING
     I Get An "Error 35"
     SimCity 2000 DEMO Locks Up
     SimCity 2000 DEMO Install Program Crashes
     I Get A "Microsoft Compatible Mouse Not Found" Message
     I Have A Diamond Stealth/Viper And Get Funny Lines On My Display

Please read _ALL_ of this document! This stuff is important! 
 
It covers a lot about memory, installation, various graphics cards and 
sound cards, gameplay issues, importing cities from other versions of 
SimCity 2000, and hot keys.   
 
I. INSTALLATION
 
Video Selection 
--------------- 
The SimCity 2000 DEMO installer will attempt to figure out what kind of 
video card you have in your machine. If it is not sure what kind of 
video card you have, or the installer detects a VESA driver in memory
(or in BIOS), it will default to the VESA SUPER VGA driver. You can 
click on the arrow to the right of the VESA SUPER VGA entry for a list 
of other cards that the installer thinks you might have. If your card 
is on this list, you can select it instead of the default VESA driver.
If the installer cannot figure out what kind of card you have and
cannot detect a VESA driver, a large red warning message will be 
displayed. If you wish to continue and try to run SimCity 2000 DEMO 
anyway, you MUST load some type of VESA driver for your video card.
 
II. VIDEO CARDS

What Is A VESA Driver And How Do I Use It?
------------------------------------------
VESA stands for Video Electronics Standards Association. It is a 
standard that allows software companies to write programs that work
on many video cards without having to know how each card works.
The VESA driver is the program that handles this. Almost every video
card available today has VESA drivers available for it. These drivers
may be stored in a chip on the video card, or they may be a program
that the user has to load by hand (or with a batch file). Some cards 
(such as the Diamond Viper) have the driver on the video card, but 
need the user to run a special program to activate the driver. During
installation of SimCity 2000, if the installer detects a VESA driver in
memory (or on the card), it will list VESA SUPER VGA as the default.
You may also be able to select specific video support for your card if
it is supported (we recommend using specific video support, if possible,
for fastest operation). If the VESA driver is an external program, it
will probably be found on the disks that came with your video card. 
If you don't have a VESA driver you should contact your video card 
manufacturer. We have included VESA drivers for most popular cards in 
your SimCity 2000 directory. To find the particular driver for your 
system, look in the SC2000\VESA directory for the subdirectory that 
sounds closest to the name of your brand of video card. In that 
subdirectory should be the VESA driver. Using most 'external' 
(programs that you must run) VESA drivers is as easy as typing the 
name of the driver at the DOS prompt. For instance, if the driver were 
called VVESA.COM, you would type:
VVESA.COM [ENTER]

ATI Ultra Pro or Mach 32 Video Cards 
------------------------------------ 
If you have an ATI Ultra Pro or other card based on the Mach 32 chip,  
you must run the included utility MW_ATIUP.EXE before playing  
SimCity, for complete compatibility. 

Simply type:    MW_ATIUP [Enter] 
then type:      SC2000   [Enter] 
 
to use your ATI card with SimCity 2000. If the MW_ATIUP program is
not run, you may get an "ERROR 35" type message when trying to run
SimCity 2000. MW_ATIUP.EXE can be found in the SimCity 2000 directory.
 
Diamond Viper
-------------
The Diamond Viper has its VESA driver on the card, but you need to
run an external program to activate it. This program is called
VPRMODE.EXE. To use VPRMODE to activate the VESA driver, type:

VPRMODE VESA [ENTER]

The VPRMODE program should have been installed by the software that
came with the Diamond Viper card.

Trident Video Cards 
------------------- 
Some older Trident video cards may not be compatible with the Trident  
driver installed by SimCity 2000. If you installed a Trident video  
card and are experiencing video problems, try running the INSTALL.EXE  
program in the SimCity 2000 directory and selecting the VESA video 
driver, then install the proper VESA driver for the card before running
SimCity 2000.

III. MOUSE DRIVERS

Microsoft Compatible Mouse Required
-----------------------------------
SimCity 2000 requires a Microsoft-compatible mouse to run. Most
mice today (including Logitech, Mouse Systems, and Kensington) are
Microsoft-compatible. In order for the mouse to work properly in
SimCity 2000, a mouse driver must be loaded before running
SimCity 2000. The mouse driver must also be fairly current and VESA 
compatible. Contact the manufacturer of your mouse or the dealer who 
sold the mouse to you to see if your driver is the most current
available.

IV. MISCELLANEOUS

Memory Issues
------------- 
SimCity 2000 requires a lot of memory to run--4 MB total. On some 
machines, even if you have the required 4 MB, SimCity 2000 may report 
that you do not have enough free extended or conventional memory. If 
this is the case, your best alternative is to create a boot disk as 
outlined on page 6 of the SimCity 2000 DOS Addendum/Quick Start Guide. 
Another solution that may help is to install SimCity 2000 with No Sound 
and No Music selected. If you have already installed SimCity 2000, you 
can change your current sound, music, and video settings by running the 
INSTALL.EXE program in the SimCity 2000 directory. 
 
Running With QEMM, EMM386 And Other Memory Managers
----------------------------------------------------
We recommend that you not load any memory managers or disk cache 
utilities while running SimCity 2000, especially if you are using 
DOS 6 on a machine with only 4 MB RAM. 
If you are using a memory manager, you MUST NOT have it set in auto  
mode--this will cause a conflict with SimCity 2000. 
If you are using MS-DOS 6 and absolutely must load EMM386.EXE, 
you will need to either have the EMS size set to 'noems' or larger 
than 4096. See your DOS manual for information on how to do this. 
If you are running QEMM in Stealth mode, SimCity 2000 may fail to
recognize your VESA driver built into the video card BIOS. You will need
to run in Frame Mode as opposed to Page Mode. To do this, change the
"ST:M" parameter in your QEMM statement to "ST:F". See your QEMM manual
for more information on how to do this.

Running SimCity 2000 Under OS/2
-------------------------------
We have successfully run SimCity 2000 under a DOS session in OS/2. We
have not been able to run it as a migrated application. During
installation, you MUST NOT swap the installer to the background. It
must always be the foreground application until installation is complete.
If you have OS/2 and are able to run SimCity 2000 under MS-DOS but not
under OS/2, please call IBM Technical Support.

Creating A Boot Disk With Stacker/DoubleSpace
---------------------------------------------
Stacker version 3.0 and earlier require certain drivers to be loaded in 
the CONFIG.SYS file in order to mount the compressed hard drive.  When 
creating a boot disk with Stacker 3.0 and earlier you must include two 
lines in the CONFIG.SYS file.  The exact path is dependent upon where 
you installed Stacker on your hard disk, but here we will provide the 
path for the default installation of Stacker.  The two lines needed in 
your CONFIG.SYS file are:
DEVICE=C:\STACKER\STACKER.COM C:\STACVOL.DSK
DEVICE=C:\STACKER\SSWAP.COM C:\STACVOL.DSK

These lines will load Stacker and mount your compressed drive when 
booting from the boot disk.

DoubleSpace and Stacker 3.1 do not require that lines be added in the 
CONFIG.SYS file as they copy hidden files to the boot disk when using 
the "SYS A:" or "FORMAT A: /S" command.  Make a boot disk according to 
the normal instructions regarding creating a boot disk in your SimCity
2000 addeundum. If you do not feel comfortable creating a boot disk 
under Stacker or DoubleSpace, contact STAC Electronics or Microsoft 
for technical support.

V. TROUBLESHOOTING

I Get An "Error 35"
-------------------
This message usually shows up if you have certain ATI cards and have
not loaded the MW_ATIUP program. See the ATI entry in Section II above
for more information.

SimCity 2000 Locks Up
---------------------
This is more than likely the result of a conflict between SimCity 2000
and a memory-resident program that is being loaded in your AUTOEXEC.BAT
or CONFIG.SYS files. The best solution to this is to create a boot disk
as outlined in the addendum. If this does not help, try running the 
INSTALL program in the SimCity 2000 directory and selecting No Sound
Effects. If this doesn't help, call Maxis Technical Support at the 
number listed on the Maxis Maxims card included in your SimCity 2000
box.

SimCity 2000 Install Program Crashes
------------------------------------
This is also probably a conflict with a loaded memory resident program.
Try making a boot disk as per the addendum. Ignore the "Bad Command or
Filename" message that appears when using the boot disk for
installation. Also try running the INSTALL program with no mouse driver 
loaded. See your mouse manual for information on disabling the mouse.

I Get A "Microsoft Compatible Mouse Not Found" Message
------------------------------------------------------
This message is usually the result of one of two problems. Most likely,
a mouse driver has not been loaded. SimCity 2000 needs a DOS mouse
driver to run (as opposed to a Microsoft Windows mouse driver). This
driver along with instructions on how to load it should have come with
your mouse. The less likely problem is that the mouse driver is being
correctly loaded, but it is an older version that is not supported. You
should contact the manufacturer (or dealer) of your mouse to get a more
up-to-date mouse driver.

I Have A Diamond Stealth/Viper And Get Funny Lines On My Display
----------------------------------------------------------------
This is a problem with SimCity 2000 and some early versions of the
Diamond drivers. There are software patches available for both the
Stealth and Viper to alleviate this problem. The Stealth patch is
available as a software program called STLBIOS.EXE or as a hardware
upgrade. For the Diamond Viper a software upgrade called VPRM202.EXE
will contain a patch. All of these are available from Diamond.


If you enjoy the Demo, you can find SIMCITY 2000 at your favorite 
software retailer.
[EOF] 
------------------------------------------------------------------------- 
 

