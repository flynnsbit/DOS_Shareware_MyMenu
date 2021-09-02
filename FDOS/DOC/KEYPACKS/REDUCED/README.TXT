Reduced Layout Packs, ver 1.15
==============================
  Henrique Peron (hperon@brturbo.com, peron@o2.net.br)
  Aitor Santamaria_Merino (aitor.sm@wanadoo.es)


Keyboard layouts for 
    FreeDOS xkeyb version 1.13 (and later)

This software is free software, and is distributed under the GNU-GPL
license version 2.0 or later.

You should have received a copy of this license with the package
(COPYING.TXT). Otherwise, please contact the Free Software Foundation at
     www.gnu.org


--------
   1.- About the layouts
   2.- How to install the layouts
   3.- Known issues
   4.- Contributions and feedback



1.- ABOUT THE LAYOUTS
=====================

This reduced pack, as opposed to the Full pack, contains an extract of
44 layouts.

For the rest of the layouts, please refer to the full pack.

All layouts  released in Reduced Layout Packs are presented either in their
standard forms (thus echoing in the screen what you see in the keyboard) or
in special "cp437-shortened" forms. The latter is related to the very  same
keyboard you have, though some labeled keys (and/or some combinations) will
NOT be echoed because codepage 437 does not provide the characters on those
labeled keys or combinations.

Please check the LAYOUTS.TXT to know about the keyboard layout definitions
and codepages under which these layouts are supposed to be used.



2.- HOW TO INSTALL THE LAYOUTS
==============================

XKEYB, from version 1.11 onwards, will admit one of these layouts as
parameter. You may provide full path as parameter, for example:

XKEYB C:\NEW\PACKS\FR.KEY

Alternatively, you can place the packs in the same directory as XKEYB.EXE,
or in a directory through the PATH environment variable, so that you avoid
fully qualifying the path to the file (and even omit the extension):

XKEYB GR

About the XKEYB program version, note that:

1) These packs are NOT compatible with xkeyb 1.12 or below, and will not work
with such versions. In xkeyb 1.11 and xkeyb 1.12, you can however workout a
correct file, by merging it with PC437.KEY, but there are no strong software
incompatibilities. This is not true for xkeyb 1.10 and below, where all layouts
having COMBI will not work.

2) After xkeyb 1.13, it is absolutely neccessary to place the mandatory
file PC437.KEY in the same directory of XKEYB.EXE, or alternatively, to place
such file visible through PATH.

3) You are strongly recommended to try and use latest version of xkeyb, as
some of the bugs in the program may not let you make full use of these new
layouts.

4) This package version is newer than the standard collections of layouts at
Xkeyb 1.13.


3.- KNOWN ISSUES
================

The information used to encode all layouts refers in most cases to graphical
operational systems, so it is possible that characters are found in <AltGr>
positions which are blank in the DOS versions of the layouts.

4.- CONTRIBUTIONS AND FEEDBACK
==============================

All your comments or ideas, and specially your feedback is welcome. You can
use the authors' email addresses as below (languages are indicated)

  Henrique  PERON (hperon@brturbo.com, peron@o2.net.br)     (English/Portuguese)
  Aitor     SANTAMARIA_MERINO (aitor.sm@wanadoo.es)         (English/Spanish)


For any problems regarding the KEY layouts, please email Henrique.
For any problems with the XKEYB executable program, please email Aitor.
If you are not sure where the problem comes from, please email both or Aitor.
