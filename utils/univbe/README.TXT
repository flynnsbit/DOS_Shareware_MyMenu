



                 UniVBE(tm) - The Universal VESA BIOS Extension
                 ----------------------------------------------

                                  Version 5.1

             Copyright (c) 1993-1995, SciTech Software, Chico, CA.
                              All Rights Reserved.



   UNIVBE v5.1, the Universal VESA BIOS driver, makes super VGA cards
   compatible with VESA BIOS Extension (VBE 2.0) programming standards so
   that games, CD-ROMs, utilities and other applications will work properly
   (and faster) in high resolution modes. It also includes chip detection,
   power management, monitor centering and compatibility & performance
   testing utilities. It now supports over 160 different SVGA chips (see list
   below). NOTE: VESA VBE is a software standard, so even if you have a PCI
   graphics card, you still need to load a VESA VBE driver; VBE is different
   from VESA Local Bus.


   It just makes your graphics run better
   --------------------------------------
   Computer games and other interactive applications (e.g. AutoDesk Animator,
   Links/386, MS Flight Simulator, the 7th Guest and *many* others) use the
   VESA VBE standard to interface with your graphics card. UniVBE helps solve
   compatability and performance problems associated with VBE graphics on
   many different Super VGA cards on the market. In addition, since it
   supports the new VESA VBE 2.0 standard, UniVBE can make applications
   written to take advantage of VBE 2.0, significantly faster by using
   protected mode access to the graphics card. UniVBE is the first product
   that will let you take advantage of the power of VBE 2.0.


   Supported Chips
   ---------------
   The following is a list of supported SuperVGA families, and chipsets
   within each family. If your graphics chip is on this list, and it probably
   is, it can be detected by UniVBE. You may not see any "board vendors" like
   Hercules, Genoa, Orchid, STB etc, but their products actually use chips
   from the manufacturers on this list, so UniVBE will work perfectly with
   those VGA boards too. See UNIVBE.TXT for any technical notes on your
   particular chip.

     .  Acer Labs ALi CAT-32/64
     .  Ark Logic ARK1000VL, ARK1000PV, ARK2000PV
     .  Avance Logic AL2101/2201/2228/2301/2302/2364 SuperVGA
     .  Ahead V5000A, V5000B
     .  ATI Technologies 18800, 28800, Mach32, Mach64
     .  Chips & Technologies 82c45x, 655xx, 643x0 WinGine
     .  Cirrus Logic CL-GD62xx, 5402, 5422/4/6/8/9, 5430/4
     .  Cirrus Logic LCD CL-GD64xx
     .  Compaq IVGS/AVGA, QVision QV1024/1280
     .  Diamond Viper P9000+W5186/OAK87 VLB and PCI
     .  Everex Viewpoint, Viewpoint/NI, Viewpoint/TC
     .  Genoa Systems GVGA
     .  Hualon HMC86304/14
     .  IIT AGX-010/11/14/15/16/17
     .  Matrox MGA Atlas
     .  MXIC 86000/86010 SuperVGA
     .  NCR 77C20/21/22E/32BLT
     .  OAK Technologies OTI-037C/057/067/077/087
     .  Paradise/Western Digital PVGA1A, WD90C1x/2x/3x
     .  Primus 2000 SuperVGA
     .  RealTek RTG3103/3105/3106 SuperVGA
     .  S3 86c911/924/801/805/928/864/964/866/868/968/Trio32/Trio64
     .  Sierra Semiconductor Falcon/64
     .  Trident 88/8900/9x00/8900CL/8900D/9200CXr/9400CXi/9420DGi/9440AGi
     .  Tseng Labs ET3000, ET4000, ET4000/W32/W32i/W32p
     .  UMC 85c408/18
     .  Video7 VEGA, HT208/209/216
     .  Weitek 5086/5186/5286, P9100


   File Descriptions
   -----------------
   If you received the complete UniVBE shareware package, you should have the
   following files when you unzip the main archive file (UNIVBE51.ZIP):

        FILE_ID.DIZ    BBS Archive Description
        README.TXT     Extended Archive Description
        ORDER.TXT      Product ordering information
        INSTALL.EXE    DOS Installation & Setup Program
        BIN.001        A zipped library of UniVBE utilities
        DOC.001        A zipped file containing the documentation
        DOS.001        A zipped library with UniCenter
        DOS.002        A zipped library with DOS DPMS utilities
        WIN.001        A zipped library with Windows screen saver
        UNZIP.EXE      Unzip program used by INSTALL


   Installing the Software
   -----------------------
   UniVBE comes with its own install program which will automatically unzip
   the remaining files into a directory that you select. It will
   automatically detect the type of chip you have and prompt you before it
   makes any changes to your system configuration and you have the option not
   to make any of the changes.

   NOTE: Unzip the files into a temporary directory with a name *other*
         than C:\UNIVBE, as install will automatically attempt to install
         to C:\UNIVBE.


   Printing the documentation
   --------------------------
   If you have a word processing program such as Microsoft Word or
   WordPerfect, you can load the 'Rich Text Format' version of the UniVBE
   documentation called UNIVBE.RTF into your word processor and print out a
   fully formatted manual for UniVBE. Alternatively you can read the plain
   ASCII text version of the documentation (UNIVBE.TXT) online using a text
   editor and/or print it to any plain ASCII text printer.

   Documentation   : UNIVBE.TXT, UNIVBE.RTF
   Keywords        : SciTech,VGA,SVGA,games,VBE,VESA,graphics,driver
   Previous Dnlds  : 10,145+


   Where to get the latest version
   -------------------------------
   You can always get the latest version of UniVBE from the following places:

   Internet/FTP    : ftp.scitechsoft.com
   World Wide Web  : http://www.scitechsoft.com
   Compuserve      : GO VESA (file library 12)
   America Online  : Keyword VESA


   How to contact SciTech Software
   -------------------------------
   If you have any questions or queries about UniVBE, feel free to contact
   SciTech Software as follows:

   Technical Support
   SciTech Software
   5 Governors Lane, Suite D
   Chico CA, 95926-1989

   Phone:          916 894-8400
   Fax:            510 208-8026
   Internet:       support@scitechsoft.com
   Compuserve:     100237,2213
