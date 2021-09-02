
           XMGR, RDISK, UHDD/UDVD2, and UIDE -- DOS Device Drivers
         ===========================================================

1. Description
   -----------

   XMGR, RDISK, and the UHDD/UIDE drivers are a set of DOS device drivers,
   for systems with an 80386+ CPU and using MS-DOS V5.0+ or equivalent.

   XMGR is a DOS driver which works as an "XMS manager" and provides up to
   4-GB of XMS memory.    XMGR has direct support for V3.70+ UMBPCI by Uwe
   Sieber.    After UMBPCI enables upper-memory, XMGR loads there and will
   provide both upper- and XMS memory to a DOS system.   XMGR uses an "I-O
   Catcher" with UMBPCI.   Disk/diskette I-O above 640K is trapped by XMGR
   and done using a low memory area, as UMBPCI "Shadow RAM" cannot do DMA!
   XMGR also runs with JEMM386 or MS-DOS EMM386.    With EMM drivers, XMGR
   using its /B switch first boots in temporary space.   When upper-memory
   gets enabled by the EMM driver, XMGR loads there with no /B, copies all
   its boot data, and takes-over XMS work.    For a small XMS-only system,
   XMGR can also run entirely in low memory.

   RDISK is a DOS RAM-disk driver.    It creates a "fast" disk drive using
   2 Megabytes to 2 GIGABYTES of XMS memory!   It loads as a system driver
   in CONFIG.SYS, or it can load later in AUTOEXEC.BAT or by user command.
   DOS can copy critical programs and data to the RAMdisk, where they will
   be read or written at memory speed!   If loaded after CONFIG.SYS, RDISK
   files can be assigned to any free DOS drive letter using its /: switch.
   RDISK runs with V2.0 or V3.0 XMS managers (60-MB maximum for V2.0 XMS).
   It uses only 656 to 752 bytes of upper-memory, depending on the system,
   and it can also load in 640K DOS memory.    RDISK is a simple and small
   RAMdisk driver, for use when resizing or other features are not needed.

   UIDE is a DOS "Universal IDE" caching driver.   It intercepts "Int 13h"
   BIOS I-O requests and caches data for up to 30 BIOS disks, including A:
   or B: diskettes and including hard disks of any size.   UIDE can handle
   48-bit LBA or 24-bit CHS I-O calls by new or old DOS systems.   It will
   handle up to 10 "Legacy" or "Native PCI" IDE controllers.   UIDE "calls
   the BIOS" for diskettes, SCSI, or other BIOS drives, thus it caches ALL
   disks on DOS systems!   I-O for "Int 13h" drivers loaded before UIDE is
   also cached.   ("ASPI" or other "non Int 13h" drivers are unsupported).
   UIDE also detects and runs up to 8 SATA, IDE, and old "PIO mode" CD/DVD
   drives.    It caches CD/DVD data and directories for MUCH faster speed,
   and it can play audio CDs and handle "raw" trackwriter input (audio and
   "raw" data is not cached).

   UIDE caches 5 Megabytes to 4 GIGABYTES of data!   It uses 5232 bytes of
   upper/DOS memory for any size cache.   All its tables or cache data use
   XMS memory.   A "stand alone" UIDE (/B switch, no caching or diskettes)
   can be used for tests or diagnostic work and takes 3744 bytes of upper/
   DOS memory.   UIDE's /H switch can be used to put most of the driver in
   "free HMA" space, thus using only 912 bytes of memory!

   UHDD is a "hard-disk only" UIDE variant.    UHDD runs up to 10 SATA/IDE
   controllers and 28 BIOS units, including A: or B: diskettes, can handle
   any size SATA/IDE hard disks, and can set up to 4-Gigabyte caches!   It
   omits only CD/DVD handling, for which the UDVD2 driver can be used (see
   below).   UHDD takes 3344 bytes of upper/DOS memory for any size cache.
   If hard-disk support is unneeded (/E or /N1 switch), UHDD will omit its
   UltraDMA routines and save 464 bytes.   Note that /E still caches disks
   by "calling the BIOS" to do I-O.    A "stand alone" UHDD (/B switch, no
   cache or diskettes) can be used for tests or diagnostics and takes 1440
   bytes of upper/DOS memory.    The "stand alone" UHDD replaces old UDMA/
   XDMA drivers and provides greatly enhanced features.   UHDD's /H switch
   can be used to load most of the driver in "free HMA" space, thus taking
   only 816 bytes of memory (656 in "stand alone" mode)!    UHDD will save
   memory for DOS systems with no IDE CD/DVD drives, while still providing
   all disk-caching features of the larger UIDE.

   UHDD can be called by external user drivers to cache their data.   Read
   the UHDD.TXT file for full details, also see the UDVD2.ASM source file.

   UDVD2 is a non-caching "CD/DVD only" driver for up to 6 SATA/IDE or old
   "PIO mode" CD/DVD drives.    On loading, it checks up to 10 "Legacy" or
   "Native PCI" IDE controllers and runs the first 6 drives found.   UDVD2
   can play audio CDs, but it omits "raw" input logic which few need!   If
   the UHDD caching driver is loaded, UDVD2 will call UHDD to cache CD/DVD
   data files plus their directories, for MUCH greater speed (audio is not
   cached).    UDVD2 takes 144 bytes of upper/DOS memory and 1840 bytes of
   free HMA with its /H switch, or 1984 memory bytes without /H.   If UHDD
   is also used, UDVD2 will take 112 extra bytes to cache CD/DVD data, and
   UDVD2 "shares" UHDD's UltraDMA buffer (only 32 extra bytes to share the
   non-caching UHDD's buffer).    Without UHDD, UDVD2 requests 128K of XMS
   memory as its own buffer, so "misaligned" and other input not suited to
   UltraDMA can still be done at UltraDMA speeds!   If XMS is unavailable,
   such input is done in "PIO mode".   UDVD2 can replace old XCDROM/GCDROM
   drivers and gives many enhanced features, including CD/DVD caching when
   UHDD is present.     UDVD2 is the "model" for interfacing other drivers
   with UHDD to achieve caching!

   Except when noted, all UIDE comments in this README also apply for UHDD
   and UDVD2.

   The small RDISKON.COM program can "re-enable" a DOS drive used by RDISK
   if a "format" command is accidentally issued to it.   This disables the
   drive on some systems!    Entering  RDISKON L  at a DOS command-prompt,
   where L is the desired drive letter (A to Z), will re-enable the drive.

   The small CC.COM "Clear Cache" program can help verify files written by
   UIDE.   Entering  CC  at the DOS command-prompt sends a BIOS "reset" to
   all disks, making UIDE discard its cache.    Data on the disk (NOT data
   still in the cache!) can then be compared with the original output.


2. NO Warranties
   -------------

   XMGR, RDISK and the UHDD/UDVD2/UIDE drivers are offered at no cost, "as
   is", "use at your own risk" and with NO warranties, not even an implied
   warranty of FITNESS for any particular purpose nor of MERCHANTABILITY!

   Driver questions and comments may be addressed to the E-Mail of Johnson
   Lam, <johnsonlam.hk@gmail.com>.


3. Revision Summary
   ----------------

   30-Apr-13   UHDD/UDVD2 can now be run without XMS (at lower speed) for
                 FreeDOS "scripts" or for tests.   UDVD2 can now do "raw"
                 (trackwriter) input.   Other drivers unchanged (re-dated
                 only).

   15-Oct-12   UHDD/UIDE again detect A: and B: diskettes from BIOS data,
                 NOT "Int 13h" calls!   See section 7 of their README for
                 details.

    4-Aug-12   UHDDJR deleted, logic is in UHDD.  UHDD /B now 1440 bytes!
                 UHDD /E or /N1 switches now dismiss all UltraDMA logic.

    2-Aug-12   UHDD "disk only" caching driver added.     UIDEJR deleted,
                 replaced by UDVD2 and UHDDJR.   UDVD2 caches CD/DVD data
                 if UHDD is also used!    New /UD switch in UDVD2/UIDE to
                 cache CD/DVD directories only (requires new SHCDX33F).

    9-Jul-12   UIDE/UIDEJR device select error, for master + slave CD/DVD
                 units on one IDE channel, is corrected.   Many Thanks to
                 Doug Beneway for finding this error!

   25-Jun-12   UIDE2 deleted:  Not-enough added speed, complex to use.

   17-Jun-12   UIDE/UIDE2/UIDEJR /A switch, init of 2 "Old IDE" channels,
                 and CD-audio "Q"/status data corrected.   Many Thanks to
                 Japheth for his research and audio-test program!

   31-May-12   UIDE and UIDE2 detection of "legacy" address CD/DVD drives
                 corrected.

   29-May-12   UIDE and UIDE2 check for diskettes via Int 13h, avoid DPTE
                 tests if no PCI BIOS, let the BIOS do I-O for disks with
                 bad DPTE data, and /N5 deleted, all re: VirtualBox BUGS!

   20-May-12   UIDE/UIDE2 now have /N5 to disable diskette caching.

   23-Mar-12   UIDE now runs 30 BIOS units like UIDE2.   UIDE/UIDE2 again
                 use "common" logic and need only 912 bytes with /H!

   24-Feb-12   UIDE/UIDE2 "64K DMA boundary error" fixed (may affect only
                 year-2000 chips or older!).    UIDE2 much smaller, minor
                 XMGR/UIDE size changes.

   16-Oct-11   UIDE /M switch deleted, search-buffer is always 512 bytes.
                 UIDE.SYS back to 7.5K, UIDE-S dropped, UIDE2 improved.

    7-Oct-11   All UIDE drivers updated to avoid BIOS "DPTE" ERRORS:  Bad
                 DPTE data for USB sticks!   Many Thanks to Daniel Nice!

   30-Sep-11   UIDE.ASM now assembles UIDE, UIDE2 or UIDE-S.   All handle
                 10 controllers, 34 BIOS units, 8 CD/DVD drives.

    9-Sep-11   UIDE2 re-added.   UIDE-S and UIDE2 handle 6 CD/DVD drives.

   22-Jul-11   UIDE /E switch added for DOS emulators (VirtualBox, etc.).

    7-Jun-11   UIDE and UIDE-S /X switch deleted.   UIDE /M switch added,
                 to save HMA but avoid speed loss!

   20-May-11   UIDE-S ("short" UIDE) added, for systems with limited HMA.

   16-May-11   More "code mod" init errors corrected in XMGR/UIDE/UIDEJR.

   14-May-11   UIDE/UIDEJR disk "timeout" now 7 seconds (was 0.4 sec) for
                 "laptop" disk spin-ups.   Disk-only UIDEJR at 1504 bytes
                 (was 1600!) in memory, still 688 bytes using /H.

    2-May-11   UIDE corrected to flush its cache before CD/DVD input on a
                 "VDS Lock" error.   /X switch added to UIDE.

   25-Apr-11   BAD "code mods" init error corrected for UIDE, UIDEJR, and
                 RDISK (XMGR not affected)!

   16-Apr-11   UIDE user-driver caching improved and re-added.

    5-Dec-10   UIDE/UIDEJR /R15 and /R63 switches added to handle old DOS
                 "games" (Thanks, Guillermo Grana Gomez!).

   28-Nov-10   Minor updates:  UIDEJR audio track-number error corrected,
                 XMGR faster in protected-mode.   Added XMGR and UIDE /Z.

   15-Aug-10   UIDE audio track-number error corrected (Thanks, Nagatoshi
                 Uehara!).   Faster speed for UIDE cache-table updates.

   10-Aug-10   UIDE binary-search buffer added.   Using $ in CD/DVD names
                 fixed in UIDE/UIDEJR (Thanks, Japheth!).

    4-Aug-10   Greater UIDE protected-mode speed, "protected" and "memory
                 only" caches deleted, /N4 added.

   13-Jul-10   Fast UIDE "memory only" cache added via /PM switch.

    4-Jul-10   README file update -- XMGR/UIDE can use "Native IDE" mode,
                 same as "Legacy"/"Compatibility", for AHCI mainboards.

   28-Jun-10   XMGR updated for AHCI, see the README sec. 7 for details.

   16-Jun-10   UIDE /E switch and external-entry logic summarily deleted.

   10-Jun-10   UIDE now ignores "removable HARD disks", size reduced.

   27-Nov-09   UIDE /HL switch added for larger /P caches, /N3 fixed.

   22-Nov-09   UIDE uses more-optimal cache blocks, UIDE /F switch added.

   16-Nov-09   UIDE now caches 4 GIGABYTES of data, UIDE /P switch added.
                 XMGR/UIDE/UIDEJR now handle 32 BIOS disks (not 40).

   15-Oct-09   XMGR/UIDE /K switch deleted re: Win95/98 trouble.   Thanks
                 to Japheth for his "warning"!

    6-Oct-09   UIDE and UIDEJR /H requests HMA use "at the user's risk"!

    3-Sep-09   XMGR now does protected-mode move "calls" (as in UIDE) for
                 faster speed using RDISK, etc.   XMGR /K switch added.

    2-Sep-09   README file updated -- FreeDOS users who desire full upper
                 memory must omit UMBPCI and load JEMM386/JEMMEX only.

   23-Jun-09   RDISK now a .COM file.    RDISK /: switch, RDISKON program
                 added.   Corrected UIDE CD/DVD handling of VDS errors.

    9-Jun-09   UIDE/UIDEJR /N3 switch added for no XMS memory.   Override
                 of /D: name by UIDE$/UIDEJR$ added for no CD/DVD drives.

   15-May-09   Added RDISK.

    6-May-09   Added UIDEJR.    UIDE/UIDEJR now run up to 10 controllers,
                 36 disks, 8 CD/DVD drives.

    1-May-09   Fixed XMGR "Port 92h" logic error.  Added XMGR /PA and /PN
                 switches to control use of "Port 92h" logic.

   25-Apr-09   XMGR/UIDE license and FreeDOS prohibition deleted, drivers
                 and sources are again available to all.   Corrected UIDE
                 CD/DVD "return codes".   UIDE /R switch re-added.


4. Switch Options
   --------------

   XMGR usually needs only its /B switch, if "booting" with an EMM driver.
      All XMGR switch options are as follows:

      /B     Specifies "boot" mode.   XMGR loads in temporary memory until
                upper-memory is enabled.     Without /B, XMGR loads stand-
                alone in low memory or direct to upper-memory with UMBPCI.
                See the CONFIG.SYS examples in section 5.

      /Mn    Specifies a temporary area for loading XMGR in "boot" mode or
                for UMBPCI upper memory I-O before DOS posts a "workspace"
                buffer.   Values are:

                    /M1 = 64K.    /M3 = 192K.   /M5 = 320K.   /M7 = 448K.
                    /M2 = 128K.   /M4 = 256K.   /M6 = 384K.   /M8 = 512K.

                Without /M, /M5 is assumed and the 320K area will be used.
                NOTE:  DOS systems may NOT load at address 0 and may leave
                temporary data anywhere in memory!     /Mn helps to find a
                "safe" area for XMGR to use.   /M is ignored if XMGR loads
                stand-alone.

      /Nnn   Specifies how many XMS "Handles" can be used by DOS programs.
                The value nn may be 48, 80, or 128.   If /N is omitted, 48
                "Handles" are used.   A big system doing much XMS work may
                need 80 or 128 "Handles".

      /PA    Specifies use or non-use of PS/2 Port 92h logic to handle the
      /PN       system's "A20" line.   /PA indicates "Always" use Port 92h
                logic.   /PN indicates "Never" use it and handle "A20" via
                normal keyboard-port logic.   If /P is omitted, XMGR "asks
                the BIOS" if the system has Port 92h logic.   If not, XMGR
                will use normal "A20" logic.   NOTE:  If "A20" was enabled
                by DOS before XMGR loads, XMGR does not handle it at all!

      /Tn    Specifies the BIOS requests to use in getting extended memory
                as follows:

                   /T0   No "E820h" nor "E801h" requests.
                   /T1   Memory-list requests only (Int 15h, AX=E820h).
                   /T2   A dual-area request only  (Int 15h, AX=E801h).
                   /T3   "E820h" requests first, then an "E801h" request.

                /T can usually be omitted, causing /T3 to be assumed.   In
                addition, XMGR always uses an old 64-MB request to get /T0
                memory, or if the requests denoted by /T1 thru /T3 are not
                successful.   Users may need to test /T1 or /T2 separately
                to see if their BIOS takes them.   A pre-1994 BIOS may not
                ignore /T1 thru /T3 correctly and may require /T0 instead.
                For old "QHIMEM" users, /T4 thru /T7 may still be used and
                work the same as /T0 thru /T3.

      /W     Specifies use of the DOS "workspace" buffer, for upper-memory
                I-O if loading with UMBPCI.    If /W is omitted, or if the
                DOS system does not have proper workspace logic, XMGR sets
                its own buffer in low memory.   With PC-DOS or EDR-DOS, /W
                must be omitted!   Without UMBPCI, /W is ignored.

      /Z     See /Z for UIDE, below.

             --------------------

   RDISK uses only /S size and /: drive-letter switches:

      /Sn    Specifies a desired RAM-disk size in megabytes of XMS memory.
                Values may be any number from 2 to 2047.    /S1024 or more
                creates a 1- to 2-GIGABYTE RAM-disk!   If /S is omitted or
                invalid, a 25-MB RAM-disk is created by default.   For old
                V2.0 XMS managers (ROM-DOS etc.) only /S2 through /S60 may
                be used.   See section 5 below for more details.

      /:L    Specifies the DOS drive letter desired to access RDISK files.
                L may be any available drive letter from A to Z, e.g.  /:N
                assigns drive N: to all RDISK files.   If the drive letter
                is too high or already in use, RDISK will abort, and users
                may need "LASTDRIVE=" in CONFIG.SYS to set up more drives.
                If RDISK is loaded by CONFIG.SYS, or if /: is omitted, the
                next free drive letter will be used.

             --------------------

   UDVD2 normally needs only a /H switch to use HMA space and a /D: switch
   to specify a "device name" for the CD/DVD Redirector program (SHCDX33F,
   etc.).   It uses only "minimal" switches, as listed below.   For a full
   description of each switch, read the equivalent notes for UHDD or UIDE.
   UDVD2 switch options are as follows:

      /A     Sets ALTERNATE "Legacy IDE" controller addressing.    Rarely
                necessary.

      /D:    Sets a CD/DVD "device name".   When /D: is not given,  UDVD1
                is set by default, same as with UIDE.

      /H     Puts most of the driver in "free HMA" space, taking only 144
                bytes of upper/DOS memory.   Read the NOTE below for UHDD
                or UIDE /H, regarding known MS-DOS kernel ERRORS!

      /R15   Reserves 15-MB or 63-MB of XMS, for old DOS "game" programs.
      /R63      NOTE:  Only the first driver to use XMS may "reserve" any
                of it!   If UDVD2 loads after UHDD for caching, UHDD must
                "reserve" XMS, and /R then must NOT be given with UDVD2!

      /UD    Caches only CD/DVD directories (no data) to save cache space
                for disk files.   NO speed loss during CD-to-disk copies!
                Requires the updated SHCDX33F of 2-Aug-2012 or later.

      /UX    Disables CD/DVD UltraDMA for all drives.   Rarely necessary.

             --------------------

   UHDD and UIDE normally need only a /H switch to use HMA space plus a /S
   switch for their cache size.   UHDD and UIDE switches are as follows:

      /A     Specifies ALTERNATE addressing, for "legacy IDE" controllers.
                The first legacy controller will use 01E8h/0168h addresses
                and a second (if present!) will use 01F0h/0170h addresses.
                /A is only for an "odd" mainboard using REVERSED addresses
                for the two "legacy IDE" controllers!    If /A is omitted,
                the first legacy controller uses 01F0h/0170H, and a second
                uses 01E8h/0168h, which is normal for most PC mainboards.

      /B     Requests a basic UltraDMA driver for disks (and CDs/DVDs with
                UIDE) i.e. no caching or diskette support.   This may help
                with tests or diagnostic work.   The /B driver can request
                128K of XMS memory as its UltraDMA I-O buffer and can load
                in HMA space.   UHDD defaults to /B if XMS is unavailable.

      /D:    For UIDE only, specifies the "device name", used by MSCDEX or
                other Redirectors to access the CD/DVD drives.   Examples:
                /D:CDROM1  /D:MYCDROM  etc.    If /D: is not given, or the
                name after a /D: is missing or invalid,  UDVD1  is used by
                default.   If no CD/DVD drives are found,  UIDE$ overrides
                any /D: name (necessary for FreeDOS "autoloader" scripts).
                UHDD ignores /D: as it does not run CD/DVD drives.

      /E     Makes the driver call the BIOS for any hard disk I-O request.
                /E avoids setup trouble on some DOS emulators (VirtualBox,
                etc.) that do NOT emulate all PC hardware logic!   /E also
                allows using hard disks on 1994 or older PCs which have no
                PCI/EDD BIOS.   /E still caches disk data, unlike /N1 that
                removes ALL disk support!    For UHDD, /E will dismiss all
                UltraDMA logic, saving 464 bytes.

                ***** NOTE *****

                Use of /E on protected-mode systems (JEMM386 etc.) may run
                VERY slow!    Many "cheap" BIOS programs have no DOS "VDS"
                logic for hard-disks, and in protected-mode, they can only
                do "PIO mode" transfers, not UltraDMA!    If /E is needed,
                users should run their systems in real-mode (UMBPCI, etc.)
                whenever possible.

      /F     Requests a "fast" cache with 32K cache blocks for 40 or 50-MB
                caches, or 64K blocks for 80-MB+ caches, giving more speed
                by handling fewer blocks.   Without /F, 40-MB thru 1023-MB
                caches have 16K blocks, and 1024-MB to 2047-MB caches have
                32K blocks, for more cache capacity from less "lost space"
                in a file's last cache block.    /F is ignored with /S2048
                and up, as 2-GB+ caches require 64K blocks.

      /H     Loads most of the driver in "free HMA" space.   UIDE will use
                912 bytes, and UHDD will use 816 bytes of upper/DOS memory
                (only 656 bytes for the /B "stand alone" UHDD).    /H must
                NOT be given with ROM-DOS, which has no HMA!   When /N3 is
                also given for UIDE, /H will be ignored.

                ***** NOTE *****

                MS-DOS kernels have ERRORS in posting free HMA space which
                can give CRASHES!   Specifying /H is "At the user's risk"!
                No such crashes are noted with other DOS systems, also HMA
                use by UHDD+UDVD2 or UIDE is less than 4.5K [Even poor-old
                V7.10 MS-DOS has about 8.75K of free HMA!].   Users should
                still TEST a PC system, before /H is given for any serious
                work with these drivers!

      /N1    Requests NO hard-disk handling by the driver.   For UHDD, /N1
                will dismiss all UltraDMA logic, saving 464 bytes.

      /N2    For UIDE only, requests NO CD/DVD handling by the driver.

      /N3    For UIDE only, requests no XMS memory.    /N3 will cause UIDE
                to set its /B basic driver.   /N3 requires loading in low-
                memory or the driver aborts!   /N3 can LOSE much speed, as
                misaligned or other I-O unsuited to UltraDMA must use BIOS
                logic for a disk or "PIO mode" for a CD/DVD drive!    UHDD
                ignores /N3, as it can now run with or without XMS memory.

      /N4    See /Z below.

      /Q     Awaits a "data request" before doing UltraDMA disk transfers.
                /Q is for "old" systems and may be used only if the driver
                loads O.K. but seems unable to transfer data.   /Q must be
                OMITTED with SATA-to-IDE adapters from Sabrent and others,
                since they may not emulate "data request" from SATA disks!
                /Q does not affect CD/DVD drives.

      /R15   Sets the driver's XMS memory at 16- or 64-MB.   /R15 reserves
      /R63      15-MB of XMS, and /R63 reserves 63-MB of XMS, for DOS game
                programs that require XMS memory below 16- or 64-MB!   The
                drivers must be able to reserve this memory, reserve their
                own XMS above that, and "free" the 15/63-MB XMS.   If not,
                the drivers display "XMS init error" and abort!    /R15 or
                /R63 need the drivers to load after the XMS manager (XMGR,
                HIMEMX, etc.), so another driver cannot take any XMS first
                and the reserved XMS is just beyond the HMA.   See section
                7 below for further details.

      /Sn    Specifies the desired cache size, in megabytes of XMS memory.
                Values for /S are 5, 15, 25, 40, 50, or any number from 80
                to 4093.   /S1024 or more will set a 1- to 4-GB cache!   A
                recommended set of /S values are --

                    Below 128-MB memory:     Use /S5 /S15 /S25 or /S40

                    With 128-MB memory:      Use /S25 /S40 /S50 or /S80
                    With 256-MB memory:      Use /S80  up to /S127
                    With 512-MB memory:      Use /S160 up to /S255

                    With 1-GB memory:        Use /S320  up to /S511
                    With 2-GB memory:        Use /S640  up to /S1023
                    With 4-GB memory:        Use /S1280 up to /S3072

                Small systems may prefer /S25 or /S50 which set 1600 cache
                blocks and are more efficient.   If /S is omitted/invalid,
                an 80-MB cache is set.   Except for 25 or 50, values below
                80 are cut to 40- 15- or 5-MB.    The drivers display "XMS
                init error" and abort, when not-enough XMS memory is free!
                If so, a smaller cache must be requested.   For older V2.0
                XMS managers (ROM-DOS etc.), only /S5 to /S50 may be used.

      /UD    For UIDE only, caches only CD/DVD directories (no data files)
                to save cache memory for disk files.    CD-to-disk copying
                speed is still QUICK, as directories WILL be cached!   /UD
                requires the use of SHCDX33F dated 2-Aug-2012 or newer, to
                "recognize" CD/DVD directory input versus data-file input.
                UHDD ignores /UD, as it does not run CD/DVD drives.

      /UX    For UIDE only, disables all CD/DVD UltraDMA, even for a drive
                that can do it.    "PIO mode" then handles all CD/DVD I-O.
                Except for some "unusual" drives by Sony, etc. that do not
                follow all ATAPI "rules", /UX is rarely needed.   /UX does
                not affect hard-disks.    UHDD ignores /UX, as it does not
                run CD/DVD drives.

      /Z     For XMGR, UHDD, and UIDE, moves XMS data in 2K-byte sections,
                if in protected-mode.   /Z is unneeded with JEMM386/JEMMEX
                MS-DOS EMM386 or real-mode UMBPCI.   With other protected-
                mode EMM/VCPI/DPMI drivers, systems must be TESTED to find
                if /Z is needed with these drivers -- BAD schemes allowing
                NOT enough interrupts during an XMS move may still exist!!
                UIDE's old /N4 switch is equivalent and still can be used.
                The /B "stand alone" UHDD ignores /N4 or /Z, since it will
                call the XMS manager to move XMS data.

             --------------------

   For all switches in each driver, a dash may replace the slash and lower
   case letters may be used if desired.


5. Setup and Configuration
   -----------------------

   XMGR and the UIDE drivers are loaded using the CONFIG.SYS file.    Your
   CONFIG.SYS should have command lines similar to the following examples:

      DEVICE=C:\DOSDVRS\XMGR.SYS /N128 /B

      DEVICEHIGH=C:\DRIVERS\RDISK.COM /S500

      DEVICEHIGH=C:\SYSTEM\UHDD.SYS /S511 /H

      DEVICEHIGH=C:\USERDVRS\UDVD2.SYS /D:TOSHIBA1 /H

      DEVICEHIGH=C:\BIN\UIDE.SYS /S3072 /H /D:MYDVD     ;3 Gigabyte cache!

   Note that when UHDD caches data for UDVD2, or other "external" drivers,
   UHDD must be loaded first!    This lets UHDD be "found" and "linked" to
   the other drivers.   See the first CONFIG.SYS example below for UMBPCI.

   With V3.70+ UMBPCI and XMGR, a "boot" procedure is not needed!   UMBPCI
   loads first to enable upper-memory, then XMGR loads to offer it and XMS
   to DOS, then other drivers may load.    For V6.22/V7.10 MS-DOS, JEMM386
   can also be loaded, to offer extra upper-memory in the "video graphics"
   areas, or if other JEMM386 features are desired.

   NOTE:  FreeDOS and some other DOS variants will NOT "add up" the memory
   found by both UMBPCI and JEMM386, like MS-DOS does!   FreeDOS users who
   want extra upper-memory or other items must omit UMBPCI and load JEMMEX
   or HIMEMX/JEMM386 per their instructions, or load XMGR/JEMM386 as shown
   in the 3rd example below.

   An example CONFIG.SYS file using V3.70+ UMBPCI and XMGR is as follows:

      SHELL=C:\DOS\COMMAND.COM C:\DOS /E:512 /P
      DEVICE=C:\BIN\UMBPCI.SYS
      DEVICE=C:\BIN\XMGR.SYS /W
      DOS=HIGH,UMB
      DEVICE=C:\BIN\JEMM386.EXE I=B000-B7FF X=C800-EFFF NOEMS   ;Optional
      DEVICEHIGH=C:\BIN\UHDD.SYS /S500 /H                       ;Or others
      DEVICEHIGH=C:\BIN\UDVD2.SYS /D:CDROM1 /H                  ;Optional
      DEVICEHIGH=C:\BIN\RDISK.COM /S250                         ;Optional
          ..
          ..  Etc.
          ..

   XMGR can be used "stand alone" on a small XMS-only system.   It must be
   the first DOS system driver to load, and it must load in LOW memory, as
   in the following example:

      SHELL=C:\DOS\COMMAND.COM C:\DOS /E:512 /P
      DEVICE=C:\BIN\XMGR.SYS
      DOS=HIGH
      DEVICE=C:\BIN\UIDE.SYS /S80 /D:MYCDROM               ;Or others
      DEVICE=C:\BIN\RDISK.COM /S20                         ;Optional
          ..
          ..  Etc.
          ..

   With JEMM386 and XMGR,  XMGR loads first in "boot" mode,  then JEMM386,
   and then XMGR finally loads in upper-memory.   JEMMEX can also be used,
   and if so, XMGR can be omitted.   An example CONFIG.SYS file which uses
   the XMGR "boot" procedure is as follows:

      SHELL=C:\DOS\COMMAND.COM C:\DOS /E:512 /P
      DEVICE=C:\BIN\XMGR.SYS /B                           ;/B for "boot"
      DOS=HIGH,UMB
      DEVICE=C:\DOS\JEMM386.EXE I=B000-B7FF NOEMS ...     ;Or JEMMEX here
      DEVICEHIGH=C:\BIN\XMGR.SYS                          ;No "boot" here!
      DEVICEHIGH=C:\BIN\UIDE.SYS /S1023 /H /D:MYDVD       ;Or others here
      DEVICEHIGH=C:\BIN\RDISK.COM /S500                   ;Optional
          ..
          ..  Etc.
          ..

   If other Int 13h DOS drivers are used, UHDD/UIDE should load after them
   to cache their I-O, too.   After XMGR, other Int 13h drivers, UHDD/UIDE
   and UDVD2 (if desired with UHDD) are loaded, further CONFIG.SYS drivers
   (RDISK, SETVER.EXE, ANSI.SYS, etc.) can then load in any desired order.

   When a specific RDISK drive letter is required, RDISK can now be loaded
   by AUTOEXEC.BAT, and its /: switch can specify any "free" drive letter,
   e.g.  /:Q  assigns drive Q: for RDISK files.    Whenever RDISK is used,
   AUTOEXEC.BAT should also include commands which copy all RDISK programs
   and data up to the RAM-disk.   This is required each time DOS loads, as
   XMS memory is LOST when a system shuts down!   Such copies usually take
   little time.

   If RDISK and UHDD/UIDE are both loaded, users must balance how much XMS
   memory the drivers use.   RDISK must use no more XMS than its files may
   need.   UHDD/UIDE can then take most remaining XMS, for a better cache.
   Some XMS memory must be saved for other programs which need it!   As an
   example, on a 4-GB PC, RDISK might use 500-MB, UHDD/UIDE might use 3-GB
   and 500-MB of XMS is "free" for other programs.    These amounts can be
   varied so that RDISK handles programs or "fast" data files, while UHDD/
   UIDE cache "ordinary" files.   Properly balanced use of XMS will create
   a VERY high-speed DOS system!

   Please be sure to set each hard disk's geometry correctly in your BIOS.
   Set it to "Auto", "LBA" or "LBA Assisted", but NOT to "None", "Normal",
   "CHS", "ECHS".   "User Cylinders/Heads/Sectors", "Revised ECHS" or "Bit
   Shift" should run but are NOT preferred.   If a BIOS has a setting like
   "UltraDMA" or "UDMA Capable" for a disk, enable it.

   "Laptop" power-saving items like a "drive spin-down timeout" should run
   O.K. but must be TESTED before use!   All these drivers allow 7 seconds
   for a disk or CD/DVD drive to spin-up, after being idle.   More DRASTIC
   power-saving items like a "drive SHUTDOWN timeout" (may require "extra"
   logic to restart the drive!) should be DISABLED, or driver I-O requests
   may time out!

   Also, be sure to use an 80-connector cable for any UltraDMA drive using
   "mode 3" ATA-44 (44 MB/sec) or higher.   When cabling a single drive to
   an IDE channel, note that you MUST use both "ends" of the cable, NOT an
   "end" and the middle connector!   This prevents ERRORS, since an unused
   cable-end can pick up "noise", like a RADIO antenna!

   Be sure to enable all CD/DVD drive(s) through the BIOS set-up routines!
   A drive that is "disabled" may cause the BIOS to clear all its UltraDMA
   flags and force the drive into "PIO mode" zero, which is terribly SLOW!


6. Error Reporting
   ---------------

   XMGR and the UHDD/UDVD2/UIDE drivers return normal XMS and CD/DVD error
   codes, when needed.   They are listed in the V3.0 XMS Specification and
   Microsoft "MS-DOS CD-ROM Extensions 2.1" document available from Micro-
   soft and other Internet sources.

   All except UDVD2 run as "BIOS drivers" and return whatever codes a BIOS
   posts for its diskettes and hard-disks.    For a SATA or IDE hard-disk,
   UHDD or UIDE can post the following error codes:

       Code 0Fh - DMA error.           CCh - Disk is FAULTED.
            20h - Controller busy.     E0h - Hard I-O error.
            AAh - Disk not ready.      FFh - XMS memory error.

   Many DOS programs display only "Disk Error" messages with NO code, thus
   disk errors may require running a diagnostic to get better information!


7. Technical Notes
   ---------------

   In all of the following notes, "UIDE" also applies to UHDD and UDVD2.

   The JEMMEX or JEMM386 drivers are now recommended for use with UIDE, if
   using a DOS system that needs their extra upper-memory, DPMI/VCPI logic
   etc.    Other EMM drivers are essentially "abandoned", some with never-
   corrected ERRORS, and they should NOT be used!

   UIDE thru 20-May-2012, and UHDD/UIDE of 15-Oct-2012 or later, detect A:
   and B: diskettes from BIOS data.   Intervening drivers issued "Int 13h"
   calls that FAIL if an LS120 (120-MB) diskette drive is present!   Those
   calls have been deleted.

   The "VirtualBox" emulator as of 15-Oct-2012 does not set a "change-line
   available" bit in BIOS byte 0:48Fh for A: and B: diskettes.   UHDD/UIDE
   IGNORE diskette drives without a "change line" (normally 1985 or older)
   as they cannot declare "media changes", i.e. a NEW diskette was loaded!
   Until "VirtualBox" gets corrected, UHDD/UIDE will NOT support A: and B:
   diskettes in a "VirtualBox" environment!

   UIDE's /R15 or /R63 switches (DOS "game" programs), are for a real-mode
   system using UMBPCI and XMGR.   Game players like real-mode as it gives
   more speed.   If protected-mode (JEMM386/EMM386) is desired, UIDE using
   a /R switch must load prior to the "EMM" driver, so the XMS reserved by
   UIDE is just beyond the HMA.   If using UMBPCI, XMGR, UIDE, and then an
   EMM driver, this works fine.   But, FreeDOS users, and others whose DOS
   systems permit only one XMS provider (i.e. UMBPCI cannot be used!) must
   load XMGR/HIMEMX first, UIDE second into low memory (upper-memory isn't
   yet enabled!), then JEMM386/EMM386 last.   Using JEMMEX with UIDE and a
   /R switch is unrecommended!   JEMMEX must load first and takes some XMS
   itself, which pushes the reserved XMS above its intended 16/64-MB area,
   and a few DOS "games" programs may CRASH!

   UIDE will NOT include any AHCI logic!    Most BIOS programs still offer
   "Legacy"/"Compatibility"/"Native IDE" BIOS settings on AHCI controllers
   with which UIDE runs fine.   If a "new" AHCI BIOS has no such settings,
   UIDE with a /E switch should be able to call the BIOS and use its logic
   to run AHCI disks.   NOTE:  Much "DOS driver" code is now being omitted
   from AHCI BIOS programs!   UIDE should thus be TESTED before normal use
   on such new "cheap BIOS" AHCI mainboards!

   Also note that CD/DVD drives are not supported by an AHCI BIOS for file
   I-O, only for "boot" CDs.   On a system whose AHCI chips can be set for
   "Legacy"/"Compatibility"/"Native IDE" mode, CD/DVD drives should be run
   from AHCI ports using such modes.   On mainboards with no such settings
   UIDE can run CD/DVD drives only on the parallel IDE port (80-pin cable)
   or IDE-capable "add on" cards from Promise, etc. that UIDE can "detect"
   using normal PCI-bus logic.

   UIDE handles only "Legacy" or "Native PCI" IDE controllers.   RAID-only
   chipsets (Via VT6420, etc.), "port multiplier" chips, and ADMA chipsets
   are not currently supported.   AHCI is supported only by BIOS "Legacy",
   "Compatiblity" or "Native IDE" mode settings, or thru UIDE "calling the
   BIOS" as noted above.     To use UIDE, a mainboard BIOS should set SATA
   and IDE controllers to some form of "IDE" mode, not RAID/ADMA/AHCI, for
   best speed.    If no "Legacy"/"Compatibility"/"Native IDE" BIOS setting
   for disk controllers is provided, a Sabrent converter card (or similar)
   will let UIDE handle SATA hard-disks or CD/DVD drives from the parallel
   port IDE controller channel, using full UltraDMA speeds.

   Except if necessary for AHCI, it is NOT RECOMMENDED for UIDE to run any
   DOS disk using only the BIOS!   A "cheap" BIOS often omits DOS "Virtual
   DMA" logic.   If so, when an EMM driver (JEMM386 etc.) enables its "V86
   protected-mode", the BIOS can do only PIO-mode transfers and LOSES much
   speed!   If needed, get SATA-to-IDE adapters for SATA disks (as above),
   or get "Int 13h" disk drivers for SCSI or other disk models.   UIDE can
   then handle such disks at full DMA speeds!

   XMGR loads in UMBPCI upper-memory BEFORE that memory is declared to the
   DOS system!   Memory displays using UMBPCI may not list XMGR, since its
   memory is not part of the DOS memory lists.   Such memory displays will
   begin with a block having a 00A7h offset, or greater if using 80 or 128
   XMS "Handles".   The upper-memory skipped by this offset contains XMGR.

   The UMBPCI upper-memory manager uses system "Shadow RAM" that CANNOT do
   DMA!   Newer BIOS programs may use UltraDMA to load programs into upper
   memory.   If this is UMBPCI "Shadow RAM", a CRASH will occur!   To stop
   this, and handle new BIOS programs, users should follow these two RULES
   for running UMBPCI together with XMGR and UHDD/UIDE:

     A) The loading "order" for V3.70+ UMBPCI and XMGR, shown in section 5
        above, MUST be used!    This lets the XMGR "I-O Catcher" intercept
        and process upper memory disk I-O, until a "UIDE" driver loads and
        takes-over disk UltraDMA.   Older UMBPCI versions, or other UMBPCI
        loading schemes, are NOT recommended!

     B) When CHS I-O is done (MS-DOS V6.22 or older), every disk MUST have
        valid CHS parameters!   If not, UIDE and the "I-O Catcher" let the
        BIOS handle CHS I-O.   If BIOS UltraDMA is not disabled, a similar
        "Shadow RAM" CRASH will occur!

   Some "CD-ROM boot" programs handle the CD/DVD as a "fake" hard disk and
   provide incorrect EDD BIOS data for it!   In scanning for disks to use,
   UIDE may display "EDD BIOS error!  Unit ignored.", then go on searching
   for more UltraDMA disks.   Users who did NOT "boot" from CD/DVD need to
   see which disk was passed-over and why.   Users who DID "boot" from CD/
   DVD, where all SATA/UltraDMA disks were found, may IGNORE this message!
   It is caused by an ERROR in the "CD-ROM boot" program, NOT by a problem
   with UIDE or its SATA/UltraDMA disks!

   Some BIOS programs do not "configure" a mainboard controller if no user
   drives are on it!     An unconfigured controller causes UIDE to display
   "BAD controller", then it goes on looking for others to use.    If this
   message is displayed, users should verify that each SATA/UltraDMA drive
   was made "active" thru the BIOS set-up logic.   If so, "BAD controller"
   says a chip was not set to both "Bus Master" and "I-O Space" modes, and
   the BIOS should be UPDATED!

