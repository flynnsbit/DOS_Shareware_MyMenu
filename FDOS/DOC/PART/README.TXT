
   Ranish Partition Manager     Version 2.37.11    September 15, 1998


   IMPORTANT: First of all run INSTALL.BAT, which will make a bootable
 floppy disk, copy partition manager, and save your current MBR on it.
 Then it will be safe to continue.

  IMPORTANT: When you resize FAT partitions you must change its size in
 two (TWO!!!) places: partition entry in MBR (that's the main screen) and
 in the partition's boot sector (select partition and press Enter).

   The help file for partition manager is part.htm. You can view that file
 with Netscape or inside partition manager (by pressing F1). If you run 
 partition manager from a floppy, get some mouse driver in order to follow
 hyperlinks in the help. For additional help and information visit my home
 page at http://www.ranish.com/part/

   There was added a replacement for the standard FAT-16 boot sector code.
 This code resolves the problem with MS-DOS not being able to boot from
 partitions above 2G, because of the bug in its boot sector code.
   With this replacement you can now boot MS-DOS from any partition below 8G.
 In addition to that you can also dual boot MS-DOS and Windows 95 OSR2, which
 also was not available, because of the bugs in OSR2 code.
   To install the code you have to run Partition Manager, select FAT-16
 partition and press Enter. You will enter boot sector setup screen. Then
 press F6 to install new code and F2 to save changes.
   When you format new partition this code will be installed by default.
 To uninstall it you must run "sys.com" of your DOS or Windows 95 system.


 ------------------------------------------------------------------------------

   At the time of writing this text I am working on the new version of the
 Partition Manager. The new version (v2.38) works with disks larger than 8G
 and does everything that does this version, plus much more. It will be the
 FULLY FUNCTIONAL shareware. Even if you don't pay a cent you still get the
 whole thing.

   The new version will run in protected mode and require 386 or better CPU
 with at least 2Mb of RAM.
 
   Therefore this version (2.37) is the last version of Partition Manager
 that:

   - Distributed as freeware with source code in the Public Domain.
   - Runs on every CPU (including 8086) with as low as 512k of memory.

   I will keep a copy of this version on my web site and will fix the bugs.
   However, I will not provide technical support for this version any more.

   If you want to get technical support you would have to register shareware
 version. The registration cost is very cheap, especially for the students -
 they simply have to send me a postcard with a view of their university.
 
   Actually, if you like my freeware version you can send me a postcard too.
 If I like the view of your city I will count it as a registration for v2.38
 and all subsequent versions of Partition Manager.

 Mikhail Ranish
 P.O.Box 140404
 Brooklyn, NY 11214  USA

 Home Page: http://www.ranish.com/part/
 Questions: http://groups.yahoo.com/group/partman/
