
Telemate 4.21    6 February, 1996
=================================

Installing a new Telemate
=========================

The following steps show how to install Telemate on the C drive of your
hard disk drive. You can use any other drive by substituting the letter
of your drive in place of C in the example below.

 1) Make a subdirectory for the Telemate files by typing MD \TM.
 2) Change to the Telemate directory by typing CD \TM.
 3) Copy all Telemate files to C:\TM.
 4) Start the installation program TMINST.EXE and set up your Telemate.

Now you are ready to run Telemate TM.EXE.


Upgrading from v4.1x and v4.20 to v4.21
=======================================

Upgrading from previous version is simple, you can replace the
following files with the new ones

    TM.EXE          the main program
    TM.OVL          the main program (overlay)
    TM.RES          the resource file
    TM.HLP          the help file
    TMS.EXE         the script compiler
    TMINST.EXE      the installation program
    TMSTAT.EXE      the statistic program
    TMPHONE.EXE     the phone maintenance utility
    HOST.EXE        the self-extract host scripts
    TOOLBOX.EXE     the self-extract toolbox scripts

There is no change in the configuration file format.
Note: DO NOT change the version number inside TM.CFG. It should
      read 4.11 even you are running 4.21.


What's new in Telemate
======================

. DTR is dropped when initializing the modem and between dialing to
  reset the modem. Some modems have problem reseting itself
  automatically.

. A form feed is now sent to the printer after printing a file or the
  clipboard.


What's fixed
============

. [Alt-R] cleared the window after dropped to DOS
. Exiting Telemate always cleared the screen.
. If a path was defined with the drive portion under the Options/
  Directory dialog, it gave the error: 'Path not found'.
. Access to hidden directory was not allowed
. While transfering, [Alt-T] only brought up the Transfer window.
  It now brings up both the Terminal window and the Transfer window.
. After jump to DOS, COM port may not respond
. Dialing directory is closed and it may run out of file handle after
  opening several of them.
. INPUT command received strange characters when [Alt-V],
  [Alt-E], etc is pressed.
. Too many WHEN command may cause a memory exception.
. TMPHONE.EXE may give wrong status line information.


Where to find it
================

Telemate 4.21 is now available in the following BBSs as TM421-1.ZIP,
TM421-2.ZIP, TM421-3.ZIP and TM421-4.ZIP.

    S.R.O. BBS             1-817-542-7388     Texas
    Terminator BBS!        1-414-867-3670     Wisconsin
    The Blackboard         1-914-354-1913     New York
    Com-Dat BBS            1-503-681-0543     Oregon
    Data Dump BBS          1-306-956-3383     Saskatchewan
    Bubble Isle BBS        1-514-657-2793     Quebec
    Arcade BBS             +61-8-262-3338     Australia
    Michael Lucas's BBS    +81-6117-44-4584   Japan
    Graeme Slogrove's BBS  +27-11-706-1749    South Africa
    Single Life BBS        +886-49-655877     Taiwan
    The Bus Stop BBS       +44-1273-774121    United Kingdom

In CompuServe, you will find TM4211.ZIP, TM4212.ZIP, TM4213.ZIP and
TM4214.ZIP in PCCOM forum Library 3/Comm program.

In Internet, you can obtain TM421-1.ZIP, TM421-2.ZIP, TM421-3.ZIP
and TM421-4.ZIP in ftp.vvm.com through FTP under the /regsite/telemate
directory; or at a later time in oak.oakland.edu [141.210.10.117]
under the /simtel/msdos/modem directory.

All ZIP files are compressed using PKZIP v2.04g and come with an
Authenticity Verification with our name and address in it.

The phone directory SUPPORT.FON is provided so that you can access
our support BBS and distribute sites easier.


------------------------------------------------------------------------------


Telemate 4.20     14 June, 1995
===============================

What's new in Telemate
======================

. @ListFile, e.g. @FILELIST.TXT, is now supported in the transfer
  file input window. The content of the ListFile, e.g. FILELIST.TXT
  (without the '@'), will be used as a list of files.

. [Center] key is now redefinable. If not redefined, the [Center]
  key will bring up the Back window. VT102.PAD has an escape code
  assigned to the [Center] key, so you cannot activate the Back
  window in VT102 terminal, unless you take out the [Center]
  definition under the Macro | Keypad dialog.

. The terminal now supports escape sequence like ^[[1;m which reset
  the terminal and then turn on high intensity.

. Enhanced BIOS support, up to 38400 baud can be used in the BIOS
  connection if an Enhanced BIOS is detected.

. The UART routine now supports serial card with SMC665 or SMC666 chips.
  Previously it may lock the system.

. When dialing, the dial bar holds the current position until there is no
  more user interaction. This makes selection while dialing easier.

. When dialing, clicking on the lower portion of the dial window will
  insert the entry into the dial list. Previously, clicking on any
  part of the dial window will dial the next entry.

. Screen saver hotkey [Alt `] can activate the screen saver even if the
  screen saver setting is set to 0.

. Leading space in the DOS command window is now trimmed

. In the File dialog, typing in the file name will position the list
  box to the closest-matched file. And you can press the [Down] key to
  go the the list box and quickly select a file.

. TMS supports a new /D option which will enforce Variable Declaration.
  Undeclared variable will be considered an error when this option is
  specified. This option is most helpful when programming larger script.
  All provided scripts are updated to declare all variables.

. TMINST.EXE allows you to disable the printer completely by setting the
  Printer to NULL. This option is most helpful to override and disable
  the printer commands sent by the remote system.

. TMINST.EXE now accepts 14400 and 28800 as the baud rate. These
  baud rates are converted to 38400 baud automatically when you
  exit TMINST.EXE.

. TMSTAT can process the CONNECT and ONLINE statement in a usage log in
  any order.

. New commands in TMScript

  1. "Set ScriptEcho, 0" will cause Telemate NOT to display the
     incoming characters. This flag is reset to 1 each time you
     run a script. The incoming characters will resume to display
     when the script is terminated.

  2. "Query ScriptEcho, flag" will put the current ScriptEcho
     setting into the <flag> variable.

  3. "Set AltKeys, 0" will disable all the ALT keys, [PgUp], [PgDn],
     [Ctrl PrtSc] and [Ctrl Home]. Use this setting carefully because
     the user cannot stop the script or exit Telemate. This flag is
     reset to 1 each time you run a script. The disabled keys will
     resume to operate when the script is terminated.

  4. "Query AltKeys, flag" will put the current AltKeys setting into
     the <flag> variable.

  5. "Waitfor -1", "Waitfor s1, s2, ..., -1". Setting the waiting
     time to -1 will cause the WAITFOR statement to return only
     if a waiting string is matched or a key is pressed on the
     keyboard.


What's fixed
============

. When dialing, press [Del] many time result in a strange dial list
. When a Zmodem auto-download occurs during chat mode, the
  chat mode is now turned off automatically
. When a Zmodem auto-download occurs during doorway mode, the
  transfer window did not go away until a key was pressed.
. Batch upload did not display the bottom half of the transfer window.
. Files larger than 999,999 bytes in DSZLOG were not considered as
  an external protocol transfer.
. SUCCESS variable did not reflect the correct value for an external
  protocol.
. GETCH command lost a lot of characters. This command is given
  higher priority so that the script can process all the incoming
  characters.
. CONCAT may cause a system error
. After a large script cannot be loaded due to memory error,
  smaller script cannot be loaded as well. This problem is fixed.
. HOST script did not set up the download path correctly
. HOST now send '.' to the remote system when the password
  is entered locally. Previously it send both the password
  and the '.'.
. When the user press ^) in the HOST script, it disconnected
  the host. This problem is fixed.


What's new in GIFLink
=====================

. When the -tm is specified, GIFLink now takes the COM base address
  and IRQ from the Telemate configuration file.

. When viewing or transfering a large amount of files, GIFLink
  may display a negative percentage. This problem is fixed.


------------------------------------------------------------------------------


Telemate 4.12     20 July, 1993
===============================

What's fixed
============

. ANSI showed characters in high intensity even if normal attribute
  should be used. Although the change was intentionally so that it
  worked the same way as in version 3.xx and before, it is now changed
  back to the way as in version 4.00.

  For those who want to use high intensity all the time, please run
  TMINST.EXE and set the terminal window color to "black on black". Then
  Telemate will understand you like high intensity and use "bright white
  on black" in the terminal window.

. Version 4.12 no longer give up timeslice to Windows. Windows does not
  give back the control to a background Telemate for several seconds (7
  seconds in my computer) if Telemate nicely give up the timeslice.

  Although OS/2 has a similar problem in heavy load, you can override it
  by setting MAXWAIT=1 in CONFIG.SYS. This means that if a program is
  without timeslice for one second, it gets a higher priority for a
  while. By default it was 3, so Telemate may ran only once every 3
  seconds.

  Two OS/2 specific files are added: TMOS2.CMD and TMOS2.ICO. TMOS2.CMD
  is a REXX script. It asks if user wants it full screen or windowed,
  creates the object and after getting users permission makes sure user
  has MSMouse for mouse in TM.CFG. TMOS2.ICO is an OS/2 format icon file.

  They should be in the same directory with TM.EXE and TM.CFG and the
  TMOS2.CMD should be run in OS/2 command line or by double clicking the
  TMOS2.CMD icon. Since the icon has name TMOS2.CMD, it is shown for the
  TMOS2.CMD. When installed, the icon will be used for the Telemate object.

. In the screen saver, if remaining transfer time is not available, the
  number of bytes transfered is shown.

  Note: The screen saver hot key [Alt `] is only available when the
  'Enhanced Keyboard' option is turned ON under the Options/Mouse &
  Keyboard dialog, because the non-enhanced BIOS does not return the key
  code for [Alt `]. On some foreign keyboards, [Alt `] is equivalent to
  pressing [Alt] together with the key left of the [1] key.

. A window position check is added to the transfer window so that the
  whole transfer window is visiable. Previously, if the window is placed
  too low, only part of the window is displayed and the content may jump
  up and down.

. Uploading with an external protocol showed 'Receive' in the usage log.

. In the keyboard translation table, setting a translation character to
  ASCII 0 now translate the character to nothing! Previous implementation
  sent out an ASCII 0 or print an ASCII 0 on the screen (printing an
  ASCII 0 on screen produces nothing, anyway).


About the Butterfly virus
=========================

It is unfortunate that the previous distribution of

    TM411-4.ZIP
    GIFLK110.ZIP
    GIFLK111.ZIP

contains a self-extracting VESA.EXE. Inside the VESA.EXE,

    OAK\37VESA.COM
    OAK\67VESA.COM

are infected by a new "Butterfly" virus. If you see any of the ZIP files
in a BBS, please ask the sysop to remove the files immediately. The files
have since been replaced by

    TM411-4A.ZIP
    GIFLK112.ZIP

The virus is not found to be dangerous. It is based on the Civil War
Virus. It is only infects .COM files increasing length by 302 bytes. The
virus is 307 bytes long. On execution of an infected program the virus
will search for and infect the next .COM file in the directory list.

The virus can be detected by

    F-Prot 2.08a in heuristic and quick scan modes
    ThunderByte anti-virus 6.02
    Norton anti-virus 2.1 (21A08def)
    Virex 2.9

ThunderByte and Norton anti-virus can disinflect the files. F-Prot is
working on a removal program. Unforetunately, McAFEE SCAN 106 DOES NOT
detect the virus but McAREE said SCAN 107 will be able to detect it.

To ensure this distribution is virus-free, we scan all the files with
six independent anti-virus softwares, namely

    McAfee SCAN 106
    F-Prot 2.08a
    ThunderByte anti-virus 6.03
    InVircible anti-virus 5.01
    Virex 2.9
    Microsoft anti-virus


------------------------------------------------------------------------------


Telemate 4.11     17 June, 1993
===============================

What's new in Telemate
======================

. Multiple upload directories can be defined by adding ';' between the
  directories. If a file is not found in the first directory, Telemate
  will search the second and so on. If the file name contains wildcard
  characters, the search will stop when a match is found. For example,
  if the upload directory is C:\TM\UL\;C:\QWK\ specifying *.* will only
  upload all the files in C:\TM\UL\.

. Multiple download directories can be defined by adding ';' between
  the directories with the wildcard between '(' and ')'. You can
  specify multiple wildcards for the same directory by adding ','
  between the wildcards. For example, if the download directory is
    C:\TM\DL\;C:\QWK\(*.QW?);C:\PIC\(*.GIF,*.PCX)
  *.QW? files are put into the C:\QWK\ directory, *.GIF and *.PCX
  are put into the C:\PIC\ directory, and all other files are put
  into the C:\TM\DL\ directory.

. Batch upload status.
. Batch Zmodem download status (if remote protocol drivers transmit the
  information, such drivers include DSZ and GSZ).
. High IRQ support, run TMINST.EXE to select IRQ number and interrupt
  number.
. Initial guessing supports "By: ".
. Hot key to the screen saver [Alt `].
. Add remaining transfer time in the screen saver.
. Video Cache option which update the screen every several lines (best
  for Windows, OS/2 or slower machine with high speed modem).
. Give up timeslice to OS/2 and Windows directly if not downloading.
. Remove "phantom drive" from the file directory dialog.
. Avatar emulation now turns off XON/XOFF flow control automatically.
. VGA 40 line screen height.

. TMScript adds two commands:
    SET QUOTESTRING, "..."
    QUERY QUOTESTRING, "..."
. WIDTH.SCR is added to help setting up 132 column mode.
. The host script is modified to adopt multiple directories. However, only
  the first directory is used.
. The host script now produces three usage logs:
    "Host: Begin session"
    "Host: Connect to user name"
    "Host: End session"

. TMSTAT calcuates total host session time.


What's fixed
============

. Auto Redial function did not work correctly if the user hangs up
  manually and the modem hangup string contains a delay.
. The Clear Screen toggle in phone directory did not work the same way
  the Clear Screen function worked.
. Zmodem recovery with date check is fixed, previously it may
  not recover even if the date check pass.
. File name conversion did not convert ".login"-type file to a valid
  DOS file name.
. Extended pacing did not work.
. The Log Filter did not strip off ASCII 0.
. The Save function in the editor caused a share violation if the
  Backup Source option is turned off.
. The Cut item was in the View menu.
. The DIR command in the DOS command window might display a false label.
. The INS command in the DOS command window did not work with ARJ 2.39.
. The screen update function did not work correctly under DesqView.
. Keystroke macro did not work when dialing.
. A bug in TMScript STRINS command is fixed.
. The READ command in TMScript can now read a string up to 512 bytes.
. The name of a printed phone directory produced by TMPHONE had one
  character missing.


------------------------------------------------------------------------------


Telemate 4.00     5 January, 1993
=================================

What's new in Telemate
======================

. Quick dial: Pressing [Ins] in the dial window replaces the dial
  list with the entry under the dial bar and starts dialing.

. When it is dialing, the [Ins] key inserts the entry under the dial
  bar to the end of the dial list. This allows you to easily add
  entries to the dial list without stopping the dialing process.

. Quick search in the Dial window no longer needs the [Ctrl] key.
  For example, pressing the [D] key now jumps to the next entry that
  start with a 'D'.

. The phone entry dialog allows an external protocol to be defined
  as the default protocol.

. VT102 now have an improved transparent print routine.

. VT102 supports <esc>[<ascii code>g, a non-standard code that
  display <ascii code> as the ASCII character.

. Select multiple files with [Spacebar] in MULTIPLE directories when
  uploading.

. In the file dialog, the whole file name field is erased if the
  first input character is '\'. This allows you to input a full path
  name quickly.

. Zmodem download adds a Skip function. If you select the Skip button
  after you press [Esc], the current file is skipped and the next file
  begins immediately without interrupting the download process.

. A date check is added to Zmodem recovery. A file with a different
  date (e.g. a QWK mail package) will not be resumed but will be
  renamed.

. New entries in the DSZ.LOG are imported to TM.USE automatically after
  an external protocol is called and the SUCCESS variable in TMScript
  reports the correct status.

. Backspace is stripped from the log file when the Log Filter is on.

. The first 2 characters are used in the guessed initial if the
  person's name has only one word.

. The default TM.CFG now have CTS/RTS flow control turned on and have
  GIFLink set up as protocol 'F' for Zmodem and 'Q' for CIS QuickB.

. More DesqView friendly, Telemate will give up control to the
  multitasker when it is idle.

. Host script allows open and close system.

. RTS/CTS is now ON by default in TM.CFG


What's fixed
============

. The /N option did not work if /T is used as well.
. When the dial list was deleted, a random number appeared in
  the dial list.
. A closed log file was not saved into disk until the user exited
  Telemate.
. Ymodem-G did not send files smaller than 1024 bytes.
. DOS command window did not allow ASCII 128-255 characters.
. Space was not allowed in the password macro.
. Set AddLineFeed did not work in script.
. Query LastCall did not return the actual date of the last call.


Introducing GIFLink
===================

In this release, we introduce GIFLink - a X/Y/Zmodem/QuickB protocol
driver that displays transmitting GIF images in stunning SuperVGA
graphics! It is the first protocol driver that uses full screen computer
graphics in SuperVGA mode.

GIFLink is distributed with Telemate as the 4th package and it is also
available as a stand-alone Shareware. Telemate registered users are
entitled to a special discount for GIFLink registration.

. When transfering GIF files, GIFLink shows the GIF images in the
  optimal size so that the full image always fits in the screen. It
  also displays a number of useful information such as COM port, baud
  rate, estimated transfer time, average cps, image resolutions, etc.

. GIFLink supports most of the popular file transfer protocols such as
  Zmodem, Batch Ymodem, Ymodem-G, Ymodem, Xmodem and CompuServe QuickB.
  If the files being transmitted are not GIF images, GIFLink will work
  just like a normal protocol driver. So GIFLink will transmit any
  files, not just GIF images.

. Not only can GIFLink shows the GIF images while you are transmitting
  them, it has a special VIEW mode so that you can look at the received
  GIF images in a slideshow format or preview the images you are going
  to sent.

. Almost all SuperVGA adapters and VESA compatible adapters are
  supported in 256 color mode or 64 grey-scale level up to 1024x768.
  Standard VGA is also allowed in 16 grey-scale level.

. GIFLink supports connection through its own COM interrupt routine,
  FOSSIL driver or BIOS INT 14H, 16550 FIFO, non-standard COM port
  address and IRQ, slow handshake and many more options.

. GIFLink provides direct Telemate support and optionally reads TM.CFG
  and writes TM.USE. Most DSZ environment variables are accepted as
  well.


