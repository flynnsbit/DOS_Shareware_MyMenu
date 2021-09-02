
                         NANSI.SYS
             An Enhanced MS-DOS Console Driver
         Version 4.0a 11/2003, 4.0b 2006 4.0c/d 2007
                  http://kegel.com/nansi/



1.  Introduction - Who should use NANSI.SYS



NANSI.SYS is a console device driver for MS-DOS  computers.   It  exe-
cutes the same ANSI cursor control sequences as does the standard con-
sole driver  ANSI.SYS,  but  significantly  faster.   It  also  offers
several extra features, while still being simple, small, and cheap.

You can benefit from using NANSI.SYS if:
1. you use programs (such as DIR, MORE, or NETHACK) which display text
on the screen via DOS, or
2. you have an EGA or VGA, and want to use the 43- or 50-line mode  of
your display, or
3. you run out of space when redefining keys with ANSI.SYS, or
4. you are a programmer who uses ANSI escape sequences, and are  frus-
trated with slow display updates, or
5. you are porting display-intensive Unix programs to  run  under  MS-
DOS.

You will not benefit from using NANSI.SYS if:
1. you never wish commands like TYPE or DIR were faster, and
2. you only use programs like Microsoft Word or  Word  Perfect,  which
bypass DOS when displaying text, and
3. you aren't interested in displaying 43 lines of text on your EGA or
VGA, and
4. you have never heard of ANSI.SYS anyway.

The display speed improvement you get by installing NANSI.SYS  depends
on  the  kind of programs you run.  Installing NANSI.SYS will bring no
improvement in display speed for programs that bypass DOS (e.g. Micro-
soft Word), a 30% improvement in display speed with most programs that
don't bypass DOS, a 50% improvement  with  "optimized"  programs  (see
chapter 9 below), and a 95% improvement with "optimized" programs that
avoid scrolling.

One "optimized" program, COPY /b, comes with DOS.  To test  the  speed
improvement  yourself,  create  a  long  text  file named foo.txt, and
display it with COPY /b foo.txt con: with NANSI.SYS installed- it will
go by very quickly.  This speed increase occurs even when running in a
window in Microsoft Windows 3.0.



2.  Compatibility



NANSI.SYS has been tested on IBM PC/XT, /AT,  and  PS/2  systems.   It
should  run  on any CGA, MDA, EGA, or VGA compatible video card. It is
compatible with Microsoft Windows 3.0.  Unlike  many  display  speedup
progams,  it  does not use wierd hardware scrolling tricks, and there-
fore remains completely compatible with programs that  write  directly
to the screen. That way, you will hardly ever need the /R switch  even
for screen reader software (which reads  the screen, e.g.  for speaker
output or Braille display output). Compatibility to multitaskers  like
DESQview should be given in /R /B mode: If not, please *report* (then,
int 10.fe "query alternate video RAM pointer es:di" will be used,  and
maybe int 10.ff "video RAM change notification" will be sent -  "RSIS"
feature will be added to NANSI, in other words!)



3.  Copyright status



This program and documentation is Copyright 1986, 1991  Daniel  Kegel.
The  executable  program  and  its documentation may be freely distri-
buted.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
or look on the web at http://www.gnu.org/copyleft/gpl.html.

Correspondence (in English, German, or French) should be
directed to the author at    dank (at) kegel.com



4.  Version



The version number can be found with the DOS command TYPE NANSI.SYS.
This documentation is for version 4.0, created November 2003.



5.  Installation and System Requirements



NANSI.SYS version 4.0 is distributed as the archive NANSI35.ZIP,  with
the following contents:

        NANSI.SYS    - the device driver
        NANSI.DOC    - this documentation file
	LICENSE.TXT  - GNU License (GPL): This now is open source freeware!
        RAW.C        - how to set and clear RAW mode
        RAW.H        - definitions for users of RAW.C

	MAKEFILE     - use with "make" to compile NANSI
	MAKEFILE.BAT - if you have no "make", use this to compile NANSI
	NANSI*.ASM   - source code for NANSI. Compiles with MS MASM or the
	               freeware version of Arrowsoft Assembler (ASM)
	TOOLS.TXT    - hints about which compilers are possible

NANSI.SYS requires MS-DOS version 2.0 or  higher,  and  uses  about  3
kilobytes of system RAM.

To install NANSI.SYS on your computer, copy the file NANSI.SYS to your
boot disk (usually C:), and include one of the following statements in
the configuration file CONFIG.SYS on your boot disk:
For IBM VGA and Vega VGA cards, or if you don't know  (or  care)  what
kind of card you have:

        DEVICE=NANSI.SYS

For Paradise VGA Plus cards:

        DEVICE=NANSI.SYS /t54 /t55 /t56 /t57

For VGA cards using the Oak Technology OTI-067:

        DEVICE=NANSI.SYS /t4F /t50 /t51

For VGA cards using the Trident Microsystems TVGA 8900:

        DEVICE=NANSI.SYS /t50 /t51 /t52 /t53 /t54 /t55 /t56 /t57 /t58 /t59 /t5A

General syntax description:

	DEVICE[HIGH]=NANSI.SYS [/K] [/C] [/X] [/S] [/Tnn] [/R] [/B|/Q] [/P]
	
In short ([/Q] means "optionally give the /Q switch"):
/K "force 84 key keyboard style"	/X "extended key definitions"
/S "safe mode - no key redefinitions"	/Tnn "mode nn is a text mode"
/R "use BIOS (for some screen readers)"	/B "use BIOS for bell sound"
/P "pass all unknown requests to CON"	/C "force 101+ key keyboard style"
/Q "use no bell sound at all (quiet)"	/? show help



6.  COMMAND-LINE OPTIONS

6.0.  /?   : Help message.

Whenever Nansi encounters any option syntax error, it shows a short
help message describing the supported options. You can for example
give the option /? to make Nansi display this help message. While
supporting /? is exotic for device drivers, it is useful for people
who want to use Nansi instead of their old ANSI driver and fail to
read the nansi.doc file in full detail ;-).

6.1.  /K   : force Nansi to use extended keyboard BIOS calls.

If you have an  101+ key keyboard  but it is not detected, NANSI would
normally use the old style BIOS calls which discard  everything  which
does not make sense on an 84 key keyboard. Use  /K  to force  NANSI to
treat the keyboard as 101+ key keyboard.

The 101+ key (AT) keyboard has F11 and F12 keys and it has blocks of
cursor and similar keys, and a numeric keypad.

WARNING: NANSI 3.x had a /K switch which ENABLED 101+ key  processing!
The new syntax is /K to DISABLE 101+ key processing, as in FreeDOS  or
MS DOS kernel "switches=/k".

6.2.  /C   : force Nansi to use 84 key keyboard BIOS calls.

If NANSI misdetects your 84 key keyboard as  101+ key keyboard,  or if
your BIOS does not support the 101+ key style calls and NANSI fails to
detect that, you can force NANSI to use only the old style  BIOS calls
with this option. This causes  the BIOS to  discard  everything  which
does not make sense on an 84 key keyboard. So you can also use this to
"simulate" an 84 key keyboard while actually having an 101+ key one.

WARNING: NANSI 3.x had a /K switch which ENABLED 101+ key  processing!
The new syntax is /K to DISABLE 101+ key processing, as in FreeDOS  or
MS DOS kernel "switches=/k".


6.3.  /X   : tell Nansi to let you redefine the extended keys indepen-
dantly

IBM's extended keyboard BIOS calls added something  new:  they  return
different  scan  codes  for different keys with the same meaning.  For
instance, they return 71 for the numeric keypad HOME key,  but  224;71
for the gray HOME key.  Nansi returns 71 when either of these keys are
pressed.  However, the /X option causes these keys to be treated  dif-
ferently  during  keyboard  redefinition.   For  example, if you start
Nansi with the /X option, you can define just the gray HOME key to say
"dir/w" by sending the string ESC [224;71;"dir/w";13p

6.4.  /S   : tell Nansi to be secure, and disable  keyboard  redefini-
tion

Although it is nice to be able to redefine the  keyboard  with  escape
sequences,  it  is  a  gaping  security hole.  To prevent trojan horse
attacks from messages in text files, archives, and programs downloaded
from  the  outside  world, disable this feature by invoking Nansi with
the /s option in config.sys.  For example,

        DEVICE=NANSI.SYS /s /t54 /t55 /t56 /t57

This saves a few bytes of memory, too. With redefinitions disabled,
less code has to stay in RAM and the buffer for ESC parsing and
redefinition storage can be smaller if no redefinitions are used.

6.5.  /Tnn : tell Nansi that video mode nn is a text mode

No two VGA cards seem to have the same set of video mode  codes.   The
same  mode number can indicate a graphics mode on one card, and a text
mode on another card.  Worse yet, BIOS can't tell  you  what  kind  of
mode  it's  in.   This  is  a  problem because Nansi gets its speed by
bypassing BIOS, which it can only do in text modes.

Nansi solves this dilemma by maintaining a 256-entry table, one  entry
per  possible  video mode.  By default, the table says that only modes
0, 1, 2, 3, and 7 are text modes.  You can add new text modes with the
/t  option.   For  instance, if modes D hex and 50 hex are text modes,
you would invoke Nansi as follows:

        DEVICE=NANSI.SYS /t0D /t50

How to tell whether you need /t:
If your board is in a non-IBM text video mode (for instance,  mode  50
hex),  and  you  haven't added /t50 after NANSI.SYS in CONFIG.SYS, the
cursor will disappear after a CLS command, and the text output will be
sluggish;  furthermore, if you turn on the graphics cursor (by TYPEing
the file GC.ON which came with NANSI), the beginning and end of  every
text line will be garbled.

How to tell whether you don't need /t:
If you mistakenly specify a graphics mode  with  the  /t  option,  the
display  will  be  garbled  while in that mode.  Get back to normal by
typing MODE CO80 or rebooting, and remove the offending /t option from
config.sys.

6.6.  /R : use the BIOS to write to screen only

Other  ANSI  implementations  use  this switch to change the scrolling
style to a more screen reading software compatible one. NANSI only has
this switch to force all writes to screen to happen through BIOS,  but
this  mode is much slower.  Basically  it is the  counterpart of /Tnn,
and tells NANSI that all modes are "no textmodes". This  is useful  if
you run DOS in a  multitasker  or another environment  which redirects
only BIOS output but not direct screen  memory access  properly.  As a
side effect, /R disables direct CRT controller programming to position
the cursor or to resize it.

6.7  /B : use the BIOS to make a beep sound

If  your computer  has no PC-AT compatible internal  timer and speaker
hardware, or if you want to redirect the beep (bell) output, use  this
switch to force NANSI to use BIOS rather than direct  hardware  access
for beeping.

6.8  /P : pass all unknown requests to CON

Some CON drivers offer extra functions. If you load NANSI after one of
them, you can try this option to make NANSI pass all function requests
that it cannot handle itself to the CON driver which predecedes NANSI.

6.9  /Q : Do not make a beep sound

Instead of the /B option, you can use the /B option to disable all
sounds made for beep / bell character output. Works on all hardware.


7.  ANSI Control Sequences



While putting text up on the screen, NANSI.SYS keeps a lookout for the
escape  character  (chr(27), known as ESC); this character signals the
start of a terminal control sequence.  Terminal control sequences fol-
low the format
    ESC [ param; param; ...; param cmd
where
    ESC is the escape character chr$(27).
    [ is the left bracket character.
    param is an ASCII decimal number, or a string in quotes.
    cmd is a case-specific letter identifying the command.
Usually, zero, one, or two parameters are given.   If  parameters  are
omitted, they usually default to 1; however, some commands (KKR) treat
the no-parameter case  specially.   Spaces  are  not  allowed  between
parameters.

For example, both ESC[1;1H and ESC[H send the cursor to the home posi-
tion (1,1), which is the upper left.

In general, if you ask the cursor to go beyond the edge of the screen,
it goes to the appropriate edge.  (ANSI.SYS was not always so nice.)

The following C macro illustrates how one could print a  string  at  a
given location on the screen:
    #define printXY(x,y,s)  printf("%c[%d;%dH%s", 27, y, x, s);

Either single or double quotes may be used to quote  a  string.   Each
character  inside a quoted string is equivalent to one numeric parame-
ter.  Quoted strings are normally used only for the Keyboard Key Reas-
signment command.

Each ANSI control sequence supported by NANSI.SYS is described  below.
The descriptions follow the format

7.0.1.  ABBREVIATED_NAME: what_to_send  LONG NAME

where ABBREVIATED_NAME is a short name for the sequence,  what_to_send
tells  you  what  characters  make up the sequence, and LONG NAME is a
long name for the sequence.


7.1.  Sequences dealing with Cursor Positioning

7.1.1.  CUP: ESC[#;#H  Cursor Position

Moves the cursor to the position specified  by  the  parameters.   The
first parameter, y, specifies the row number; the second parameter, x,
specifies the column number.  If no parameters are given,  the  cursor
is moved to (1,1), the upper left corner of the screen.

7.1.2.  HVP: ESC[#;#f  Horizontal and Vertical Position

This is identical to Cursor Position.  Don't ask me why it exists.

7.1.3.  CUU: ESC[#A    Cursor Up

Moves the cursor up the given number of rows without changing its hor-
izontal position.

7.1.4.  CUD: ESC[#B    Cursor Down

Moves the cursor down the given number of rows  without  changing  its
horizontal position.

7.1.5.  CUF: ESC[#C    Cursor Forward

Moves the cursor right the given number of  columns  without  changing
its vertical position.

7.1.6.  CUB: ESC[#D    Cursor Backward

Moves the cursor left the given number of columns without changing its
vertical position.

7.1.7.  DSR: ESC[#n    Device Status, Report!

# must be 6.  The sequence ESC[6n causes the console driver to  output
a CPR (Cursor Position Report) sequence.

Note: This sequence is not supported by the  ANSI.SYS  emulator  built
into Microsoft Windows 1.x or 2.x.

7.1.8.  CPR: ESC[#;#R  Cursor Position Report

The console driver  outputs  this  sequence  upon  reciept  of  a  DSR
sequence.   The first parameter is the cursor's vertical position; the
second parameter is the cursor's horizontal position.

Note: Contrary to the  MS-DOS  manual,  ANSI.SYS  outputs  a  carriage
return  after  this  sequence.   NANSI.SYS  faithfully reproduces this
quirk.

The resulting string can have up to eleven characters.   For  example,
if   you  have  a  100-line  display  (wow),  and  the  cursor  is  at
(x=132,y=100), the string will be ESC[132;100R followed by a  carriage
return.

This should never be sent to the console driver.

Also note: This sequence is not supported  by  the  ANSI.SYS  emulator
built into Microsoft Windows 1.x or 2.x.

Here is an example of how to use DSR/CPR to find  the  current  cursor
position with the C language:

        /* Code fragment to get current cursor X and Y from console */
        /* Be sure to disable line-buffering on stdin before calling */
        int x, y, c;
        printf("\033[6n");
        fflush(stdout);
        if (getchar() != '\033' || getchar() != '[')
            abort("Console not responding to DSR?");
        for (y=0; isdigit(c=getchar()); y=y*10+(c-'0'));
        if (c != ';')
            abort("Console CPR faulty?");
        for (x=0; isdigit(c=getchar()); x=x*10+(c-'0'));
        if (c != 'R')
            abort("Console CPR faulty?");
        #ifndef VT100
            getchar();  /* ignore trailing CR */
        #endif

This can also be useful for sensing screen size.

7.1.9.  SCP: ESC[s      Save Cursor Position

Saves the cursor's X and Y locations in  an  internal  variable.   See
RCP.

7.1.10.  RCP: ESC[u    Restore Cursor Position

Moves cursor to the position it held when the last  SCP  sequence  was
received.


7.2.  Sequences that Edit the Display

7.2.1.  ED: ESC[#J    Erase in Display

# must be 2.  Clears the entire screen.

Note: Contrary to the MS-DOS manual, ANSI.SYS also moves the cursor to
the  upper  left corner of the screen.  Contrary to the ANSI standard,
ANSI.SYS does not insist on # being 2.   NANSI.SYS  faithfully  repro-
duces  these quirks.  (Version 2.2 of NANSI.SYS insisted on # being 2,
and it caused compatibility problems with programs  that  ignored  the
MS-DOS manual.  Sigh.)

7.2.2.  EL: ESC[K    Erase in Line

Deletes from the cursor to the end of the line.

7.2.3.  IL: ESC[#L    Insert Lines

The cursor line and all lines below it  move  down  #  lines,  leaving
blank  space.   The  cursor  position  is unchanged.  The bottommost #
lines are lost.

Note: This is not supported in ANSI.SYS.

7.2.4.  DL: ESC[#M    Delete Lines

The block of # lines at and below the cursor are  deleted;  all  lines
below  them  move up # lines to fill in the gap, leaving # blank lines
at the bottom of the screen.  The cursor position is unchanged.

Note: This is not supported in ANSI.SYS.

7.2.5.  ICH: ESC[#@    Insert Characters

The cursor character and all characters to the right of it move  right
#  columns,  leaving  behind  blank  space.   The  cursor  position is
unchanged.  The rightmost # characters on the line are lost.

Note: This is not supported in ANSI.SYS.

7.2.6.  DCH: ESC[#P    Delete Characters

The block of # characters at and  to  the  right  of  the  cursor  are
deleted;  all characters to the right of it move left # columns, leav-
ing behind blank space.  The cursor position is unchanged.

Note: This is not supported in ANSI.SYS.


7.3.  Sequences that Set Modes

7.3.1.  KKR: ESC["string"p   Keyboard Key Reassignment

The first char (or, for function keys, two chars) of the string  gives
the  key  to  redefine; the rest of the string is the key's new value.
To specify unprintable chars, give the ASCII value of the char outside
of  quotes,  as  a  normal  parameter.  IBM function keys are two byte
strings starting with zero.  For instance, ESC[0;59;"dir a:";13p rede-
fines  function key 1 to have the value "dir a:" followed by the ENTER
key.

There are about 500 bytes  available  to  hold  redefinition  strings.
Once this space fills up, new strings are ignored.

To clear all definitions, send the string ESC[p.  (There was no way to
do this in ANSI.SYS.)

This feature is a security risk, and  can  be  disabled  with  the  /s
option  when  loading  Nansi  in config.sys.  See Command-line Options
above.

Here's a table of the ASCII values of the common  function  keys;  for
others,  see  the IBM Basic manual or the "IBM PS/2 and PC BIOS Inter-
face Technical Reference," a steal at $80 from IBM (1-800-IBM-PCTB).

        F1  0;59        F2  0;60        F3  0;61        F4  0;62
        F5  0;63        F6  0;64        F7  0;65        F8  0;66
        F9  0;67        F10 0;68        F11 0;133       F12 0;134
        HOME 0;71       END  0;79       PGUP 0;73       PGDN 0;81
        INS  0;82       DEL  0;83       LEFT 0;75       RIGHT 0;77
        UP   0;72       DOWN 0;80

When /X is given, the gray Insert, Delete, Home, End, PageUp,  PageDn,
and  arrow keys on an Extended keyboard can be redefined separately by
using 224 rather than 0 as the initial byte.

7.3.2.  SGR: ESC[#;#;...#m  Set Graphics Rendition

The Set Graphics Rendition command is used to  select  foreground  and
background  colors  or  attributes.  When you use multiple parameters,
they are executed in sequence, and the effects are cumulative.

        Attrib     Value
            0      All attributes off (normal white on black)
            1      Bold
            4      Underline
            5      Blink
            7      Reverse Video
            30-37  foreground black/red/green/yellow/blue/magenta/cyan/white
            40-47  background black/red/green/yellow/blue/magenta/cyan/white

7.3.3.  SM: ESC[=nh  Set Video Mode

This sequence selects one of the available video modes. The  IBM  BIOS
supports  several  video modes; the codes given in the BIOS documenta-
tion are used as parameters to  the  Set  Mode  command.   (In  bitmap
modes, the cursor is simulated with a small blob (^V).)

            Mode Code           Value
                0               text 40x25 Black & White
                1               text 40x25 Color
                2               text 80x25 Black & White
                3               text 80x25 Color
                4               bitmap 320x200 4 bits/pixel
                5               bitmap 320x200 1 bit/pixel
                6               bitmap 640x200 1 bit/pixel
                13              bitmap 320x200 4 bits/pixel
                14              bitmap 640x200 4 bits/pixel
                15              bitmap 640x350 1 bit/pixel
                16              bitmap 640x350 4 bits/pixel
                17              bitmap 640x480 1 bit/pixel
                18              bitmap 640x480 4 bits/pixel
                19              bitmap 320x200 8 bits/pixel

Modes 0, 1, and 4-19 require a CGA, EGA or VGA.
Modes 13-16 require an EGA or VGA.
Modes 17-19 require a VGA.
Other graphics cards may support other video modes.

The EGA and VGA let you use a shorter character cell in text modes  in
order to squeeze more lines of text out of the 25-line text modes.  To
enter short line mode, set the desired 25-line text  mode  (0  to  3),
then Set Mode 43.  For instance: ESC[=3h ESC[=43h.  To exit short line
mode, set the desired 25-line text mode again.  On IBM VGA cards, this
sequence gives you a 50 line screen.  NANSI.SYS ignores mode 43 unless
there is an EGA or VGA on your computer.

7.3.4.  SM: ESC[?nh  Set Nonvideo Mode

This sequence is used to set non-video modes.   The  only  value  sup-
ported is

            Mode Code           Value when set
                7               Cursor wraps at end of line


Setting mode 7 tells the cursor to wrap around to the next  line  when
it passes the end of a line.

7.3.5.  RM: ESC[?nl  Reset Nonvideo Mode

This sequence is used to reset non-video modes.  The only  value  sup-
ported is

            Mode Code           Value when reset
                7               Cursor stops at end of line

Resetting mode 7 tells the cursor to 'stick' at the end  of  the  line
instead of wrapping to the next line.



8.  Background - What does a console driver do, and how?



A console driver consists of subroutines which are called  by  MS-DOS.
MS-DOS itself is mostly just subroutines which can be called by appli-
cation programs.

Programs that want to display text on the screen can call the  "Write"
subroutine  provided  by  MS-DOS.   This  subroutine in turn calls the
"Write" subroutine of the console driver.

When you, for example, type
    C> type foo.txt
COMMAND.COM uses the "Read" subroutine of  MS-DOS  to  read  the  file
"foo.txt" from the disk; it then uses the "Write" subroutine of MS-DOS
with the file's contents.  MS-DOS  then  calls  the  console  driver's
"Write" subroutine, which finally puts the data up on the screen.

Both ANSI.SYS and NANSI.SYS use IBM Video BIOS to control the  screen.
However,  NANSI.SYS  writes directly to the screen in text modes; this
allows much faster operation.



9.  How to Display Text Quickly



Output to the screen via DOS is usually slow  because  characters  are
sent  one-at-a-time  through  several layers of software.  Application
programs often call a DOS function for each character or line.

To avoid this overhead, application  programs  should  write  as  many
characters  per  DOS call as possible (in C programs, this means using
setbuf(), fflush(), and buffered output).

Another problem is that application programs sometimes send line after
line  of  text,  letting  the cursor stay at the bottom of the screen.
This forces the console driver to scroll the entire screen up once for
each line displayed, which is rather expensive.

This can be fixed by having the application program clear  the  screen
and home the cursor after each page of output.

Finally, the biggest problem is that DOS calls the device driver  once
or twice for each character written.

Fortunately, DOS can be told to pass the entire write request directly
to  the device driver; this is called "raw" mode.  The files RAW.C and
RAW.H, included in this package, provide an easy way to set and  clear
"raw"  mode, to turn break checking on and off, and to check for keys-
trokes when in raw mode.

Even if you follow all these rules, output with ANSI.SYS will still be
very  slow,  simply  because  IBM  did  a  bad job designing BIOS, and
because ANSI.SYS was written with  total  disregard  for  performance.
NANSI.SYS, on the other hand, was written by a performance fanatic.

If you use  FreeDOS,  there are less device calls.  In general, if you
use an "int29" / fast TTY driver for CON, the DOS kernel  will  bypass
some layers of software for some more common calls. While MS DOS  uses
BIOS functions 2 and 9 to position cursor and put characters,  FreeDOS
only uses BIOS function 14, TTY output, right away. This is often  the
faster way. Note that "speed up drivers" for MS DOS have no effect  on
FreeDOS, nor the other way round, due to this difference.



10.  NANSI and Microsoft Windows



Microsoft Windows 1.x and 2.x allowed you to run command.com in a win-
dow,  but did not give you access to NANSI.SYS.  Windows 3.0 gives you
full access to NANSI.SYS, even when running command.com  in  a  window
(wow!).   However,  you  can only do this if you have a 386-based com-
puter (boo, hiss); on other computers, Windows runs  command.com  only
in full screen mode.

Under Microsoft Windows 3.0, if you write text to stdout in RAW  mode,
the display is not refreshed until the end of the write; no intermedi-
ate scrolling is shown.  I suspect this  is  because  Windows  doesn't
refresh the display until display memory hasn't been touched for a few
milliseconds.



11.  Version differences



11.1.  New in version 4.0 of NANSI.SYS (changes by Eric Auer)

The new /B and /R flags now allow you to force using the BIOS to sound
a beep and to put characters on screen respectively.

The /K command line switch now works like the kernel SWITCHES=/K switch
and a new /C command line switch does what the  old NANSI 3.x /K switch
has done. See above.

The new /P flag allows  you to pass  on unsupported  requests to  other
CON drivers in the chain (improved in version 4.0a and 4.0b).

Compiling with free Assemblers and linkers is now explicitly supported.
Documentation got updated to reflect the changes between 3.3 and 4.0.

Version 4.0c implements the int 2F control interface ANSI install check
(return AL=FF for INT 2F calls with AX=1A00) and, for the fun of it,
also functions 1a01 and 1a02 (get/set display info, misc. control).

The /Q quiet bell (disable bell) option is also new in version 4.0c.

Version 4.0d saves a few 100 bytes of RAM when the /S option is used.
Version 4.0d also introduces the improved /? help message.

11.2.  New in version 3.3 of NANSI.SYS

Fixed bug that caused erratic behavior after ESC[p.  Bug was present in
all prior versions of NANSI.

Fixed a few typos in documentation. Changes between  3.3 and  3.4  are,
alas, not documented. But 3.4 has been a popular release of NANSI.

11.3.  New in version 3.2 of NANSI.SYS

Can finally read F11 and F12!

New /K command-line option forces Nansi to use Extended Keyboard  BIOS
calls  if  for  some  reason Nansi doesn't recognize the extended key-
board.

New /X command-line option lets user redefine "new" cursor motion keys
independently of "old" cursor motion keys.

Both of these switches are compatible with the switches  of  the  same
name in ANSI.SYS.

11.4.  New in version 3.1 of NANSI.SYS

A new escape sequence has been added to enable and disable  the  simu-
lated  cursor in graphics mode (see SET MODE 99).  The graphics cursor
is disabled by default.

Nansi can now sense options given  on  the  DEVICE=NANSI.SYS  line  in
config.sys.

/S command-line option has been added to disable the keyboard redefin-
ition escape sequence.  This closes up a big security loophole.

/T command-line option has been added to allow the user to tell  Nansi
about  nonstandard  text video modes (see COMMAND-LINE OPTIONS).  This
is important if you want to use non-IBM text modes properly, as  Nansi
treats  nonstandard  modes  as  graphics  by default, which results in
slower display.

11.5.  New in version 3.0 of NANSI.SYS

Now obeys BIOS's idea of number of screen lines, when supported.

Works properly when on video pages greater than zero, too.

Supports 132-column displays.

Deleted Output Character Translation feature.  It took up  260  bytes,
and nobody ever used it.

Fixed bug related to setting background color while in graphics mode.

No longer assumes AH is zero upon entry to driver.



12.  Limitations in the current version of NANSI.SYS



Video modes are specified in hexadecimal on the command line,  and  in
decimal  in  escape  sequences.  This is a needless inconsistancy, but
since users' manuals usually specify  the  mode  numbers  in  hex,  it
shouldn't  be  too big a bother.  You can convert a hexadecimal number
to decimal in BASIC with the print command.  For example, from the DOS
prompt, typing

        C:>basic
        print &h7f
        system

displays "127".

All parameter values must be between 0 and 255  (in  escape sequences,
ANSI is defined that way anyway.

The maximum number of characters available for  keyboard  redefinition
is  500.   Any  single  keyboard  redefinition escape sequence must be
shorter than (500 - (total keyboard redefinition space already  used))
bytes. If you use more redefinitions, NANSI might crash!

Insert and delete character do not work in graphics modes.

Graphics mode writing is slow.  If this bothers you, try NNANSI, which
is someone else's modification of NANSI v2.2 to attack just this prob-
lem.

Does not support erase-to-end-of-screen and other useful functions. **

Nansi determines whether the BIOS number-of-screen-lines  variable  is
supported by checking for an EGA card. There might be a better way for
users of "older than EGA" cards that support other than 25 lines  - if
such cards exist.

Nansi only checks for an EGA or VGA card at startup time.  If you have
two  video  cards  installed, and one shows more text lines per screen
than the other, AND you switch between the  cards  without  rebooting,
Nansi could CONCEIVABLY become confused about the number of text lines
on the screen. NANSI 3x can update the line count automatically later!


