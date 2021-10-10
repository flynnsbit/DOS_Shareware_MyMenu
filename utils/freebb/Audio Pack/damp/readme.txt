DAMP - The DOS MP3 Player and Visualisation Program
By Matt Craven. (c)1999/2000 Hedgehog Software.
Version 0.96

* WHEN CONTACTING ME ABOUT DAMP, ESPECIALLY IF REPORTING A BUG, REMEMBER
  TO INCLUDE WHICH VERSION OF DAMP YOU'RE USING, AND THE HARDWARE
  YOU'RE USING IT ON! (in other words, READ the "Bug reports" section of
  this readme file)

Contents
========
o Introduction
o Requirements
o Disclaimer / Legal
o Licence
o Usage
o Getting the best sound quality
o Help with DAMP.ini
o Keypad Control
o Joystick Control
o LCD Display support
o Input Drivers
o The DAMP GUI
o History
o Future
o Known bugs
o Bug reports
o Credits
o Hall Of Fame

Introduction
============
DAMP is an MP3 player for DOS. If you don't know what DOS
and/or MP3 is, you probably don't want it.

Why?

a) Windows MP3 players are bloated (seeing as they're now becoming
   media players rather than straight MP3 players)
b) I wasn't overly impressed by the DOS MP3 players I found
c) I decided that one of my mates needed an MP3 player for DOS (for some
   reason I forget now)
d) DAMP is a cool name for a program

Here's a brief feature list:

o Plays MP3 files (Duh!)
o Can play a sequence of MP3 files from a WinAmp playlist (.M3U) file
o Can play a sequence of MP3 files from a Sonique playlist (.PLS) file
o Ignores non-MP3 files in playlists
o Can play a selection of songs from a playlist, rather than the WHOLE
  playlist.
o Random play
o "Surround Sound"
o A pretty funky visualisation option that can even synchronise its graphics
  to the beat of the music
o Supports long filenames (under Windows - and under plain DOS if you
  get the lfndos.zip from http://members.xoom.com/dosuser/ )
o Keypad control (for jukeboxes/stereos)
o Joystick control (user defineable via DAMP.ini)
o Multiple playlist support.
o ID3 tag support
o LCD support
o An optional GUI
o Input driver support

Requirements
============

Minimum:
o A PC with DOS
o A Sound Card
o Some MP3s

Recommended:
o A fast PC
o A Sound Blaster 16 card
o Some GOOD MP3s
o Kickass speakers
o The biggest monitor/display you can get hold of

**Note**: It may be quite un-stable on NT machines, so I would strongly
advise you not to run it under NT. Worst case it could damage your monitor.

It works fine on my Windows 95 machine, and my Windows 98 machine.

To run it under pure DOS, you'll need CWSDPMI.exe (if you don't
have it, you can download it from the DAMP web page).

Supported sound cards:
ESS Audiodrive
Any card which properly emulates a SoundBlaster1, 1.5, 2, Pro, or 16.
SB Live! (although not under plain DOS)

DAMP is known to work on the following machines:

Intel Pentium III 700MHz with Creative SoundBlaster Live! (The development machine)
Intel Pentium 166MMX with Creative SoundBlaster AWE64
Intel PII-350 with Creative SoundBlaster Vibra16 (The primary test machine)
Intel Pentium 133 with ProSound 3d (onboard)
Intel Pentium 90 with ProSound 3d (onboard) 16Mb RAM, 1Mb Diamond Stealth VGA
AMD K6-2 300MHz with Creative SoundBlaster16
AMD K6-2 350MHz with Creative Vibra16, 64MB RAM, SIS6326 AGPx2 (8Mb) graphics card.
AMD 486/133 P75 with Opti929 sound card.

But it should work well on other (slower or faster) machines. Of course
there's a limit to how slow you can go before audio quality is degraded -
I'd recommend a P100 or higher.

Stereo output is only supported on the SBPro and SB16 drivers.
16-bit output is only supported on the SB16 driver.

If you want to know which driver it's using on your system, run DAMP
with the -developer option, and it should tell you (and it will also
tell you a lot of other things you probably don't need to know).

Disclaimer / Legal
==================

I haven't tested DAMP on a large variety of systems, and as such,
no warranty is either expressed or implied, and neither the author
nor Hedgehog Software can be held responsible for any effects,
adverse or otherwise that this software may have on you, your computer,
your pet tortoise or anything else you can think of.
Bottom line: USE THIS SOFTWARE AT YOUR OWN RISK!

All trademarks in this document are property of their respective owners.


Licence
=======

DAMP is copyright 1999/2000 Hedgehog Software.

This software is FREE. You can copy it for anyone, put it on the net,
CDs etc.

If you wish to use DAMP for live performance, or in a club etc, you
MUST let me know by email to damp@damp-mp3.co.uk

MAGAZINES: If you put DAMP on your cover CD, let me know by email
to damp@damp-mp3.co.uk

ARTICLES: If you write an aricle about DAMP, for either a printed
or on-line magazine, you MUST let me know by email to damp@damp-mp3.co.uk

COMMERCIAL:
If you want to use DAMP in a commercial product, (something you make
money out of), you MUST contact me first at damp@damp-mp3.co.uk in
order to obtain my permission.
DAMP is free for commercial use, provided you have contacted me, and
agree that, at my discretion I may request your product for myself,
free of charge. (Eg: If you make portable MP3 players using DAMP,
I can ask you to send me one, at your expense).
Also, I reserve the right to deny you permission to use DAMP in a
commercial product.
Finally, you must place the following in the documentation accompanying
your product:

"This product is powered by DAMP - http://www.damp-mp3.co.uk/"

Please also be aware that DAMP uses several libraries, whose authors
may require payment for commercial use.  See the DAMP web site
for links to the libraries (in the "Thanks" section).

However DAMP is used, it MUST NOT be reverse-engineered, decompiled, or
altered in any way, and this file MUST accompany any copy of DAMP that
is distributed.

Seeing as I'm giving this away for free, and as I put quite a bit of
work into it, I'd like to know that someone out there is using it, so
email me at damp@damp-mp3,co.uk and tell me you've used it,
and what you thought of it.

If you like DAMP and use it regularly, it would be nice if you could
make a donation to a charity of your choice.

If you have a web site and link to Hedgehog Software at
http://come.to/hedgehog-software/
or the DAMP web site at:
http://www.damp-mp3.co.uk/
Let me know, and I'll return the favour.

YOU MAY NOT USE THIS SOFTWARE if you are a racist.
YOU MAY NOT USE THIS SOFTWARE if you are a paedophile.


Usage
=====

I'm assuming you've unzipped DAMP into a directory somewhere, or you're
going to do it now...

Go into DOS, or open an DOS box in Windows. Change to the directory
where you installed DAMP.

The general usage for DAMP is one of:

  DAMP filename.mp3 {options}
  DAMP filename.m3u {options}
  DAMP filename.pls {options}

Where giving it an MP3 filename will play that MP3 file, and any
of the other extensions to play from a playlist. You can play all the
MP3 files in a directory by using *.MP3 as the filename, eg:

  DAMP c:\mp3_files\*.mp3

You can also specify multiple MP3 files on the command line:

  DAMP c:\mp3_files\first.mp3 c:\mp3_files\cool_tune.mp3

If you specify a mix of MP3 filenames and playlist filenames, the MP3
files will be played first, then the playlists.

You can use multiple playlist filenames (of multiple types if you like):

  DAMP c:\mp3_files\album1.m3u c:\mp3_files\album5.m3u c:\temp\test.pls

and you can use wildcards:

  DAMP c:\mp3_files\album\*.mp3 c:\mp3_files\*.m3u c:\mp3_files\*.pls

Now onto the options. The options can be one or more (or none) of:

-r       : Enable random play
-g       : Enable full graphical visualisation mode
-p <n>   : Only play <n> tracks from the playlist
-s       : Enable "Sync to beats" - Auto-changes graphics on the beat (COOL!)
-s <n>   : Sync to beats and set minimum threshold to <n>. Default is 5.
           Decrease this if it flashes too much, increase it if it doesn't
           sync often enough. The range allowed is 0 (low sensitivity) to
           10 (high sensitivity).
-q <n>   : Set quality to <n>. This is only really useful when using the
           graphics module. If you use -q 1, the graphics will update faster,
           and be less jerky, but with less accurate sync to beats, and
           the sound may suffer stuttering. -q 2 works well on my
           system (P166 MMX), but you may need to use -q 10 on slower systems.
           If this is omitted, the default is 4.  Using -q 0 will produce
           absolute best quality output, but will cause very jerky graphics
           on anything other than very fast machines.
-bnw     : Use an alternating black/white palette. Looks really freaky.
-n <n>   : Display track name in graphics mode (the name will scroll across
           the screen). <n> Is the number of times to do this (in case it annoys
           you after a while), or -1 to do it continuously.
-m       : Displays a menu, from which you can set the commonly used options!
-z       : Stops DAMP from changing the zoom method when sync to beats and
           graphics are on.
-v       : Make DAMP display its version number as it starts up.
-c       : Enable continuous play (ie when it finishes playing all the files
           you specified, or it finishes playing the playlist, it starts again
           from the beginning). Note that when multiple playlists have been
           specified, this option will cause the first playlist to be played
           over and over again - it will never play the other playlists.
-noid3   : Disable ID3 tag support.  As tag support is preliminary in this
           version of DAMP, it may cause problems, so you can disable it
           by using this option.
-rp      : If you specified multiple playlists, this option will randomize
           the order in which the playlists themselves get selected.
-noscope : Disables the text-mode volume meter.
-surround: Enables surround sound at startup.
-keypadhack: See the "Keypad Control" section.
-beatsync <n> : Allows you to manually set the beat sensitivity threshold.
                <n> should be a number (which can be floating point eg:0.001)
                This is for use if you don't like any of the 10 defaults
                offered by the -s option.  NOTE: Do not use this option
                as well as using the -s option, use it INSTEAD of the -s
                option.  To give you some idea of the values you can use,
                the 10 default -s values are:
                8.0, 4.0, 3.0, 2.0, 1.75, 1.25, 0.90, 0.5, 0.1, -1.0
                low sensitivity ................... high sensitivity
-lcd     : Enables output to LCD display.  See the section
           below for more details.
-beep    : Causes DAMP to emit a short beep at the start of each track.
           Useful if you're using your machine "blind", to know that
           everything's running okay.
-fnfnoquit: If you specify this option, DAMP will not quit when it cannot
            find a file.  Be warned that if you use this option and DAMP
            cannot find ANY files, it will hang.  It is merely useful if
            you use a removeable-media drive and always want to specify
            it as well as some other fixed drive.
-gui     : Use the DAMP GUI.  See the section entitled "The DAMP GUI" for
           more details.
-indrv   : Use the input driver specified in DAMP.ini (see "Input Drivers").
-paused  : Start DAMP in "pause" mode.
-skip <n>: Skips the first <n> tracks. Eg -skip 2 will skip the first 2
           tracks and start playing at track 3.
-remaining: Makes the time display show time remaining rather than time
            elapsed.
-sleep <n> : Makes DAMP quit after <n> minutes.  If you have set the
             "sleep_fade" setting in the "[options]" section of DAMP.ini to
             "yes", then after <n> minutes, DAMP will begin fading out
             the audio. Note that fading out can add up to 2 minutes 10 secs.
             onto the total time until DAMP quits. (eg: If you are playing
             DAMP at full volume, and specify -sleep 5, DAMP will actually
             quit after approx. 7 mins 10 secs.)

Some of these options have more verbose versions:

-r   =  -random
-g   =  -graphics
-p   =  -play
-s   =  -sync_to_beats
-q   =  -quality
-bnw =  -black_and_white
-n   =  -name
-m   =  -menu
-z   =  -zoomchange
-v   =  -version
-c   =  -continuous
-rp  =  -randomplaylists

For example, to play an MP3 file, with graphics visualisation and sync
to beats enabled, you would do something like:

  DAMP c:\mp3_files\tune.mp3 -g -s

Or to play a whole directory of MP3s, in a random order, with playback
quality at its best (using verbose names):

  DAMP c:\mp3_files\*.mp3 -random -quality 0

And if you get sick of typing the same command line options every
time you run DAMP, you can edit the DAMP.ini file and set your
prefered default options in there.  Note that any parameters
passed on the command line will override their counterpart settings
in the ini file. (note "override", NOT "overwrite" - so your ini file will
remain intact).

The DAMP.ini file also contains a [sound] section where you can
set up your soundcard properties (helps if you're having trouble
getting DAMP to detect your soundcard).  The most important setting
in this section is "quality".  Set it to 2 if you can, as this will
do interpolation and give MUCH better sound quality.

Also in DAMP.ini are [gfx_waveforms] and [gfx_modifiers] sections, which
let you select which graphical styles you would like to use.

And just in case you missed it, I'd like to bring special attention to
the -m option. This will bring up a menu from which you can set some of
the common options (in case you can't remember all those command-line
options).  When the menu is displayed, press the number next to the item
you want to change. If it is an on/off toggle, it's value will change.
If it is a number, HOLD DOWN the option number, and use the + and - keys
(the ones on the main keyboard, not the keypad) to alter the value.

There are some other things you can do whilst DAMP is running:

Press ESC to quit.

Press ENTER to move to next track. If you are
using multiple playlists and press ENTER while playing the last
track in a playlist, it will load the next playlist (or quit if there
are no more playlists left to play).

Press BACKSPACE to move to the previous track.

Press P to pause the track.

Press + to increase volume.

Press - to decrease volume.

Press [ to rewind.

Press ] to fast-forward.

Press S to toggle surround sound on and off.

Press G to toggle graphical output on and off.

Press T when using graphics to scroll the track title (filename)
across the screen once.

Press Z to select the previous playlist (if you specified multiple
playlists).

Press X to select the next playlist (if you specified multiple playlists).

Use the keypad keys to select a track.

Use the NUMLOCK key to toggle random play on and off.

Press C to toggle continuous play on and off.

Press V to toggle the time display between time elapsed and time remaining.

Press B to toggle "sync to beats" on and off.

Press cursor right to skip forward several tracks, and cursor left
to skip backwards several tracks. The number of tracks skipped depends
on the "large_skip" setting in DAMP.INI

Press TAB to save a screenshot (if you're in graphics mode) called
shot000.bmp, shot001.bmp etc.

If using graphics, and NOT using "Sync to beats", press N for a new
waveform and new set of colours, and M for a new zoom method.
(A new waveform and set of colours will be chosen at the start of
each track, along with a new zoom method).

Press F1 (if not using graphics mode or the GUI) to display a help page
giving a summary of the DAMP keys.


Getting The Best Sound Quality
==============================

A few people have asked me how to get the best sound quality in DAMP.
The first thing you should do is edit DAMP.ini:

From the "[options]" section, set "graphical_output" to "no".

From the "[sound]" section, set "quality" to "2", and "sound_freq" to 45454.

Then run DAMP like this:

damp <filename(s)> -q 0 -noscope


Help with DAMP.ini
==================

If you've had a look at DAMP.ini and don't understand some of the options,
then this is the bit you need to read.  Here I'll try and offer some helpful
advice on using DAMP.ini to store your favourite settings and tweak DAMP
to meet your needs.

So lets begin with the first section, [options].

random_play       :  Set this to yes to enable random play. (default = no)
                     This is the same as the -r option.

graphical_output  :  Set this to yes to enable graphical visualisation.
                     (default = no). This is the same as the -g option.

black_and_white   :  Set this to enable black and white output when in
                     graphical visualisation mode. (default = no). This is
                     the same as the -bnw option.

display_track_title_times
                  :  Set this to the number of times you would like
                     the track title to be scrolled across the
                     screen when in graphical visualisation mode.
                     (default = 0). This is the same as the -n option.

sync_to_beats     :  Set this to yes to enable synchronisation of the graphics
                     to the beat of the music when in graphical visualisation
                     mode. (default = no). This is the same as the -s option.

sync_threshold    :  Use this option to set the sensitivity of the sync to
                     beats option, from 1 to 10. (default = 5).  This is the
                     same as the value you can specify when using the -s
                     option.

change_zoom_method:  When using the graphical visualisation mode, DAMP has
                     various "modifiers" it uses to affect the display, such
                     as zooming out, zooming in, fisheye-effect etc.  When
                     using sync_to_beats, the method being used will change
                     on the beat.  Setting this option to no will prevent
                     selection of a new "modifier" effect. (default = yes).

tracks_to_play    :  If you wish to restrict the number of tracks DAMP will
                     play, you can set this value to the desired number.
                     (default = blank = no restriction). This is the same
                     as the -p option.

playback_quality  :  If you hear "stuttering" or repeating whilst playing
                     MP3 files, you'll need to make this value higher.
                     (default = 4). This is the same as the -q option.

display_menu      :  If you set this to yes, DAMP will display its options
                     menu when it starts (although the options menu is now
                     somewhat defunct as you can use DAMP.ini much more
                     easily). (default = no )This is the same as the
                     -m option.

display_version   :  If you set this to yes, DAMP will display its version
                     number at startup. (default = no). This is the same
                     as the -v option.

continuous_play   :  If you set this to yes, DAMP will play continually (ie
                     when it has no more MP3's left to play, it will start
                     again from the beginning). (default = no). This is the
                     same as the -c option.

random_playlists  :  If you set this to yes, and specify multiple playlists
                     when running DAMP, this will select the playlists in
                     a random order rather than one after the other.
                     (default = no). This is the same as the -rp option.

surround_sound    :  Setting this to yes will enable surround sound at
                     startup. (default = no). This is the same as the
                     -surround option.

show_time_in_gfx_mode
                  :  Setting this to yes will make the track time be
                     displayed when you are using graphical visualisation
                     mode. (default = no).

text_scope_char   :  This is the ASCII code of the character to use to
                     display the vu-meter in text-mode.  It is set to
                     254 by default, which on my machine is a small
                     filled square.  You might like to change it to something
                     else on your system.

text_scope_smooth :  Set this to "yes" to enable "smoothing" of the text-mode
                     vu-meter.  This will stop it "jumping about all over
                     the place". (default = yes).

beautify_filenames:  If you set this to "yes", then DAMP will automatically
                     convert any '_' characters in the filename to spaces,
                     as well as removing the ".mp3" extension before
                     displaying it. Setting it to "no" will make it display
                     the actual filename. (default = yes).

show_file_info    :  If you set this to "yes", and you are running DAMP
                     in text-mode, it will also output the file information
                     (bit-rate, mono/stereo etc.). (default = no).

use_gui           : If set to yes, the DAMP GUI will appear when DAMP is
                    started. See the section, "The DAMP GUI" for more
                    details. (default=no).

posterize_graphics: One for the Pop-Art fans!  If this is set to "yes" and
                    you use the visualisation part of DAMP, it will appear
                    "posterized". (default=no).

keypad_timeout    : The number of seconds DAMP waits after you've pressed
                    a key on the keypad befor it selects that track or
                    playlist (default=1).

ffwd_rew_speed    : This is the amount (in seconds) that DAMP will skip
                    when fast-forwarding and rewinding (default=1).

vol_up_down_speed : This is the amount DAMP will alter the volume when
                    you use the volume up/down controls (default=1).

startup_mp3       : If this isn't set to NONE, it is assumed to be the
                    filename of an MP3 to play when DAMP starts up. Note
                    that while the MP3 is playing, all you can do is
                    press ESC or your joystick quit button to skip it, so
                    don't have a really long startup MP3, it's only intended
                    for a short "System Initialized" message or something
                    similar. (default=NONE).

start_paused      : If this is set to yes, DAMP will start in pause mode.
                    (default=no).

large_skip        : This is the number of tracks skipped when using the
                    cursor left/right keys to skip several tracks at once.
                    (default=10).

sleep_fade        : If this is set to yes and you use the -sleep <n> option
                    when running DAMP, the music will fade before DAMP
                    quits, otherwise DAMP will quit as soon as the <n>
                    minutes have elapsed.
                    (default=yes).

Phew! That wasn't too bad was it?  Anyway, on with the next section,
[joystick].  This is where you should specify your joystick type, or 0
for no joystick.  There may also be lots of other setting here if you
have calibrated your joystick.  To recalibrate your stick, delete all
the settings apart from the "type" setting.

Next is [joystick_control]. This section has a good description
in the ini file. I suggest you read the comments, and of course,
the "Joystick Control" section below, and if you still don't
understand it, let me know.

The next couple of sections are for people who enjoy the graphical
visualisation mode, but wish they could turn "that really horrible effect"
(surely there aren't any?) off.  The [gfx_waveforms] section allows you
to enable and disable the different waveforms that DAMP displays.  The
names are fairly bizarre (they are effectively the same names I used
within the DAMP source code).  I suggest you go through, running DAMP with
just one of them enabled each time, and you'll learn which one is which,
and be able to turn off the ones you don't like.  The same goes for the
[gfx_modifiers] section.  A word of warning though: Don't turn ALL the
waveforms or ALL the modifiers off, otherwise DAMP will hang.

The [graphics] section currently contains one item, "filter". This is the
name of the filter that you want to use (for example gf_blur). The name
should be the same as one of the filter sections that follow the
[graphics] section.  Filters are defined like so:

[filter_name]
0 = a b c
1 = d e f
2 = g h i
divisor = x

Where a-i are the filter matrix values, and x is the divisor applied to
the matrix sum of pixel values.  It's effectively the same as the
"user defined filter" in Paint Shop Pro.

Be sure to send any interesting filters you come up with to
damp@damp-mp3.co.uk for inclusion in future releases of DAMP.

The next section, [gui] is for configuring the GUI options.
The first two parameters are "width" and "height".  Using these, you can
specify the resolution you'd like DAMP to run in when using the GUI.
Make sure you specify a resolution that is supported on your graphics
card!
The next setting is "colours". This is followed by the name of the
colour scheme you'd like to use, which should be one of the colour
schemes that follow.  The colour schemes are defned like so:

[gui_c_name]
background = br bg bb
titlebar = tr tg tb
highlight = hr hg hb
shadow = sr sg sb

Where br, bg, bb etc. are the red, green, and blue components of the
colour, in the range 0 to 255.  See DAMP.ini for some examples.  If you
create any nice colour schemes of your own, why not send them to me at
damp@damp-mp3.co.uk for inclusion with the next release of DAMP!


The next section, [lcd] is for configuring LCD displays.  Please see the
"LCD Display support" section below for full details.

The next section, [input] is for using input drivers. Please see the
"Input Drivers" section below for full details.

The final section is [sound].  This lets you specify manually settings for
your sound-card.  The only things I'd reccommend altering in here are
"quality", which I suggest you set to 2, and "sb_freq" which I would
suggest you set as high as you can (based on the listed frequencies in
DAMP.ini).



Keypad Control
==============
In case anyone want's to use DAMP in a jukebox/stereo etc., I have
added a lot of DAMP functionality to the keypad.
Here are the keypad functions:

NumLock : Toggle random play on/off.
/       : Toggle surround sound on/off.
*       : Pause / unpause.
-       : Decrease volume.
+       : Increase volume.
Enter   : Skip to next track.
.       : Skip to previous track.

If you are using a playlist, or playing several MP3 files,
use the keys 0-9 to select tracks, simply by typing the track
number. After a short pause (determined by the keypad_timeout
setting in DAMP.ini) it will then select that track. Alternatively,
you can hit your "next track" key/button and it will go to that
track or playlist immediately. (So if you always want to confirm your
selection rather than have it do it automatically, set the
keypad_timeout setting to a big number like 999, and just use the
"next track" key/button to confirm.  You can also use the
"previous track" key/button to cancel whatever you've typed.

If the track number you typed doesn't exist (like you typed
142 and there's only 140 tracks), it will continue to play
the current track and ignore what you typed.

So for track 5, press 5.  For track 15, press 1 followed by 5.
Basically, after each keypress, you have one second in which to press
another key, otherwise it will just select the track based on
what number you have typed so far. For example, if you wanted to
play track 123 and pressed 1, then pressed 2, then waited longer than
one second, it will play track 12.

Oh, and track selection is only supported for tracks 1 to 999999,
so I apologise in advance to anyone who has a playlist with
a million tracks in it :)

Also, if you have specified multiple playlists, you can hold down
the LEFT CTRL key whilst using the keypad to select a playlist.
(The playlists will be listed with their numbers when DAMP starts up).
Also note that you should RELEASE the CTRL key after you have selected the
playlist.

NOTE: If you are using a non-standard device such as a serial-port keypad
to control DAMP, you may experience difficulties.  To overcome this, you
can try the -keypadhack option, which uses a less low-level keyboard
driver. HOWEVER, the CTRL key will not work (so you cannot perform
playlist selection using the keypad), and the NUM LOCK key will not work
(so you cannot toggle random play on and off). Instead, the backspace key
replaces the NUM LOCK key as the random play toggle, and the BACKSLASH key
replaces the CTRL key.




Joystick Control
================

For those of you wanting to integrate digital joystick/joypad controls into
your jukebox/car mp3 player etc., you'll be glad to know that DAMP has
good support for joystick control.

If you take a look in DAMP.ini, you'll find a section called
[joystick_control] where you can assign various functions to the different
joystick directions/buttons.  The defaults are:

left    = previous track
right   = next track
up      = increase volume
down    = decrease volume
button1 = pause/unpause
button2 = toggle surround sound on/off
button3 = previous playlist
button4 = next playlist
button5 = rewind
button6 = fast forward
button7 = quit
button8 = random play toggle

NOTE: Do not assign two buttons to the same action, as only one of them
will work!

The EXIT_CODE_* actions make DAMP exit with the given code, so
EXIT_CODE_3 should make DAMP exit, setting ERRORLEVEL to 3.  This might
be useful for frontend authors.

There is also support for a second joystick
(provided you select the appropriate joystick driver in DAMP.ini)

There is also a "volume_fine" setting. If this is set to "yes" then you
must repeatedly press the volume up/down buttons to change the volume. If
it is set to "no" then you can hold the volume up/down buttons to
rapidly change the volume.

You should make sure the joystick is connected and centred when DAMP
starts up.

If you are using DAMP for the first time, it'll probably ask you to
calibrate your controller.  Simply follow the on-screen prompts, and
the joystick calibration settings will be saved in the [joystick]
section of DAMP.ini

If you want to re-calibrate your joystick, delete all the settings
except the "type" setting from the [joystick] section of DAMP.ini

Note that DAMP doesn't support "Windows-only" joypads/sticks.



LCD Display support
===================
DAMP supports various LCDs by using a driver-based system.
If DAMP doesn't work on your LCD, check the DAMP web site to see if
someone's written a driver for you LCD, and if not, have a read of
lcddrv.txt and see if you can write a driver for it.

If enabling LCD support fries your LCD, then don't blame me.
You have been warned.

In the "[lcd]" section of DAMP.ini, you should set the "driver"
setting to the name of the LCD driver you wish to use. (The LCD
drivers come in seperate files with a .sc extension). Make sure you
put the full filename, including the .sc extension.

To decide which driver you should use on your system, have a look
at the wiring diagrams on the DAMP web site.

You may also want to set display_width to the width of your
LCD display. WARNING! Don't set this value higher than 40.
There's also a display_lines setting to set the number of lines your
display has.

Also note that LCD driver authors are free to ignore the display_width
and display_lines settings, so they might not be supported in all drivers.

Then to enable LCD support, simply add the -lcd option to your usual DAMP
command line.  If the driver is very simple, you should get a display that
looks a bit like this:

filename.mp3 CRS
xx:xx PLAY> damp

Where filename.mp3 will be the filename of the MP3 you are playing (or
the artist and title if it had an ID3 tag).  It will scroll so you
can see the full name.  You can configure the scroll speed by adjusting
the "scroll_speed" option in the "[lcd]" section of DAMP.ini

The R symbol only appears when random play is enabled.
The S symbol only appears when surround sound is enabled.
The C symbol only appears when continuous play is enabled.

xx:xx is the current track time (either elapsed or remaining depending
on what state you're in)

The "PLAY>" portion of the display represents the current state. It
will either be "PLAY>", "PAUSE", "FFWD>>", "<<REW", "VOL +" or "VOL -".

If you use a keypad to select a track, the track number will appear where
it says "damp", as you are typing.

However, driver authors are free to reconfigure the display to any layout
they choose, but it should contain most of the elements listed above.


Input Drivers
=============

This version of DAMP features input driver support.

If you want to use an input driver, the first thing to do is find the
[input] section in DAMP.ini and set the driver= line to point to the
filename of the driver you wish to use (eg: driver=ICONSOLE.sc)

Then when you run DAMP, add -indrv to your usual set of command-line
options to enable the input driver.

If there isn't an input driver for your favourite input device, check
the DAMP web site to see if anyone has written a driver for it.  If not,
take a look at indrv.txt for details of how to write an input driver,
and have a go yourself!


The DAMP GUI
============

This version of DAMP features a very preliminary version of the GUI I am
working on.  So far it only displays an information window, and if you
are using visualisation, it'll also display that in a window.  It also
displays a controls window, with the standard set of buttons (yes, I
know they look horrible - I'll draw some nice ones when I have time).
The other window it displays is a playlist window.  So far you can just
scroll the playlist up and down and nothing more.

Because of the preliminary nature of this version of the GUI, you can
expect problems, and you are definitely using it at your own risk.

And that's it so far! So I don't want too much feedback about this just
yet.  I would like to know what sort of windows people would like. So
far I have thought of:

o File window (to select files and add them to the playlist or play
  them immediately)
o Ability to add/remove songs to playlist window.

The resolution and colours are configureable from the [gui] section
of DAMP.INI

To enable the DAMP GUI, use the -gui option on the command-line, or
set the "use_gui" option in DAMP.ini to "yes".

Just have a play with it.  You can drag the windows around,
but other than that, there's not a lot else to do.  All
the normal DAMP input will work as usual (except the graphics toggle
button).


History
=======

See the file CHANGES.txt for a full list of changes to each version.

The idea for DAMP came to me whilst I was staying at my mates house one
weekend.  We were probably quite drunk, and talking about the fact that he
listens to MP3s before he goes to sleep. He'd messed around making
a program that would shut down his computer, but we talked about how its
much better to have it shut down from DOS.  So I decided to write him
an MP3 player for DOS.  And that was the beginning...


Future
======

The future of DAMP depends upon you, the end user.  Is there something you
don't like about DAMP?  Or a feature you think would be useful?

LET ME KNOW!

Send an email to damp@damp-mp3.co.uk and tell me about it.
Anyone who suggests anything that gets added will be given a nod in the
credits section. This is YOUR mp3 player, it should have the features
YOU want.

I would ask you to make absolutely sure that the feature you want doesn't
already exist!  In other words, READ THIS DOCUMENT FULLY before requesting
a feature. I'd also recommend reading the changes.txt file, in case I've
added a feature and forgotten to document it...

Oh, but before you go rushing off to request something:

Don't ask for support for input device "xyz" - That's what the input driver
system is there for. I can't write the driver myself, and if you can't
either, then you could try asking on the DAMP mailing list (details of
how to subscribe are on the DAMP web site).

Similary, I'd recommend any questions about LCD displays go to the
DAMP mailing list, as there are plenty of people there who know a lot
more about LCDs than I do...


Known bugs
==========

DAMP doesn't support filenames containing a '#'

When you flip to graphics by pressing G, then flip back again, it doesn't
always update the text output properly.

Has been known to hang the computer if you try and run it whilst
WinAMP is running in the background :)  I'd advise you don't have any
other programs running in the background that need to take control of
your sound hardware.

"Sync to beats" doesn't work as well in surround-sound mode. This is
because the surround sound takes a lot of the "bottom end" off the sample,
which kind of makes it hard for the sync to grab onto anything.

DAMP doesn't always auto-continue to the next track when running under
a Windows DOS box. Until I figure out why, you'll just have to press
ENTER to force it onto the next track.

If you are using Windows and have been playing a game, and then you run
DAMP, sometimes DAMP will not output any sound.  To overcome this problem,
restart your computer and run DAMP again.

DAMP sometimes hangs when running under plain DOS. If this happens to
you and you can still press keys (eg: ENTER), then find the [sound]
section in DAMP.INI and set all the sound_* settings to the correct
values for your sound card (in particular try the sound_dma setting
with the high and low dma values for your sound card).
This doesn't always fix it - my SB Awe64 works fine under plain DOS,
but my SB Live doesn't...  This seems to be due to a problem with one
of the libraries I use, so I don't think there's anything I can do
to fix it right now.  Also if you're experiencing this problem, make sure
you're using the DAMP.ini file that came with this version of DAMP,
and not one from an earlier version.

There seems to be a compatibility issue with certain sound cards under
DOS.  This is usually newer cards such as the SB Live! (and probably
other PCI cards) that can use shared resources and weird ports, and
generally make themselves pretty unfriendly towards DOS.
I'd recommend you use an SB16, or download the Linux driver source code
from http://developer.soundblaster.com and write a full Live! driver for
Allegro: http://www.talula.demon.co.uk/allegro/


Bug Reports
===========

Found an "annoying bug"? Don't complain to your mates about it, complain
to ME. That's what I'm here for.  If something doesn't work, I should
know about it.  Mail me at bugs@damp-mp3.co.uk and tell me what
the problem is, giving me as much detail as you can, and I'll do my best
to fix it. (Please make sure it's not in the "known bugs" section above).

BE SURE TO INCLUDE THE VERSION NUMBER of DAMP which you are using (the
number at the top of this document should be correct, but do a
DAMP -v to make sure).  It'd help if you could give me your system details
as well, eg:  sound card, processor, operating system etc.


Credits
=======

DAMP was coded by Matt Craven of Hedgehog Software.
http://come.to/hedgehog-software/

The official DAMP web site is at:
http://www.damp-mp3.co.uk/

It was coded in C, using DJ Delorie's DJGPP.
http://www.delorie.com/djgpp/

It uses the Allegro Library by Shawn Hargreaves.
http://www.talula.demon.co.uk/allegro/

It uses the LibAMP library by Ove Kaaven (which is based on AMP
by Tomislav Uzelac).
http://www.arcticnet.no/~ovek/

It also uses the SeeR scripting library by Przemyslaw Podsiadly.
http://home.elka.pw.edu.pl/~ppodsiad/

It was originally designed for and tested by Chris Varnom.
http://www.varno.co.uk/


Hall Of Fame :-)
================
This is where all the people who've suggested features for DAMP get
the credit they deserve...

Jerod suggested the keypad functionality and found a couple of bugs.

Joe Rybacek suggested the joystick functionality.

Heiko Valnion suggested the user-defineable joystick control.

Larry Neidiger suggested the user-configureable visualisation options, and
the user-configureable beat sensitivity (-beatsync option).

Klaus Peichl suggested the rewind and fast-forward controls, and gave me
some audio advice resulting in the much improved text-mode vu-meter and
improved sync-to-beats. He also helped me improve the LCD support, writing
a very elegant LCD driver.

Andy Chandler suggested, tested and worked on the LCD display support,
and found a couple of bugs. He also suggested the ffwd_rew_speed and
vol_up_down_speed settings. As well as all this, he suggested the
-skip option, and gave me the info I needed to correct the "time remaining"
function.

Xavier suggested the support for extra joystick buttons, and support for
NEXT_N_TRACKS and PREVIOUS_N_TRACKS in the joystick control.

Alessandro Ambrosini suggested the -beep option, and prompted me to
export the damp_vu variable for the LCD driver.

A. Kaseva suggested the "convert underscores to spaces" and
"make all words start with uppercase" parts of the "beautify filenames"
option.

Terry Rudy suggested the -fnfnoquit option.

Andrew Ayers suggested the keypad_timeout option, and the ability to confirm
your track selection with a key rather than waiting for the timeout.

Ian Preston requested the damp_track_number and damp_selection_buffer
variables in the LCD driver.

Ian Richards requested that the random toggle be added to the joystick
configuration.

Euth suggested the startup_mp3 option.

Robert Gruner suggested the EXIT_CODE_* joystick functions.

Andreas Koch suggested the "start paused" feature, and asked me to
export the playlist filename for LCD drivers to use.

Luca suggested the "playlists within playlists" feature.

Klaus Ening suggested the -remaining option, and the toggles for
continuous play, sync to beats, and time remaining. He also requested
the symbol for continuous play to be added to the LCD display.

Tom Sj”lund suggested the ability to skip forwards and backwards
several tracks at a time.

Christian Ening spotted a bug in the time display when rewinding whilst
"time remaining" was enabled.

Several people asked for the LCD display width to be configureable, so
I won't list them all here. You know who you are :-)

Richard Potter suggested the "volume_fine" setting for joysticks in
DAMP.ini

Martin Pipe pointed out that DAMP supports .MP2 files if they're renamed
to .MP3, so I added support for specifying .MP2 files directly.

JoÆo Silva requested the sleep timer function.

Florian Xaver prompted me to add the ID3 genre support.

Andi requested the damp_shared_* variables for the drivers.

