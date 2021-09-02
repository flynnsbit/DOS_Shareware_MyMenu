     FD-DISPLAY.SYS/PRINTER.SYS: codepage management for console and printer
     ======================================================================

  ===========================================================================

   FD-DISPLAY.SYS/PRINTER.SYS: implements codepage management (generic IOCTL)
   for the console and printer devices

   Copyright (C) 2002-2006 by Aitor SANTAMARIA_MERINO
   aitor.sm@gmail.com

   Version  : 0.13b
   Last edit: 2006-08-06 (ASM)

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 2 of the License, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
   more details.

   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc., 
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

  ===========================================================================

   The following hard-ware specific code is included:

   EGA/VGA adapter     version 0.13b
                       2002-2006 under the GNU-GPL license
                                      by  Aitor SANTAMARIA_MERINO
                                          aitor.sm@gmail.com
                                      and Ilya V. VASILYEV 
                                          hscool@netclub.ru

   CGA adapter (GRAFTABL)
                       version 0.13
                       2002-2006 under the GNU-GPL license

  ===========================================================================



0.- INTRODUCTION
================


DISPLAY.SYS and PRINTER.SYS are device drivers that supply existing drivers
with codepage replacement capabilities (through the IOCTL interface).

Both routines have hardware type dependant routines to do the actual job, as
well as (mainly) two other routines, one to SELECT the wanted codepage,
interfacing with whichever other DOS programs is due, and interfacing between
the fixed (firmware) and the configurable (software) codepages, and a second
routine, PREPARE, to manage several buffers with information about different
codepages. DISPLAY also hooks the multiplexer (2Fh) interrupt vector to
interface with the rest of DOS. However, they share much of the code, so that
the sources supplied here are supposed to be valid for both.

Communication between the user and the device driver to change codepage is made
through IOCTL calls, where a generic IOCTL call informs the device (e.g. CON)
that a codepage change is starting, and that the contents of a CPI (Codepage
Information) file is going to be sent through the IOCTL WRITE line. Usual DOS
kernel device drivers for which codepage selection has a meaning, such as CON
or PRN, do not implement the response of these calls. The mission of 
DISPLAY.SYS and PRINTER.SYS is to implement these functions without disturbing
with the rest device driver calls.

Both drivers are linked to hardware-specific routines, that may belong to
third party developers. Typical hardware for DISPLAY includes different
graphic adapters, and for PRINTER different printer adapters.


0.1.- Who should use the software

You use this software if you want to add codepage support to your console or
printer in FreeDOS (or any other DOS).


0.2.- Compatibility

At this stage of development (pre-1.0), DISPLAY and PRINTER do not interface
through the usual device driver interface, but through the multiplexer. There
is no PRINTER driver, due to:
- PRINTER does not have multiplexer interface
- there are no printer-specific routines submitted to the FreeDOS project

The codepage information should come as a CPI file (older RAW files are
deprecated and unsupported).

Currently supported hardware by DISPLAY:

   CGA adapters (i.e. GRAFTABL)
   EGA adapters
   VGA adapters
   LCD adapters
   
Please see the hardware specific documentation for more information.

DISPLAY/PRINTER 0.13 CORE SOURCE is supplied under the GNU-LGPL license.
This version is linked to EGA/VGA and CGA code, which are both distributed
under the GNU-GPL version, thus the whole package comes under the GNU-GPL.

If you wish to create new hardware specific routines, please read the
accompaining documentation. Please do make sure not to link version-
incompatible sources. I.e. you cannot compile the EGA/VGA driver with a
third party closed-source hardware specific code.


0.3.- Limitations and incompatibilities

A maximum of 8 codepages can be prepared at a time (depending on the available
memory, up to 64KB, which gives a practical maximum of 5).

It is incompatible with older versions of DR-KEYB, with MS-MODE and with
unspecific versions of FreeDOS MODE (please always check the documentation of
MODE to see the versions of DISPLAY for which MODE works).


0.4.- Version

This is version 0.13b of FreeDOS DISPLAY.

(version 0.13b is a bug-fixed version of version 0.13. This document will refer
to version 0.13 to mean version 0.13b)


0.5.- Copyright

Version 0.13 of this program is distributed under the GNU General Public
License version 2.0.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc., 
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

The license applies regardless if it includes runtime libraries or packing forms
(online compression) which are not open source.


0.6.- Installation

DISPLAY requires a single executable. In this version, it is distributed as an
EXE file (DISPLAY.EXE), (later versions from 1.00 onwards may be distributed as
a SYS device driver).

To operate with DISPLAY you may need FreeDOS MODE and CPI files. Look for them
in the FreeDOS repository.

Place your DISPLAY.EXE commandline in AUTOEXEC.BAT if you want DISPLAY to load
automatically when you boot up.


0.7.- Known bugs and reporting bugs

There are no known bugs.

If you find a bug, please make sure that the bug affects DISPLAY.EXE and not
MODE or the CPI files that you are using. If the problem is MODE or in the CPI
files, then you would need to contact the respective developers.


If you want to report bugs, please fill a bug report on the FreeDOS Bugzilla:

http://www.freedos.org/bugs/bugzilla/

Alternatively, write an email to

Aitor SANTAMARIA MERINO
aitor.sm@gmail.com


0.8.- File history

FD-DISPLAY has grown as a large number of files around the original code by
Ilya V. Vasilyev (now contained in EGAR.ASM and VIDEOINT.ASM). The rest of the
files have been written anew by Aitor Santamaría Merino. 

0.06:  int2Fh interface, MODE interface
0.07:  PREPARE and SELECT use independent buffers
0.08:  commandline parsing
0.09:  communicate with others (KEYB, PRINT, ARABIC/HEBREW, GRAFTABL)
       modularity (PRINTER.SYS is now possible with the same sources)
       error codes reported
0.10:  parse CPI files
0.11:  support for CGA
       GRAFTABL locking
       EXE file (instead of COM)
       prepared buffers loaded into XMS (if available)
0.12:  Ability to prepare more than 1 codepage at a time (Generic IOCTL pseudo-call)
0.13:  Core code separated from the hardware specific code (and change on license)
       Heavy source re-structure
       New commandline parsing
       Fix the crash when-no-XMS bug

0.9.- Acknowledgements

I am sincerely very grateful to a large number of people that have helped me.

Henrique Peron for his help and bug reports.

Ilya V. Vasilyev for the original DISPLAY, and presently for the EGA/VGA
specific code.


1.- DISPLAY and PRINTER features
================================

At this stage of development, nor DISPLAY neither PRINTER are device drivers
that communicate through device driver calls. They are loadable TSRs, and in
the case of DISPLAY, it communicates with the rest of the world through a
slightly enlarged muliplexer interrupt. PRINTER has no binary, being one of
the reasons that it has no way to interface with programs outside. It is
intended that they will work as they should in version 1.0. For a list of
other limitations of current version, see the sections below.

As mentioned above, there is no PRINTER executable file. There are only three
diferences on DISPLAY.SYS and PRINTER.SYS:
- DISPLAY.SYS has a multiplexer interface (PRINTER doesn't)
- Both have their font signature in their files (1 DISPLAY, 2 PRINTER)
- DISPLAY interfaces with KEYB, PRINTER with PRINT)

The codepage preparation is usually made by the DOS MODE command, whereas the
selection is directly made by the kernel-loadable NLSFUNC component, or
improperly, by the DOS MODE command. When preparing the codepages, MODE sends
to DISPLAY/PRINTER the information of codepages included into CPI files. The
FreeDOS repository should have the latest MODE needed and sets of CPI files.

Also notice that Eric Auer has implemented into MODE the capability of using
self-compressed CPX files. As the file is compressed into a CPI before it is
sent to DISPLAY, there's no problem with using these CPX files in what concerns
DISPLAY or PRINTER.

DISPLAY 0.12 EGA/VGA specific routine is able to admit DR-FONTs. Note however
that you would need a DR-FONT-aware MODE.


1.1.- Commandline syntax

Be sure that no other DISPLAY program (identified though int2Fh, MUX=ADh,
fn=00) has been previously loaded.
The commandline is of the form:

   DISPLAY   devname[:]=(hwname,[hwcps],buffers)   [/C] [/V] [/NOHI]
   DISPLAY   devname[:]=(hwname,[hwcps],(buffers,param))   [/C] [/V] [/NOHI]


devname   Name of the device for which generic IOCTL is implemented
          (DUMMY at the moment, usually CON)

hwname    Name of the hardware adapter (CGA, EGA,...). See NewHW.txt for a list

hwcps     List of hardware codepages. Either a single number (for a single
          codepage) or a list   (n1,n2,...)  for several hardware codepages.
          (For more than one codepage, you'll need third party drivers, such as
          ARABIC.COM or HEBREW.COM)

buffers   A single number representing the number of buffers that you want to
          allocate, or a pair  (buffers,subfonts) with the number of buffers
          and the number of subfonts wanted
          
param     This optional parameter is passed to the hardware-specific routine.
          See the hardware-specific routine documentation for more information
          
/C				ExClusive:  will not load if there is another DISPLAY loaded

/NOHI     Forbid to use XMS to store the prepare buffers

/V        Verbose: prints extended information
                    


Example:

   DISPLAY  CON=(VGA,437,2)

specifies to use DISPLAY for the CON device, for an VGA adapter type and 2
buffers for prepared codepages.

To interface with DISPLAY, use FreeDOS MODE. Please make sure that the version
of MODE that you are using matches the DISPLAY versioning.

DISPLAY does not offer the possibility to unload once loaded.



1.2.- Exit codes and causes of errors

DISPLAY produces no exitcodes, but provides a set of errors through the
int2Fh/AD03h function for each function. You should check it after each
unsuccessful operation.

Error code      Operation           Meaning
------------------------------------------------------------------------------
1               All                 Unknown function
26              Select              Codepage was not prepared
26              Query               No dodepage was already selected
27              Select              KEYB failed to change codepage
27              Query               Device error
27              Prepare             The codepage was not found in file
29              Select              Device error
29              Prepare             Device error OR XMS error
31              Prepare             Source file damaged OR XMS error
31              End Prepare         No Start prepare found
------------------------------------------------------------------------------


1.3.- DISPLAY features

The following is a brief list of features of DISPLAY:

* Codepage management support for a standard character device (generic IOCTL).

* Codepage buffer preparation to XMS

* MS compatibility in commandline and API (but incompatible with MS MODE)

* Modular and easily extensible. Currently supports CGA, EGA, VGA

* Last but not least, it is open source software under the GNU-GPL 2.0, which
  is written in NASM assembler


1.4.- Compiling the driver


To compile DISPLAY, get the latest NASM release and compile it in its binary
form. The result is a COM file.

The program is finally packed using the open source UPX packer, and turned
into an EXE file using COM2EXE. Apply UPX first, and COM2EXE next.

UPX:          http://upx.sourceforge.net/
COM2EXE:      get Arakdy Belousov's CuteMOUSE

Respect to the structure of the program, there is a main assembler where the
rest of the files are included. For the filelist, please check the DISPLAY.ASM
documentation.

Finally, the program TEST by Ilya V. Vasilyev is included. It helps testing
DISPLAY in the different screen modes.


1.5.- Interactions

DISPLAY/PRINTER 0.10 interact with other parts of DOS. Namely:
  - KEYB  (DISPLAY.SYS):    KEYB is asked to replace codepage when it is due
                            DISPLAY.SYS fails if KEYB fails
  - PRINT (PRINTER.SYS):    PRINTER.SYS checks wether PRINT is already in use
                            PRINTER.SYS fails if PRINT is printing
  - GRAFTABL (DISPLAY.SYS): GRAFTABL has priority over DISPLAY.SYS when setting
                            fonts
  - ARABIC/HEBREW (DISPLAY.SYS):
                            DISPLAY.SYS calls these to manage more than one
                            hardware codepages


1.6.- Future wishes

In a nearby future, I'll be considering these tasks:

(1) Turn the files into proper device drivers (expect by 1.00)


Here I show a list of wishes that I'd leave for other contributors:
- load CPI files in several chunks (as MS-DISPLAY does)
- configure more than one device at a time. E.g.:
    DEVICE=PRINTER.SYS LPT1=... LPT2=...
- (DISPLAY.SYS) communicate with ANSI.SYS via IOCTL calls
- (PRINTER.SYS) enable the Privileged Lock Codepage Switching feature


2.- Brief review about using FreeDOS MODE for codepages
=======================================================

(please read the documentation accompaining FreeDOS MODE)


MODE CON CODEPAGE

   gets status of DISPLAY.SYS and prepared/selected codepages

MODE CON CODEPAGE PREPARE=((nnn) file.CPI)

   prepares codepage nnn from file.CPI into the first buffer

MODE CON CODEPAGE PREPARE=(([mmm,]...nnn) file.CPI)

   prepares the given codepages in the given buffers from file.CPI

MODE CON CODEPAGE SELECT=nnn

   makes codepage nnn be active for DISPLAY.SYS (and thus makes your
   screen to display those characters)
   Codepage nnn must have been prepared beforehand


For the moment, this is the only way to select the DISPLAY codepage. However,
note that in the future, you are not supposed to use MODE for doing that. You'd
rather do it by loading NLSFUNC and calling the internal command CHCP, like

CHCP 850

Finally, if for some reason, your codepage was messed, you can always recover
it with the REFRESH command:

MODE CON CODEPAGE REFRESH

Please always read the fast help of MODECON program to know more about it.



<<<EOF>>>
