                          COMMAND & CONQUER
                           [Version Demo 1.0]

                 Copyright (C) 1995 Westwood Studios
 
 Topics covered in this README file:

 i. Installation of Demo Version
 
 1. Autodetection of Sound Cards
 2. Known Sound Card Problems
 3. Windows Notes
 4. Keyboard Shortcuts and Special Features
 5. Multi-CD machines and CD-changers
 6. Game updates and patches
 7. Revision History

 i. Installation of Demo Version
 ===============================
 
         From CD-ROM
         -----------
         To install the demo version of Command & Conquer from the
         CD-ROM drive, run the install program located in the
         demo directory the CD-ROM drive. Run the "install" program
         if you are in DOS or the "setup" program if you are in
         Windows. This program will install all necessary files to 
         the hard drive. The demo can then be played by executing 
         the program "C&C" located in the installed directory. To 
         enjoy the movie sequences, the CD-ROM must be present in 
         the drive.

         From .ZIP File
         --------------
         To install the demo version of Command & Conquer from the
         distributed .ZIP file do the following;
	 
         a. Create a directory on a hard drive that has at least
            20 megabytes of free space.

         b. Unzip the demo version into this directory.

         c. Run the "setup.exe" program to specify your sound card.

         d. Execute the "C&C" program to run the demo version.

 
 1. Autodetection of Sound Cards
 ===============================
 
 C&C utilizes sophisticated techniques to autodetect your sound card.
 Because of the vast number of machine configurations possible on PC's,
 C&C may not autodetect your sound card or it might misidentify the card.
 For this reason you should treat the detected card as a suggestion only.
 If you know that the detected card is definitely wrong you can override
 the selection and pick the correct card from the SETUP program.
 
 If you select a sound card that is not present in your machine, your machine
 may lock-up, or the sound card may stop responding. Either of these
 situations may be corrected by simply turning off the computer, waiting 15
 seconds and then turning it back on.
 
 2. Known Sound Card Problems
 ============================
 
         Windows 95
         ----------
         See the Windows section below for sound card notes.
 
         Creative Labs - Soundblaster 1.0/1.5 card
         -----------------------------------------
         These early Soundblaster cards do not support some of
         the features which are built into later versions of the
         card. This may result in lower audio quality on
         these cards.
 
         Soundblaster Compatible Cards
         -----------------------------
         The Soundblaster code in C&C is written for 100% Soundblaster
         compatible sound cards made by Creative Labs. If you have a
         Soundblaster compatible sound card from another manufacturer
         you may experience stuttering or popping in the sound, or even
         no sound at all.
 
         If you are unsure of the correct Port, IRQ and DMA settings
         for your Soundblaster compatible card, try typing SET from
         the DOS prompt. If your machine has been configured with a
         BLASTER environment variable in your AUTOEXEC.BAT file you
         should see a line similar to:
 
         SET BLASTER=A220 I5 D1 H5 T4
 
         The number after the A (i.e., 220 in this case) is your port address;
         the number after the I (5 in this case) is your IRQ and the number
         after the D (1 in this case) is your DMA channel setting. Armed with
         these numbers you can go ahead and manually select your soundcard
         from the SETUP program and enter the Port, IRQ and DMA in the boxes
         when prompted. If you have a Soundblaster 16 or AWE32 soundcard and
         you are having difficulty with autodetection, these same comments
         apply except that you may have to enter the number after the H as
         your DMA setting, depending on your configuration.
 
         Compaq Computers
         ----------------
         Some Compaq machines may not autodetect the installed sound
         card.  If this occurs, try selecting Sound Blaster Pro/Pro2
         from the SETUP program.
 
         Sound Galaxy Basic 16
         ---------------------
         This Soundblaster compatible card can sometimes be incorrectly
         autodetected as a Soundblaster Pro or Soundblaster 16, causing
         unpredictable results. We recommend that you manually select
         Soundblaster and enter the Port, IRQ and DMA values that
         correspond to your card. See the comments under Soundblaster
         compatible cards above.
         
         ESS AudioDrive
         --------------
         Under certain circumstances the autodetect code can incorrectly
         identify this card as a Soundblaster 16. If this occurs you will
         need to override this driver by selecting ESS AudioDrive with
         the correct values for your system.
 
         Adlib Gold
         ----------
         Under certain circumstances the autodetect code can return
         incorrect Port, IRQ and DMA settings. If you are having difficulty
         obtaining sounds on this sound card try manually selecting the
         card in the SETUP program and entering the correct Port, IRQ and
         DMA settings.
 
         Golden Sound Pro 16
         -------------------
         We have found that better results may be obtained on this
         sound card by reducing the game volume from the in-game
         sound control menu. Volume levels should be set to about
         half way.
 
         GRAVIS ULTRA SOUND
         ------------------
         Some Gravis Ultrasound owners may experience audio clipping
         and/or reduced game performance.  We recommend that you turn
         the volume for musical scores all the way down (off) to see
         if this helps.

         -----------------------------------------------------------
         If you continue to have trouble with your soundcard please
         consult the troubleshooting section of your soundcard manual
         or contact Westwood technical support as described in your
         C&C manual.

 3. Windows Notes
 ================
 
         Windows and Windows for Workgroups v.3.1 & v.3.11
         -------------------------------------------------
         C&C uses special code to launch itself from the Windows icon
         and will attempt to close any active Windows applications prior
         to running. You will not be able to access other Windows programs
         when C&C is active.
 
         This greatly enhances the performance and playability of the game
         on 486 class machines.
 
         Windows 95
         ----------
 
         Installing C&C on an 8MB Windows 95 system:
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         If you have an 8MB system you must make an
         adjustment to the setup program information.

           1. Click on the "My Computer" desktop and select
              the CD-ROM drive that contains the C&C CD.
           2. Right click on the "_SETUP.EXE" program there.
           3. Select the "PROPERTIES" menu item.
           4. Click on the "MEMORY" tab.
           5. In the "MSDOS PROTECTED MODE (DPMI) MEMORY" field
              select 16384.
           6. Click on the "OK" button.

         You will then be able to install Command & Conquer 
         normally.

         C&C on an 8MB Windows 95 system:
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         If you have an 8MB system and you are running Windows 95,
         you may need to make a slight adjustment to the PIF
         (the Program Information File) after installing C&C:

            1. Click the "START" button on the TASKBAR
            2. Under the "FIND" menu item, select "FILES OR FOLDERS"
            3. In the "NAMED" field, enter "C&C.EXE"
            4. In the "LOOK IN" field, enter the drive letter
               where C&C is installed
            5. Click the "FIND NOW" button
            6. Click the right mouse button on the C&C.EXE that
               you are using
            7. Select the "PROPERTIES" menu item
            8. Click on the "MEMORY" tab
            9. In the "MSDOS PROTECTED MODE (DPMI) MEMORY" field
               select 16384
           10. Click the "OK" button

         The next time you run C&C the new settings will take effect.
         There is no need to reboot your system.

         Running through Windows 95:
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~
         C&C's default behavior under Windows 95 is to run as a DOS
         box process. The reason for this is that the method of exiting
         Windows used in Windows v.3.1 and v.3.11 can result in a
         program environment that is lacking CD-ROM drivers.
 
         The performance of C&C in a Windows 95 DOS box is slightly
         slower than in a real DOS environment. You can improve movie
         playback performance by going into the Settings option on
         the Win95 START menu, selecting CONTROL PANEL, then SYSTEM,
         PERFORMANCE, FILE SYSTEM and then CD-ROM. There is a menu
         here which allows you to enable read-ahead buffering of the
         CD (this seems to be disabled by default). Select the setting
         that matches your CD-ROM drive (2X, 4X etc.). You can also
         change the size of the buffer, usually the bigger this is
         the better the performance will be, although this does take
         away memory from the rest of the system.
 
         Autodetecting Soundcards in a Windows 95 DOS box:
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
         Because the Windows 95 DOS box is really just emulating
         DOS (Windows continues to run in the background) you may
         experience problems autodetecting your sound card in this
         mode. There are two things you can do to address this:
 
         1. Do not autodetect, but pick your soundcard manually and
            enter the correct PORT, DMA and IRQ settings, or
         2. Run through Windows 95 DOS mode, as detailed below.
 
         Running through Windows 95 DOS:
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
         If you can choose REBOOT AS MSDOS from the START/SHUTDOWN
         menu and then still access your CD-ROM drive in that mode,
         we recommend running in that environment and installing from
         the DOS prompt. Whether you can do this or not depends on
         having the correct drivers loaded in the DOS environment.

         Windows 95 System Agent with C&C:
         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
         The System Agent software, that is available for Windows
         95 (Plus! pack), can cause peculiar behavior with the C&C 
         setup process. If the setup program, when run from the hard
         drive, proceeds with a complete reinstall, then stop the 
         System Agent software.

 4. Keyboard Shortcuts and Special Features
 ==========================================
 
 C&C has a range of keyboard shortcuts and extra features which are
 keyboard driven. These are intended for the advanced player and are
 not essential to normal gameplay. They are, however, very cool:
 
 Unit Control:
 
 G        : Guard Area
            Select a group of units and then hit G to put them into Guard
            Area mode. In this mode, units will patrol and open fire on any
            enemy units that come within range.

 X        : Scatter Units
            This causes a selected group of units to scatter (for example,
            to make themselves into more difficult targets).

 S        : Stop Unit
            Causes a unit to stop in its tracks.
 
 Keyboard Shortcuts:
 
 F7-F10   : Map Bookmark System
            Use CTRL+F7-F10 to place a bookmark, then use F7-F10 to jump to
            that spot.

 <CTRL>-# : Team Creation
            Use CTRL and a number key (0-9) to mark a group of selected
            units as a team.

 0-9      : Team Selection
            Selects a pre-marked team (see Team Creation) as the 
            current active group.

 TAB      : Open/Close Sidebar
 
 H        : Automatically selects and centers the view around your
            construction yard.
     
 N        : Your next unit on the playing field is selected and the 
            view is centered about it.
          
 R        : Allows resigning the game.

 <HOME>   : Centers the view around the currently selected object.
     
 <ALT>-#  : If the <ALT> key is held while pressing a team number, the
            specified team will be selected and the view centered over
            the team members. This is identical to pressing the team
            number and then pressing <HOME>.

 Cursor Modifiers:
 
 CTRL     : Force Attack
            Holding down the CTRL key forces your cursor into the target
            cursor. This allows you to target your own units, amongst
            other things.

 ALT      : Force Move
            Forces your units to move when they would normally just stand
            and fight. This is useful with tanks against enemy infantry,
            for example. Try it and see.

 CTRL+ALT : Guard Area or Unit
            Select a group of units and then CTRL+ALT click on a building,
            this forces your units to patrol the area around the building
            looking for the enemy. They will engage the enemy if found. If
            you CTRL+ALT click on another one of your units (for example,
            the harvester) your selected units will guard that unit as it
            moves around the map. This also applies to enemy units, which
            is perhaps not so useful.
 
 5. Multi-CD machines and CD-changers
 ====================================

 C&C does not support multiple CD-ROM drives or CD-changers and assumes
 that you only have one CD-ROM drive. If you have more than one CD-ROM
 drive, you should insert the C&C CD you are using into the first CD
 driver letter. For example, if you have drives E:, F: and G:, your
 C&C CD should be inserted into the E: drive.
                     
 6. Game updates and patches
 ===========================

 If it becomes necessary to update your game, you can find game updates 
 on our web page at http://www.westwood.com or at our FTP site 
 (ftp.westwood.com). Please mail all questions to our internet mailing 
 address: mail@westwood.com

 7. Revision History
 ===================

 Demo 1.0 > Initial Release Version
