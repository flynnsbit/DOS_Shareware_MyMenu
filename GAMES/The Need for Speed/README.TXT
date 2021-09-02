

THIS SOFTWARE IS PROVIDED AS IS WITHOUT WARRANTY OF ANY KIND, WHETHER EXPRESS
OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
PARTICULAR PURPOSE WHICH ARE HEREBY DISCLAIMED. IN NO EVENT WILL ELECTRONIC 
ARTS BE LIABLE FOR ANY SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES RESULTING 
FROM POSSESSION, USE, OR MALFUNCTION OF THIS ELECTRONIC ARTS SOFTWARE PRODUCT.

ELECTRONIC ARTS RESERVES THE RIGHT TO MAKE IMPROVEMENTS IN THIS FILE AND TO THE
SOFTWARE AT ANY TIME AND WITHOUT NOTICE.

THIS FILE AND THE SOFTWARE HEREWITH IS COPYRIGHTED.  ALL RIGHTS ARE RESERVED.  
NO PART OF THIS FILE OR THE SOFTWARE MAY BE COPIED, REPRODUCED, TRANSLATED, OR 
REDUCED TO ANY ELECTRONIC MEDIUM OR MACHINE-READABLE FORM WITHOUT THE PRIOR 
WRITTEN CONSENT OF ELECTRONIC ARTS. 
  
COPYRIGHT 1995 ELECTRONIC ARTS
ALL RIGHTS RESERVED.









                      *******************************
                      *    ROAD & TRACK Presents    *
                      * The Need For Speed - PC/CD  *
                      *    EA WEB SITE DEMO v1.0    *
                      *******************************


HARDWARE REQUIREMENTS
---------------------
The minimum platform required is a 486 DX2-66 MHz CPU or higher
with an SVGA VLB/PCI 512K video card, 8 MB of RAM (with 400K conventional
and 7104K of XMS free)and 8 MB of Hard Drive Space. 


RUNNING THE GAME
----------------
This DEMO is designed to run on your hard drive. 

To start the game, simply run the appropriate batch file that best suits 
the audio card on your machine. Please see the list below.

1) SOUND BLASTER & COMPATIBLES (8-bit & 16-bit cards)
        type "runsb"    for Sound Blaster
        type "runsbpro" for Sound Blaster Pro
        type "runsb16"  for Sound Blaster 16/AWE

2) GRAVIS ULTRASOUND (including MAX)
        type "rungus"

3) WINDOW SOUND SYSTEM & COMPATIBLES
        type "runwss"

4) NO SOUND 
        type "nosound"


CONTROLS AND KEYS USED IN THE DEMO
----------------------------------

If you have a joystick pluged in, and if it is calibrated, the game will
use the joystick as the primary input control. If you do not have a joystick,
or if you choose not to calibrate the joystick, then the keyboard will be 
used as the primary control.  This demo defaults to Automatic shift.

JOYSTICK
--------
Left/Right      - Steering
Up/Down         - Accelerate/Brake
Button1/Button2 - Shift up/Shift down (Reverse, Neutral and Drive)

KEYBOARD
--------
Arrow left/right- Steering
Arrow up/down   - Accelerate/Brake
A/Z             - Shift up/Shift down (Reverse, Neutral and Drive)

OTHER KEYS
----------
ESC             - End game (press multiple times to exit to dos)
Space           - Hand Brake
H               - Car Horn
P               - Pause
C               - Change Camera view
F9              - Dashless view
F5              - Mute


CONFIGURING FOR BEST PERFORMANCE
--------------------------------

For best "Need For Speed" performance on PC, the program checks to
see what kind of system you have, and configures it appropriately.

If you have a 486 machine, you are limited to low-res support of
the game. If you have a Pentium or better, you will get hi-res
support for the game.

The following are some graphics detail funtions that is enabled 
during the game.

F1      - Adjust window size
F2      - Adjust image quality 
           - 2 levels for low-res (high, medium)
           - 5 levels for hi-res  (high, medium, low, auto-medium, auto-low)
F3      - Adjust view distance 
           - 3 levels (far, medium, close)
F4      - Toggle horizon on/off


FEATURE SET
-----------
NEED FOR SPEED will debut in September 1995... Look for it and 
for the following sampling of additional features...
    
    TRACKS
        o 9 Open road segments.
        o 3 Closed circuit race tracks.
        o 1 Extra bonus track.

    CARS
        o 7 Additional exotics, each with
          - Digitally sampled engine SFX.
          - Road & Track Statistics, Narration and Photography.
          - Full Motion Video
          - Accurate Handling and Driving Experience.

    GAME MODES
        o 2 PLAYER direct or Modem link
        o Time Trials - Race against the clock
        o Head to Head - One on One on any track
        o Single Race - Race with 'The Pack'
        o Tournament - Race for the Championship & access to the Bonus Track

    REPLAYS
        o Full Regular and Cinematic Replay 
        o 8 Dynamic Replay Camera View Angles
        o Load and Save those exciting events...


PROBLEMS RUNNING THE DEMO
-------------------------
This release of this DEMO may have problems running on machines with QEMM 
memory managers,or with shadow ram enabled. If you should encounter problems, 
the easiest solution is to make a boot disk with the following recommended 
settings.

**************************<config.sys>*******************************
DEVICE=C:\DOS\HIMEM.SYS
DEVICE=C:\DOS\EMM386.EXE NOEMS
BUFFERS=30,0
FILES=40
DOS=UMB
DOS=HIGH

SHELL=C:\DOS\COMMAND.COM C:\DOS\ /E:1024 /P

rem *ENTER YOUR OWN CD-ROM DRIVER HERE*
example: DEVICE=C:\CDROM\NEC_IDE.SYS /D:NECCDO


*******************<autoexec.bat> (QEMM USERS ONLY)*******************
Modify your own autoexec.bat file so that any indication of "QEMM" is
not being executed.

example: change "C:\QEMM\LH <stuff>" to "LH <stuff>"




( Electronic Arts is a trademark of, and The Need For Speed is a trademark 
of Electronic Arts. ROAD & TRACK is a registered trademark of Hachette 
Filipacchi Magazines, Inc, used under license by Electronic Arts. )








(If this is the last line you see while everything just zipped by...)
(type "TYPE README.TXT | MORE"                                      )













