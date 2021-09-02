README.TXT

Readme File:

Program:  MIRROR.EXE

Version:  0.2

Author:  Brian E. Reifsnyder
         reifsnyderb@mindspring.com

Description:  Mirror stores a copy of the boot sector, FAT tables, and root
              directory in a "storage location" near the end of the disk.

              By using the /partn switch with the mirror command you can
              save a backup of the partition tables to a partnsav.fil on 
              the a: drive.

Note:  The mirror image created by this program is only re-coverable by 
       using the UNFORMAT program for FreeDOS located at 
       http://www.23cc.com/programs/unxmat07.zip

Compiler:  Borland Turbo C++ 3.0 (Program is written in C)

Licensing:  Licensed under the GNU GPL.

Warranties:  This program does not have any warranties, either stated or
             implied.  By using this program, you are assuming full
             responsibility for the outcome of the program's execution.

Operating systems this program is known to work under:
         MS-DOS 6.22
	 FreeDOS

Operating systems this program will not work under:
         MS-Windows NT (No major loss :-)  ) (This is due to NT's control over 
           direct access to hardware.)
       

