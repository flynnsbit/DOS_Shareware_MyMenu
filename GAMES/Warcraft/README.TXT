

                        Warcraft: Orcs and Humans


---------------------------------------------------------------------
- WHAT THIS READ ME TEXT CONTAINS:
---------------------------------------------------------------------
1. System Requirements
2. Setup and Loading
3. Hot Keys
4. Unit Modifications
5. Attack vs. Move
6. Network Play
        Messages on the Network
        Two player Warcraft
        Selecting Units in Two-Player Custom mode
7. Modem Play
8. Troubleshooting
9. Making Your System Run Faster


---------------------------------------------------------------------
- 1.  SYSTEM REQUIREMENTS
---------------------------------------------------------------------
Warcraft has a minimum requirement of DOS 5.0 or better.  It requires
a 100% IBM PC compatible with a 386 microprocessor or better and a
VGA monitor.  Your system should have at least four megabytes of
total memory.  Warcraft will use either EMS or XMS memory and does
not require any special memory drivers other than HIMEM.SYS. 


---------------------------------------------------------------------
- 2.  SETUP AND LOADING
---------------------------------------------------------------------
To install Warcraft, type "INSTALL [Enter]" at the DOS prompt 
and follow the onscreen instructions.  

To run the game, type "WAR [Enter]" at the DOS prompt.

If you change your sound or music card, you can reconfigure Warcraft
using the setup utility.  Go to the WARCRAFT directory and type 
"SETUP [Enter]" at the DOS prompt.  


---------------------------------------------------------------------
- 3.  HOTKEYS
---------------------------------------------------------------------
The keys listed below are shortcuts which provide additional
functionality during game play.

F1 or Alt-H        Help
Shift F2 - F4      Save map position for immediate recall
F2 - F4            Recall saved map position
F5                 Display overview of map
F6                 Display Unit Screen (shows units in play/units destroyed)
F7                 Economy Screen (Lists total resources harvested)
F8                 Score (This is an indication of your success,
                   including your rank and current mission objectives)
F10                Options Menu

G                  Shows the building grid for structures
C                  Centers map on selected units
Ctrl-M or Alt-M    Music (toggles between ON/OFF)
Ctrl-S or Alt-S    Sound Effects (toggles between ON/OFF)
Ctrl-X or Alt-X    Exit the program
Ctrl-Esc           Disconnects the systems in two player mode
+ / - keys         Speed up or Slow down the game speed
Esc                Cancel any command just issued in any menu
Right click        Cancel any command just issued in any menu

Shift+Click on a unit             Allows grouping of up to four units
Ctrl+Drag Mouse over units        Allows grouping of up to four units


---------------------------------------------------------------------
- 4.  UNIT MODIFICATIONS
---------------------------------------------------------------------
Both Catapults and Summoned Creatures operate in manners dissimilar
from other units in the game:

The catapult will attack enemy units automatically ONLY if there 
are no friendly units that will be effected by splash damage from the 
missile.  If you select the Attack command and specify a target, the 
catapult will fire at the selected target regardless of friendly unit 
proximity.

Summoned Creatures have a Magic Point (MP) bar as well as a
Hit Point (HP) bar. The MP bar will degrade over time, and when it is 
drained, the summoned creature will begin taking damage, as the powers 
that hold it here are no longer in force.


---------------------------------------------------------------------
- 5.  ATTACK VS. MOVE
---------------------------------------------------------------------
When a Unit is instructed to Move, it will head to the selected location and 
ignore anything that crosses it path, including units that attack it. This 
allows for uninterrupted movement, as well as enforced retreats.

When a Unit is instructed to Attack, you may choose either an area to attack, 
or a specific target.

When you choose an area to Attack, the unit will move there, but if he is 
attacked in transit, the unit will stop and respond to the attack.  When the 
unit arrives at the selected location, it will look for immediate targets 
within its range to attack.

When you choose a specific target to Attack, your unit will move to engage 
the selected target, ignoring all other enemies or threats.


---------------------------------------------------------------------
- 6.  NETWORK PLAY
---------------------------------------------------------------------
MESSAGES ON THE NETWORK
Messages can be sent to an opposing player in a Two-Player game by simply 
pressing the Enter key during gameplay. A MSG: prompt will appear at the
bottom of the screen.  Type in your message, and then press Enter to send it.


TWO PLAYER WARCRAFT
Your CD-ROM enables you to play Warcraft with a friend who does NOT have a 
copy of the game.  To play Warcraft with a friend over a modem or network,
perform a PARTIAL or FULL INSTALL on one system and use the CD-ROM with any
installation setting on the other system.  This will allow both systems to
play against each other, though at least ONE system MUST have the CD.


SELECTING UNITS IN TWO-PLAYER CUSTOM MODE
In a Two-Player Custom game, players can either have the default setting
of two Peons/Peasants or they can elect to create custom armies through 
the Select Armies dialog.  Not only can you effect what units you are 
choosing for your side, but you may select or deselect units for the 
enemy side by using the mouse to click the arrow keys in the Unit Selection 
area.  If you wish to negate the ability to create specific units, they 
may be turned OFF in the same manner, making them unavailable for play.


---------------------------------------------------------------------
- 7.  MODEM PLAY
---------------------------------------------------------------------
For best performance you will want to disable compression and error control 
on your modem.  Here are some init strings for popular modems that we have 
found to work well.

HAYES ACCURA 144B, ZOOM 14400, PRACTICAL PERIPHERALS:
        AT &K0 M1 S46=0 &D2 &Q6

US ROBOTICS SPORTSTER:
        AT &K0 M1 &D2

If your system does not run smoothly during MODEM or DIRECT LINK
play, these are some suggestions which may help:

	* You can turn music OFF to increase game speed

	* Decreasing the BAUD rate may increase game speed


---------------------------------------------------------------------
- 8.  TROUBLESHOOTING
---------------------------------------------------------------------
Most systems should experience no difficulties running Warcraft.  
However, a small percentage of systems may experience occasional
system conflicts.  Many of these problems are quite easy to fix
using the information provided below.  Before attempting to
remedy any problem, we urge you to save your important system 
files (AUTOEXEC.BAT and CONFIG.SYS in particular) before making
any modifications.  Please refer to your system's documentation
before making any changes.

--------------
Problem #1:
    The SAVE/LOAD game feature doesn't work properly,
    or causes my system to "freeze" occasionally.
--------------
If you have SMARTDRIVE installed with WRITE-CACHING, the SAVE/LOAD 
feature may not work properly.  This is due to problems with
SMARTDRIVE and DOS. Every version of SMARTDRIVE we have tested
from v4.0 through v5.01 has write-caching conflicts.  Either disable 
write-caching on the hard disk containing WAR.EXE or remove SMARTDRIVE
altogether.

Example:  if WAR.EXE is installed on the C: drive, try using the
following command to remove write-caching:

	SMARTDRV C


--------------
Problem #2:
    The install program cannot install the program
    to my hard disk due to an error condition.
--------------
A SMARTDRIVE conflict is the most likely cause of this problem.  
see the solution to Problem #1 above.

If you are using NDOS from SYMANTEC/Norton Utilites, the installer
may be unable to copy Warcraft onto your hard disk.  Remove NDOS
and try to install again.


--------------
Problem #3:
    Warcraft occasionally "freezes" or displays irregular behavior.
--------------
EMM386.EXE is the most likely cause of irregular behavior.  There are
several known problems with EMM386.EXE which prevent proper program
operation.  We recommend trying the following alternatives:
(this list courtesy of Rational Systems Extenders)

    * Run with HIMEM.SYS only (This will also speed 
      your system performance).

    * Replace EMM386 with another memory manager, such 
      as QEMM-386 or 386Max.

    * Run in a Windows DOS box.

    * Configure EMM386 with both the NOEMS and NOVCPI options.

    * Convert the DEVICEHIGH statements in your CONFIG.SYS to 
      DEVICE statements, and remove the LH (Load High) commands
      from your AUTOEXEC.BAT.


--------------
Problem #4:
    Warcraft does not work properly when I run it from a network drive.
--------------
Warcraft should run properly using most network cards.  A few network
cards may cause sporadic crashes while running Warcraft.  Try
playing Warcraft from the CD (MINIMAL install), or perform a PARTIAL
or FULL install to your local hard disk.


--------------
Problem #5:
    I have two monitors, and Warcraft runs very slowly on my system.
--------------
If you are using a monochrome monitor in addition to your VGA color monitor,
the Diamond Stealth video card will cause the game to run very slowly.
Other video cards may also display similar problems.  Removing the 
monochrome card is highly recommended.  


--------------
Problem #6:
    I don't have enough free memory to play Warcraft
--------------
Here are several solutions to increase your free memory:

   * Remove unneeded TSR programs from memory

   * Remove SMARTDRIVE, or reduce the size of its disk buffer

   * Run the memory optimizer that comes with your memory manager
     (MemMaker for EMM386, Maximize for 386MAX, etc)

--------------
Problem #7:
    The installer told me I don't have enough disk space
to install Warcraft
--------------
Before Warcraft is installed onto your hard disk, the installer will
check to make sure there is enough free space available.  Some disk
compression utilites like Stacker and DoubleSpace estimate the amount
of free space available.  If that estimate is incorrect, the
installer will not be able to properly complete its operation.

If the installer indicates that you do not have enough free disk
space to complete the installation, you have the following options:

    * Free up more space on your hard disk by deleting unneeded files

    * Choose a Warcraft configuration which requires less disk space


---------------------------------------------------------------------
- 9.  MAKING YOUR SYSTEM RUN FASTER
---------------------------------------------------------------------
Adjust the speed using the Options Dialog or the + or - keys.

The EMM 386 memory manager (EMM386.EXE) slows the game speed of Warcraft
considerably.  Use HIMEM.SYS only (without EMM386), or another memory 
manager like QEMM or 386MAX to increase game speed.  Refer to your 
DOS manual to change your memory configuration.  Also, please refer to 
the notes regarding EMM386.EXE in the TROUBLESHOOTING section.
