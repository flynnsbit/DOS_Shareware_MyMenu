README.TXT

**** CyClones Notes: ****

This file contains any pertinent information about the game that was
not able to make it into the regular documentation.

Version:  1.00

CD ERRORS
---------
If the game has trouble with the CD:
    Some CD-ROM drives on some specific machines may have trouble reading
from the CD on the first try.  The game may show symptoms such as being
unable to play the music off of the CD during the game introduction, or
displaying a error such as "Cannot read from Drive D" (or your CD drive
letter) during the video sequences.  If the game appears to be having such
trouble,  try simply getting a directory of your CD at the DOS prompt (by
typing "DIR D:" (or E:  or whatever your CD drive happens to be) before
running the game.  This can clear up any problems your computer may have.


ITEMS
-----
Activated Items:
    Items that can be activated in your inventory (that is, "turned on"
for a continuing effect and later "turned off" to conserve power) did
not make it into the final game.  The only types of items available
are instantaneous use items (such as bio-kits and mech-kits) which are used
as soon as they are clicked on in your inventory, and readied items.

Readied Items:
    Items that can be readied in your inventory (that is, readied then
used on a target in the world, such as a door) work slightly differently
than described in the manual.  When an item is readied (right clicked
in the inventory), the frame around it turns red.  At that point, right
clicking in the world will use that item upon whatever is click on in the
world.  IN ORDER TO CLOSE THE INVENTORY OR USE ANOTHER ITEM, YOU MUST
RIGHT-CLICK AGAIN ON THAT ITEM TO UNREADY IT.


CONTROLS
--------
Key remapping:
    Several of the keys described on page 15 of the manual are designated as
"Changable" (remappable, using the Configure section of the options screen),
when in fact they are not.  The following keys are permanently placed on
the keyboard, and no other function can remap to that key:
    I  =  Inventory:  Brings up items, if any exist, that Havoc possesses.
    C  =  Weapons Cache:  Brings up weapons that Havoc possesses.
    O  =  Options Screen:  Accesses all off-line game functions.
	      Also works well as a gameplay pause.
    M  =  Automapper:  Shows everything that Havoc has seen, in 3D.
    P  =  Detonate Demolition Packs:  If any demo packs have been used,
	      a "DP" button appears on the right of the screen.  The
	      'P' key duplicates clicking on that icon, blowing them up.
    J  =  Toggle Jump-jet:  If Havoc has the jump jet with any charges
	      remaining, a "JJ" button stays on the left of the screen.
	      The 'J' key duplicates clicking on that icon, which toggles
	      the jumpjet on and off.

Alternate key remapping:
    We at Raven Software feel that the default key configuration is the
best all-around setup for easy movement, centered around the keypad.
 KP 1      =  Slide Left               (Keypad) ENTER = Select (Right-click)
 KP 2 OR 5 =  Back up                      (Keypad) 0 = Fire
 KP 3      =  Slide Right      Page Up and (Keypad) * = Look up
 KP 4      =  Rotate Left    Page Down and (Keypad) / = Look down
 KP 6      =  Rotate Right
 KP 7      =  Forward and Left
 KP 8      =  Straight Forward
 KP 9      =  Forward and Right

    However, some people find it awkward to use the right side of the
keyboard when the mouse is directly to the right of it as well.  So, here
are a few remapping suggestions that we have found to our liking:
    Left side of the keyboard for movement:
      A = Turn Left
      D = Turn Right
      S = Back up
      W = Move Forward
      Q = Slide Left
      E = Slide Right
	      In this setup, Z and X, 1, 2, 3, and TAB all make excellent
	      keys for other game functions.  The "Forward and Left" and
	      "Forward and Right" keys can be duplicated by holding down
	      both the forward and the left or right keys.

    Cursor Keys for movement:
	      For people who prefer using the standard inverse-T arrows
	      on their keyboard because of its use in other games,
	      a player can easily remap their movement keys here, moving
	      the cursor movement to A/D/W/S if it is needed.  < and >
	      can be used for sliding keys in this configuration.

    Experiment!
	      We have found that in many instances, a slight variation
	      on a certain setup is more to the liking of a certain person.
	      We encourage you to try out a few setups if you feel
	      uncomfortable, and we promise you will be blasting CyClones
	      like a pro in no time!

    Having more than one key setup:
	      The key setups are stored in the file KEYMAP.BIN on your
	      hard drive.  If there is more than one person using the
	      game on your machine, each person can have their own key
	      setup if they back up the file under another name, such
	      as KEYMAP.TIM after they exit the program, then copy their
	      own special setup before running the game.


JOYSTICK SUPPORT
----------------
    One feature that was completed after the creation of the manual was
the joystick support in the game.  The game will support any standard
two-button PC joystick, analog (any joystick that can be pushed "part-way"
to "all the way" in a particular direction) as well as digital (like the
Gravis Gamepad, which only can be pushed in the eight directions, with
no finer control).

Joystick Setup (Calibration):
    When the game is started up, the joystick is not hooked up to the control
of the character, as it needs to be calibrated before it can be used.  The
JOYSTICK SETUP button is in the Options Screen, inside the SETTINGS menu.
Just click on the button, which lies right next to the AUDIO SETUP button,
and you will be put into yet another page of the Options Screen.
    There you will be asked to calibrate your joystick.  It begins by asking
you to center your joystick and press button 1.  This usually is the "top"
button or the trigger on the joystick.  It will then ask you to define the
four corners of the joystick, in a configuration like the letter 'Z'.
Finally, it asks you to re-center the joystick and press the button again.
    From this information, the program determines where the four corners
of your joystick are and how to read them.  If for any reason that
information is bad, if, for example, you did not go to the corners in the
correct order, the program will tell you the configuration was bad, and
return to the SETTINGS page.  The joystick will be disabled until you
run the configuration program again.
    This setup must be run every time the program is started up for use with
a joystick, because many joysticks tend to lose their calibration over time.
If, during play, you feel that your joystick is getting uncalibrated, or "off
center", return to the Options Screen and run JOYSTICK SETUP again.  Run the
calibration as many times as you need to in order to get the "feel" of the
joystick to your liking.

Joystick Movement:
    The joystick movement is quite simple.  Pushing the joystick left or
right will turn Havoc left or right.  Pushing it forward or back will move
Havoc forward or backwards.  The sole difference between the movement using
the mouse reticle and the joystick is that pushing the joystick backwards and
to the left or right does NOT slide Havoc to the left or right.  It moves
backward while rotating him in the corresponding direction.
    Pressing Button 1 on the joystick (frequently the trigger or the top
button on most models) will fire Havoc's current weapon.
    Pressing Button 2 will act in the same way that right-clicking will with
the mouse:  that is, open doors, pick up objects, and click icons.  Also,
holding Button 2 and moving the joystick will slide the cursor around the
screen.  When the button is released, the cursor will remain in its new
position.


SOUND CARD SETUP
----------------
install, Autodetect, and Manual Setup:
    The program install on your hard drive will set up CyClones to the proper
configuration for your sound card.  The easiest way to use it is to, when
asked if you want the program to auto-detect your sound card, to answer "Yes".
Usually, the program will find the right hardware settings to make your card
sing!
    Unfortunately, on some cards, most notably the Soundblaster 16, our
autodetect program may have trouble.  The program may hang when autodetect is
selected, or improper settings may be given.  DON'T PANIC if this happens!
All is not lost!
    If necessary, use the manual card setup (say "No" to autodetect).  The
first part involves selecting a card type.  If you don't see your card
listed, usually a setting of Soundblaster (number 0) is the best bet.
    After selecting your card, the technical specifications are needed.  The
numbers it needs are an IRQ (interrupt), a DMA channel, and a port address.
If you are uncertain of what values you need, try running the setup
program included with your sound card.  If you keep a sharp eye out when
running it, this will tell you the three values you need to know.  Another
place to look is to simply type "SET" at the DOS command prompt.  In the list
of names and values, you may see a line like this:
    BLASTER=A220 I7 D1
which tells me that my Soundblaster needs an address of 220, and IRQ of 7 and
a DMA of 1.  These, incidentally, are the most common sound card settings that
exist, and could match your own.

NOTE ON 16-bit cards:
    The autosetup part of the program has a tendency to detect an improper DMA
channel (the high-bit channel instead of the low 8-bit channel).  For example,
a Soundblaster 16 will often register as having a DMA of 6, rather than a
proper channel, such as 1.  The result is that the sound with be scrambled or
buzzing.  Use the manual setup in this case.

Improper Sound Setups:
    If the sound card is improperly set up, the program may do strange and
nasty things.  At best, there will be no sound, the sound could be scrambled
or sound terrible, or the game could even crash at the moment the first sound
is played.
    If such a thing occurs, try running the game with No Sound set up.  If
your game works correctly without sound, you can assume that there is some
problem with your sound setup or the card's compatibility with this game.
If you cannot rectify the problem on your own, contact your sound card's
manufacturer.


CHANGING THE PATHS FOR THE GAME FILES
-------------------------------------
    The file CYCLONE.CFG on the hard drive tells the program the location
of all the different files of the game.  Normally, the program install rewrites
this file every time it is run, storing a standard path configuration based
off of the CD drive letter you specify.  However, if for any reason you need
to change the paths, the file is set up as follows:
D               --The first line is the CD drive letter.  D is standard.

.\              --This indicates where the regular game files are located.
		      The default is the current directory.
D:\game\        --This indicates where the reference game files are located,
                      such as the maps and video.  The default is the GAME
                      directory on the CD.
.\sound\        --This shows where the game sounds are located.  It defaults
		      to the sound subdirectory under the regular game
                      playing dir.
D:\game\sound\  --The last line is where the sound for the video is
                      located.  It usually is in the sound subdirectory on
                      the CD.

    So, if you somehow have 100MB of disk space handy (we sure don't) and wish
to play CyClones at its absolute optimum performance, all the data can be
copied manually from the CD to any directory on your hard drive.  All that
needs to be done after that is to change lines 3 and 5 to the proper path on
your hard disk so that the game can find the proper files.  You'll still need
the CD to get the game's soundtrack, but otherwise everything will work fine
from your hard drive.


TUTORIAL
--------
    There was only the briefest mention of the tutorial in the manual, so we
will rehash it here:
    In the Options Screen, if the TUTORIAL button is selected, the game will
go into an automatic demonstration of the basic controls of CyClones.  The
mouse will be under control of the computer, and will move and click by itself
during its demonstration.  In fact, all input by the user will be locked out.
There is only one exception:  The ESC key will cancel the tutorial and return
to the Options Screen.
    NOTE:  As the game will warn when the button is pressed, the player's
current game will be lost when the Tutorial is started.  If you care about
your position in the game, make sure you SAVE your position before watching
the tutorial.  The game you save may be your own.

						  --November 6, 1994
						      --Pat Lipo

CyClones by Raven Software.
Published by Strategic Simulations, Inc.

        Copyright 1994 Strategic Simulations, Inc.
		All rights reserved.

