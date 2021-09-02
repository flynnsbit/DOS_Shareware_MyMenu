                       ษอออออออออออออออออออออออป
                       บ                       บ
                       บ   RELEASE NOTES FOR   บ
                       บ      DESCENT 1.4      บ
                       บ       SHAREWARE       บ
                       บ                       บ
                       ศอออออออออออออออออออออออผ

            ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
              GIVE SHAREWARE DESCENT TO EVERYONE YOU KNOW!

                  THIS GAME MAY BE FREELY DISTRIBUTED
                       See section 10 for details
            ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ


                         ษอออออออออออออออออออป
                         บ TABLE of CONTENTS บ
                         ศอออออออออออออออออออผ

                       1. Playing DESCENT!
                            a. System Requirements
                            b. Installation & Setup
                            c. Menus
                            d. Powerups
                            e. Doors
                            f. PTMC Mine Centers

                       2. Tips for New Pilots

                       3. Multiplayer Descent
                            a. Features/Rules
                            b. Modem/Serial Games
                            c. Network Games

                       4. Using Thrustmaster controls,
                          Gravis Phoenix, or Logitech Cyberman

                       5. Demos & Screenshots

                       6. Command-line Options

                       7. Troubleshooting/Common problems

                       8. Getting Technical Support

                       9. Ordering REGISTERED DESCENT!

                      10. Distribution Information

VERSION CHANGES:

1.0  Initial Shareware release

1.1  Fixed: non-responsive joystick axes
            problems with Wingman Extreme/FCS hat switches
            demo playback not showing F8 messages
            demo playback not decloaking ships
            problems with SLIDE ON using joystick or mouse
            soundcard clicks during modem play
            loadpatch problems with >512k GUS cards
            detail levels not saving properly
            incorrectly mapped MIDI instruments

     Added: support for non-standard COM IRQ settings
            default taunt macros for new pilots
            moving reticle for VR helmet head tracking               
            mouse sensitivity slider
            shield/energy indicators to full-screen view
            keeps COM port unchanged when exiting game
            documented Automap 'S' key in REFCARD.TXT  
            VR helmet information phone numbers in README.TXT
            -NoDosCheck command line option for DR-DOS users

1.2  Fixed: buffer allocation bug if no VESA driver loaded
            "divide overflow" bug if you pause game overnight
            bug with joysticks glitching out occasionally
            UART detection code that couldn't detect some UARTS
            bug with net kills getting lost after you exit mine
            hang bug with some Cyrix/TI CPUs
            hang bug when using mouse with disk write caching
            bug with robot's shields reseting after you die

     Added: support for multiple sockets during netgames
            hooks for Spaceball controller support
            alternate joystick reading methods, -joypolled and -joybios

1.3  Added: support for Virtual I-O's Iglasses! head tracking and
              stereoscopic 3D in 320x400 mode.  See the command line help
              for the switches to enable these new options. By default, the
              screen isn't rendered at the full resolution to keep the frame
              rate high.  However, with a fast enough computer you can toggle
              between the low-res mode and the fullest resolution by hitting
              Shift+F6 during the game.

1.4  Fixed: Level 7 Boss robot made easier to kill
            -joybios switch now causes buttons to be read via BIOS also

     Added: Full Save/Restore added to single-player games!  Use Alt-F2 
              to save, ALT-F3 to restore
            HUD information added in VR modes
            In modem & serial games, RTS/CTS now disabled by default.  Use
              -rtscts on command line to enable
            
            

            


                         ษอออออออออออออออออออออป
                         บ 1. PLAYING DESCENT! บ
                         ศอออออออออออออออออออออผ

The year is 2132.  You are an outside contractor working for the Post
Terran Minerals Corporation, a company known for its power, technology,
and shameless materialism.  Rumor has it the untouchable PTMC has a serious
problem with its planetary mining network... you are ordered to report for
a briefing...

Descent is a heart-pounding, gun-wrenching, edge-of-your-seat experience.
Following is a few pointers on how to easily get inside and move around
the Descent universe.


ษอออออออออออออออออออออออออป
บ 1a. System Requirements บ
ศอออออออออออออออออออออออออผ

BARE REQUIREMENTS:
       - IBM PC compatible 386-33 or faster
       - 4 MB RAM
       - DOS 5.0 or greater

STRONGLY RECOMMENDED:
       - 486 or Pentium processor
       - 8 MB RAM
       - stereo 16-bit soundcard with General MIDI support
       - a quality joystick


ษออออออออออออออออออออออออออป
บ 1b. Installation & Setup บ
ศออออออออออออออออออออออออออผ

To install Descent, use PKUNZIP to unzip the distributed files into a
temporary directory.  From that directory, type:

INSTALL <ENTER>

The Installer will uncompress and assemble the needed files.  It will then
run SETUP to allow you to configure your sound card(s).

To change soundcard configuration at any time, you can also type:

SETUP <ENTER>

Follow the prompts to configure your sound device(s).  Be sure you test
the sound and music!  If soundcard settings are incorrect, Descent may
not work properly or even fail.

To start Descent type:

DESCENT <ENTER>

After starting the game, you will be prompted to enter your PTMC pilot
name.  This will be the name Descent uses to store your control
configurations and for tracking you in Multiplayer games and in high scores.


ษอออออออออออป
บ 1c. Menus บ
ศอออออออออออผ

Use the arrow keys to move around menus in Descent.  Unless otherwise
noted, hitting <ESC> will accept the current menu's settings and return
to the previous one.  Some menus contain radio-type switches and checkboxes
that can be toggled by hitting <SPACEBAR>.  From the game you can always
hit the <F1> key to bring up a list of Game Options.


DESCENT MENU
ฤฤฤฤฤฤฤฤฤฤฤฤ
NEW GAME - Start a new game of Descent.  You may begin on any level you
       have reached in previous games.
  
LOAD GAME - Resume a previously saved game.  Saved games are stored in your
       pilot file, so be sure the proper pilot is selected.

MULTIPLAYER - Allows you to start a game of Multiplayer Descent using a
       modem, serial cable, or IPX network.  See Section 3 for details.

OPTIONS - Takes you to the Options Menu (see below).

CHANGE PILOTS - Allows you to change the current pilot or create a new one.
       All control configurations and saved games are stored in your pilot
       file.

VIEW DEMO - Lets you play a recorded demo file.  See section 5 for details.

HIGH SCORES - See Descent High Scores.

ORDERING INFO - Shows how to order the full registered/commercial version
       of Descent!

CREDITS - See the list of people who created Descent.

QUIT - This will return you to DOS.


OPTIONS MENU
ฤฤฤฤฤฤฤฤฤฤฤฤ
FX VOLUME - Changes volume of sound effects.

MUSIC VOLUME - Changes volume of the music.

REVERSE STEREO - Allows you to reverse the stereo sound channels.  This is
       sometimes necessary for earphones, speakers, or extension cables
       that are wired incorrectly.

BRIGHTNESS - Some monitors are darker than others.  If you have trouble
       seeing details on your game screen, try adjusting this slider.

CONTROLS - Takes you to the Controls Menu (see below).

DETAIL LEVELS - Allows you to adjust the Detail Level of Descent (see below).

CALIBRATE JOYSTICK - If your joystick drifts, you probably need to calibrate
       it.  Also available in the game by hitting <F4>.

JOYSTICK SENSITIVITY - Adjusts the responsiveness of your joystick controls.

SHIP AUTOLEVELING - If this is on, your PyroGX ship will attempt to align 
       itself with the curvature of the mine tunnels.  This is useful for 
       first-time Descent players, but may be turned off once you're 
       accustomed to full 3D flight.


CONTROLS
ฤฤฤฤฤฤฤฤ
>> NOTE:  See REFCARD.TXT in your Descent directory for a list of the
>>       default keyboard controls.  If you have a printer, you can also use
>>       the Paintbrush utility in Windows to print the file REFCARD.PCX.

The Controls menu allows you to choose your prefered controls for Descent.
If you are using a Thrustmaster stick, the Gravis Phoenix, or a Logitech
CyberMan, see Section 4.

By choosing Customize Keyboard you can change the default keys to your
preferences.  Any changes are saved in your pilot file.  If you use a
Thrustmaster WCS, FLCS, or Gravis Phoenix, you should keep the keyboard
configuration in its default setup and alter the appropriate downloadable
device file.


DETAIL LEVELS
ฤฤฤฤฤฤฤฤฤฤฤฤฤ
If you are running on less than a 486-50 with 8 MB RAM, you may wish to
lower your detail level to achieve better performance.  There are several
preset detail levels available to you, as well as a Custom Detail Level.
The following is a list of options availble under the Options/Details/Custom
menu:

OBJECT COMPLEXITY:  This affects the number of polygons used by objects
       like robots, player ships, and other 3D objects.  Lower values will
       increase speed, but simplify the shapes of many objects.

OBJECT DETAIL:  This determines at what distance an object changes from
       flat-shaded to texture-mapped details.  Setting this slider to a
       lower value will cause robots to be flat-shaded much closer.

WALL DETAIL:  This option determines at what distance walls appear flat-
       shaded vs. texture-mapped.  It also affects the accuracy vs. speed
       of the texture mapper.  If you notice wall textures "sliding" or
       "jumping" a little in the distance, this slider is set too low.

WALL RENDER DEPTH:  This will change the maximum distance you can see.
       Lower settings will increase the speed of Descent, but will cause
       flat-colored "walls" to appear across long hallways.  These
       boundaries do not affect weapons or other objects, only your visuals.

AMOUNT OF DEBRIS:  Changing this slider will determine how much debris is
       made when robts explode.  Setting this to a low value will make fewer
       pieces in heavy combat.

SOUND CHANNELS:  Sound can have an affect on the speed of your game as well.  
       This slider will change the maximum number of sounds that can be played 
       at once.


ษออออออออออออออป
บ 1d. Powerups บ
ศออออออออออออออผ

ACCESS KEYS:  These access keys give you access to the different security
       levels of the mines.  They are color-coded to the doors they open.

ENERGY BOOST:  This will give your energy banks a boost, up to 200 units
       max.  Energy Centers can deliver recarge up to 100 units.

SHIELD BOOST:  This will give your ship's shields a kick.  By getting
       shield powerups, you can get your shields up to a maximum of
       200 units.

CLOAKING DEVICE:  Gives your ship cloaking ability for a limited time.

INVULNERABILITY:  Makes your ship invulnerable for a short time.

EXTRA LIFE:  Gives you a bonus life.

LASER: Laser cannons have four power levels.  The laser powerup will give
       you the next available level.

QUAD LASER:  This powerup will modify your existing laser system to fire
       four bolts instead of the standard two.

VULCAN CANNON:  This weapon rapidly fires explosive-tipped shells.

VULCAN AMMO:  This gives you more ammunition for the Vulcan Cannon.

SPREADFIRE CANNON:  This fires a spread of energy at your target.

* PLASMA CANNON:  Fires bursts of supercharged plasma.

* FUSION CANNON:  Fires destructive blasts of energy directly from the
       ship's fusion reactor.  Capable of punching through large crowds of
       robots before running out of power.

CONCUSSION MISSILES:  All-purpose dumbfire rockets.  Come singly or in
       packs of four.

HOMING MISSILES:  Same size warhead as Concussion Missiles, these are
       equipped with a tracking device that can follow a target around
       most turns.  Come singly or in packs of four.

PROXIMITY BOMBS:  These bombs are launched behind your ship, waiting to
       explode when something gets near.  Can be armed as a secondary
       weapon, or dropped directly by hitting the default key "B".

* SMART MISSILE:  When this missile detonates, it sends bomblets of
       heated plasma after the surrounding targets.

* MEGA MISSILE:  Stand back when you launch this earthshaker.

     * These four weapons are only available in the registered/commercial
       version of DESCENT.  See ORDERFRM.TXT for details.


ษอออออออออออป
บ 1e. Doors บ
ศอออออออออออผ

Doors in the PTMC mines can be opened by shooting them or bumping them.
If a door is locked, it needs the appropriately colored access key.
If a door is not color coded and cannot be opened, it is a special
door that may open by a motion sensor somewhere in the mine.


ษอออออออออออออออออออออออป
บ 1f. PTMC Mine Centers บ
ศอออออออออออออออออออออออผ

ENERGY CENTER:  Designed for "on the fly" replenishing of robot's power
       cells, it will also recharge your own.  These will charge your
       ship's energy banks (up to 100 units).

ROBOT GENERATOR:  Automated centers that determine a mine's needs
       and assemble robots from surrounding minerals and metals.  Very
       dangerous.  Identifiable by its violet color.

MAIN REACTOR:  The power generator of the whole mine.  Usually in a
       secluded place away from day-to-day mine mishaps.



                       ษออออออออออออออออออออออออป
                       บ 2. TIPS for NEW PILOTS บ
                       ศออออออออออออออออออออออออผ

Here are a few things that help new players adjust to the fully 3D world
and intelligent robots of Descent.  Heed these tips and you'll soon be
blasting robot hordes (and your friends!) with ease.

     o Use a quality joystick.  Thrustmaster, Advanced Gravis, and
       CH Products provide full lines of controls well suited to 3D
       flying.

     o If you use a two-button joystick, try keeping one hand on the
       A and Z keys to control your FORWARD and REVERSE.

     o If you're up against a wall, try using REVERSE to back away 
       instead of turning around.

     o Learn how to SLIDE well.  Using vertical sliding instead of pitching
       will help keep you upright.  If your joystick has a Hat Switch, 
       use it to slide.

     o Use SLIDE to evade enemy fire.  This will help keep the robots
       in your sights.

     o Sweep fire side-to-side to hit evading robots.  This is especially
       important on higher skill levels where robots evade faster.  Also
       try using lasers and missiles simultaneouslly against an evading
       robot.

     o Rescue the hostages!  If you rescue all hostages in a mine, you
       receive a full rescue bonus.  But be sure you make it out after
       picking them up - if your ship's destroyed, so are they.

     o Try clearing a path to the exit before you attack the Main Reactor.
       You may run out of time if you're battling hordes of robots on
       your escape!

     o The blast radius of a concussion missile is very effective 
       against tight groups of robots.  

     o Look for secret doors.  Weapons and ammo are often behind them.                      
       They can be a different color, or have small seams running down
       them.  Keep in mind, Descent is fully 3D, and secret doors aren't
       only in the walls...

     o DON'T SIT STILL.  The best way to stay alive is to keep moving.
       Using SLIDE to circle a target while you're firing is very
       effective.

     o Learn to use your ship's Automap.  It can reveal things your
       eyes may miss.

     o Flares can help sniff out cloaked robots & players.

                       ษออออออออออออออออออออออออป
                       บ 3. Multiplayer Descent บ
                       ศออออออออออออออออออออออออผ

ษออออออออออออออออออออป
บ 3a. Multiplayer:   บ
บ     Features/Rules บ
ศออออออออออออออออออออผ

   >> NOTE:  ONLY ANARCHY MODE IS AVAILABLE IN SHAREWARE VERSION. <<
   >>  SEE ORDERFRM.TXT TO RECEIVE THE FULL DESCENT EXPERIENCE!   <<

There are several features available to players of Multiplayer Descent
not used in normal single player games.  Here is the rundown:

Multiplayer Keys
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
TEAMMATE ID DISPLAY (F6):  Available in Network Team games only.  If
       enabled, this will show a teammate's name if he is in your sights.
       Hitting F6 will turn this on/off.

KILL LIST DISPLAY (F7):  This toggles the Multiplayer Kill List on/off.
       In Network Team games, this alternates the display between Player
       Kills, Team Kills, and no kill display. 

SEND MESSAGE (F8):  Lets you type a message to other player(s).  Addressing
       the message to specific player(s) can be done by using a colon.
       For example, sending the message "ST:YOUR TIME IS NEAR!" will send
       the message "YOUR TIME IS NEAR!" to any players with "ST" as their
       name or first characters.  This would include the players STEVE or
       STACY.  If there is no address, the message will be sent to
       everyone.  If there is an address but no match, it will not be sent.
       In Team Anarchy, addressing messages to "1:" or "2:" will send
       them only to Team 1 and Team 2, respectively.

TAUNT MACROS (F9-F12):  This works the same as above, but lets you
       send one of four predefined messages with one keypress.  By using
       SHIFT, you can define or re-define what F9-F12 will send.  For
       example, hitting SHIFT-F10 will let you change what F10 will send
       when you hit it by itself.  Message addressing using ":" is
       available in macros as well (see above).  Taunt Macros are stored
       in your pilot file for future games.


Multiplayer Rules
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Some special rules apply to Multiplayer Descent Games.  Here is the
rundown:

     o When players are killed, they drop their weapons and powerups!
       This also means that if there is only one Spreadfire Cannon placed
       in a level, only one player can have it at a time.  If you want
       a certain weapon, you may have to beat it out of someone!

     o When you fire secondary weapons in a multiplayer game, a new powerup
       of that type is created randomly somewhere in the mine.  This keeps
       the number of weapons in the game constant.  If you see a weapon
       suddenly appear in front of your ship, consider yourself lucky!
       Cloak/Invulnerability replacements are created when these effects
       wear off of a player.  Concussion Missiles do not replace themselves.

     o Bringing up a menu in Multiplayer Descent does NOT stop the action.
       Your ship is still vulnerable to attack.  If you need to spend
       time in a menu, find a place to hide.  If you're attacked while in
       a menu, the game will automatically return you to the game so you
       can defend yourself.  It will also return you from menus if the
       reactor is about to explode.

     o After finishing a level in Multiplayer Descent, there may be
       a waiting period while other players escape the mine.  Everyone
       will then enter the new mine together.  The waiting delay may be
       up to 60 seconds.  If you wish, you can exit the game entirely by
       hitting <ESC> at this screen.


ษออออออออออออออออออออออออป
บ 3b. Multiplayer:       บ
บ     Modem/Serial Games บ
ศออออออออออออออออออออออออผ

>NOTE:  If you experience any problems, see Section 7 for troubleshooting
        tips and solutions.

Modem/Serial Setup
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Before attempting to start a Serial game, both users should check
the Com Settings menu to verify that the options are correct.  Any 
changes are saved for future games.

NOTE:  Games using a null-modem cable require that both machines use the
       same baud rate in the Com Settings menu.  Modem games, however, do
       not require this.

If your machine has a 16450 UART, you should choose 9600 or 19200 baud.
The higher the baud rate, the better Descent will perform.  If your
computer has a 16550 UART, you can use 38400 baud rate for optimum
performance.  If you are unsure what type of UART your machine has, you
can try selecting the 38400 baud rate option.  Descent will tell you if
it does not detect the 16550 UART required for 38400.

For modem users, note that changing the baud rate in the Com Settings 
menu actually sets the rate of communication between the computer and the
modem.  Even though many modems do not support actual baud rates above
14400, it is still better to choose a 38400 baud rate in the menu.
This will allow Descent to spend less time communicating with the modem,
and will increase game performance.

Modem Descent requires at least a 9600 baud modem with an error correction
protocol (preferably v.42).  Data compression is also helpful, and
should be enabled in the modem (v.42bis is preferable).  The modem should
respond to a drop in the DTR control line by hanging up.  Fortunately,
most modern modems have adequate factory settings for playing Descent.

If you receive good performance at 9600 baud or above when using your
modem for things like on-line services, no special initialization string
should be necessary to run Descent ("ATZ" will do nicely).  If your modem
is something more exotic, you may wish to use an init string of "AT&F"
to reset it to factory defaults, which should work great with Descent.


Connecting
ฤฤฤฤฤฤฤฤฤฤ
>> NOTE: If you are using a serial port with a non-standard IRQ, you will
need to use the Custom option in the Com Settings menu.  Pressing return
on this checkbox will allow you to change the settings.

Starting a game of Serial Descent is a two-stage procedure.  First, a 
link must be established between two machines.    This is accomplished 
differently depending on what type of game you are playing.

If you are establishing a null-modem cable link, both players must select 
"Establish Null-Modem Link" from the serial game menu.  After the two 
computers have established a connection over the null-modem cable you 
will be returned to the menu and should have new options available to you.
If the two machines fail to achieve a link, check the serial parameters 
on both sides.  The baud rate settings must be identical on both sides for 
them to communicate properly.   After establishing the null-modem link, 
one machine is designated as the master and the other is the slave.  This 
is not visible from the menu, but when you go to start game, only one of 
the two machines will prompt for the game settings to use.  See Starting 
a Game below for more information.

If you are starting a modem game,  One person must select Dial Modem 
from the serial game menu and the other must select Answer modem.
After the modems connect, you will be returned to the serial game menu
and new options will be available to you.


Starting
ฤฤฤฤฤฤฤฤ
You should now see the "Start Game" option on your menu.  The blue line
should indicate if you are connected or not.  When selecting Start Game,
one player will be offered a menu of game options such as start level
and game mode.  If a modem is being used, the person who dialed
will need to choose the game options, while the other waits for him/her
to start.  In null-modem games the starter is randomly determined.  After
this, both players will be placed in the mine and the game begins.

After the game is finished or if one of the players decides to leave the 
game, both players are returned to the serial game menu.  The 
communication link is STILL ACTIVE, however.  If you want to play 
another game, perhaps with different settings or a different starting 
level, just select Start Game once again.  If you want to hangup the 
modem or release the null-modem connection, select Close Link.  

Another feature of the modem game is the ability to send messages back 
and forth between connected players before they are in the game.  
You can do this by selecting Send Message from the Serial Game menu.  
This option is only available once a connection has been established.  
This is useful if you do not have an extra phone line for voice 
communication while playing and you need to negotiate the terms of the 
game.  Another feature is automatic notification when a game is starting.  
If one player selects start game but the other does not, the person who 
didn't start will be informed that the other player is ready.  If the
user isn't prepared to start yet, the first user will be notified.  

Make sure you select Close Link or exit the serial game menu if you're 
finished with the modem game.  If you do not, the modem will remain
connected to the other player.


Phone Book
ฤฤฤฤฤฤฤฤฤฤ
A small phonebook is available from the dial menu of the serial game 
menu.  This lets you store the names and phone numbers of your 8 most 
frequent opponents.  To edit the phonebook go to the Dial menu and 
select Edit Phonebook.


ษอออออออออออออออออออป
บ 3c. Multiplayer:  บ
บ     Network Games บ
ศอออออออออออออออออออผ

Netgame Requirements
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Descent is designed to run on networks using the IPX protocol.  
To use IPX protocol on your LAN-connected PC, you must be loading the 
IPX.COM driver provided by Novell, in addition to lower-level drivers 
required by your particular brand of network card.

Shareware Descent requires that network players all be connected to the
same local network so their packets can be routed directly without
intermediate processing by routers.  The Registered/Commercial version
of Descent will support routing through network servers.

Netgame Setup
ฤฤฤฤฤฤฤฤฤฤฤฤฤ
Descent supports up to 4 simultaneous network games on a single socket.  
If you need to run more than 4 games on a single LAN, players can use 
the -socket option to change to a different socket number.  Descent uses 
a default socket number of 5100(Hex).  The -socket option adds a value 
to this base, so '-socket 1' would tell Descent to use socket 5101(Hex).  
This option can be used to avoid socket conflicts with other network 
services should they arise.

Also, if you are on a large network with many games playing, you can use
the -msockets command line switch.  Then, while you are in the searching
for net games menu, you may hit PgUp and PgDn to toggle between 50 
different sockets, which should allow for up to 200 games to be played.
If you leave this menu and go to the start net game menu, the net game
that you start will be started on the current socket that you selected in
the join menu with the PgUp and PgDn keys.

One person playing must select Start Netgame from the Multiplayer menu.
The starting parameters are explained below:

Starting a Netgame
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
DESCRIPTION:  The name of the game, literally.  This is merely for other
       people will see this when they are choosing games to join.

LEVEL:  The level the game will start on.  Play may progress to other
       levels during the game.

MODE:  Determines type of game to be played:

                  ANARCHY:  A human-only free-for-all battle to the death.
                            The goal is to accumulate the most kills.

           * TEAM ANARCHY:  Same as Anarchy, but with teams.

    * ANARCHY with ROBOTS:  Same as Anarchy, but with robots thrown
                            in.  The goal is still to kill your human
                            opponents, but the robots have their
                            own agenda... Robots are also a good source of
                            powerups.

            * COOPERATIVE:  Humans vs. the robots.  Save humanity!

* Only Available in registered/commercial Descent.
  See ORDERFRM.TXT for details.

CLOSED GAME:  Determines whether or not new players will be allowed
       to join once the game has started.  If you have checked the
       Closed Game box, only the starting players will be in the game.
       Note that even in Closed games, the starting players are allowed
       to leave Descent and rejoin at any time. 

DIFFICULTY:  This determines many factors from robot awareness and
       deadliness to time for mine destruction countdowns.  If the
       slider is to the left the game will be easier, to the right it
       will be harder.

Once parameters are set, hit <ENTER>.  The next screen is player
selection.  As each player selects your game from the Join Game screen,
his/her name will appear on your list.  By default, all players wishing
to join will be selected, but you can deselect them by pressing the
spacebar on their checkbox.  Press <ENTER> to start the action.

Team Selection
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If you've chosen Team Anarchy mode, the next screen will be Team Selection.
Team names can be modified in the text boxes.  Pressing <ENTER> on a
player's name will move him/her to the other team.  Team 1 ships will be
colored BLUE and Team 2 ships will be RED.  Press <ESC> to accept the teams
and start the game.  

Joining a Netgame
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
Choose Join Netgame from the Multiplayer level.  The next screen will show
you all active netgames on that socket.  Below each game is listed the
current level number, number of people playing, and game status.  Netgame
status can be:

                  FORMING:  Game is in player-selection phase.
                            Anyone may attempt to join a forming netgame.

                     OPEN:  This means the game is in progress, and you
                            may join at any time.

                   CLOSED:  The game is playing, but closed to new players.
                            This is because there are 8 players in the
                            netgame already, or the game was started
                            as Closed.

           BETWEEN LEVELS:  The game is in progress, but the players are
                            rushing for the escape tunnel.  If you wait
                            for the level to advance, it will change to
                            JOIN and you can then hop in.  Closed netgames
                            will never show this message.
       
Rejoining a Netgame
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
If you leave a netgame for any reason, you may rejoin the ongoing game
when you're ready.  Although you lose accumulated items, you will
retain your ship color and kill count (unless you've been gone long
enough for someone new to have taken your spot).  Make sure you rejoin
from the same computer using the same pilot name so the game knows
you as a previously-joined player.

The person who started the game is also free to leave and re-join the 
game at will; there are no special restrictions for this person once
the initial parameters have been chosen.


                ษออออออออออออออออออออออออออออออออออออออออออป
                บ 4. Thrustmaster controls, Gravis Phoenix บ
                บ          and Logitech Cyberman           บ
                ศออออออออออออออออออออออออออออออออออออออออออผ

Thrustmaster, Gravis Phoenix, and Logitech Cyberman controls are fully
supported by Descent.  The device control files (DESCENT2.ADV, DESCENT.B50,
DESCENT.M50, and DESCENT.PHX) can be found in your Descent directory.
If you have a Wingman Extreme, you should use the Thrustmaster FCS option.

       Thrustmaster FCS:  Choose "Thrustmaster FCS" under Options/Controls.
          Mark I/II       This is for players _not_ also using the WCS.
       (when not used     If you use the WCS throttle with the FCS, follow
          with WCS)       instructions for the WCS below.

     * Thrustmaster WCS:  Load the DESCENT2.ADV file into your WCS.  In
           Mark II        Descent, choose "Joystick" under Options/Controls.
                          Now choose "Configure Above" and change the
                          THROTTLE entry to respond to the WCS (the Y2 axis).
                          Also see special note in section 7 about the WCS.

    * Thrustmaster FLCS:  Load the DESCENT.B50 & .M50 files into your FLCS. 
                          If you also use a WCS throttle, no program should
                          be loaded into the WCS.

         Gravis Phoenix:  Load the DESCENT.PHX file into your Phoenix. In
                          Descent, choose "Joystick" under Options/Controls.
                          Now choose "Configure Above" and change the
                          THROTTLE entry to respond to the throttle
                          slider (the Y2 axis).

      Logitech Cyberman:  You must have the Cyberman SWIFT driver loaded
                          before you run Descent.  See Cyberman docs for
                          details.  

Calibration Note:  When using one of the analog throttles listed here or
                   the CH Flightstick, you will be prompted to calibrate
                   your throttle as well as your joystick.

*  >> NOTE TO WCS and FLCS USERS:  Because these devices intercept the
      keyboard signals, your ship may fly strangely when you also hold down
      keyboard keys (like 'A' and 'Z').  If you keep the WCS or FLCS on
      your system, it's recommended that you use those devices for throttle
      control and sliding, not the keyboard.


                       ษออออออออออออออออออออออออป
                       บ 5. Demos & Screenshots บ
                       ศออออออออออออออออออออออออผ
Demos
ฤฤฤฤฤ
Descent has a fully integrated demo recording and playback system.  This
recording will work in single or multiplayer games, so you can have
a permanent record of blasting your friends to pieces.  Hitting F5 in the
game will turn on recording.  Hitting it again will turn it off and
prompt you for a filename.  If you press <ESC> from the filename box, the
demo will NOT be saved.  The demos will record the advance from one
level to the next; however, the escape sequences will be skipped in
playback.

Demo files are saved in the Descent directory and have the filename
extension ".DEM".  Of course, Descent DEM files may be distributed freely.

>>NOTE:  Descent .DEM files can become quite large on disk.  This is
         especially true when recording heavy combat.  Make sure you have
         adequate disk space before recording.  If you have less than 500k
         free on disk, you won't be allowed to record a demo.

To view a recorded demo, choose View Demo from the Descent menu.  During
playback, the following keys are available:


   Arrow keys:                 Also:   SHIFT-LEFT ARROW  = fast reverse
                                       SHIFT-RIGHT ARROW = fast forward
                                       CTRL-LEFT ARROW   = go to start
            play                       CTRL-RIGHT ARROW  = go to end
             /\
             ||                        PRINT SCREEN      = save screenshot

  rewind <=      => forward

             ||
             \/
            stop


Certain gauges and other trivial items won't display accurately in demo
playback in order to minimize the space needed for demo files.


Screenshots
ฤฤฤฤฤฤฤฤฤฤฤ
Hitting the PRINT SCREEN key will save a screenshot.  The files are
written to the Descent directory with the name convention SCREENxx.PCX.
The number xx will automatically increment as long as you're in Descent.
If you leave the game, then return, the numbering will start over and
overwrite existing screenshots.  The pictures are in .PCX format.


                       ษอออออออออออออออออออออออออป
                       บ 6. Command-Line Options บ
                       ศอออออออออออออออออออออออออผ

The following DOS command-line options are available in Descent:

  -CyberMaxx     Enables CyberMaxx helmet display
  -MaxxTrak <n>  Enables CyberMaxx head tracking via COM port n
  -Iglasses      Enables Virtual I-O's iglasses! stereo helmet display
  -VioTrack <n>  Enables iglasses! head tracking via COM port n
  -VFX           Enables VFX helmet support
  -VFXTrak       Enables VFX head tracking (VFX1.COM must be resident)
  -VFXMono       Enables monoscopic rendering for VFX helmet

  -Volume <v>    Sets sound volume to v, where v is between 0 and 100
  -Socket <n>    Changes IPX socket for network games
  -Msockets      See network section of readme for more info.
  -LowMem        Lowers animation detail for better performance with
                 low memory machines

  -Verbose       Shows initialization steps for tech support
  -NoSound       Disables sound drivers
  -NoMusic       Disables music
  -NoDigiDrums   Disables the digital drums on FM sound cards
  -NoMemCheck    Disables memory requirement checking
  -NoLoadPats    Disables patch loading for Gravis UltraSound
  -NoNetwork     Disables network drivers
  -NoSerial      Disables serial drivers
  -NoJoystick    Disables joystick support
  -NoMouse       Disables mouse support
  -NoDosCheck    Disables DOS version checking
  -JoyPolled     Uses polling to read joystick. Use with Windows/OS/2.
  -JoyBios       Use BIOS function 15h to read the joystick.


                 ษออออออออออออออออออออออออออออออออออออออป
                 บ 7. Troubleshooting & Common Problems บ
                 ศออออออออออออออออออออออออออออออออออออออผ

Regardless of configuration, you should have no trouble running Descent.
But in the unlikely case you do have problems, here are some helpful
pointers:
      
General Problems
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
=> Q:  DESCENT RUNS SLOWLY ON MY MACHINE, ESPECIALLY IN LARGE BATTLES.
       WHAT CAN I DO?

   A:  Try putting your detail level on a lower setting.  Also try using
       F3 and +/- to change the size of the game window.  Lowering the
       number of available sound channels in Options/Detail/Custom
       menu can help significantly in large battles.

=> Q:  I HAVE A SMALL GAME WINDOW AND A LOW DETAIL LEVEL, BUT DESCENT STILL
       LOADS AND RUNS SLOWLY.

   A:  Check your sound card settings in SETUP.  Incorrect settings
       can cause significant slowdown.

=> Q:  THE WALLS IN MY GAME SEEM TO JUMP AROUND IN THE DISTANCE.  WHY?
=> Q:  I GET A COLORED WALL IN THE MIDDLE OF MY TUNNELS.  WHAT IS THIS?

   A:  These are due to the Detail Level being set below the highest
       setting.  See "Detail Levels" in Section 1.  

=> Q:  MY COMPUTER HAS 4 MEGS OF RAM.  THE GAME IS SLOW AND ACCESSES THE
       HARD DRIVE ALL THE TIME.

   A:  If you have less than 8 megs of RAM, try running a disk cache (even
       as small as 256k).  This can help immensely.  Also try using the
       "-lowmem" command line option when running Descent.  You might
       consider purchasing a memory upgrade.  Every meg of RAM you add will
       increase performance.

=> Q:  DESCENT LOCKS UP WHEN I RUN IT.

   A:  Try running Descent with the "-nosound" option.  If this works, then
       chances are it's a sound card problem.  Run SETUP and make sure
       your card settings are correct.  If you don't hear digital sounds or
       music when you test them in SETUP, try Autodetection.  If this
       doesn't help, refer to your sound card manual for troubleshooting
       instructions, or call Interplay Technical Support.    

=> Q:  DESCENT DOESN'T WORK WITH MY GRAVIS ULTRASOUND.  I HAVE MORE THAN
       512K RAM ON MY GUS CARD, AND THE GAME HANGS WHEN LOADING PATCHES.

   A:  In your Descent directory there is a file called DESCENTG.INI.  Edit
       this file with a text editor like DOS EDIT or BRIEF.  Change the
       third line to read: "O 768 8 22" instead of "O 768 8 44".  Also
       change the fourth line to read "O 1024 8 22" instead of "O 1024 8 44".
       This will force the patches to load in 22khz instead of 44khz, and
       should solve your problem.

=> Q:  MY COMPUTER LOCKS UP WHEN AUTODETECTING SOUND CARDS IN SETUP.
       WHAT'S WRONG?

   A:  Due to hardware conflicts, autodetecting for sound cards is a
       risky process.  If you know the brand, port address, IRQ, and
       DMA of your sound card(s), it is recommended that you manually
       configure these items.  Lockups are also common when autodetection
       is used when no sound cards are installed.

=> Q:  I CAN'T SELECT THE RIGHT PORT/IRQ/DMA FOR MY SOUNDCARD IN SETUP.

   A:  If the proper selections don't appear in the SETUP, then you can
       always select them manually by editing your DESCENT.CFG file
       located in your DESCENT directory.  While we tried to account for
       every possibility, some of the more exotic configurations may not
       be listed.  Contact Interplay if your setup is not listed.  

=> Q:  WHY DON'T I HEAR ANYTHING WHEN I TEST MY SOUND IN SETUP?

   A:  You may have the wrong sound card selected, or incorrect port,
       IRQ or DMA settings.  Volume may be set too low in your sound
       drivers (or the volume slider on the back of your sound card).
       Hardware conflicts or loose cables may be to blame as well.
      
=> Q:  MY JOYSTICK ISN'T RESPONDING IN THE GAME.  WHAT'S WRONG?

   A:  Be sure you have JOYSTICK selected in the Options/Controls menu,
       and that it's calibrated.  If your joystick connects to your
       soundcard, make sure the joystick port jumper is ENABLED on the card.
       Some soundcards have this disabled by default.

=> Q:  HEY!  SOME OF MY POWERUPS DISAPPEARED.  WHAT HAPPENED?

       Certain powerups will remove themselves from the game if they have
       been around 4 or 5 minutes.  This only happens to Concussion
       Missiles, Energy, and Shield powerups dropped by a dead player.
    
=> Q:  WHY DOES DESCENT ACT STRANGELY WHEN I RUN IT UNDER WINDOWS?

   A:  While Descent may run under Windows, it isn't recommended.  You will
       probably get odd behavior and slowdowns due to timer conflicts.
       GUS users may get no sound at all under Windows.  

=> Q:  WHY DOES MY JOYSTICK ACT STRANGELY WHEN I RUN UNDER WINDOWS OR OS/2?

   A:  OS/2 and Windows might allow a task switch during the joystick 
       reading process which can cause erratic readings.  This effect can
       be reduced by using the -joypolled command line switch.  Also, if 
       you use a special joystick driver for OS/2 that implements a quality
       joystick reading routine via BIOS function 15h, try using the 
       -joybios switch which use function 15h to read the stick.

=> Q:  I HAVE A THRUSTMASTER WCS HOOKED UP WITH A JOYSTICK.  WHEN I USE
       THE STICK TO FLY, AND THE 'A' AND 'Z' KEYS TO MOVE FORWARD AND
       BACK, I START FLYING OUT OF CONTROL.  WHY?

       Holding down keyboard keys will produce erratic results when the
       WCS or FLCS controls are installed.  See note in Section 4 for
       details.

=> Q:  WHY ISN'T MY MIDDLE MOUSE BUTTON WORKING IN DESCENT?

   A:  While Descent supports three-button mice, you still need to load
       a mouse driver that supports three buttons.  Typically Microsoft
       mouse drivers support two and Logitech drivers use three.

Modem/Serial Problems
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
=> Q:  WHEN PLAYING A MODEM/SERIAL GAME, MY GAME FREEZES ON THE "WAITING
       FOR OPPONENT" SCREEN.  WHAT GIVES?

   A:  This screen will appear if you have died in/escaped from an
       exploding mine.  If the other player is still flying there can be
       up to a 60 second delay.  This is normal.  However, if your game
       sits at this screen much longer, chances are something is wrong.
       Likely culprits:  opponent is having technical difficulties,
       interference with unshielded serial cables, loose cables,
       baud rate set too high, or uncorrected errors in the modem
       transmission.

=> Q:  MY MODEM GAMES ARE MUCH SLOWER THAN NORMAL ONE-PLAYER GAMES.

   A:  Try using a higher baud rate in the Com Settings menu.  If your
       computer does not have a 16550 UART, acquiring one will allow
       up to 38400 baud when communicating with the modem.  See the
       Modem/Serial Game section for details. 

=> Q:  STRANGE THINGS HAPPEN IN MY MODEM/NULL-MODEM GAMES.  WHAT CAN
       I DO TO HELP THIS?

   A:  This may be a result of dropped serial characters.  Some examples
       of "strange" things:  players not dropping powerups when killed,
       ships jumping from place to place on screen, or ships flying
       through doors that appear closed.  If you get error messages during
       play or during the "waiting for opponent" screen, this could be
       the cause as well.

       These problems may occur for several reasons.  Serial play adds an
       additional burden to the CPU when playing the game, so a computer
       capable of playing the game in single-player mode may have
       difficulties with modem or serial play.  If you are using a
       4-megabyte machine, the disk activity needed to run the program in
       a small memory space can cause lost characters.  A lot of sound
       activity can also cause lost serial characters.  Increasing the RAM
       for the game or reducing the number of sound channels in the detail
       settings menu can sometimes help.  Of course you can also reduce
       the baud rate in the Com Settings menu to slow down the game
       somewhat while improving reliability.

       The best thing you can do to improve serial performance is to equip
       your machine with a 16550 UART.  However, even with this UART 38.4k
       baud rate can still be problematic if you have the burden of low
       RAM or heavy sound activity, so don't be ashamed to run a 16550
       UART at 19.2k baud if need be.


Netgame Problems
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
=> Q:  I'M GETTING AN ERROR SAYING MY IPX DRIVERS AREN'T LOADED PROPERLY.
       WHAT DO I DO?

   A:  First, make sure you have a reasonable amount of low memory
       available.  Although Descent uses a DOS extender to avoid low-
       memory hassles, some low memory is still needed for network buffers.
       If this fails, make sure your IPX.COM and other network drivers
       are loaded properly.  A good way to test this is to logon to
       a network server, if one is available.

=> Q:  MY NETGAMES SEEM SLOW AND UNRELIABLE.  WHAT'S UP WITH THAT?

   A:  Try using a different socket number.  It's possible that some other
       application on your computer uses socket 5100h and this is
       preventing Descent from opening a proper network connection.  Try
       large values for the -socket option (like 32 or 100).  Remember,
       your opponents will need to use the same socket you do.

=> Q:  DESCENT TELLS ME MY NETWORK CARD IS MISSING PACKETS.  WHAT THE
       HECK DOES THAT MEAN?

   A:  This can be a result of a slow network card, heavy traffic on the
       network, or software conflicts in your system.  If you get this
       message, you can rejoin the game and try again.  If the problem
       persists, one of the following could be to blame:

       - Loose cables.  Happens to the best of us.  Check the plugs on
         the back of your computer, specifically the ones running to/from
         your network card.

       - Too many players.  While 8 players is offered as the maximum
         in Descent, it's possible that your LAN or computer configuration
         can only support 4-6 players reliably.

       - Bad network card.  Some cards drop IPX packets even without
         heavy loads or interference.  If you suspect your LAN card, try
         swapping it with one from another computer.

       - Software conflicts.  Other drivers may be running that cause
         problems with the network interrupts.  These conflicts may not
         emerge when performing other LAN tasks that either don't use
         IPX or have layers of error-checking.  Try removing unneeded
         drivers from your CONFIG.SYS and AUTOEXEC.BAT.

       - Router problems.  Playing Descent with players on different sides
         of a router may cause lost packets or delays.  Playing this way
         is not recommended because it creates a significant load on the
         router that may disturb other LAN users.


                          ษออออออออออออออออออออออป
                          บ 8. Technical Support บ
                          ศออออออออออออออออออออออผ

=> Q:  YOU'RE NO HELP AT ALL!  I DON'T UNDERSTAND WHAT'S HAPPENING!
       CAN'T YOU SEE I NEED PROFESSIONAL HELP, MAN?

   A:  Don't panic.  Interplay Technical support is happy to help with
       with any problems you have.  Help is available 24 hours a day
       through our Automated Customer Service system, with representatives
       available during normal business hours.  Here's how to contact us:

                     ษออออออออออออออออออออออออออออออออป
                     บ   Interplay Technical Support  บ
                     บ       & Customer Service       บ
                     บ                                บ
                     บ          714-553-6678          บ
                     ศออออออออออออออออออออออออออออออออผ

   Please try to have your system information available and be near your
   computer if at all possible.

   Other ways to get help:

   Interplay Productions     Interplay BBS: 714-252-2822
   attn: Customer Service   America Online: keyword INTERPLAY
   17922 Fitch Avenue                       or email to "IPTECH"
   Irvine, CA  92714                 GEnie: type "M805;1"
                                CompuServe: GO GAMBPUB
                                   Prodigy: email to "PLAY99B"
                                  Internet: email to support@interplay.com


                     ษออออออออออออออออออออออออออออออออป
                     บ 9. Ordering Registered DESCENT บ
                     ศออออออออออออออออออออออออออออออออผ

Can't get enough Descent?  It's a common malady.  It inflicts everyone
sooner or later.  The only cure is to order the full 30-level Descent
experience.  Call 1-800-INTERPLAY or see ORDERFRM.TXT in your game
directory for details.

VFX-1 helmet information can be acquired from Forte at 716-427-9595.
For CyberMaxx helmet information, call VictorMaxx at 1-800-815-MAXX x221.
For Iglasses! helmet information, call Virtual I-O at 206-382-7410.

INCLUDED IN REGISTERED DESCENT:
     - 30 heart-pounding levels!
     - 4 new earthshaking weapons!      
     - Tons of new, deadlier robots!
     - New Multiplayer modes, including Cooperative and Teams!
     - The long-awaited IN-LEVEL SAVE FEATURE!

Yes, it's true!  By popular demand, Registered Descent will have an
in-level save game feature!  Thanks to all who responded.


                      ษออออออออออออออออออออออออออออออป
                      บ 10. Distribution Information บ
                      ศออออออออออออออออออออออออออออออผ

Shareware Descent is freely distributable to anyone and everyone so
long as it is distributed in UNMODIFIED FORM and no fees are charged.

For more infomation on authorized distribution, contact any of the
following distributors:  

          ABCO, American Distributors, D&H Distributors, Handleman,
          Ingram Micro, Josha Distributors, Merisel and Navarre
          or call Interplay at 714-553-6655.


ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
        DESCENT IS COPYRIGHT (C) 1994 PARALLAX SOFTWARE CORPORATION
                           ALL RIGHTS RESERVED
                 PUBLISHED BY INTERPLAY PRODUCTIONS, INC.
ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

-END OF FILE-
