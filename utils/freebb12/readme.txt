
             ______             ____  ______     _____  ______ 
            |  ____|           |  _ \|  ____|   / / _ \|  ____|
            | |__ _ __ ___  ___| |_) | |__     / / |_| | |__ 
            |  __| '__/ _ \/ _ \  _ <|  __|   / /|  _  |  __|
            | |  | | |  __/  __/ |_) | |____ / / | | | | |
            |_|  |_|  \___|\___|____/|______/_/  |_| |_|_|


               The free VBE/AF driver project, version 1.2

                  http://www.talula.demon.co.uk/freebe/


                "The nice thing about standards is that
               there are so many of them to choose from."



======================================
============ Introduction ============
======================================

   VBE/AF is a low level driver interface for accessing graphics hardware. 
   It provides all the same features as VESA 3.0 (access to linear 
   framebuffer video memory, high speed protected mode bank switching, page 
   flipping, hardware scrolling, etc), and adds the ability to use 2D 
   hardware acceleration in an efficient and portable manner. An /AF driver 
   is provided as a disk file (vbeaf.drv), and contains clean 32 bit machine 
   code which can be called directly by a C program. If implemented 
   correctly, these drivers have the potential to be binary portable across 
   multiple operating systems, so the same driver file can be used from DOS, 
   Windows, Linux, etc.

   FreeBE/AF is an attempt to implement free VBE/AF drivers on as many cards 
   as possible. This idea came about on the Allegro mailing list, due to the 
   need for a dynamically loadable driver structure that could support 
   hardware acceleration. VBE/AF seemed to fit the bill, and Allegro already 
   had support for the SciTech drivers, so it seemed like a good idea to 
   adopt this format for ourselves. The primary goal is to make these 
   drivers work with Allegro, so the emphasis will be on implementing the 
   functions that Allegro actually uses, but we encourage other developers 
   to join us in taking advantage of this excellent driver architecture.

   This project currently provides fully accelerated drivers for a handful 
   of chipsets, plus a number of dumb framebuffer implementations based on 
   the video drivers from older versions of the Allegro library. It has also 
   defined a few extensions to the stock VBE/AF API, which allow Allegro 
   programs to use these drivers in a true protected mode environment 
   without having to resort to the nearptr hack, and provide a number of 
   hook functions that will be needed to remain compatible with future 
   generations of the SciTech drivers.

   The current status of the VBE/AF standard is somewhat confused. It was 
   designed by SciTech Software (http://www.scitechsoft.com/), who provide 
   commercial VBE/AF drivers for a wide range of cards as part of their 
   Display Doctor package. It was originally going to be released as a VESA 
   standard, but the VESA people seriously messed this up by charging 
   exorbitant sums of $$$ for copies of the spec. As a result, very few 
   people bothered to support these drivers, and the FreeBE/AF project was 
   only made possible by the information available in the SciTech MGL 
   library source code, and the helpfulness of Kendall Bennett (the designer 
   of the spec) himself. Unfortunately SciTech have now abandoned VBE/AF 
   themselves, replacing it with an equivalent but non-public API called 
   Nucleus, which is only available under NDA. SciTech will continue to 
   provide VBE/AF drivers for the cards which they already support, but 
   will not adding any new ones in the future, so this project is now the 
   only active source of VBE/AF driver implementations.

   At present, the Allegro (http://www.talula.demon.co.uk/allegro/) and MGL 
   (http://www.scitechsoft.com) libraries are the only major packages which 
   can take advantage of accelerated VBE/AF drivers. As such, this project 
   is starting to look more like a implementation of video drivers 
   specifically for the Allegro library, rather than a potential 
   industry-wide standard :-) But it doesn't have to be this way! VBE/AF is 
   technically an excellent design: efficient, easy to write and use, and 
   highly portable. If you are writing graphics code, and getting frustrated 
   by the many limitiations imposed by VESA, why not think about using 
   VBE/AF instead? Even better, if you have a card that our project doesn't 
   yet support, why not add a new driver for it? This can be a lot of fun, 
   and we would be delighted to offer any help or advice that you might need.



============================================
============ Supported Hardware ============
============================================

   Not all VBE/AF drivers provide the complete set of possible features. 
   Some may be written in a 100% clean and portable manner, allowing them to 
   be used on any platform, but others make use of the video BIOS in order 
   to set the initial video mode: this makes them a lot easier to write, but 
   means that it can only be used under DOS. Some of the drivers, in 
   particular the ones based on the old Allegro library chipset support, 
   don't support any hardware accelerated drawing at all: these are still 
   usefull because they provide high speed protected mode bank switching and 
   can work around the bugs in some manufacturer's VESA implementations, but 
   are obviously not nearly as cool as a fully accelerated driver.

   This table lists the currently available FreeBE/AF drivers, and what 
   features they each provide:
   
   ATI 18800/28800
   Uses BIOS
   Banked modes only
   Supports farptr extension
   Dumb framebuffer
   
   ATI mach64
   Uses BIOS
   Banked and linear modes
   No FreeBE/AF extensions
   Hardware accelerated
   
   Avance Logic ALG-2101, ALG-2201, ALG-2228, ALG-2301, ALG-2302
   Uses BIOS
   Banked modes only
   No FreeBE/AF extensions
   Dumb framebuffer
   
   Cirrus 54xx (not 546x). Should be ok with 5426, 5428, 7541, 7543
   Uses BIOS
   Banked and linear modes
   No FreeBE/AF extensions
   Hardware accelerated
   
   Matrox Millenium, Mystique, Millenium II
   Uses BIOS
   Banked and linear modes
   Supports farptr and config extensions
   Hardware accelerated
   
   NVidia Riva 128, TNT. Conflicts with Windows!
   100% portable
   Banked and linear modes
   Supports config extension
   Hardware accelerated
   
   Paradise
   Uses BIOS
   Banked modes only
   Supports farptr extension
   Dumb framebuffer
   
   S3
   Uses BIOS
   Banked modes only
   Supports farptr extension
   Hardware accelerated
   
   Trident TGUI 9440. Doesn't work under Windows!
   100% portable
   Banked and linear modes
   No FreeBE/AF extensions
   Hardware accelerated
   
   Trident
   Uses BIOS
   Banked modes only
   Supports farptr extension
   Dumb framebuffer
   
   Tseng ET3000/ET4000/ET6000
   Uses BIOS
   Banked modes only
   Supports farptr extension
   Dumb framebuffer
   
   Video-7
   Uses BIOS
   Banked modes only
   Supports farptr extension
   Dumb framebuffer
   
   stub driver (for testing and development purposes only)
   Uses BIOS
   Banked and linear modes
   Supports farptr and config extensions
   Slow software emulation of hardware drawing functions



===================================
============ Copyright ============
===================================

   As the name implies, FreeBE/AF is free. Both the driver binaries and 
   sources may be distributed and modified without restriction. If you find 
   any of this stuff useful, the best way to repay us is by writing a new 
   driver for a card that isn't currently supported.

   Disclaimer: no warranty is provided with this software. We are not to be 
   held liable if it fries your monitor, eats your graphics card, or roasts 
   your motherboard.



=================================
============ Credits ============
=================================

   The DRVGEN utility is based on the djgpp DXEGEN system, by Charles 
   Sandmann (sandmann@clio.rice.edu) and DJ Delorie (dj@delorie.com).

   Linking/relocation system and ATI mach64 driver by Ove Kaaven
   (ovek@arcticnet.no).

   VBE/AF framework, stub driver, Matrox driver, NVidia driver, most of the 
   old Allegro chipset drivers, conversion from Allegro to VBE/AF format, 
   and installation program by Shawn Hargreaves (shawn@talula.demon.co.uk).

   Cirrus 54x driver by Michal Mertl (mime@eunet.cz).

   Trident TGUI 9440 driver by Salvador Eduardo Tropea (set-soft@usa.net).

   Avance Logic driver by George Foot (george.foot@merton.oxford.ac.uk).

   Fixes to the Cirrus 5446 MMIO routines by Keir Fraser (kaf24@cam.ac.uk).

   Tseng ET6000 support by Ben Chauveau (bendomc@worldnet.fr).

   Paradise driver by Francois Charton (deef@pobox.oleane.com).

   Tseng ET4000 15/24 bit support by Marco Campinoti (marco@etruscan.li.it).

   Trident driver improved by Mark Habersack (grendel@ananke.amu.edu.pl).

   Video-7 fixes by Markus Oberhumer (markus.oberhumer@jk.uni-linz.ac.at).

   S3 driver improved by Michael Bukin (M.A.Bukin@inp.nsk.su).

   Video-7 driver by Peter Monks (Peter_Monks@australia.notes.pw.com).

   S3 hardware acceleration by Michal Stencl (stenclpmd@ba.telecom.sk).

   Website logo by Colin Walsh (cwalsh@nf.sympatico.ca).

   More graphics hardware support by [insert your name here] :-)

   VBE/AF itself is the brainchild of SciTech software, and in particular 
   Kendall Bennett (KendallB@scitechsoft.com).

   The Video Electronics Standards Association does _not_ deserve any 
   mention here. The absurd prices they charge for copies of the /AF 
   specification have prevented it from being widely supported, and I think 
   this is a great pity. Long live freedom!



=================================
============ History ============
=================================

   30 March, 1998 - v0.1.
      First public release, containing an example driver implementation that 
      runs on top of VESA.

   31 March, 1998 - v0.11.
      Added support for multi-buffered modes.

   5 April, 1998 - v0.2.
      Added an accelerated Matrox driver.

   8 April, 1998 - v0.3.
      Added accelerated drivers for ATI mach64 and Cirrus 54x cards, plus 
      minor updates to the Matrox driver.

   12 April, 1998 - v0.4.
      Proper installation program, more drawing functions implemented by the 
      stub and Matrox drivers, improved ATI driver, compiled with PGCC for a 
      5% speed boost.

   26 April, 1998 - v0.5.
      More accelerated features in the Cirrus and ATI drivers. Fixed bugs in 
      the Matrox driver. Added an option to disable hardware emulation in 
      the stub driver, which produces a non-accelerated, dumb framebuffer 
      implementation. The init code will now politely fail any programs that 
      try to use VBE/AF 1.0 functions, rather than just crashing.

   10 June, 1998 - v0.6.
      Fixed scrolling problem on Millenium cards.

   1 November, 1998 - v0.7.
      Added drivers for Trident TGUI 9440 and Avance Logic cards, and 
      improved the build process.

   14 December, 1998 - v0.8.
      Bugfixes to the Matrox Millenium II and Cirrus drivers. Converted all 
      the old Allegro library chipset drivers into non-accelerated VBE/AF 
      format, adding support for ATI 18800/28800, Paradise, S3, Trident, 
      Tseng ET3000/ET4000/ET6000, and Video-7 boards. Designed and 
      implemented an API extension mechanism, providing the ability to use 
      these drivers in a true protected mode environment, a more rational 
      relocation scheme, and various hooks that will later be needed for 
      supporting the SciTech Nucleus drivers.

   20 December, 1998 - v0.9.
      Bugfixes. Added a config mechanism, allowing the install program to 
      optionally disable some features of a driver.

   3 January, 1999 - v1.0
      Bugfixes.

   27 March, 1999 - v1.1
      Added acceleration support to the S3 driver, plus some bugfixes.

   27 June, 1999 - v1.2
      Added driver for NVidia cards. Improved the PCI bus scanning code to 
      know about bridges to secondary devices (so it can locate AGP cards). 
      Minor bugfix to the Mach64 driver (it was using the wrong clip rect 
      for scrolling displays). Minor bugfix to the Matrox driver (it was 
      setting the wrong background color for the hardware cursor).

