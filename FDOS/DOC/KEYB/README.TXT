     FD-KEYB: international keyboard BIOS enhancement for FreeDOS
     ============================================================

  ===========================================================================

   FD-KEYB: enhances or replaces BIOS keyboard management to adapt it to
   international keyboards.

   Copyright (C) 2006 by Aitor SANTAMARIA_MERINO
   aitorsm@inicia.es

   Version  : 2.00
   Last edit: 2006-08-29 (ASM)

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



0.- INTRODUCTION
================

FD-KEYB enhances or replaces the BIOS keyboard management to adapt it to
international keyboard layouts (such as German, Spanish or Japanese keyboards),
thus allowing DOS to transparently use these keyboards as natively supported
by BIOS.

It is often called a "keyboard driver", and it also implements the DOS KEYB
Multiplexer API. From now on we shall also use the word "driver", in the
understanding that it is not a true DOS device driver.

Besides producing characters, the driver can also be programmed to produce a
large variety of other effects, such as producing characters, triggering
interrupts, managing power or introducing the diacritics.

The driver has been specially built from scratch to fill the FreeDOS needs for
keyboard management (some code of KEYB2 was previously contributed to FreeDOS
xkeyb).


0.1.- Who should use the software

The software is to be used by all those worldwide users that own localized
keyboards and want their keyboard to act responsively on their FreeDOS (or
other DOS).

It also allows keyboard reprogramming, and may be used for those that want
to assign strings or other effects, or reprogram the behaviour of their
keyboard.


0.2.- Compatibility

In this version, the keyboard requires a PC with a DOS 2.0 or later.

FD-KEYB 2.00 understands KL files on their version 1.1, and compilation
files version 1.0.


0.3.- Limitations and incompatibilities

The KL files must be at maximum of 3 Kb files.

The driver may be incompatible with other drivers of the same style, specially
the earliest versions of KEYB of DR-DOS.


0.4.- Version

This is version 2.01 of FD-KEYB.

It understands version 1.1 of KL files, and version 1.0 of compilation files.


0.5.- Copyright

This program are distributed under the GNU General Public
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


0.6.- Installation

FD-KEYB requires a single executable to work, which is KEYB.EXE. You would also
need KL files suited to your keyboard layout, or compilation (KC files), such
as KEYBOARD.SYS.

(HINT: you may find packs of compilation files in the FreeDOS site, or make
your own with the compiler).

Place your KEYB.EXE commandline in AUTOEXEC.BAT if you want KEYB to load
automatically when you boot up.

Respect to the compilation files, or the KL files, they will be sought in
current directory, in the directory of KEYB.EXE and through the %PATH%
environment variable.


0.7.- Known bugs and reporting bugs

There are no known bugs.

If you find a bug, please make sure that the bug affects KEYB.EXE and not the
layout you are using. If the problem is in one of the KL files you are using
and not in KEYB.EXE, the resolution can be delayed as you would need to contact
the developer of the KL files instead.

If you want to report bugs, please fill a bug report on the FreeDOS Bugzilla:

http://www.freedos.org/bugs/bugzilla/

Alternatively, write an email to

Aitor SANTAMARIA MERINO
aitor.sm@gmail.com


0.8.- File history

FD-KEYB has been completely rewritten from scratch, although it has been
written by successively replacing different parts of xkeyb in the xkeyb
executable (in prototypes 1-4).

This version of KEYB is completely new, and does not have any xkeyb code
(although some routines written by me may be shared between the prototypes
and FD-KEYB).

Version 2.00 is released the 28th of August, 2006

Version 2.01 is released the 26th of September, 2011
- Fix: IRET now preserves flags too
- Fix: Memory allocation strategy was not properly recovered after running KEYB
- Fix: Before using XT-specific flags, XT machine is tested
- Fix: bug that prevents working with the secondary buffer and long strings



0.9.- Acknowledgements

Although developed from scratch, I am sincerely very grateful to a large number
of people that have helped me.

Henrique Peron for his help and bug reports.

Matthias Paul for his extensive knowledge of hardware and DOS, his hints and
his contributed code for the APM management commands (flushing caches).

Axel Frinke, for his help with code, patience and very interesting ideas that
have saved several bytes of code.

T. Kabe for his ideas, valuable information (mainly about DOS/V) and testing.

D. Hoehmann, for creating the original xkeyb, from which I learnt about
leyboards, and for his ideas, mainly for string management.

Eric Auer, for his beeping code and hints


1.- KEYB features
=================


1.1.- Commandline syntax


  KEYB  layoutName[,[CP][,filename]]  [/ID:nnn]  [/E] [/9] [/I] [/Dx] [/V]
        [/L=m] [/NOHI] [/B] [/S]
  KEYB [/U]
  KEYB /?

A keyboard layout is identified by two labels, a string label, which is
mandatory (usually a two letter string, such as GR, FR or SP), and an optional
numeric identifier to distinguish different variants.

KEYB data is stores in a separate MCB in upper memory by default.

Parameterless KEYB will show information on the currently loaded KEYB.

LayoutName    string identifier
/ID:nnn       Specifies the numeric identifier nnn
filename      The KL file that contains the information for the given layout,
              or the compilation file where the information resides.
              If it is omitted, then KEYBOARD.SYS is tried, alternatively 
              <LayoutName>.KL
/E            Specifies that the keyboard is an AT enhanced keyboard
              (this switch is incompatible with /9)
/9            Specifies that int9h management services must be activated
              (this switch is incompatible with /E)
/I            Forces the installation over an already existing keyboard driver
/Dx           Sets the decimal separator character to x
/V            Verbose: prints more information
/L=m          Sets the initial submapping to m, provided that it is compatible
              with current codepage
/NOHI         Forbids KEYB to load any data to upper memory
/B            Forbids KEYB to produce sound alerts (beep)
/S            Safemode: open compilations loading, strings, some critical
              commands are forbidden

/U            Unloads a KEYB previously loaded in memory

/?            Shows the fast help


1.2.- Exit codes and causes of errors

FD-KEYB is compatible with the exit codes of MS-KEYB. However, as a large
number of possible error causes is considered, an alternative numeration of
errors is shown on screen at load time.

ExitCode  KEYB error code  Error description
==============================================================================
    0        0             Successful execution

                         INVALID LANGUAGE, CODE PAGE OR INCORRECT SYNTAX
    1        3             Missing keyboard identifier <layoutName>
    1       11             Invalid modifier or switch
    1       14             Specified file does not contain information for
                             this layout/id
    1       21             Required submapping does not match with current
                           codepage: you are using /L=m but the requested
                           submapping does not correspond with current CP

                         BAD OR MISSING KEYBOARD DEFINITION FILE
    2        4             Specified file could not be opened
    2       13             Invalid file, or file corrupt
    2       19             Incompatible version of keyboard descriptor
                           (the compilation file or KL file are of an
                           incompatible version)
    2       20             Invalid checksum for data block: the compilation
                           file is corrupt
   
    3       10             The keyboard table could not be created

    4       16             Error in communication with the CON device

    5       17             The codepage has not been prepared

    6       12             Codepage not found in keyboard definition file - 

                         INCOMPATIBLE KEYB OR VERSION FOUND
    7        1             Different version of KEYB installed
    7        2             Incompatible keyboard driver installed
    7       18             Incompatible version of DR-KEYB installed

--- Not present in MS-KEYB

                         RESIDENT PART OF KEYB COULD NOT BE REMOVED
    8        5             The resident part of KEYB could not be removed
    8        8             KEYB was NOT installed

                         UNEXPECTED PROBLEM: VISIT THE KEYB SITE FOR A NEWER
                         VERSION OR CONTACT THE AUTHOR
    9        6             Internal failure: Global memory space too small
    9        7             KEYB (still) requires an AT/286 or better
    9        9             Overloading is (still) not supported
    9       15             KL file too large ((still) 3KB maximum)

==============================================================================


1.3.- FD-KEYB features

The following is a brief list of features of FD-KEYB:

* Programmability. The driver can be programmed using KL files. You can create
  customized KL files with the compiler, or use precompiled KL files, and use
  compilation packs of KL files, such as KEYBOARD.SYS.

* MS-KEYB compatibility. FD-KEYB is compatible with MS-KEYB in commandline, DOS
  Multiplexer API and Exitcodes. Note however that Microsoft's KEYBOARD.SYS is
  not compatible with FD-KEYB.

* Small size. Compared to MS-KEYB or xkeyb (around 6KB in resident size),
  FD-KEYB has a typical resident size of over 2KBs. This reduction is size is
  obtained by reubicating data and shrinking the memory used, and also by
  recycling BIOS keyboard support as much as possible.

* Codepage support. FD-KEYB implements full codepage support. Unlike MS-KEYB,
  that supports 2 codepages per layout, the number of supported codepages in
  FD-KEYB is virtually limitless. The next chapter is extensively devoted to
  the codepage management of KEYB.

* Extensive number of commands and effects: string output (including special
  chars and key combination simulation), diacritics, interrupt triggering
  (incl. Break, Print Screen, SysReq, etc.), managing system power and self
  configuring. The anexe document lists the supported commands.

* Keys, key combinations, key pressing/releasing and E0-prefixed keys are
  supported and can be reprogrammed.

* Automatic detection of keyboard type (that can be overriden with the /E and
  /9 switches)

* Additional shifting and locking keys can be defined to create entire new
  planes of effects.

* It can be automatically disabled/enabled by pressing Ctrl+Alt+F1/F2,
  respectively. The decimal separator char can be easily reprogrammed through
  the commandline or in KL files

* It supports APL software by IBM

* It implements specific software hooks for Japanese language.

* Last but not least, it is open source software under the GNU-GPL 2.0, which
  is written mostly in x86 assembler (TASM), with a non-resident stub in Pascal
  (Turbo Pascal)


1.4.- Compiling the driver

In order to compile the driver, you need a Turbo Pascal compiler that supports
embedded TASM procedures, such as Borland/Turbo Pascal 7.0 (French version
freely available under the Borland France site).

The program is finally packed using the open source UPX/UCL packer.

Respect to the structure of the program, just a couple of notes:

- The program has a resident part in assembler, and a non-resident part in
  Pascal.

- The resident part has two parts, a first core part that is always kept,
  corresponding with the basic int15h management (main code hooks at int15h,
  AH=4Fh), the multiplexer and other basic stuff. The second part is a
  collection of modules, that are discarded if not used.

- Interrupts 15h and 2Fh are always hooked. Interrupt 9h is hooked when modules
  6 onwards are loaded. Interrupt 16h is hooked if strings are used.

- When strings are used, a secondary buffer is created. This buffer contains
  references to strings that are expanded into the primary buffer. This code is
  made by the int16h handler, that works otherwise transparently

- When KEYB has to check wether a scancode/plane pressed is found, three tables
  are checked. The one for the particular submapping, then the one for the
  general submapping, and finally a third table catching Ctrl+Alt+F1/F2 and the
  numeric Del key. If it is not catched, then it is surrended back to BIOS.



2.- Codepage support
====================

Codepage support is an interesting topic requiring a full chapter.

Each layout can be adapted to work with a certain number of codepages. Notice
that the keyboard is part of the CON (console) device, thus KEYB will enforce
consistency of codepages with DISPLAY.SYS and with the system as much as
possible.


2.1.- The boot-up check

When KEYB is loaded, the following sequence is followed in order to determine
the codepage to be used.

(1) Codepage specified by the user in the commandline. This overrides any other
specification.

(2) Codepage shown by DISPLAY.SYS, if any. If the user didn't specify a
codepage, KEYB will check wether DISPLAY.SYS is present, and wether it has an
active codepage. If both conditions are met (DISPLAY.SYS present and with
active codepage), that codepage will be used by KEYB.

(3) If DISPLAY.SYS is not present, or it doesn't have an active codepage, then
KEYB will finally try the system codepage, obtained from interrupt AX=6601h of
DOS in BX (this can be read running "CHCP" parameterless).

Whenever FD-KEYB has determined the codepage that is to be used, it will read
and search for it in the KL file to be loaded. If it is not found there, then
KEYB will refuse to load. Otherwise, the first particular submapping
implementing that codepage (or with cp 0) will be used.


2.2.- Interfacing with DISPLAY.SYS

DISPLAY.SYS and KEYB form a functional unit that implements a codepage aware
console.

However, KEYB will never talk to DISPLAY after boot time (where KEYB asks
DISPLAY the current codepage). KEYB will expect that DISPLAY requests it to
change the codepage as appropriate (through the MuX interrupt already
implemented).

DISPLAY.SYS issues codepage change calls whenever it (the CONsole) is forced
to change its codepage (by NLSFUNC or MODE CON CP SEL). FD-KEYB responds as
appropriate to any call issued by DISPLAY.SYS to change the codepage.

============= <END-OF-DOCUMENT>