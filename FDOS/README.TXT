Odi's DOS tools for long file names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ALWAYS GET THE LATEST VERSION FROM http://www.odi.ch/
AND READ THIS BEFORE SENDING ME EMAIL!

Contents
--------

1. Overview
2. Description
3. Known bugs 
4. Where can I report bugs and get the latest version?
5. FAQ
6. License
7. Acknowledgements

1. Overview
1.1 What's this?
----------------
These tools provide easy file management under DOS with long filenames created by 
Windows 95/98 on FAT32, FAT16 and FAT12 file systems. To take full advantage of these 
tools, run them in pure DOS mode - not a DOS box under Windows. As far as I know this 
is the only completely FREE solution to handle long filenames in DOS.

To show you what I mean: Open up a DOS box in Windows 95 and type DIR - it will 
display long filenames. Do the same in DOS mode and you will only get the short 
names. Copy a file with a long filename in DOS mode and it will lose its long name.
Using my LFN Tools you can just feel like in a DOS box when you are actually in DOS 
mode. Typing LDIR brings up the directory with its long filenames. Copying a file 
with LCOPY preserves long filenames. You can even create directories (LMD) with long 
names or rename files (LREN) with long names.

1.2 What is it not?
-------------------
It is NOT an extension of DOS. All your DOS programs can NOT handle long file names 
even with these tools. (I should mention that there is a driver called LFNDOS that 
provides the Microsoft Long Filename API under DOS. You can find it somewhere on the 
web.) Other file systems than FAT and ISO-9660/Joliet for CD-ROMs are not supported 
yet. Thus these tools do not work on Apple Mac-Drives, Windows NT-Drives, Linux etc. 
But they run on Iomega ZIP drives. They are not supposed to run in a DOS-Box under 
Windows nor are they supposed to handle any short names. Use the generic DOS commands 
instead.
Do not use with Windows NT or Windows 2000.

1.3 Who may need these tools?
-----------------------------
Anyone who has Windows 9x/me running. Anyone who wants to make a backup copy of his 
Windows. Anyone who loves good old DOS. Anyone who must work in DOS mode for 
maintainance of the OS. Are you reinstalling Windows cause it's wrecked and want to 
backup all your data? Bought a new Harddrive and do not want to reinstall Windows? 
LCopy it! Want to restore your Windows directory from a ZIP drive or CD-ROM? Try it!

1.4 What do the tools do?
-------------------------
Each tool corresponds to a DOS equivalent but can handle long file names and FAT32.

LDIR.EXE   List a directory/folder like DIR
LCD.EXE    Changes to any directory/folder like CD
LREN.EXE   Renames a file like REN
LDEL.EXE   Deletes a file line DEL
LCHK.EXE   Display information about a volume
LCOPY.EXE  Copies files better than COPY
LMD.EXE    Creates a directory like MD
LRD.EXE    Removes a directory like RD

1.5 How do the tools work internally?
-------------------------------------
They do not use the common DOS calls to handle files and/or directories. Instead they 
access disks directly either through BIOS INT 25h and 26h or Int 21h function 7305h, 
depending on the version of operating system. For CD-ROM access Int 2Fh function 15h 
is used. Thus only FAT file systems and ISO9660/Joliet are supported. Five different 
file systems after all.

1.6 What's new?
---------------
To find out what version you have run LCHK. For details see history.txt.

1.7 A note on CD-ROM file systems
---------------------------------
On Windows platforms mostly two file systems (FS) are used for CD-ROMs at the same 
time: ISO-9660 and Microsoft Joliet (which is optional). Windows uses Joliet if 
available. DOS always uses ISO. ISO can either store short names in uppercase OR long 
names (31 characters) in a reduced ASCII character set. Long names are converted to 
short ones in DOS. Joliet can use long filenames in Unicode characters. This is the 
reason for the /I switch. 

1.8 Multisession CD-ROMs
------------------------
LFN Tools are capable of accessing previously recorded sessions on Multisession CD-
Rs. LCHK can list all tracks on a CD. Every track containing DATA is considered a 
"session" and has its own file system. Sessions can include or "overwrite" files from 
previous session. A new session can "delete" a file by simply not making a directory 
entry for it. With LFN Tools you are able to recover such "deleted" files.

1.9 Extended memory EMS and XMS
-------------------------------
LCOPY by default tries to use extended memory for its disk cache (2'393'300 bytes). 
This can improve performance on huge directories like the Windows\System directory. 
However for the extended memory to be used you need to load a memory manager like 
EMM386 in your config.sys. The simplest way to do so is to include the following line 
in your config.sys file:
device=c:\windows\emm386.exe RAM
If no memory manager is installed LCOPY can not use extended memory and so uses its 
standard cache method. Use the /V switch with LCOPY to turn off use of extended 
memory.
All the other tools do by default NOT use extended memory because overhead would be 
too big and performance would not necessarily be better.

2. Description

Note: When working with long filenames files do not need to have any extension or can 
have more than one. For example: "Mailbox", "Mail from Mama.txt", "Book.doc.zip". 
Thus wildcards do behave slightly different. (Microsoft's DOS Box instead keeps the 
behaviour compatible to DOS.) To select all files use a single * instead of *.*. 
Because *.* would select all files containing a dot - and most of the directory names 
don't!

Switches need not be separated by spaces anymore. However when using /Tnn it must be 
followed by a space if additional switches are specified. Otherwise they are ignored!

2.1 LDIR
--------
This command displays the specified directory if supplied a long directory name. 
Without parameters it displays the current directory. If the path or filename 
contains spaces double quotes are required (see example). You can use the common 
wildcards (?,*) to restrict the output to certain files. Use asterix to abreviate a 
long directory name. The /a switch displays hidden files too. The /b switch displays 
only long file names; no date/time information. The /s switch displays all 
subdirectories. When viewing large directories use the /p switch to pause listing 
between screen pages. Witch the /c switch you can turn off the cache. This will slow 
down the whole thing a bit, but consumes less memory (~128 KB). The /I and /T 
switches are for CD-ROM only. /I forces LDIR to use ISO file system rather than 
Joliet. /T must be followed by the number of a valid data track and a space. The 
track number identifies which session to use. When /T is absent the last session 
recorded is used. Use LCHK to display valid track numbers.

Note: When using quotation marks never put a backslash at the end! (See "Known Bugs & 
Features" for details)

Syntax:  LDIR [drive:][path][filename] [/?] [/A][/B][/S][/P]
	[/C][/I][/Tn]

Example: D:\WINDOZE>LDIR "C:\new folder\*.txt"

         .       .    <DIR>       13.01.1999  19:49  .
         ..      .    <DIR>       13.01.1999  19:49  ..
         NEWTEX~1.TXT        1247 13.01.1999  20:02  New textfile.txt

         D:\>LDIR w*

         WINDOZE .    <DIR>       13.01.1999  19:49  Windoze

         D:\>LDIR w*\

         .       .    <DIR>       13.01.1999  19:49  .
         ..      .    <DIR>       13.01.1999  19:49  ..
         NEWTEX~1.TXT        1247 13.01.1999  20:02  New textfile.txt


2.2 LCD
-------
This command changes the current working directory to the specified location. Unlike 
the corresponding DOS command LCD changes directly to a specified drive (see 
example). LCD will change to the first matching directory it meets. In addition 
wildcards can be used in pathnames. The first item occuring in the directory 
structure (this could be a file!) is used. The /I and /T switches are for CD-ROM 
only. /I forces LDIR to use ISO file system rather than Joliet. /T must be followed 
by the number of a data track. The track number identifies which session to use. When 
/T is absent the last session recorded is used. Use LCHK to display valid track 
numbers.


Syntax:  LCD [drive:]pathmask [/?][/I][/Tn]

Example: D:\WINDOZE>LCD "C:\new folder"

         C:\NEWFOL~1>LCD ..

         C:\>LCD pro*\onli*

         C:\PROGRA~1\ONLINE~1>

2.3 LDEL
--------
This command deletes the specified file(s). You can use the common wildcards (?,*) to 
select more than one file. The /s switch also deletes files found in subdirectories. 
Empty subdirectories are deleted automatically. The /a switch also deletes files with 
the read-only attribute set. If combined with the /s switch also read-only 
directories are processed. Hidden, system etc. files / directories are NOT affected 
by /a. To remove even those use /f. /f automatically includes /a. The /p switch asks 
you before deleting each file wheter to proceed or not. With the /c switch you can 
turn off the cache. This will slow down the whole thing a bit, but consumes less 
memory (~128 KB). To delete all files in a directory use "LDEL *" istead of "LDEL 
*.*".


Syntax:  LDEL [drive:][path\]file [/A][/F][/S][/P][/C][/?]

Example: C:\TEMP>LDEL *.txt
         Letter from Al.txt deleted
         My memories.txt deleted

         C:\TEMP>LDEL "E:\Garbage folder\*"
         Trash 1.dat deleted
         Trash 2.file deleted

Use /s with extreme care!
LDEL D:\* /s /f          Deletes everything on drive D:
LDEL d:\temp /s          Removes all files called temp from all directories on D:
LDEL d:\temp\* /s        Removes all files from directory D:\TEMP and down


2.4 LREN
--------
This command assigns a new long name to a file or directory. Do not use any wildcards 
(?,*); rename only a single file or directory. You will not be able to rename a file 
to a name containing unicode characters such as the Euro Symbol. Renaming to a short 
name does not remove the long name; its case is stored in this place for example. 

Syntax: LREN [drive:][path\]filename newfilename [/?]

Example: C:\TEMP>LREN "An important file.txt" "Not so important any more.txt"

         C:\TEMP>


2.5 LCOPY
---------
This command copies one or more files to any destination. You can use wildcards (?,*) 
to select more than one file. If files already exist in the destination directory the 
user is prompted if to proceed. This prompting can be turned off with the /Y switch. 
If the targetfile is read-only, hidden or system the file is not copied by default. 
To overwrite even those files, use the switch /R. The DOS 8.3 name is used for the 
target file if possible. If however a file with that name already exists a new unique 
8.3 alias is created. When copying from CD a new 8.3 name is generated by default. 
However by specifying the /K switch LCOPY will use the short name provided by the CD 
file system. If the destination is omitted the current drive and directory are used. 
The switch /S copies also all subdirectories with their contents. The /E switch 
prevents that empty directories are copied. When using the /D switch together with /S 
all matching files in all subdirectories are copied (collected) to the same 
destination directory and no subdirectories are created. The switch /A copies also 
hidden files. If /A and /S are combined even hidden directories are copied. With the 
/C switch you can turn off the cache. This will slow down the whole thing a bit, but 
consumes less memory (~128 KB). If you have a memory manager like EMM386 installed 
LCOPY tries to use extended memory (EMS and XMS) for the cache. This improves 
performance on huge directories but is slightly slower with short ones. If you prefer 
not to use extended memory use the /V switch. You can abort the operation by pressing 
any key. [The "any" key is the space bar ;-)] The /B switch turns off this feature. 
The /I and /T switches are for CD-ROM only. /I forces LDIR to use ISO file system 
rather than Joliet. /T must be followed by the number of a data track. The track 
number identifies which session to use. When /T is absent the last session recorded 
is used. Use LCHK to display valid track numbers. 

Note: When copying files from CD-ROM to hard drive, read-only attribute is NOT set by 
default. 

Syntax: LCOPY [drive:][path\]sourcefile [drive:][destination] 
[/?][/S [/D]][/E][/A][/C][/V][/R][/Y][/B][/I][/Tn]

Example: C:\TEMP>LCOPY "*.text" A:\BACKUP\
         A Secret.text
         An important.text
         2 file(s) copied

         C:\TEMP>LCOPY "A Secret.text" "D:\WEB\Now A Public.text"
         A Secret.text
         1 file(s) copied

         C:\TEMP>LCOPY C:\WINDOWS\* "D:\WRECKED SYSTEMS" /A /S /B

The last line would copy the entire operating system to another directory. You are 
not allowed to abort the operation.

C:>LCOPY . D:\ /S

The last line would copy the directory structure only (no files). With switches /S 
LCOPY always mirrors the directory structure, even if no matching file is found.

C:\>LCOPY *.ZIP C:\ARCHIVES /S /D

The last line would copy all zip files on drive C to the directory \ARCHIVES. No 
subdirectories are created.

2.6 LMD
-------
This command creates a new subdirectory (folder).

Syntax: LMD [drive:][path\]newdir [/?]

Example: C:\>LMD "Backup Folder"
         Ok.
         C:\>LCD Backup*
         C:\BACKUP~1>D:
         D:\>LMD "C:Apr 1,1999"
         Ok.

This creates a new Folder called "Apr 1,1999" in "Backup Folder" on drive C.

2.7 LRD
-------
This command removes a subdirectory (folder).

Syntax: LRD [drive:][path\]dirname [/?]

Example: C:\>LRD "Backup Folder"
         Ok.

2.8 LCHK
--------
This command displays information about a disk. This information is taken from the 
disk's boot sector. This command works on CD-ROMs as well. It displays detailed 
information on how many tracks (sessions) are on the CD-ROM. Use the track numbers 
displayed for the /T switch of LCOPY, LDIR and LCD.

Syntax: LCHK [drive:]

Example: C:\>LCHK D:
Version 1.41
Copyright (C) 1999 Ortwin Glueck
This is free software under GPL. See the readme file for details.

DOS Version: FF-7.10
Drive: 3
Bytes per Sector: 512
Sectors per Cluster: 8
Reserved Sectors: 32
Number of Clusters: 917916
Number of FATs: 2
Number of Root entries: 0
Media Descriptor: f8
Sectors per FAT: 7179
Sectors: 7357707
First Data Sector: 14390
First Root Sector: 14390
First Root Cluster: 2
Root Sectors: 0
Fat entries per Sector: 128
Label:
File System: FAT32
FAT32 compatible disk access enabled
Volume locking enabled

3. Known bugs and features
--------------------------

- LDIR "D:\My Files\" does not work as expected. Leave away the last backslash. Dos 
seems to convert \" into a quotation mark (") at the very end.
- The DOS command line can not exceed 127 characters! (use asterix to abbreviate 
directories). Even batch file command lines will only pass 126 characters!
- You can not use LCOPY to create a file whose name equals the drive label in the 
drive's root directory. This is a DOS limitation. The LABEL command of DOS prior to 
6.22 can destroy long filenames. [MS KB Q118493]
- Only Unicode characters from codepages 00h and 25h are translated. Unknown 
characters are converted to underscore (_). May cause non-unique filenames!
- LRD: You can remove the current working directory without notice.
- If a disk's boot record reports a wrong FAT format, FAT is corrupted (lcopy, lmd, 
lrd). This can especialy happen on (old) wrong formatted floppy disks. Check the 
filesystem with the LCHK tool first. 1.44MB-Diskettes should always be FAT12.
- FAT32: Only the first copy of the FAT is used for reading. Changes are ALWAYS 
written to all copies (mirroring).
- FAT32 hard drives can only be accessed if the DOS version supports FAT32. Otherwise 
the drive is not assigned a drive letter. Use a Win98 or Win95B boot diskette.
- CD-ROMs can only be accessed if a CD-ROM driver is loaded (MSCDEX). Otherwise the 
drive is not assigned a drive letter.
- I have made a short test with IDE-ATAPI Iomega ZIP drives. LFN Tools seem to work 
fine on them. However one user reported problems when writing which I could not 
reproduce.
- Network drives are not supported.
- When using the virtual memory cache (default) you need to load himem.sys and 
EMM386.


4. Where can I report bugs and get an updated version?
------------------------------------------------------
Any comment is to be sent to the e-mail address supplied on my homepage. I speak 
German and English.
Odi's LFN Tools are still under light development. So be sure to check for a newer 
version every 6 months or so. Type LCHK to find out what version you have.
Get the latest version from WWW: http://www.odi.ch/

5. FAQ
------
Q: Can LFN Tools access a network drive?
A: No. LFN Tools need physical access to individual sectors of the drive. This is not 
supported by DOS network drives.

Q: I have problems with my home burned CD-Rs. I cannot see long filenames.
A: Learn how to use your CD recording software and read about CD-ROM standards. You 
might have burned a darkgreenwithyellowspots-book CD.

Q: I would like to support your work with my money.
A: Please read the "Donations" Section.

Q: I have programmed a DOS utility. Could you convert it to handle long names?
A: Definitely not! Fix it yourself. You have the LFN source code.

Q: When trying LCOPY c:\*.* d:\ not all files are copied.
A: Use * instead of *.* and RTFM.

Q: I need a 16-bit compiler in order to compile your source code.
A: You must use Microsoft Visual C++ v1.51! Write to a newsgroup and ask for it. You 
will certainly find a person who owns an old CD-ROM. You could use some Borland C++ 
5.0 too, but this requires sophisticated modifications of the code. The vmemory 
library is by Microsoft and usually not included with compilers other than MS.

Q: Please place your program on my website and inform me about new releases.
A: Please do that yourself! You are allowed to. Check back to my website every 3 
months.

Q: I lost all my data after using your tools.
A: Sorry for that. Backup important data regularly. I do not guarantee that the 
software works always and everywhere. Please let me know what EXACTLY you did. See 
section 4.

6. Donations
------------
You can support LFN Tools by donating a small amount of money. Please log on to 
http://www.paypal.com/ and create an account. Send your donation to the following 
Email Adress: odi@odi.ch


7. License
----------
This is free software under the GNU General Public License. No warranty. Source code 
(MS-C++) available on http://www.odi.ch/. If you can not compile the code with your 
favourite compiler this is YOUR problem. I can not help you compile the code.
See the license.txt file included in the ZIP archive.

8. Acknowledgements
-------------------
I would like to say thank you to:

Marcin Frankowski (NZ) for Latin-2 support
Geert Keteleer for valuable help and the cars :-)
Kurt Salentin for the debugging
Milan Stanik
Wolf Bartels
Silvio Vernillo
Alfred Schumann
Ralph E. Griffin 
Herbert Schmidt, Martin Kunkel for the key hints on the bootable CD problem
Martin Kunkel for his digging in my code
Frank Littmann, Mario Latzig for hints on filename problem with Joliet
(Odi can't code...)
Bill Hall for some good hints
Isy for two bug reports
64.245.58.28 for cool sound (R.I.P.)
H. Ellenberger for the bug report in 1.42
Benjamin Wells for his note on LCOPY *.TXT C:\FUN /S
Mark Marinac for his hints on ZIP drives and compression
Michael Marquart for the hint on DOS 6 and extensive testing
Leanne & Walt Smith for the IBM PC-DOS testing
Gordon Chaffee for Unicode support (Linux kernel)
The Linux people who helped me out with the ISO structs
