;Lange Dateinamen unter nacktem DOS
;Noch zu tun:
;* UnterstÅtzung von SektorlÑnge 128..4096 Bytes
;* Umbenennen gleiche Datei
;* korrektes Lîschen mit Wildcards
;* HeapWalker

;N: Most Protected Mode DOS extenders doesn't translate the LFN API to
;   Real Mode. (When running Windows9x, Windows makes that task, effectively
;   disabling the DOS extender.)
;   For DPMI programs, it is up to the programmer to translate these DOS
;   calls to Real Mode, using DPMI services at INT31. Best solution would
;   be a DLL that makes this task at load time, hooking the protected mode
;   INT21 chain.
;   When running Windows3 in Enhanced Mode,
;   DOSLFN auto-loads an LFNXLAT.386 VxD that translates these APIs.
;   With this VxD, there is no need for translation for Windows programs.
;   Unfortunately, Win32s programs cannot see long file names,
;   unless someone publish a great patch of one Win32s DLL.
;   The rarely used Standard Mode should be configured to load the DLL
;   (above mentioned) at startup - but DOSLFN requires a 386 itself.
	%NOLIST
	include	prolog.asm
public COMentry		;damit's mit SoftICE klappt
	P386
	JUMPS
REQfunc		equ	7146h		;in AX
REQcode		equ	9877h		;in DX
ANScode		equ	8766h		;in AX; DX=Segmentadresse
DEFHEAPSIZE	=	1000	;fÅr einige FindInfos
DEFHEAPSIZE_CD	=	2000	;dazu eine durchschnittliche .JLT-Datei
FDChangeTime	=	3*18 ;Neue DPB einlesen nach 3 Sekunden InaktivitÑt
CDChangeTime	=	7*18 ;dauert naturgemÑ· viel lÑnger,
	;auch das Einlesen der ersten CD-Sektoren und der Link-Tabelle
macro INT3
ifdef DEBUG
	INT 3
endif
endm

USEOLDDOS	=	1	;1 to enable LFN filtering on legacy find fns
USEWIN		=	1	;1 to enable Windows recognition code
USECP		=	1	;1 to enable codepage changing
USEDBCS 	=	1	;1 to enable double-byte character sets
USECE		=	1	;1 to enable use of CeQuadrat link table
USEWINTIME	=	1	;1 to enable real Win <-> DOS time conversions
USEXP		=	1	;1 to enable reading of XP lowercase 8.3 names

USEFREESPC	=	0	;1 to enable DPB free space writing
;In MS-DOS 7, writing directly to disk causes the free cluster count to become
;unknown. For large drives or frequent calling, this introduces a noticeable
;slowdown. Fortunately, there is a function to set the free cluster count.
;Enabling the above feature will: get the extended DPB, write to disk, and
;restore the free space from the DPB. Do not enable this feature if the
;extended functions are not available (Int21/AX=730[245]).

;********************
;** DOS structures **
;********************

struc tExDPB		;structure returned by INT21/AH=32, valid: DOS 4.0+
 Drive  db	?	;{0=A}
 UnitNo db	?	;number of device driver unit
 SecLen dw	?	;{Bytes pro Sektor}
 HiSec  db	?	;{Anzahl Sektoren pro Cluster -1, 2**n-1}
 Shift  db	?	;{Verschiebung n}
 ResSec dw	?	;{Reservierte Sektoren am Anfang des Laufwerks}
 FATs	db	?	;{Anzahl der FATs}
 RootEn dw	?	;{Anzahl WurzelverzeichniseintrÑge}
 UsrSec dw	?	;{1. Sektor mit Userdaten}
 HiClus dw	?	;{Anzahl Cluster -1}
 SecFAT dw	?	;{Sektoren pro FAT}
 SecDir dw	?	;{Sektornummer 1.Dir}
 unused db	5 dup (?) ;Luft zum FAT32-DPB, der beginnt ab Ofs.24
			;from here starts extended trail from INT21/AH=73
 dpb_flags		db	?
 next_dpb		dd	?	;Pointer
 start_search_cluster	dw	?
 free_clusters		dd	?
 mirroring		dw	?
 file_system_info_sector dw	?
 backup_boot_sector	dw	?
 first_sector		dd	?
 max_cluster		dd	?
 sectors_per_fat	dd	?
 root_cluster		dd	?
 free_space_cluster	dd	?
 filler			db	?	;"gerade" StrukturlÑnge!
ends

struc tRWRec		;DOS structure for reading and writing sectors
 sect	dd	?	;sector number, allowing partitions up to 2 Terabyte
 numb	dw	?	;sector count
 addr	dd	?	;FAR address of sector data
ends

struc TSearchRec	;DOS legacy search record, returned at INT21/AH=4E&4F
;N: All undocumented fields are not used to maintain compatibility with
;   non-MS clones of DOS or some TSRs
 Drive	db	?	;bit7 set at network drives and FAT32, undocumented
 SName	db 8 dup (?)
 SExt	db 3 dup (?)
 SAttr	db	?
 DirNo	dw	?
 union
  struc
   Clus	dw	?
   Res	dd	?
  ends
  struc
   Clus32 dd	?	;on FAT32
   DirNoHi dw	?	;eventually high part of DirNo?
  ends
 ends
 Attr	db	?	;here the documented part begins
 Time	dd	?
 fsize	dd	?
 FName	db 13 dup (?)	;in DOS form, with dot if extension follows
ends
;N: Length "undocumented" = 21 bytes, "documented" = 22 bytes

struc TW32FindData	;DOS new and Win32 search record, at INT21/AX=714E&4F
;N: This is the same structure as WIN32_FIND_DATA, but file names will return
;   in OEM character set rather than ANSI
 attr	dd	?	;bits 0..6: like DOS, bit 8: temporary (not used)
 timec	dq	?	;file creation time	FAT stepping: 10 ms
 timea	dq	?	;last access time	FAT stepping:  1 day
 timem	dq	?	;last modification time	FAT stepping:  2 s
			;On CDFS, all times have 1 s stepping
 sizeh	dd	?	;(not used) high part of file length (in wrong order)
 sizel	dd	?	;file length (FAT, CDFS: up to 2GB)
 res	dq	?	;maybe compressed file length? inode number? security?
 lname	db 260 dup (?)	;long name (LFN), alone if short
 sname	db 13 dup (?)	;short name (SFN), also called "alias"
ends

struc tErrInfo		;for Set_Error_Info INT21/AX=5D0A DS:DX=pointer
 err_AX	dw	?
 err_BX	dw	?
 err_CX	dw	?
 err_DX	dw	?
 err_SI	dw	?
 err_DI	dw	?
 err_DS	dw	?
 err_ES	dw	?
 res	dw	?
 cid	dw	?	;computer ID (0 for localhost)
 pid	dw	?	;process ID (same as PSP)
ends

struc tWinStart		;Format of Windows (W3) Startup Information Structure
 ver_major db	?	;major version of info structure (3)
 ver_minor db	?	;minor version of info structure (0)
 next	   dd	?	;pointer to next tWinStart structure or 0000h:0000h
 vxd_fname dd	?	;pointer to ASCIZ name of virtual device file or zero
 vxd_rdata dd	?	;virtual device reference data
 idata	   dd	?	;pointer to instance data records
ends

;*************************
;** FAT/CDFS structures **
;*************************

struc tDirEnt	;legacy directory entry on FAT media (FAT12, FAT16, FAT32)}
		;source: Ralf Brown Interrupt List, SIZE=32
;N: First character (byte) has special meaning:
;   00: no more following DirEnts (a new cluster will be filled with zeroes)
;   05: first character is E5
;   E5: deleted entry, undeleted DirEnts may follow
 FName 	db	11 dup (?)	;FCB form without dot, upper-case letters
 Attr   db	?
 resv   db	?	;Win95: Null (maybe high part of file size)
 timeC10ms db	?	;Win95: 10ms additional value to timeC [0..199]
 timeC	dd	?	;Win95: creation time (all local time)
 timeA	dw	?	;Win95: last access date
 ClusH  dw	?	;FAT32: high part of first cluster
 timeM  dd	?	;modification time
 ClusL	dw	?	;first cluster, FAT32: low part of first cluster
 fsize	dd	?	;file size
ends

struc TLfnDirEnt	;FAT LFN directory entry structure, SIZE=32
;N: The NameX protions of this structure are not directly used;
;   they are addressed by "LODSW" and the gaps skipped by "ADD SI,space"
 count	db	?	;Bit 0..5: number (1+), Bit 6=last entry
 Name1	dw 5 dup (?)	;five Unicode name characters
 Attr	dw	?	;always 000Fh
 check	db	?	;SFN checksum link
 Name2	dw 6 dup (?)	;six Unicode name characters
 Clus1	dw	?	;always zero
 Name3	dw 2 dup (?)	;two Unicode name characters
ends

struc TCD_DirEnt	;CD (ISO and Joliet) directory entry structure
;N: A bunch of entries are ignored, SIZE>=34
 r	db	?	;the number of bytes in this record
 ea	db	?	;number of sectors in extended attribute record, zero
 sect	dd	?	;Logical Block Number of file start
 sectm	dd	?	;same for Motorola
 fsize	dd	?	;file or directory length in bytes, always divisable
			;by sector size (2048) for directory length
 fsizem	dd	?	;same for Motorola
 year	db	?	;years past 1900 (all local time)
 month	db	?	;1 = January
 day	db	?	;1 = 1.
 hour	db	?	;0..23
 minu	db	?	;0..59
 seco	db	?	;0..59, mostly an even number(?)
 tz	db	?	;time zone of local time, signed, 15min, +east, -west
 flags	db	?	;attributes, Bit0=hidden, Bit1=Dir, Bit7=more DirEnts
			;(Bit 7 is not correct on most CDs)
 isiz	db	?	;for interleaving, unused
 igap	db	?	;for interleaving, unused
 vsn	dw	?	;volume sequence number, unused
 vsnm	dw	?
 fnamelen db	?	;file name length in Bytes (always even if Unicode,
			; except for "." and ".." entries)
 fname	db	?	;file name (Motorola byte order if Unicode)
ends

;********************************
;** DOSLFN internal structures **
;********************************
;N: These structures are used inside DOSLFNs heap

;== part 1: DriveInfo data ==
IF 0
;bits for following <dtype>
DTM_mask	=7	;lower three bits are for general mode switch
DTM_FB		=0	;no bit set if FallBack
DTM_FAT		=1	;001 if FAT mode
DTM_ISO		=2	;010 if ISO mode
DTM_JOL		=3	;011 if Joliet mode, other codes are for future:
DTM_PT		=4	;100 PipeThrough (For this drive, there is an
			;    underlying LFN API, e.g. NTFSREAD)
;DTM_X		=5	;101 extfs2 (Linux) via LTOOLS
;DTM_UDF	=6	;110 UDF (Universal Disc Format, DVD)
;DTM_LFNBK	=7	;111 LFNBK file based LFN support - or some network
DT_Joliet	=1	;if not, take LFNs from ISO (these may also be long)
DT_CDFS		=2	;bit 1 acts as CDFS switch too
DT_BigDos	=8	;use extended INT25/26 interface
DT_FAT16	=16	;FAT quantity, otherwise, it's FAT12
DT_FAT32	=32	;don't use INT25/26, use INT21/AH=73 instead
;DT_SmartOS	=64	;set if OS already remove LFNs (MS-DOS7+) - no dtype!
DT_Locked	=128	;set if drive was locked (for writing, MS-DOS7+)
;N: Depending on DTM_mask'ed value if <dtype>, DOSLFN works in nearly
;   complete different modi
;   * FAT mode for diskettes and hard drives (even a ZIP drive uses FAT)
;   * CD mode (rarely used) for ISO CDs with "long" ISO file names
;   * Joliet mode, typical for Windows9x CDs
;   * fall-back mode for all other drives
;     This mode does not only map LFN_FindFirst/Next to its
;     legacy companion, it also makes the extended pattern matching.
;     Equally, LFN_Delete may delete multiple files using wildcards
;     calling "legacy delete" multiple times.
;     From the view of a programmer, it is very nice to have an LFN API
;     on _all_ drives, and there is no need to make ugly cases.
;     Note that also Win9x does wrap e.g. DOS network drives (Novell Lite)
;     with its LFN API - therefore, FallBack is a "must" for compatibility.
;     However, it conflicts with actual versions of NTFSREAD.
;   Another useful mode would be an LFNBK mode, simply using a file
;   for keeping long file names - this would instantly work on all drives.

struc TDI_FAT
 shift   db	?	;shift count for sector->cluster
 shift2  db	?	;shift count for byte->sector (always 9)
 fatsec	 dd	?	;first sector of active FAT
 dirsec  dd	?	;sector of root directory
 usrsec  dd	?	;sector of first cluster (ie cluster # 2)
 lastsec dd	?	;last valid sector of user data
ends
ENDIF

struc TDI_ISO
 voldesc dd	?	;volume descriptor
 rootdir dd	?	;root directory sector
 rootlen dw	?	;count of root directory sectors
ends

struc TDI_JOL
 isotree TDI_ISO <?>	;same as above
 joltree TDI_ISO <?>	;same as above for the Joliet tree
 linktbl dw	?	;pointer to link table (keep trees together)
ends

IF 0
struc TDI		;linked structure for all media ("Drive Info")
 next	dw	?	;NEXT pointer into LocalHeap, zero if last
 prev	dw	?
 time	dw	?	;for discarding after a while (removable media only)
 drive	db	?	;drive number (0=A:)
 dtype	db	?	;control flags (DT_xxx constants)
 secsiz	dw	?	;sector size (DOSLFN is able to process any size?)
 union
  fat TDI_FAT	<>	;additional data for FAT media
  iso TDI_ISO	<>	;additional data for ISO media
  jol TDI_JOL	<>	;additional data for Joliet media
 ends
ends
;N: drive information is kept in a cache of 2..4 entries. Otherwise,
;   copy actions (between different drives) would often retrieve the
;   drive info, and clumsy-DOS seems to always read in boot area
ENDIF

;== part 2: SectorCache data ==
IF 0
struc TSC		;linked "sector cache" entry; sector data follows!
 next	dw	?	;NEXT pointer into LocalHeap, zero if last
 prev	dw	?
 secnum	dd	?	;sector number (of first sector)
 count	db	?	;sector count (always 1)
 drive	db	?	;drive number (0=A:)
 dirty	dw	?	;16 "dirty" (="modified") bits for up to 16 sectors
ends
;N: sector data is held in cache because MS-DOS doesn't cache anything,
;   even when SmartDrv is loaded, when direct disc access is detected.
;   Especially CD access is too slow without internal cacheing of at least
;   two sectors. The LocalHeap is used up for cacheing until no more
;   memory is available. All other memory allocations free least-recently
;   used SectorCache entries to get necessary space.
ENDIF

;== part 3: FindHandle data ==

struc TFI_FAT		;size=6
 entry dw	?	;offset from start of sector to current DirEnt
 sect  dd	?	;sector number of current DirEnt
ends

struc TFI_ISO		;size=8
 entry dw	?	;offset from start of sector to current DirEnt
 sect  dd	?	;sector number of current DirEnt
 count dw	?	;number of sectors to end of directory
ends

struc TFI_JOL		;size=22
 i	TFI_ISO	<>	;same as above
 j	TFI_ISO	<>	;same for Joliet tree
 restart dd	?	;search-restart SFN sector
 restlen dw	?	;search-restart SFN directory length
ends
;N: For Joliet, many additional fields are necessary to make a round-robin
;   SFN match possible. Searching is primary done with LFN, and then
;   the next matching SFN will be taken. If no such SFN is found, searching
;   restarts at start of directory (using <restart> and <restlen> fields)
;   until found. If there is no match too, simply the following entry
;   is used. A match is when two DirEnts have the same start sectors
;   (if file) or matching start sectors (via LinkTable, if directory).
;   This complicated processing is necessary because entry order of LFN
;   and SFN entries are not always the same.
;   Limitation of <count> to a word seems to be not so bad; if some dude
;   reach it, he has more than 500 000 files in one directory

struc TFI_FB		;size=21
 dta	db 21 dup (?)	;space for undocumented DTA part
ends

struc TFI		;interal representation of FindHandle ("FindInfo")
 magic	db	?	;MagicByte (to detect invalid handles)
 drive	db	?	;drive number (0=A:)
 attr	dw	?	;Search (LowByte) and MustMatch (HighByte) attributes
 union
  fb  TFI_FB	<>	;additional for FallBack
  fat TFI_FAT	<>	;additional for FAT
  iso TFI_ISO	<>	;additional for ISO
  jol TFI_JOL	<>	;additional for Joliet
 ends
 fflags	db	?	;file flags (only DotAtEnd flag is used)
;N: fflags cannot be adressed easily. Structure fill and read-out
;   is intended using LODSx and STOSx, respective.
;N: The file match pattern follows, but if it had a dot (.) at end,
;   these dot is stripped from pattern and DotAtEnd flag is set
;   due to special meaning of such a pattern
;N: For FallBack, also the file match pattern follows, but is only
;   necessary if File_Flag_Is_LFN or _Char_High bits are in fflags
ends

IF 1
struc tFindInfo		;als interne ReprÑsentation von FindHandle
 usage	db	?	;MagicByte
 drive	db	?	;Laufwerk
 attr	dw	?	;Attribute
 entry	dw	?	;Eintrags-Nr. (DirEnt-Zeiger)
 sect	dd	?	;Sektor-Nummer
ends

struc tFB_FindInfo
 usage	db	?	;ein anderes MagicByte
 undoc	db	21 dup (?)	;"undokumentierter" DTA-Bereich
 mmattr	db	?	;Attribut (CX beim Aufruf)
 fflags	db	?	;(nicht mehr wesentlich: File_Flag_DotAtEnd)
			;anschlie·end: Maske
			;(nur nîtig wenn File_Flag_Is_LFN oder Char_High)
ends
MAGIC_hFind	=0ACh	;Magic-Byte fÅr gÅltiges Find-Handle
MAGIC_FB_hFind	=0ADh	;dito fÅr RÅckfallmodus

ENDIF

;== part 4: FastOpen data ==
IF 0
struc TFO		;linked structure for FastOpen
 next	dw	?
 prev	dw	?
 drive	db	?	;0=A:
ends
;N: FastOpen is absolutely necessary for reasonable speed.
;   For multi-drive and copy-on-single-drive support, FastOpen
;   is now organized as a cache with multiple entries.
ENDIF
;== done with the 4 parts ==

;N: All caches are organized as linked lists with most-recently used
;   entries on head and least-recently used entries at tail of the lists.
;   A cache hit moves the matched entry onto queue's head and updates
;   the time stamp. Otherwise, a new structure is put onto head, and
;   trailing entries may discarded to maintain maximum entry count
;   (for drive info and FastOpen) or to get room (for sector cache).
;   Because moving-to-head is done at access, and DOSLFN must not be
;   reentered, static list pointers are also work area pointers.

;bits for main function control byte <ctrl0>
CTRL_Main	=bit 7	;main switch whether DOSLFN is active or turned off
CTRL_Write	=bit 6	;allow write access (except for DELETE/UNLINK/MOVE)
CTRL_Tilde	=bit 5	;tilde usage (HKLM/.../NameNumericTail)
CTRL_Tunnel	=bit 4	;tunnel effect
CTRL_CDROM	=bit 3	;CDROM support (default is ON if MSCDEX was loaded)
CTRL_InDOS	=bit 2	;InDOS flag and RESET drive usage
CTRL_RoBit	=bit 1	;write-protect attribute for CDROM files (like NORO)
CTRL_SmartOS	=bit 0	;"smart" (LFN entry deleting) DOS (MS-DOS7) detected

;**********************************
;** static variables in PSP area **
;**********************************
;N: "Program Segment Prefix" area is used to reduce memory consumption
;   of DOSLFN. Area before 5Ch is apparently used by some DOS extenders.
;   Because DOS is not reentrant, LFNDOS doesn't need to be reentrant,
;   therefore, these handy variables and buffers are allowed and usable.

		org	5Ch
argv0		dw	?	;points to heap
argv0file	dw	?	;points behind last backslash, 13 bytes space
;60h
LocalHeap	dw	?	;zeigt auf Anfang des Heaps
TrailMinLen	dw	?	;TrailByte: Minimum und Anzahl
DriverChain	dd	?	;Zeiger ins DOS auf Treiber-Kette
lead_byte_table	dd	?	;Zeiger ins DOS fÅr FÅhrungsbyte-Bereiche
uppercase_table	dd	?	;Zeiger ins DOS fÅr Zeichen >=80h
		;Offset ist um 7Eh vermindert fÅr direktes XLAT
;70h
CurSector	dd	?	;current "working" sector
longpos_s	dd	?	;internal, set by Locate_DirEnt (FAT)
longpos_a	dw	?	; -"-
CurPathComp	dw	?	;Momentan "aktive" Pfad-Komponente oder Maske
DPB_Shift	db	?	;{Verschiebung fÅr Sektoren pro Cluster}
DPB_Drive	db	?	;{Drive Parameter Block: Laufwerk, 0=A}
DriveType	db	?	;{Schalter fÅr Festplatten-Zugriffsart}
DT_Joliet	=bit 0		;Wir haben Laufwerks-Info (for CD)
DT_FAT12	=3		;FAT12/16/32 = number of nibbles
DT_FAT16	=bit 2		;wegen FAT-Zugriff
DT_FAT32	=bit 3		;grî·ere énderungen (kein INT25/26)
DT_CDFS		=bit 4		;genauer: Joliet
;DT_Int2526	=bit 5		;wenn Int21/AX=7305 (SmartDrv) nicht geht
DT_Locked	=bit 6		;wenn geschrieben wurde (MS-DOS7+)
DT_Dirty	=bit 7		;Sektor muss geschrieben werden!
;In AbhÑngigkeit von DriveType arbeitet das Programm genaugenommen
;in 3 Modi (mehr sind nicht allgemein machbar):
;* FAT-Modus fÅr Disketten und Festplatten
;* Joliet fÅr Windows9x-typische CDs
;* RÅckfallmodus fÅr alles andere: LFN_FindFirst u.a. wird mittels "normaler"
;  Funktionen nachgebildet (wie es sonst jedes Programm zu Fu· tun mÅ·te,
;  und das ist beim Programmieren nervenaufreibend, verflixte DTAs und
;  das erweiterte Globbing)
;Sehr nett wÑre ja noch ein "Netzwerk-Modus", bspw. per NFS oder DOS-Samba,
;aber wer liefert mir den Quelltext?
;Weiterhin ein "lfnbk"-Modus, mit Abbildung der langen Dateinamen Åber
;eine regulÑre Hilfsdatei
LFN_DirEnts	db	?	;Anzahl DirEnts beim Schreiben des LFN

;This command-line area must not contain variables that initialize at startup
;80h - following 32 bytes are used (at least) three times!
ErrInfo		TErrInfo	<>	;overloads following
		org	80h
FCB_Name	db  11 dup (?)	;used for building unique file name
				;Never contains 05h as first byte
ShortName	db  13 dup (?)	;filled by (CD_)Locate_DirEnt
;here we have 8 bytes room - temporary needed for reading ISO file names
		org	80h
DirEnt_Copy	TDirEnt	<>	;32 bytes space for moving FAT DirEnt while
				;inserting LFN, may have 05h as first byte
;A0h
DPB_FAT1Sec	dd	?	;FAT: Startsektor 1. FAT
DPB_DirSec	dd	?	;{Sektor Hauptverzeichnis (nur FAT)}
DPB_UsrSec	dd	?	;{Sektor des 1. Clusters (mit Nr. 2)}
DPB_LastSec	dd	?	;{Letzter Sektor der Partition}
;B0h
union TMedium
 jol	TDI_JOL	<>	;all specific medium Information
ends
Medium	TMedium	<>

union TSearch
 jol	TFI_JOL	<>	;all file find information
ends
Search	TSearch	<>

SearchAttr	dw	?	;Such-Attribut, enthÑlt im Low-Teil
	;die invertierten Attribut-Flags und im High-Teil die
	;Must-Match-Attribute. Das Attribut 88h dient (spÑter) dem
	;Aufsuchen gelîschter EintrÑge wie bei Novell-DOS
MatchPtr	dw	?	;"Virtuelle" Methode Match&Stop
SuchSektor	dd	?	;fÅr gegenseitige Suche auf Joliet-CD
	;auch: Start-Sektor Ziel-Vrz. bei mkdir, creat und move
num_cluster	dw	?	;Anzahl Cluster fÅr Verzeichnis

subst_root	dw	?	;Anzahl Zeichen fÅr SUBST
		;in Truename: Zeiger in LongBuffer, normal LongBuffer+2
throw_fi	dw	?	;Zeiger auf Exit-Behandlung (wegen lfn_move)

shortbuffer	dw	?		;Puffer fÅr kurze 8.3-Dateinamen
shortbuffer3	dw	?		;[shortbuffer] + 3
longbuffer	dw	?		;Zwischenpuffer fÅr Zerlegung/TRUENAME
longbuffer2	dw	?		;[longbuffer] + 2
longbuffer_end	dw	?		;2 Bytes hier spart 6 Bytes im Code
longname	dw	?		;Puffer fÅr LFN von NextDirEnt()
longname_26	dw	?		;[longname] - 13*2
tunnel2 	dw	?;0	;Kopie fÅr MOVE-Vorgang (initialised at install)
;100h - three bytes for JMP are free for use
LastAccessTime	dw	?
subst_drive	db	?	;Zeichen, geSUBSTetes (virtuelles) Laufwerk

;Program Control Flag Byte Assignment:
PF_Fail_Uni2Oem	=bit 0		;Nicht zu OEM konvertierbarer Unicode-Name
PF_Follow	=bit 1		;Sektor-Verfolgung nach DirScan
PF_LFN_Input	=bit 2		;LongName-API Namensinterpretation
PF_Slash	=bit 3		;Entfernter Slash bei Gen_Alias
PF_Tunnel_Save	=bit 4		;save LFN before calling OldInt21
PF_Tunnel_Restore=bit 5 	;restore LFN after calling OldInt21
PF_Install_Short=bit 6		;install the shortname directory entry

;*****************************
;** Stack Frame Assignments **
;*****************************
;N: Due to complex data processing inside DOSLFN, it's not worth
;   to keep register data. Registers are pushed onto stack, and with setting
;   BP, these registers are easily available via stack frame, ie
;   BP and a small offset value, as defined below.
;   This technique is known from Windows VxD programming.
;N: Some bit registers are kept onto stack too, their bit-access consumes
;   one byte less op-codes than bit-access to a static variable.

File_Flags	equ	byte bp-6	;properties of last path component
FuncNum		equ	byte bp-5	;{properties of drive used}
Client_E_DX	equ	word bp-4	;high part of EDX (unreferenced)
Client_E_AX	equ	word bp-2	;high part of EAX (unreferenced)
Client_DI	equ	word bp		;frame of "pusha" op-code
Client_SI	equ	word bp+2
Client_BP	equ	word bp+4	;(unreferenced)
;Client_SP	equ	word bp+6	;free space for us - never popped
PFlags		equ	byte bp+6	;input control flags
ctrl		equ	byte bp+7	;program control flags
Client_BX	equ	word bp+8
Client_DX	equ	word bp+0Ah
Client_CX	equ	word bp+0Ch
Client_AX	equ	word bp+0Eh
Client_ES	equ	word bp+10h
Client_DS	equ	word bp+12h
Client_FS	equ	word bp+14h	;(unreferenced)
Client_IP	equ	word bp+16h	;(unreferenced)
Client_CS	equ	word bp+18h	;(unreferenced)
Client_Flags	equ	word bp+1Ah

Client_DXBX	equ	dword bp+8
Client_CXDX	equ	dword bp+0Ah	;CX=High, DX=Low, in einem Schlag
Client_AXCX	equ	dword bp+0Ch

Client_AL	equ	byte LOW  Client_AX
Client_AH	equ	byte HIGH Client_AX
Client_BL	equ	byte LOW  Client_BX
Client_BH	equ	byte HIGH Client_BX
Client_CL	equ	byte LOW  Client_CX
Client_CH	equ	byte HIGH Client_CX
Client_DL	equ	byte LOW  Client_DX
Client_DH	equ	byte HIGH Client_DX

;*******************************
;** Start of program and ISRs **
;*******************************
;N: Both Interrupt Service Routines (ISRs) are moved to start of .COM
;   image to reduce possible offset changes during development.
;   Offset changes made resident DOSLFN indeinstallable, and I had to reboot
	org	100h
	jmp	transient
ctrl0	db	11110110b		;8 Ein/Aus-Schalter
		;Bit7: global ein/aus
		;Bit6: Schreiben e/a
		;Bit5: Schlangen e/a
		;Bit4: Tunneleffekt e/a
		;Bit3: CDROM-Code vorhanden e/a
		;Bit2: InDOS-Benutzung
		;Bit1: Schreibschutz-Attribut fÅr CD e/a (NORO.COM GegenstÅck)
		;Bit0: SmartOS gefunden (lîscht LFN-EintrÑge selbstÑndig)

proc NewInt21 far	;Neue INT21-Routine
;D: Int21 handler, always returns with IRET, chaining to OldInt21
;   by jumping rather than calling preserves stack frame for odd-behaved
;   other APIs (if any)
;   Contains Installation Check of DOSLFN (maybe moved to Int2F)
	pushf
	 cmp	ax,REQfunc      ;Installationscheck?
	 jne	I21cont
	 cmp	dx,REQcode
	 jne	I21cont
	 mov	ax,ANScode
	 mov	dx,cs
	popf
	iret
endp

if USEWIN or USECP
proc NewInt2F far
;D: Because of dummies and for easier usage, DOSLFN (version 0.32j+)
;   traps Int2F for following actions:
; * Disables itself when Win9x starts, giving a hint message
; * Loads an API translating VxD "LFNXLAT.386" when Win3x starts
; * giving a warning message pointing to missing API translation
;   when Win3x or Win2x start in Standard Mode (=PM286)
; * Loads the appropriate OEM<->Unicode conversion table when
;   NLSFUNC changes the code page
; * Future Installation Check of DOSLFN may reside here
	pushf
if USEWIN
	 cmp	ax,1605h	;Windows Enhanced Mode Init Broadcast
	 jz	@@handle
	 cmp	ax,1606h	;Exit Broadcast
	 jz	@@handle
endif ;USEWIN
if USECP
	 cmp	ax,1401h	;NLSFUNC.COM CallOut BX=Codeseite
	 jz	@@handle
;	 cmp	ax,0AD01h	;DISPLAY.SYS API Aufruf BX=Codeseite
;	 jz	@@handle
endif ;USECP
@@e:	popf
	JMPF		;= db 0EAh
OldInt2F dd	?
@@handle:
	popf
	pushf
	call	[cs:OldInt2F]
	call	HandleWindowsOrCP
	iret
endp
endif ;USEWIN or USECP

proc I21cont far
	 test	[cs:ctrl0],CTRL_Main
	 jz	@@isrend	;do nothing if main switch is OFF
	 xchg	ah,al		;AL comparings are shorter
	 cmp	al,71h		;LFN functions?
	 je	@@yes_lfn
	 cmp	al,3Ah		;SFN rmdir?
	 je	@@yes_sfn	;remove LFN entry, prepare tunnel!
	 cmp	al,41h		;SFN unlink?
	 je	@@yes_sfn	;remove LFN entry, prepare tunnel!
	 cmp	al,56h		;SFN move? (dst=ES:DI)
	 je	@@yes_sfn	;remove LFN, prepare&apply tunnel!
	 cmp	al,39h		;SFN mkdir?
	 je	@@yes_sfn	;apply tunnel!
	 cmp	al,3Ch		;SFN creat?
	 je	@@yes_sfn	;apply tunnel IF file doesn't exist
	 cmp	al,5Bh		;SFN create new?
	 je	@@yes_sfn	;apply tunnel!
	 cmp	ax,006Ch	;SFN extended open/create?
	 je	@@yes_sfn	;apply tunnel IF..., take DS:SI!
if USEOLDDOS
	 cmp	al,4Eh		;SFN FindFirst?
	 xchg	ah,al
	 je	@@filter0F	;filter out volume labels!
	 cmp	ah,4Fh		;SFN FindNext?
	 je	@@filter0F	;filter out volume labels too!
	 cmp	ah,11h		;FCB FindFirst?
	 je	@@FCB_11	;filter out volume labels!
	 cmp	ah,12h		;FCB FindNext?
	 je	@@FCB_12	;filter out volume labels too!
else
	 xchg	ah,al
endif
@@isrend:	popf
		JMPF		;jmp far (db 0EAh)
OldInt21	dd	?	;only this kind of jump makes no trouble

if USEOLDDOS
@@filter0F:	;bei FindFirst/FindNext RÅckgaben mit Attribut 0Fh auswerfen
	popf
	call	sfn_find
@@cfiret:
	push	bp
	 mov	bp,sp
	 pushf
	  shr	[by bp+6],1	;shift out old value of carry
	 popf
	 rcl	[by bp+6],1	;rotate in new value
	pop	bp
	iret
@@FCB_11:
	popf
	call	sfn_find_FCB
	mov	ah,11h		;set back (may be altered to 12h)
	iret
@@FCB_12:
	popf
	call	sfn_find_FCB
	iret
endif

@@yes_lfn:
	 INT3
@@yes_sfn:
	popf			;save two bytes of stack needed
	xchg	ah,al
	call	IncInDosFlag
	sti			;reentrancy should be detected by caller
	push	fs ds es	;bp+14h .. bp+10h
	pusha			;ax=bp+0Eh, cx..dx..bx..sp..bp..si..di=BP+0
	 mov	bp,cs
	 mov	ds,bp
	 mov	es,bp
	 mov	bp,sp
	 push	eax		;High-Teile retten fÅr PKZIP
	 mov	al,[ctrl0]
	 mov	[ctrl],al	;access needs less bytes
	 pop	ax
	 push	edx
	  cld
	  mov	[throw_sp],sp	;prepare and beautiful error exit, less "jc"
	  mov	[throw_fi],ofs _fcb_retu	;standard finalizer
	  mov	fs,[Client_DS]	;hÑufig benîtigt
	  cmp	ah,71h
	  je	@@yes_long
	  mov	al,PF_Tunnel_Restore
	  cmp	ah,3Ah
	  je	@@rm
	  cmp	ah,41h
	  je	@@rm
	  cmp	ah,56h
	  jne	@@cr
	  mov	al,PF_Tunnel_Save or PF_Tunnel_Restore
	  ;jmp	@@cr
	  db	0a9h		;test ax,nnnn
@@rm:	  mov	al,PF_Tunnel_Save
@@cr:	  mov	[PFlags],al
	  call	sfn_process	;all writing SFN functions
	  jmp	__no_func
@@yes_long:
if USECP
	  call	CheckLoadCP
endif
	  mov	[PFlags],PF_LFN_Input
	  mov	[FuncNum],al
	  mov	di,ofs verteiler
	  call	case
	  jc	@@chain
	  inc	[counter_i2171]
	  call	[wo di]
__no_func:
	  jnc	@@no_ax
	  mov	[Client_AX],ax
@@no_ax:
ife USEOLDDOS
	  pushf
	   shr	[by LOW Client_Flags],1 ;CY ausschieben
	  popf
	  rcl	[by LOW Client_Flags],1 ;CY einschieben
endif
	 pop	edx
	 push	ax
	 pop	eax
	popa
	pop	es ds fs
	call	DecInDosFlag
if USEOLDDOS
	jmp	@@cfiret
else
	iret
endif
@@chain:
	;unrecognised function, pass it along to the OS (for Udo's DR-DOS
	;42h 64-bit seek function)
	mov	ax,[Client_Flags]
	mov	[oflags],ax
	pop	edx
	push	ax
	pop	eax
	popa
	pop	es ds fs
	call	DecInDosFlag
	push	1234h
oflags = wo $-2
	jmp	@@isrend
endp

proc Check_CDFS_Throw
	call	Check_CDFS
	jnz	SetErr5
	ret
endp

;THROW-Geschichten...
SetErr18:
	mov	al,18
	db	0B9h		;mov cx,nnnn
SetErr5:
	mov	al,5
	db	0B9h		;mov cx,nnnn
SetErr3:
	mov	al,3
	db	0B9h		;mov cx,nnnn
SetErr2:
	mov	al,2
SetError:
;DOS-Fehler (fÅr Int21 AH=59h) setzen (fÅr momentanes PSP)
;TatsÑchlich benîtigt Win95 COMMAND.COM diese Funktion!
	mov	ah,0			;alles "kleine" Fehler
	push	ax
	 mov	di,ofs ErrInfo
	 mov	dx,di
	 stosw
	 mov	cx,(SIZE ErrInfo)/2 -2
	 xor	ax,ax
	 rep	stosw			;dazwischen lauter Nullen
	 mov	ah,62h
	 call	CallOld			;PSP ermitteln
	 xchg	bx,ax			;als letztes
	 stosw
	 mov	ax,5D0Ah
	 call	CallOld			;Fehler setzen
	pop	ax
	stc
proc Throw
ifdef PROFILE
	call	throw_profile
endif
	mov	sp,8086
throw_sp = wo $-2
	call	[throw_fi]
	jmp	__no_func
endp

;***************
;** Profiling **
;***************
;N: use the Pentium time-stamp counter to provide timing information. Currently
;   setup to allow a profile to be enabled and disabled, but not vice versa.
;   Multiple profiles can be used, but there is no "child" information.
ifdef PROFILE
profile_ebx	dd	0

struc Tprofile
 count	dd	0		;number of times called
 ticks	dd	0		;tick count
 tick_h dw	0		;high word of tick count
 off	db	0		;enabled
 throw	db	0		;throw should disable
 start	dd	0		;start tick
 desc	db	16 dup (0)	;description
ends

profile_data = $
profile_read	Tprofile <,,,,,,'read sector'>
profile_write	Tprofile <,,,,,,'write sector'>
profile_exist	Tprofile <,,,1,1,,'exist'>
profile_install Tprofile <,,,,,,'install'>
profile_open	Tprofile <,,,,,,'open'>
profile_attr	Tprofile <,,,,,,'attr'>
;profile_	Tprofile <,,,,,,''>
ifdef PROFILECACHE
profile_putc	Tprofile <,,,,,,'put to cache'>
profile_termc	Tprofile <,,,,,,'terminate cache'>
profile_findc	Tprofile <,,,,,,'find in cache'>
endif
profile_stop = $

macro start_profile prof
	  push	ofs profile_&prof
	  call	_start_profile
macro end_profile
	  push	ofs profile_&prof
	  call	_end_profile
endm
endm
macro enable_profile prof
	mov	[(Tprofile profile_&prof).off],0
macro disable_profile
	mov	[(Tprofile profile_&prof).off],1
endm
endm

proc _start_profile
	mov	[profile_ebx],ebx
	pop	ebx		;return address (LO) and profile parameter (HI)
	push	bx
	pushf
	rol	ebx,16
	cmp	[(Tprofile bx).off],0	;disabled?
	jne	@@e
	push	eax edx
	db	0fh,31h ;rdtsc
	mov	[(Tprofile bx).start],eax
	inc	[(Tprofile bx).count]
	pop	edx eax
@@e:	popf
	mov	ebx,[profile_ebx]
	ret
endp

proc _end_profile
	mov	[profile_ebx],ebx
	pop	ebx
	push	bx
	pushf
	rol	ebx,16
	cmp	[(Tprofile cs:bx).off],0	;disabled?
	jne	@@e
	push	eax edx
	db	0fh,31h ;rdtsc
	sub	eax,[(Tprofile bx).start]	;assume individual profiles are
	add	[(Tprofile bx).ticks],eax	;dword but overall
	adc	[(Tprofile bx).tick_h],0	;is 48-bit
	and	[(Tprofile bx).start],0 	;reset for throw
	pop	edx eax
@@e:	popf
	mov	ebx,[profile_ebx]
	ret
endp

proc throw_profile
	mov	bx,ofs profile_data
@@l:	cmp	[(Tprofile bx).start],0
	je	@@n
	push	bx
	call	_end_profile
	mov	cl,[(Tprofile bx).throw]
	mov	[(Tprofile bx).off],cl
@@n:	add	bx,size Tprofile
	cmp	bx,ofs profile_stop
	jne	@@l
	stc
	ret
endp

else
macro start_profile
endm
macro end_profile
endm
macro enable_profile
endm
macro disable_profile
endm
endif ;PROFILE

;***************************
;** Legacy API twiddeling **
;***************************
;N: Except MS-DOS7+, other DOS versions generate some garbage on
;   FindFirst/Next: they list out LFNs as volume labels.
;   Well-behaved file managers ignore these entries, but some other
;   like COMMAND.COM's built-in DIR doesn't.
;   Therefore, it's up to DOSLFN to wipe out such returns, proceeding
;   with next DirEnt.
;   And while we twiddle with DirEnts, this is a good chance to
;   remove the ugly ReadOnly bits out of CD DirEnts, but is not yet done.

if USEOLDDOS
proc noentry_sfn_find
;D: DirEnts with attribute 0Fh (LFN designator) must be wiped out.
;   (MS-DOS 7+ and Windows NT [DOS 5] do this;
;    this is necessary for all other DOS versions)
;I: registers unchanged, _without_ BP stack frame!
;F: INT21/4E&4F alter AX even if successful! 09/01, claude.caillet@free.fr
@@rept:	popf
	mov	ah,4Fh
sfn_find:
	call	CallOld
	jc	@@e
	pushf			;don't change other flags (esp. ZF)
	 push	ax bx es
	  mov	ah,2Fh
	  call	CallOld		;get address of DTA
	  cmp	[(TSearchRec es:bx).attr],0Fh
	 pop	es bx ax
	 je	@@rept		;next iteration makes FindNext
	popf
@@e:	ret
endp

proc sfn_find_FCB
;FU: FindFirst/FindNext via FCB muss auch gefiltert werden
;    (so ein Laster, das von der COMMAND.COM aufgebÅrdet wird,
;     niemand sonst verwendet diese Funktionen heutzutage.)
;    (MS-DOS 7 und Windows NT [DOS 5] filtern selbst;
;     notwendig ist diese Aktion fÅr alle anderen DOS-Versionen)
@@rept:	call	callold
	or	al,al
	jnz	@@err
	push	bx es
	 mov	ah,2Fh
	 call	CallOld			;get address of DTA
	 cmp	[by es:bx],0FFh 	;Extended FCB?
	 jne	@@1			;nein, bx nicht verschieben
	 add	bx,7
@@1:	 cmp	[by es:bx+12],0Fh
	pop	es bx
	mov	ah,12h
	je	@@rept
@@err:	ret
endp
endif ;USEOLDDOS

proc SFN_AL_CallOld
;FU: Aufruf des vorherigen INT21 mit DX=Zeiger auf ShortBuffer
;    Seiteneinstiege ohne Laden von AH und DX
	mov	ah,[Client_AL]
SFN_CallOld:
	mov	dx,[ShortBuffer]
CallOld_org = $ - PSPOrg
CallOld:
;	call	DecInDosFlag
	pushf
	call	[cs:OldInt21]
;	call	IncInDosFlag
	ret
endp

proc CallOldAndThrow
	call	CallOld
	jc	Throw
	ret
endp

;*****************************************
;** Windows and Code Page Notifications **
;*****************************************
if USEWIN or USECP
proc HandleWindowsOrCP
;D: Instruct Windows 3.x to load a VxD for API translating
;PE: DS und ES zeigen (n)irgendwohin!
;    Bei Windows (AH=16):
;     Bit0(DX)=0: Enhanced Mode
;      Bei Windows-Start (AL=5):
;	DS:SI=(uninteressant hier)
;	ES:BX=LPWinStart
;	CX=0: Windows darf starten
;	DI=Versionsnummer
;    bei Codeseitenwechsel (AH<>16):
;     AL=0: OK (von DISPLAY.SYS o.Ñ.)
;     BX=Codeseite
;PA: nur bei Windows-Start (AX=1605, DI<0400):
;	ES:BX=neue LPWinStart zum Laden von LFNXLAT.386
;VR: keine! Auch keine Segmentregister! Au·er ES:BX im Fall s.o.
;    [ErrInfo]
	push	ds es
	pusha
	 LD	es,cs
	 LD	ds,cs
	 mov	bp,sp
	 cld
if USEWIN and USECP
	 cmp	ah,16h		;Betrifft Windows?
	 je	@@win
endif
if USECP
	 or	al,al		;CHCP verlief OK?
	 jnz	@@e
	 mov	[NewCP],bx	;Wegen InDOS muss verzîgert geladen werden
if USEWIN
	 jmp	@@e
endif
endif
if USEWIN
@@win:
	 BTST	dx,bit 0	;Enhanced Mode?
	 jnz	@@e
	 cmp	al,05h		;Init Broadcast?
	 je	@@winstart
	 BSET	[ctrl0],CTRL_Main ;dann Exit Broadcast (AL=6)
	 jmp	@@e
@@winstart:
	 ;or	cx,cx		;Anderes TSR strÑubt sich?
	 ;jnz	@@e
	 inc	cx
	 loop	@@e
	 cmp	di,400h		;Windows 95+?
	 jc	@@loadvxd
	 BRES	[ctrl0],CTRL_Main
	 jmp	@@e
@@loadvxd:
	 lea	di,[ErrInfo]
	 mov	[Client_BX],di	;BX modifizieren
	 mov	ax,3		;Version 3.00
	 stosw
	 xchg	ax,bx
	 stosw
	 mov	ax,es
	 xchg	ax,[Client_ES]	;ES modifizieren
	 stosw
	 mov	ax,[argv0]
	 stosw
	 mov	ax,ds
	 stosw
	 xor	ax,ax
	 stosw			;2 DWîrter
	 stosw
	 stosw
	 stosw
	 lea	si,[lfnxlatvxd$]
	 mov	di,[argv0file]
	 call	strcpy
endif ;USEWIN
@@e:	popa
	pop	es ds
	ret
endp
endif ;USEWIN or USECP

macro bin2dec_code install
proc bin2dec&install
;D: convert AX to decimal ASCII
;I: AX = number
;   DI -> buffer (pointing after units, filled backwards)
;O: DI -> most significant digit
;M: AX (0),DX
@@l:	sub	dx,dx
	div	[ten]
	dec	di
	add	dl,'0'
	mov	[di],dl
	test	ax,ax		;Null?
	jnz	@@l		;nÑchste Ziffer
	ret
endp
endm

macro chcp_code install
proc MakeTblFileName
;PE: DI=Ziel Dateiname
;    BX=Codeseite
;VR: AX,BX,CX,DX,DI
	lea	si,[TblFileName$]
	call	strcpy	;DI zeigt hinter die Null
	sub	di,8	;"UNI.TBL\0" zurÅck auf die letzte Ascii-Null
	xchg	ax,bx
	;jmp	bin2dec
endp

bin2dec_code install

proc LoadCP
;D: Loads Code Page Table (CPxxxUNI.TBL) file according to code page in BX
;PE: BX=Codeseite (bei Nummern >=1000 wird "P" oder "CP" Åberschrieben)
;VR: alle (au·er FS)
	mov	di,[argv0file]
	call	MakeTblFileName
	mov	dx,[argv0]
;	jmp	LoadUniFile
endp

proc LoadUniFile
;D: Loads Unicode file to, removes old table from heap
;I: DX=filename
;O: CY=1 error, BL=3: cannot open file, BL=4: wrong file format
;   CY=0 OK, table loaded
;VR: alle, DS=ES, [ErrInfo], [TrailMinLen], [UniTableLen]
;LÑdt beide Arten von Tabellen; die Unterscheidung, ob SBCS oder DBCS
;fÑllt Oem2Uni bzw. Uni2Oem anhand IsDbcsLeadByte, dem Tabellen-Wert u.Ñ.
	DOS	3D00h		;zum Lesen îffnen
	mov	bl,3
	jc	@@e		;Datei nicht gefunden o.Ñ.
ReadUniFile:		;Einstieg mit AX=Handle
	xchg	bx,ax
	mov	cx,32
	lea	dx,[ErrInfo]
	DOS	3Fh		;32 Bytes lesen, Header darf nicht lÑnger sein
	cmp	ax,cx
	jne	@@e13		;Datei ungÅltig: viel zu kurz
	mov	si,dx
@@l:	lodsb
	or	al,al		;Kennbyte 00h
	jz	@@e13		;von ASCII->ASCII-Tabellen wei· DOSLFN nichts
	dec	ax		;Kennbyte 01h (in ersten 32 Byte)? (AH=0)
	jz	@@1		;"normale" Unicode-Tabelle
	dec	ax		;Kennbyte 02h (in ersten 30 Byte)? (AH=0)
	loopnz	@@l
	;DBCS
if USEDBCS
	cmp	cl,2		;Keine 2 Bytes da?
	jc	@@e13		;dann .TBL ungÅltig
	lodsw			;DBCS-Info
	mov	[TrailMinLen],ax
else
	jmp	@@e13
endif
@@1:	;SBCS
	sub	si,dx
	xor	cx,cx
	push	si		;Lese-Position
	 cwd
	 DOS	4202h		;Datei-LÑnge in DX:AX, DX wird ignoriert
	pop	dx
	sub	ax,dx
	or	ah,ah		;wie "cmp ax,100h"
	jz	@@e13		;Datei zu kurz
	push	ax		;Rest-LÑnge in AX
	 shr	ax,1
	 mov	[UniTableLen],ax ;Anzahl Unicodes, bei SBCS = 80h
	 DOS	4200h		;jetzt zum Daten-Anfang (CX=0)
	 lea	di,[UniXlat]
	 call	FreeDIPtr
	pop	ax
	push	ax
	 call	LocalAlloc
	 mov	[UniXlat],di
	pop	cx
	jc	@@e13		;Zu lang, Heap reicht nicht
	mov	dx,di
	DOS	3Fh
	cmp	ax,cx
	jne	@@e13		;Datei ungÅltig: zu kurz (kann nicht sein)
@@cl:	DOS	3Eh		;DOS setzt CY
@@e:	ret
@@e13:	call	@@cl
	mov	bl,4
	stc
	ret
endp

proc CheckLoadCP
;PrÅft auf neue Unicode-Tabelle und lÑdt diese gegebenenfalls nach
	pusha
	 xor	bx,bx
	 xchg	[NewCP],bx
	 or	bx,bx
	 jz	@@e
	 call	LoadCP
	 jnc	@@e
	 mov	[LastError],5
@@e:	popa
	ret
endp
endm
if USECP
	chcp_code
endif

;****************************************
;** Initialized Constant and Data Area **
;****************************************

language	db	'E'	;'D'eutsch,'F'rancais,'N'ihongo,'R'ussky?
UniXlat		dw	0	;0 bedeutet hier: OEM = ISO-Latin-1
rwrec		tRWRec	<?,4,ofs Sektor>
if USECP
NewCP		dw	0	;wird bei Int2F gesetzt
TblFileName$:	dz	"CP000UNI.TBL"  ;see TBL.TXT
endif
if USEWIN
lfnxlatvxd$:	dz	"LFNXLAT.386"
endif

if USEWINTIME
		;	  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
month_start	dw	0,  0, 31, 59, 90,120,151,181,212,243,273,304,334
TimeOffset	dd	0e1d58000h ;100-ns intervals from
		dd	001a8e79fh ; 1 Jan 1601 0:00:00 UTC to 1 Jan 1980
endif

Invalid_Lfn_Chars db	'"<|>:\/'	;7 characters

Invalid_Chars	db	0,' .+,;=[]'	;the order here is strategic
;B: Both charsets above mean invalid characters for SFN. The dot (.)
;   has special meaning in SFN and is handled separately

;B: Normally, the space character 32 (20h) is allowed in SFN,
;   but the Win9x LFN API dircards spaces (and dots) when building SFN aliases
;   Furthermore, the space is problematic because most command-line
;   utilities do not support an escape to interpret a space literally

;B: Dots and spaces are invalid for LFNs at the end! They are stripped
;   automatically. Consequently, names containing only dots and/or spaces
;   are invalid, with the exception "." and ".." for the special directories.
;B: Although Explorer doesn't allow to create names _beginning_ with a dot
;   or space, these are allowed file names. This is an Explorer bug.

MaxCluster	dw	0FFF7h, 0FFFh	;FAT16 & FAT32 maximum cluster number

;Statistik-ZÑhler
counter_read	dd	0
counter_write	dd	0
counter_i2171	dd	0
LastError	db	0

proc Check_CDFS
	test	[DriveType],DT_CDFS	;bytefressender Befehl
	ret
endp

proc Check_FB
	cmp	[DriveType],1		;CY if fallback mode
	ret
endp

proc Check_Slash
	bt	[wo PFlags],3 ;PF_Slash ;CY if slash follows
	ret
endp

;*****************************
;** Basic Sector Read/Write **
;*****************************

proc ReadSec_long
	mov	eax,[longpos_s]
	mov	bx,[longpos_a]
	jmp	ReadSecEAX_addBX
ReadSec_subBX:
	sub	bx,[Sektorp]
	db	0b9h		;mov cx,nnnn
ReadSec_setBX:
	sub	bx,bx
ReadSec_addBX:
	mov	eax,[CurSector]
	db	0b9h
ReadSecEAX_setBX:
	sub	bx,bx
ReadSecEAX_addBX:
	call	ReadSecEAX
	pushf
	 add	bx,[Sektorp]
	popf
	ret
endp

ReadNextSec:
	inc	[CurSector]

proc ReadSec
;{Liest einen Sektor Nummer <CurSector> nach <Sektor>, PA: CY=1:Fehler}
;Liest nur, wenn's ein neuer Sektor ist!
;PE: CurSector=Sektor-Nummer
;PA: [Sektor] gefÅllt mit Sektor-Daten
;    CY=1: Fehler
;VR: alle except BX (bedeutet hier und im folgenden EAX,CX,EDX,SI und DI,
;	   nicht aber DS,ES,SS,SP und BP, werden dann extra gelistet)
	mov	eax,[CurSector]
ReadSecEAX:
	call	_set_cur
	call	Check_CDFS
	jnz	CD_ReadSec
	sub	eax,[rwrec.sect]
	cmp	eax,4
	jb	@@e		;nichts tun!
	call	FlushDirty
	add	[rwrec.sect],eax
	inc	[counter_read]
	push	bx
FAT_R:	 xor	si,si		;extended read (FAT12/16/32)
	 ;mov	al,25h		;standard read (FAT12/16; patched by install)
	 start_profile read
	 call	Fat_RW
	 end_profile
	pop	bx
	mov	al,0
@@e:	add	al,al
	add	al,high (Sektor - PSPOrg)
	mov	[by high Sektorp],al
	add	al,2			;clears carry
	mov	[by high SektorEnde],al
	ret
endp

;******************************
;** Basic Sector Cache Flush **
;******************************

proc FlushDirty
	test	[DriveType],DT_Dirty
	jz	@@e
_WriteNow:
	start_profile write
	push	eax bx
	 call	WriteSec
	pop	bx eax
	end_profile
DriveClean:
	and	[DriveType],not DT_Dirty
wn_e:
unl_e:
@@e:	ret
endp

proc WriteNow
	call	_WriteNow
ResetDrv:
	;test	[ctrl],CTRL_InDOS
	;jz	wn_e		;"riskanter" Modus
	nop			;modified by "i" switch to RET
	mov	ah,0Dh
_CallOld:
	jmp	CallOld
endp

proc UnlockDrive
	test	[DriveType],DT_Locked
	jz	unl_e
	mov	cx,086Ah	;MS-DOS7 UNLOCK
endp
proc LockDrive
	mov	bl,[DPB_Drive]
	inc	bx
	mov	ax,440Dh
	jmp	_CallOld	;DOS7 (UN)LOCK
endp

proc WriteSec
;{Schreibt Sektor <Sektor> nach Nummer <RWRec.Sect>, PA: Fehlercode}
;PE: RWRec.sect=Sektor-Nummer
;    [Sektor] gefÅllt mit Sektor-Daten
;PA: CY=1: Fehler
;VR: alle
	inc	[counter_write]
	bts	[wo DriveType],6;DT_Locked
	jc	Fat_W		;Laufwerk ist bereits gesperrt
	mov	bh,0		;LOCK LEVEL
	mov	cx,084Ah	;DOS7 LOCK
	mov	dx,1		;fÅr Schreibzugriff
	call	LockDrive
FAT_W:	mov	si,4001h	;extended write (FAT12/16/32)
	;mov	ax,26h		;standard write (FAT12/16; patched by install)
	;jmp	Fat_RW
if USEFREESPC
	call	GetExDPB
	adc	[by fw],cl	;change JMP to CALL if successful (CL = -1)
endif
endp

Fat_RW_org = $ - PSPOrg
proc Fat_RW
;FU: Lesen und Schreiben von/auf FAT12/16/32
;PE: SI=0 fÅr Lesen, 4001h fÅr Schreiben Verzeichnis-Daten
;    [DPB_Drive]=Laufwerk (0=A: usw.)
;    [RWRec]=Sektor,Anzahl,Speicheradresse
;VR: alle
	lea	bx,[RWRec]
if USEFREESPC
	mov	al,5
endif
@@edd:	mov	cx,0FFFFh
	mov	dl,[DPB_Drive]
	inc	dx
ife USEFREESPC
	mov	ax,7305h
	jmp	CallOld 	;10/02: ohne Rekursion
	nop			;padding byte for GetDPB_std
else
@@ed:	mov	ah,73h
fw:	jmp	CallOld 	;or CALL
	inc	[by fw] 	;change CALL back to JMP
	jc	wn_e
	mov	di,ofs exDPB.free_clusters-8
	;mov	cx,24		;size of structure
	push	di
	 call	stosq0		;size (dw), version (dw) & function (dd)
				;(dd) free space (set via GetExDPB)
	 mov	[di+4],eax	;(dd) don't change next-free
	pop	di
	mov	al,4		;Set DPB to use for formatting
	jmp	@@ed

GetExDPB:
	mov	di,ofs exDPB-2
	mov	al,2
	jmp	@@edd
endif ;USEFREESPC
endp

GetDPB_org = $ - PSPOrg
proc GetDPB
;I: DL=drive to get info (A=1)
;O: [DPB_Drive]=physical drive (changed if SUBSTed)
;   [DriveType], [DPB_FAT1Sec], [DPB_UsrSec], [DPB_DirSec] filled with values
;   EAX=max_cluster
;   CL=shift
;   CY=1 if error
;N: change 10/01: stack storage for tExDPB, never overwrite sector data
;   jmh 05/04: why? the sector is always invalidated
diDPB	equ	(TExDPB di+2)
ife USEFREESPC
	mov	di,ofs exDPB-2
	;mov	[wo di],3Dh	;61 bytes space, not necessary on call
	mov	ax,7302h	;{get extended DPB}
	mov	cl,3Fh		;CX >= 63 bytes
	call	CallOld
else
	call	GetExDPB
endif ;USEFREESPC
	jc	@@e		;{Fehler: kein FAT32}
	cmp	[by HIGH diDPB.SecLen],2 ;assume multiple of 256
	jne	@@err		;cannot yet accept other sector sizes
	dec	dx
	cmp	[diDPB.Drive],dl
	jne	@@err		;cannot support SUBSTed drives yet
	mov	dl,DT_FAT32	;assume FAT32 (DT_FAT32 = 8)
	mov	ax,[exDPB.ResSec]
	mov	[wo DPB_FAT1Sec],ax	;high word cleared during install
	mov	eax,[exDPB.first_sector]
	mov	[DPB_UsrSec],eax
;here bugfix 10/01: root directory is not always at cluster 2!
	mov	cl,[diDPB.Shift]
	mov	eax,[exDPB.root_cluster]
	test	eax,eax
	jz	@@1216
	call	Clust2Sec
@@root: mov	[DPB_DirSec],eax
	mov	eax,[exDPB.max_cluster]
	or	[DriveType],dl		;(clears carry)
	db	0b5h ;mov ch,nn
@@err:	stc
@@e:	ret
@@1216: cmp	[diDPB.HiClus],0FF7h	;Letzter Cluster
	sbb	dl,4			;DT_FAT12 = 3, DT_FAT16 = 4
	mov	ax,[exDPB.SecDir]
	jmp	@@root
endp

;Create a segment containing FAT_RW and GetDPB for the standard calls.
;The installer will overwrite the extended calls with these if it doesn't
;detect the extended functions. (There's probably a better way to do this?)
segment std_fn byte public use16
assume cs:std_fn
org_0:

org   CallOld_org
label CallOld_std near		;get around the different CS

org  Fat_RW_org
proc Fat_RW_std
;FU: Lesen und Schreiben von/auf FAT12/16
;PE: AL=25h fÅr Lesen, 26h fÅr Schreiben Verzeichnis-Daten
;    [DPB_Drive]=Laufwerk (0=A: usw.)
;    [RWRec]=Sektor,Anzahl,Speicheradresse
;VR: alle
	mov	[int2526],al
	mov	cx,0FFFFh
	lea	bx,[RWRec]
	mov	al,[DPB_Drive]
	push	bp		;zumindest DR-DOS zerstîrt BP
	 int	25h
int2526 = $-1 - org_0		;absolute address to prevent relocation
	 pop	bp		;{Stack korrigieren}
	pop	bp
@@e:	ret
endp

org  GetDPB_org
proc GetDPB_std
;I: DL=drive to get info (A=1)
;O: [DPB_Drive]=physical drive (changed if SUBSTed)
;   [DriveType], [DPB_FAT1Sec], [DPB_UsrSec], [DPB_DirSec] filled with values
;   EAX=max_cluster
;   CL=shift
;   CY=1 if error
	push	es
	push	ds
	 mov	ah,32h		;{liefert AL=0:OK, FFh=Fehler}
	 call	CallOld_std
	 LD	es,ds
	pop	ds
	or	al,al
	jne	@@err
	cmp	[by HIGH (tExDPB es:bx).SecLen],2 ;{StandardmÑ·ige SektorlÑnge?}
	jne	@@err				  ;(assume multiple of 256)
	dec	dx
	cmp	[(tExDPB es:bx).Drive],dl	;geSUBSTet?
	jne	@@err
	mov	ax,[(tExDPB es:bx).ResSec]	;the high words are
	mov	[wo DPB_FAT1Sec],ax		; cleared during install
	mov	ax,[(tExDPB es:bx).UsrSec]
	mov	[wo DPB_UsrSec],ax
	mov	ax,[(tExDPB es:bx).SecDir]
	mov	[wo DPB_DirSec],ax
	movzx	eax,[(tExDPB es:bx).HiClus]	;Letzter Cluster
	cmp	ax,0FF7h
	cmc				;NC = FAT12, CY = FAT16
	adc	[DriveType],DT_FAT12	;DT_FAT12 = 3, DT_FAT16 = 4 (NC)
	mov	cl,[(tExDPB es:bx).Shift]
	db	0b5h ;mov ch,nn
@@err:	stc
@@e:	pop	es
	ret
endp
std_size = $ - Fat_RW_std
ends
assume cs:dgroup

proc GetDrvParams pascal
;{Ermittelt Laufwerksparameter fÅr <@drive> (1=A: usw.)
; und setzt die Variablen DPB_xxx sowie DriveType, PA: DriveType<>0 wenn OK}
; Von Laufwerken >=C: erfolgt die Bestimmung nur bei neuem Buchstaben,
; bei Disketten- und CD-Laufwerken nur nach Ablauf eines TimeOuts
;PE: AL=Laufwerksnummer (0=current, 1=A:)
	push	si
	sub	al,1
	jnc	@@nodef
	mov	ah,19h		;Akt. Laufwerk beschaffen
	call	CallOld
@@nodef:
	cmp	al,[DPB_Drive]	;gleich?
	jne	@@readin	;bei Unterschied sofort lesen
	cmp	al,2
	mov	cx,FDChangeTime
	jc	@@chktick	;Laufwerke default:, A: und B:
	call	Check_CDFS
	jz	@@ret
	mov	cl,CDChangeTime
@@chktick:
	push	ax
	 call	GetTick
	 sub	ax,[LastAccessTime]
	 cmp	ax,cx
	pop	ax
	jc	@@no_change
	;risk disk changes not causing any cache problems
@@readin:
	push	ax
	 call	FlushDirty
	 call	UnlockDrive
	pop	ax
	;mov	[DPB_Drive],al
	;mov	[DriveType],0
	cbw
	mov	[wo DPB_Drive],ax
	call	InvalSector
ife USEFREESPC
	xchg	dx,ax		;DL = drive
	inc	dx		; A = 1
endif
	call	GetDPB
	jnc	@@fat
	;test	[ctrl],CTRL_CDROM
	;jz	@@nodrv 	;Will kein CD-ROM erkennen
test_cd:
	call	CD_Init 	;modified by install/"c" switch
	jnc	@@e
	and	[CD_VSN],0
@@nodrv:
	mov	[DriveType],0	;kein unterstÅtzter Laufwerkstyp
	;jmp	@@e		;save two bytes and simply fall through
@@fat:
	mov	[DPB_Shift],cl
	inc	eax
	shl	eax,cl		;1.nicht-adressierbarer Sektor
	dec	eax
	mov	[DPB_LastSec],eax
@@e:
@@no_change:
	call	GetTick
	mov	[LastAccessTime],ax
@@ret:	pop	si
	ret
endp

;Es muss die Zeit beim Zugriff auf wechselbare Medien
;(A:, B: und CD-Laufwerke) erfasst werden...
proc GetTick
	push	ds
	 push	40h
	 pop	ds
	 mov	ax,[6Ch]	;55-ms-Timer abfragen (AufwÑrtszÑhler)
	pop	ds
	ret
endp

fstrcpyBS: mov	ax,ofs strcpyBS
	;jmp	noentry_fstrcpy
	db	84h		;84 B8 nn nn = test [bx+si+nnnn],bh
fstrcpy: mov	ax,ofs strcpy
proc noentry_fstrcpy pascal
;fast normale strcpy-Funktion, erwartet cld, verÑndert keine Register
;liefert in AX Anzahl kopierter Zeichen (ohne Null), also strlen
;arg @dst:dword,@src:dword
;uses ds,es,si,di
@src equ dword bp+4
@dst equ dword bp+8
	push	bp			;TASM generates ENTER 0,0
	mov	bp,sp			; but this is one byte shorter
	push	ds es si di
	lds	si,[@src]
	les	di,[@dst]
	call	ax
	xchg	ax,si
	dec	ax
	sub	ax,[wo LOW @src]	;Anzahl Zeichen
	pop	di si es ds
	pop	bp
	ret	8
endp

proc strcpyBS
@@l:	lodsb
	cmp	al,'/'
	jne	@@1
	mov	al,'\'
@@1:	stosb
	or	al,al
	jnz	@@l
_fcb_retu:
	ret
endp

File_Flag_Wildcards	=01h		;? oder * enthalten
File_Flag_Is_LFN	=02h		;s.u.
File_Flag_Has_Star	=04h		;* enthalten
File_Flag_Has_Dot	=08h		;. (nicht am Anfang) enthalten
; File_Flag_DotAtEnd	=10h		;(Abgeschnittener) Punkt am Ende
File_Flag_NDevice	=20h		;RegulÑrer Dateiname
File_Flag_LowerCase	=40h		;Kleinbuchstaben a-z enthalten
File_Flag_Char_High	=80h		;codeseitenabhÑngige Zeichen
; File_Flag_DBCS_Char	=80h

;Ist File_Flag_Is_LFN gesetzt, kann entweder ein langer Name vorliegen,
;oder der (vielleicht kurze) Name enthÑlt die Zeichen ' .+,;=[]'
;Es bedeutet, dass der Name keinesfalls als FCB-Name zu finden ist.
;Beim Erstellen mit Schlangen-Zwang ist Schlange zu setzen.
;In Verbindung mit File_Flag_Has_Star bedeutet es, dass der Win32-
;Namensvergleich stattfinden muss (d.h. im RÅckfallmodus muss nach
;der Suche nach *.* noch einmal getestet werden)
;
;ZusÑtzlich zu File_Flag_Lowercase ist auch File_Flag_Char_High gesetzt,
;wenn Umlaute (also Zeichen >=80h) enthalten sind.
;Auch bei nur gro·en Umlauten
;legt Win9x auch in diesem Fall LFN-EintrÑge an,
;um Probleme mit Codeseiten zu umgehen
;Suche nach LFN-Dateinamen deshalb bei Is_LFN und/oder Char_High
;
;Ist weder File_Flag_Lowercase noch File_Flag_Is_LFN gesetzt,
;ist bei CREATE/MKDIR/MOVE keinerlei LFN-Eintrag zu erzeugen!

proc _noentry_Copy_FCB_Part
;BE: Kopiert LFN in FCB, FCB muss mit SPACE vorgefÅllt sein
;PE: SI=LFN-Zeiger
;    BX=LFN-Ende (zeigt hinter Punkt), 0 fÅr Ende durch ASCII-Null
;    DI=FCB-Zeiger
;    DX=FCB-Ende-Zeiger+1
;    AH=Flags (File_Flag_Has_Dot)
;    DS,ES=CS
;PA: AH=weitere Flags (File_Flag_Wildcards u.Ñ.) gesetzt
;VR: AX,CX,DX,SI,DI
if USEDBCS
@@lead:	pop	dx
	dec	dx		;potentielles Ende bei 7 oder 2 Bytes
	cmp	di,dx
	je	@@a		;kein Platz fÅr Trail-Byte!
	inc	dx
	stosb
	lodsb			;TrailByte
	or	ah,File_Flag_Char_High or File_Flag_LowerCase
	jmp	@@b
endif ;USEDBCS

@@l2:	push	dx
	 mov	dl,al
if USEDBCS
	 call	IsDbcsLeadByte
	 jnc	@@lead
endif
	 call	UpCase
	 or	dl,dl		;>=80h
	 js	@@is_lower
	 cmp	al,dl		;verÑndert?
	 jz	@@was_upper
@@is_lower:
	 and	dl,80h
	 or	ah,dl		;Bit 7 setzen (lassen, sprungfrei)
	 or	ah,File_Flag_LowerCase
@@was_upper:
	pop	dx
@@b:	stosb
Copy_FCB_Part:			;Einsprung fÅr Erweiterung
@@l3:	lodsb
	cmp	al,'?'
	je	@@qm
	cmp	al,'*'		;zu Fragezeichen machen?
	je	@@star
	push	di
	 mov	di,ofs Invalid_Chars	;0,' .+,;=[]'
	 mov	cx,9
	 repne	scasb
	pop	di
	jnz	@@cp		;erlaubte SFN-Zeichen
	or	al,al
	je	_fcb_retu
	cmp	si,bx		;auf dem (letzten) Punkt?
	je	_fcb_retu
	or	ah,File_Flag_Is_LFN
	cmp	al,' '		;Leerzeichen ist DurchlÑufer (kein Ersatz)
	je	@@l3
	cmp	al,'.'		;Punkt ist DurchlÑufer (kein Ersatz)
	je	@@l3
	mov	al,'_'		;'+,;=[]' durch '_' ersetzen
@@cp:	cmp	di,dx		;haben noch Zeichen und kein Platz?
	jne	@@l2		;Noch ist Platz
@@a:	or	ah,File_Flag_Is_LFN
	jmp	@@l3		;weiter nach '*' oder '?' fahnden

@@qm:	;falls Fragezeichen: Bit setzen und weiter
	or	ah,File_Flag_Wildcards
	jmp	@@cp
@@star:	;falls Stern: einige ExtrawÅrste
	or	ah,(File_Flag_Wildcards or File_Flag_Has_Star)
	test	ah,File_Flag_Has_Dot
	jnz	@@q0
	mov	dx,ofs FCB_Name+11	;alles mit Fragezeichen!
@@q0:	mov	al,'?'
	db	0B1h		;mov cl,nn
@@q1:	stosb
	cmp	di,dx
	jne	@@q1
	jmp	@@l3		;zur Auswertung von File_Flag_Is_LFN
endp

proc Gen_Alias pascal
;Alias-Generierung, "ersetzt" Int21/AX=2900h
;Eine "Erweiterung" ist definiert als der String hinter dem letzten Punkt,
;welcher nicht in einer Kette am Anfang stehender Punkte ist, also
;".ab" oder "..exe" enthalten keine "Erweiterungen"
;
;TRUENAME muss schon dafÅr sorgen, dass:
;- nachlaufende Leerzeichen und Punkte entfernt sind
;- ein Punkt am Ende nur verbleibt, wenn ein '*' enthalten ist
;- Pfad-Trenner zusammengefasst zu '/' sind  (fÅr DBCS)
;- keine ungÅltigen LFN-Zeichen enthalten sind
;- Wildcards vor Backslash als Fehler gelten
;
;Hier werden (noch) keine Schlangen zugesetzt, das macht Poke_Number...
;Beachtet erstes Zeichen im FCB (05h fÅr E5h) nicht!

;PE: SI=Pfad-Komponente
;    DS,ES=CS
;PA: FCB gefÅllt
;    Pfad-Komponente ggf. modifiziert, Null-terminiert
;    SI=nÑchste Pfad-Komponente oder auf ein Null-Byte
;    AH=[File_Flags]=File_Flags
;    [CurPathComp]=momentane Pfad-Komponente (=SI beim Aufruf)
;    [PFlags]:PF_Slash zeigt gelîschten Slash an
;VR: AX,BX,CX,DX,SI
uses di
	mov	[CurPathComp],si
	;FCB lîschen
	mov	di,ofs FCB_Name
	mov	cx,6		;CH bleibt 0
	mov	ax,'  '         ;AH = File_Flag_NDevice
	rep	stosw		;das Byte zuviel macht nichts
	;Pfad-Komponente isolieren
	BRES	[PFlags],PF_Slash
	push	si
@@l:	 lodsb
	 or	al,al
	 je	@@e2
	 cmp	al,'/'
	 jne	@@l
	 BSET	[PFlags],PF_Slash	;ein Fall fÅr File_Flags!
	 mov	[by si-1],cl		;CL is 0 from rep
@@e2:	pop	si
	xor	bx,bx
	;nicht-erste Punkte Åbergehen suchen
@@l1:	lodsb
	cmp	al,'.'		;Punkt(e) am Anfang (".login" o.Ñ.)
	je	@@l1		;zÑhlt nicht als Erweiterung
	cmp	al,' '		;auch wenn gemischt mit Leerzeichen
	je	@@l1		;(was fÅr grausige Dateinamen!)
;	or	al,al
;	jz	@@ende		;Notbremse, sollte hier nie vorkommen!
	;letzten Punkt finden
@@l2:	lodsb
	or	al,al
	jz	@@ende
	cmp	al,'.'		;Punkt entdeckt?
	jne	@@l2		;Kein anderes Zeichen mit Sonderbehandlung
	mov	bx,si		;potenzieller Ext-Zeiger (hinter Punkt)
	or	ah,File_Flag_Has_Dot	;"normaler" Punkt
	jmp	@@l2

@@ende:	dec	si		;auf die Null!

	;Name in FCB kopieren
	push	si
	 mov	si,[CurPathComp]
	 mov	di,ofs FCB_Name
	 mov	dx,ofs FCB_Name+8
	 push	dx
	  call	Copy_FCB_Part	;Namensteil (8)
	 pop	di
	 test	ah,File_Flag_Has_Dot
	 jz	@@keine_ext
	 mov	si,bx
	 mov	dx,ofs FCB_Name+11
	 call	Copy_FCB_Part	;Erweiterung (3)
@@keine_ext:
	pop	si
	mov	[File_Flags],ah
	ret
endp

ife USECP
bin2dec_code
endif

proc Poke_Number_Over_FCB pascal
;BE: in [FCB_Name] wird die Zahl SI "eingepflanzt"
;    Es erfolgt kein Test auf SI=0
;PE: [FCB_Name]-Namensteil gefÅllt, ab erstem Leerzeichen oder derart,
;    dass die Zahl rechtsbÅndig steht. (Bei DBCS ist bisweilen 1 Leerzeichen
;    dahinter, also nur 7 Bytes insgesamt, erforderlich!)
;    Erstes Byte muss hier noch E5h sein, nicht 05h!
;    [FCB_Name] darf keine regulÑren Zwischen-Leerzeichen enthalten!
;    DS,ES=CS
;PA: [FCB_Name]-Namensteil modifiziert unter DBCS-Beachtung
;    BX=Zeiger auf Tilde (zum Wegpoken fÅr den nÑchsten Versuch)
;VR: AX (AH=0),BX,CX=0,DX
uses SI,DI
	xchg	ax,si		;Zahl
	mov	di,ofs cache_temp+6
	mov	cx,di
	call	bin2dec
	sub	cx,di		;Number of digits
	mov	al,8
	sub	ax,cx		;Verbleibende Bytes +1
	mov	si,di
ife USEDBCS
	mov	di,ofs FCB_Name-1
@@n2:
else
	mov	di,ofs FCB_Name-2
@@n2:	inc	di
endif
@@n1:	inc	di
	mov	dl,[di]
	cmp	dl,' '		;In generierten SFN gibt es keine Leerzeichen
	je	@@ok
if USEDBCS
	dec	ax
	jz	@@ok
	call	IsDbcsLeadByte
	jc	@@n1
endif
	dec	ax		;2 Bytes
	jnz	@@n2
@@ok:	mov	bx,di		;RÅckpatch-Zeiger
	mov	al,'~'          ;...die geliebte Schlange voran...
	stosb
	rep	movsb
if USEDBCS
	cmp	di,ofs FCB_Name+7	;ein Trail-Byte zu tîten?
	jne	@@e
	mov	al,' '
	stosb
endif
@@e:	ret
endp

proc Change_First_FCB_Byte
;FU: Hilfsprogramm fÅr Copy_FCB_8P3 und Is_FCB_Equal
;PE: AL=1. FCB-Byte
;    CL=Ersatz fÅr E5 (Lîsch-Kennung)
;PA: AL=GeÑndertes Byte: E5->CL, 05->E5, sonst unverÑndert
;VR: AL,CL
	cmp	al,0E5h		;Gelîschter Eintrag?
	je	@@1		;auf CL setzen (Vorgabe)
	cmp	al,05h		;Ersatzbyte fÅr E5?
	mov	cl,0E5h		;das ist das Byte (nicht Zeichen - DBCS!) E5
	jne	@@e
@@1:	mov	al,cl
@@e:	ret
endp

proc Pick_Sector_From_DirEnt
;PE: BX=DirEnt-Zeiger (nur FAT!)
;PA: EAX=[CurSector]=[SuchSektor]=Sektor-Nummer
;    CY=1 wenn ungÅltige Cluster-Nummer
;VR: EAX,CL
	xor	ax,ax
	test	[DriveType],DT_FAT32
	jz	@@1
	mov	ax,[(TDirEnt bx).ClusH]
	and	ah,0Fh			;Obere 4 Bits undefiniert = FAT28!
@@1:	shl	eax,16
	mov	ax,[(TDirEnt bx).ClusL]
	;jmp	Cluster2Sector
endp

proc Cluster2Sector
;PE: EAX=Cluster-Nummer
;PA: EAX=[CurSector]=[SuchSektor]=Sektor-Nummer
;    CY=1 wenn ungÅltige Cluster-Nummer
;VR: EAX,CL
	or	eax,eax
	jz	_set_root_sector
	mov	cl,[DPB_Shift]
	call	Clust2Sec
	;cmp	[DPB_LastSec],eax	;öberlaufprÅfung!
	jmp	_set_cur_and_such
_set_root_sector:
	mov	eax,[DPB_DirSec]
_set_cur_and_such:
	mov	[SuchSektor],eax
_set_cur:
	mov	[CurSector],eax
	ret
endp

proc Clust2Sec
;PE: EAX=Cluster number
;    CL=sector shift
;PA: EAX=Sector number
	sub	eax,2
	shl	eax,cl			;Cluster->Sektor
	add	eax,[DPB_UsrSec]
	ret
endp

proc two2shift
;PA: DI=2 to the power of DPB_Shift - 1 (number of sectors per cluster - 1)
;    Z=1 if AX is multiple thereof
	mov	cl,[DPB_Shift]
two2CL:
	mov	di,1
	shl	di,cl
	dec	di		;0->0, 1->1, 2->3, 4->7 usw.
	test	ax,di
	ret
endp

proc Calc_Next_Cluster pascal
;Berechnung fÅr Next_Sektor, liest die FAT ein
;PE: EAX=(vorhergehender) Sektor (gerechnet ab UsrSec)
;    CL=Shift
;PA: EAX=nÑchster Sektor (erster Sektor des nÑchsten Clusters, ab UsrSec)
;    CY=1: Ende der Cluster-Kette, EAX=Cluster-Nr.
;VR: alle, [Sektor]-Inhalt zerstîrt
	shr	eax,cl
	add	eax,2		;EAX ist nun CLUSTER
	movzx	edx,[DriveType]
	and	dl,DT_FAT12+DT_FAT16+DT_FAT32	;Nibbles pro FAT-Eintrag
	push	dx
	;nun in EDX Nibbles pro Cluster-Eintrag
@@1:	mul	edx		;EDX:EAX=Nibble-Nummer
	mov	bx,ax
	and	bh,03		;%1024=Nibble-im-Sektor
	mov	ch,bl		;letztes Bit retten
	shr	bx,1		;Nibble->Byte
	shrd	eax,edx,10	;/1024=Sektor-Nummer
	add	eax,[DPB_FAT1Sec]
	push	cx
	 call	ReadSecEAX_addBX
	pop	cx
	pop	dx
	jc	@@e
	and	[by bx+3],0Fh	;die obersten 4 Bit sind reserviert!
	mov	eax,[bx]
	cmp	dl,DT_FAT16
	ja	@@3
	movzx	eax,ax
	je	@@3a
;dicke Extrawurst fÅr FAT12: Nachlese 2.Sektor, falls bx am Ende
	inc	bx
	cmp	bx,[SektorEnde]
	jnz	@@4
	pusha
	 call	ReadNextSec
	popa
	jc	@@e
	mov	bx,[Sektorp]
	mov	ah,[bx] 	;2. Byte vom Anfang nachlesen
@@4:	shr	ch,1		;Nibble-Bit gesetzt?
	jnc	@@5
	shr	ax,4
@@5:	and	ah,0Fh
	cmp	ax,0FF7h
	jmp	@@3b
@@3:	;nun wieder Cluster in Sektor umrechnen
	db	66h		;extended prefix
@@3a:	cmp	ax,[MaxCluster]
;Also bietet FAT32 max. 256 Mega-Cluster, bei heute Åblichen LBA-Laufwerken
;mit 28-bit-Sektoradresse (also max. 128 GB) reicht das fÅr 512-Byte-Cluster
@@3b:	cmc
	jc	@@e		;Ende der Clusterkette
	sub	eax,2
	jc	@@e		;momentaner Cluster ist frei (falsch!)
	shl	eax,cl
_nde_ret:
@@e:	ret
endp

proc Next_DirEnt
;PE: BX=DirEnt-Zeiger
;PA: BX=vorgerÅckter DirEnt-Zeiger, ggf. mit neu gelesenem Sektor
;    CY=1: kein weiterer Sektor in Clusterkette
;VR: alle
	call	Check_CDFS
	jnz	CD_Next_DirEnt
	add	bx,32		;Grî·e von DirEnt
	cmp	bx,[SektorEnde]
	cmc
	jnc	_nde_ret
;	jc	Next_Sektor	;CY durchreichen
;@@e:	ret			;noch im gleichen Sektor: OK
endp

proc Next_Sektor pascal		;nur FAT
;liefert nÑchsten Sektor der Clusterkette bzw. des Hauptverzeichnisses
;PE: [CurSector]=momentaner Sektor
;PA: [CurSector]=nÑchster Sektor, bereits gelesen
;    BX=Zeiger auf Sektor-Anfang
;    [num_cluster] inkrementiert bei Cluster-Wechsel
;VR: alle
	mov	eax,[CurSector]
	inc	eax
	cmp	[DPB_LastSec],eax
	jc	_nde_ret	;war User-Bereich: Ende!
	sub	eax,[DPB_UsrSec];Hauptverzeichnis-Ende?
	cmc
	jz	_nde_ret	;war Hauptverzeichnis: Ende! (mit CY=1)
	jnc	@@er		;war Hauptverzeichnis: es gibt weitere
	call	two2shift
	jnz	@@er		;noch im gleichen Cluster: weiter!
	dec	eax
	call	Calc_Next_Cluster
	jc	_nde_ret	;kein nÑchstes Cluster: Ende!
	inc	[num_cluster]
@@er:	add	eax,[DPB_UsrSec]
	jmp	ReadSecEAX_setBX ;Sektor lesen & Zeiger an Anfang stellen
endp

if USEDBCS
proc IsDbcsLeadByte
;Testet DL auf FÅhrungsbyte von Zwei-Byte-ZeichensÑtzen
;PE: DL=Zeichen oder FÅhrungsbyte
;PA: CY=1: kein FÅhrungsbyte
;VR: -
	push	ds si ax
	 lds	si,[lead_byte_table]
@@l:	 lodsw
	 cmp	ax,1
	 jc	@@e
	 cmp	dl,al
	 jc	@@e		;hoffentlich aufsteigend sortiert!
	 cmp	ah,dl
	 jc	@@l
@@e:	pop	ax si ds
	ret
endp
endif ;USEDBCS

Upcase2:
	call	Upcase
	xchg	ah,al

proc Upcase
;konvertiert AL in Gro·buchstaben, auch fÅr >=80h
;fÅr Dateinamensvergleich bei LFN
;Darf nicht fÅr TrailBytes aufgerufen werden!
;Dass es mit LeadBytes geht, dafÅr sorgt DOS mit einer 1:1-Tabelle;
;DOSLFN vertraut dieser (komischen) Sache nicht, umgeht Upcase auch dann.
;PE: AL=Zeichen
;PA: AL=Zeichen oder Gro·buchstabe
;VR: AL
	cmp	al,'a'
	jb	@@1
	cmp	al,'z'
	ja	@@2
	bres	al,bit 5
@@1:	ret
@@2:	cmp	al,80h
	jb	@@1
	push	ds bx
	 lds	bx,[uppercase_table]
	 xlat
	pop	bx ds
	ret
endp

proc Globbing
;FU: Dateinamen-Vergleich mit DOS-typischer Suchmaske
;PE: SI=MASKE (kann unter DOS auch Name sein)
;    DI=NAME  (beide Strings seien korrekte DBCS-Strings)
;    DS,ES=CS
;PA: CY=0 bei Treffer
;VR: AX,DX (DL geht bei HandleDBCS drauf, DH ist "Punkte-ZÑhler")
	mov	dh,0
@@r:	push	si di
@@l:	 lodsb			;MASKE
	 mov	ah,[di]		;NAME
	 cmp	ah,'.'
	 jne	@@1a
	 inc	dh		;NAME enthÑlt Punkt
@@1a:	 cmp	al,'.'		;MASKE-Punkt (mit Sonderbedeutung)?
	 jne	@@nodot
	 cmp	[by si],0	;folgt Stringende?
	 je	@@dotatend	;Bedeutung: NAME darf keinen Punkt haben
	 cmp	[wo si],'*'	;folgt Stern und Stringende?
	 je	@@dotstar	;Bedeutung: NAME ohne Punkt darf zu Ende sein
@@nodot:
	 or	al,al
	 jz	@@end
	 cmp	al,'*'
	 jz	@@star
@@2:	 inc	di		;erst jetzt NAME-Zeiger vorrÅcken!
	 or	ah,ah
	 jz	@@f
	 cmp	al,'?'
ife USEDBCS
	 jz	@@l
else
	 jz	@@qm
	 mov	dl,al
	 call	IsDbcsLeadByte
	 jnc	@@leadbyte	;gibt's nicht mit Upcase!
endif
	 call	UpCase2
@@trail: cmp	al,ah
	 jz	@@l
@@f:	 stc
@@e:	pop	di si
	ret

@@end:	 cmp	al,ah		;Auch Null? CY=1 wenn ah<>0! (Stringenden
				; fallen nicht zusammen!)
	 jmp	@@e		;okay oder auch nicht!
@@dotatend:
	 or	dh,dh
	 jnz	@@f		;Fehler wenn Punkt enthalten!
	 ;jmp	@@e0		;already know DH is zero, so just fall through
@@dotstar:
	 or	dh,dh
	 jnz	@@2		;weiter so, wenn Punkt enthalten
@@e0:	 cmp	dh,ah		;NAME muss zu Ende sein fÅr CY=0
	 jmp	@@e
@@star: 		;bei Stern
	 call	@@r		;Rekursion!
	 jnc	@@e		;wenn der Rest passt, dann ist's OK
	 mov	dl,[di]
	 or	dl,dl
	 jz	@@f		;Wenn NAME zu Ende, dann Fehler
	 inc	di
ife USEDBCS
	 jmp	@@star		;mit nÑchstem Zeichen(!) weitermachen
else
	 call	IsDbcsLeadByte
	 jc	@@star
	 inc	di
	 jmp	@@star		;mit nÑchstem Zeichen(!) weitermachen
@@qm:			;bei Fragezeichen: ganzes Zeichen(!) Åbergehen
	 mov	dl,ah
	 call	IsDbcsLeadByte
	 jc	@@l
	 inc	di		;Trailbyte ungesehen Åbergehen
	 jmp	@@l
@@leadbyte:
	 cmp	al,ah
	 jnz	@@f
	 lodsb			;MASKE Trail, darf nichts ungÅltiges sein!
	 mov	ah,[di]		;NAME Trail
	 inc	di
	 jmp	@@trail 	;zum Vergleich der Bytes
endif ;USEDBCS
endp

proc Glob_LFN_Proc
;Globbing fÅr FAT lange UND kurze Namen (hier gleich Win95-Verhalten)
	call	Locate_DirEnt
	;jc	@@e		;raus bei Fehler
	jc	_glob_ret
	mov	al,[(TDirEnt bx).attr]
	call	Match_Attr
	;jnz	@@e		;raus, kein Treffer! (CY=0)
	jnz	_glob_ret
	cmp	dl,1
	jne	@@cmpshort
	mov	si,[LongName]
	call	GlobbingEx	;LFN-Suche
	;jz	@@e		;Treffer, raus!
	jz	_glob_ret
@@cmpshort:
	mov	si,ofs ShortName
	;call	GlobbingEx	;SFN-Suche mit LFN-Syntax
;@@e:	ret
endp

proc GlobbingEx
;FU: wie Globbing, testet jedoch auch noch bei Treffer, ob bei
;    File_Flag_DotAtEnd der Name keine Erweiterung hat
;    (Der Trick, im FCB das erste Zeichen der Erweiterung zu testen,
;     klappt bei CDs nicht, oder man mÅsste da erst nach FCB konvertieren)
;PE: SI=Name (umgekehrt als bei Globbing!!)
;    [CurPathComp]=Maske (immer ohne '.' am Ende)
;    [File_Flags]=Punkt-Merker "File_Flag_DotAtEnd"
;    DS,ES=CS
;PA: Z=1 bei Treffer
;    CY=0 (immer)
;VR: AX,DI(=Maske)
	mov	di,[CurPathComp]
	xchg	si,di
	call	Globbing
	xchg	si,di
	db	0D6h		;setalc
	or	al,al		;Umwandlung NC->Z
_glob_ret:
	ret
endp

proc BE_Uni2Oem			;Big Endian Version
	xchg	ah,al
endp
proc Uni2Oem
;Konvertiert Unicode-Zeichen zu OEM-Zeichen anhand [UniXlat]
;PE: AX=Unicode-Zeichen
;    DI=Speicherziel
;PA: AL=Oem-Zeichen oder zweites Byte bei DBCS (nur wenn IsDbcsLeadByte)
;       (Da TrailByte>=40h interessiert es nicht bei der Sonderzeichenbeh.)
;    AL='_' bei nicht konvertierbarem Zeichen sowie PF_Fail_Uni2Oem gesetzt
;    DI=vorgerÅcktes Speicherziel
;    Z=1 wenn AL=0
;VR: AX,DI
	cmp	ax,80h
	jc	@@e
	push	cx di
	 mov	di,[UniXlat]
	 or	di,di
	 jz	@@nc		;ohne Tabelle keine öbersetzung
if USEDBCS
	 push	di
endif
	 mov	cx,80h		;WIRD HIER GEPATCHT!
UniTableLen = wo $-2
	 push	cx
	  repne	scasw		;wenn gefunden bei Index=0, dann CX=7Fh
	 pop	ax
if USEDBCS
	 pop	di
endif
	 jne	@@NoConv
	 sub	ax,cx		;aus Index 0 wird AX=1
	 add	ax,7Fh		;nun Index 0 ist AX=80h
if USEDBCS
	 or	ah,ah		;>=100h?
	 jz	@@e1		;1-Byte-Zeichen
	 dec	ah		;-100h
	 div	[by HIGH TrailMinLen]	;AH=TrailIndex, AL=LeadIndex
	 push	dx
	  xor	dx,dx
	  xchg	dh,ah		;TrailIndex retten, AH nullsetzen
	  inc	ax		;1-basiert
	  ;mov	di,[UniXlat]
	  mov	cl,80h		;wird NICHT gepatcht!
	  repne	scasw		;MUSS gefunden werden! Sonst Fehler in .TBL
	  mov	dl,0FFh		;AH ist 0
	  sub	dl,cl		;Index 0 -> Leadbyte 80h
;	  call	IsDbcsLeadByte	;Das sollte es sein!
	  xchg	dx,ax		;AL=LeadByte, AH=TrailIndex
	 pop	dx
;	 jc	@@NoConv	;So geht es nicht!
	 pop	di
	 stosb			;Lead-Byte schreiben
	 xchg	ah,al
	 add	al,[by LOW TrailMinLen]
	 jmp	@@e2
endif ;USEDBCS
@@nc:
	 or	ah,ah		;>=100h?
	 jz	@@e1		;geht OK, ISO-Latin-1 annehmen
@@NoConv:
	 INT3			;sollte sehr selten vorkommen!
	 mov	al,'_'		;nicht konvertierbares Zeichen
	 BSET	[PFlags],PF_Fail_Uni2Oem
@@e1:	pop	di
@@e2:	pop	cx
@@e:	stosb
	or	al,al
	ret
endp

proc Oem2Uni
;FU: konvertiert jede Art von OEM-Zeichen in Unicode anhand [UniXlat]
;PE: SI=Quellstring
;PA: AX=Unicode-Zeichen
;    SI=vorgerÅckter Quellstring
;VR: EAX,SI
;BUG: Bei DBCS-Codeseite, aber OHNE LeadByteTable (die Situation beim Start
;     einer chinesischen Win9x/Me-Bootdiskette ohne Aufruf von PDOS95.BAT)
;     ist das Ergebnis von Oem2Uni dasselbe
	xor	eax,eax
	lodsb
	cmp	al,80h
	jc	@@e
	push	ecx dx
	 movzx	ecx,[UniXlat]
	 jcxz	@@e1		;ohne Tabelle keine öbersetzung: ISO-Latin-1
	 mov	dx,ax		;Kopie zum Test, DH=0
	 dec	ch		;CX-100h (CX > 100h)
	 mov	ax,[ecx+2*eax]
if USEDBCS
	 cmp	ax,80h		;ein LeadByte-Index? (!Forderung fÅr SBCS!)
	 jnc	@@e1		;nein, OK
;	 call	IsDbcsLeadByte	;DL extra prÅfen
	 xchg	ax,dx		;LeadIndex nach DX, AH=0 {LeadByte nach AL}
;	 jc	@@e1		;nein, Chinesisch ist noch nicht aktiv!
	 lodsb			;Trail-Byte "ziehen", AH=0
	 sub	al,[by LOW TrailMinLen]
	 ;jc	@@e1		;fÅhrt zu falschem Chinesisch (GB vs. GBK)
	 xchg	dx,ax		;LeadIndex nach AX, TrailByte nach DX
	 dec	ax		;Index 0 (ungenutzt)?
	 js	@@e1		;Wird Unicode FFFF draus!
	 mul	[by HIGH TrailMinLen]	;Index->Adresse des TrailByteVektors
	 add	ax,dx		;TrailIndex dazu
	 add	ch,2		;CX+200h ([UniXlat]+100h)
	 mov	ax,[ecx+2*eax]
endif ;USEDBCS
@@e1:	pop	dx ecx
@@e:	ret
endp

proc calc_check
;FU: FCB-PrÅfsumme berechnen
;PE: SI=FCB-Zeiger
;PA: AH=PrÅfsumme
;VR: AX,CX=0
	mov	cx,11
	mov	ah,ch		;mit 0 vorbesetzen
@@l2:	ror	ah,1
	lodsb
	add	ah,al
	loop	@@l2
	ret
endp

proc store_longpos
;FU: store the position of the longname directory entry
;PE: [CurSector]=sector containing entry
;    BX=offset of entry
;    [Sektorp]=offset of sector in memory
;PA: [longpos_s]:[longpos_a] filled
;VR: SI,DI,AX
	mov	di,ofs longpos_s
store_entry:
	mov	si,ofs CurSector
	movsd
store_offset:
	mov	ax,bx
	sub	ax,[Sektorp]
	stosw			;longpos_a
	ret
endp

proc Locate_DirEnt
;FU: von BX aus gÅltigen Nicht-LFN-DirEnt aufsuchen, dabei longname auffÅllen
;    Gelîschte DirEnts werden einfach Åbergangen (hier noch kein Unerase)
;PE: BX=Zeiger in Sektorpuffer auf ein DirEnt oder LfnDirEnt
;    DS,ES=CS
;PA: BX=Zeiger auf DirEnt,
;    CY=1 wenn Ende
;    DL=1: LFN gÅltig,
;    DL=FF: LFN nur wegen Checksumme falsch (aber trotzdem ungÅltig!)
;    [longname] gefÅllt mit langem Dateinamen, Leerstring wenn DL<>1
;    [shortname] gefÅllt mit 8.3-Namen
;    [longpos_s] Position Startsektor LFN
;    [longpos_a] Zeiger BX in Sektor-Puffer
;    [PFlags]&PF_Fail_Uni2Oem gelîscht oder gesetzt
;VR: alle
;in der Schleife: DL=Sequenz-Nummer, DH=PrÅfsumme
	mov	dl,0
@@l:	mov	al,[(TLfnDirEnt bx).count]
	cmp	al,1
	jc	@@e		;Ende!
	cmp	al,0E5h
	je	@@3a		;nÑchste Runde, LFN-in-Aufbau lîschen
	cmp	[(TLfnDirEnt bx).attr],0Fh	;LFN-Kennung?
	jne	@@exk		;BX ist OK, zeigt auf normalen DirEnt
	test	al,40h		;"Letztes" StÅckel LFN?
	jz	@@2
	and	al,3Fh		;Sequenz-Nummer
	mov	dl,al
	jz	@@3		;ungÅltig, 0
	cmp	al,20
	ja	@@3		;ungÅltig, >20
	call	store_longpos
	mov	dh,[(TLfnDirEnt bx).check]	;PrÅfsumme
@@2a:
	mov	al,13*2
	mul	dl		;Adresse ermitteln
	mov	di,[longname_26]
	add	di,ax		;AL<>0 fÅr Copy_Uni_Oem!
	lea	si,[(TLfnDirEnt bx).name1]
	push	di
	 mov	cx,5
	 rep	movsw
	 inc	si
	 lodsw			;zusammen "add si,3"
	 mov	cl,6
	 rep	movsw
	 lodsw			;add si,2
	 movsw
	 movsw
	pop	di
	xor	ax,ax
	mov	cl,13
	repne	scasw		;Unicode-Null suchen
	bt	[wo (TLfnDirEnt bx).count],6 ;"Letztes" StÅck?
	jz	@@t		;wenn Namensteil <13 Zeichen
	jnc	@@3		;nein
	stosw			;terminieren!
	db	0b8h		;MOV AX,nnnn
@@t:
	jnc	@@3a		;UngÅltig, DirEnt verwerfen
	jmp	@@3		;Terminierung nicht (mehr) erforderlich
@@2:
	cmp	dl,2		;Sequenz noch Null oder bereits 1?
	jc	@@3a		;ungÅltiger LFN
	dec	dx
	and	al,3Fh
	cmp	dl,al
	jne	@@3a		;Reihenfolge falsch
	cmp	dh,[(TLfnDirEnt bx).check]	;PrÅfsumme gleich?
	je	@@2a		;PrÅfsumme gleich
@@3a:
	mov	dl,0
@@3:
	push	dx
	 call	Next_DirEnt
	pop	dx
	jnc	@@l
@@e:	ret
@@exk:	;BX zeigt auf kurzen Dateinamen, öberprÅfung von Checksum
	BRES	[PFlags],PF_Fail_Uni2Oem	;FÅr den Fall: kein LFN
	mov	di,[longname]
	cmp	dl,1
	jnz	@@nolong
	mov	si,bx
	call	calc_check	;SI->AL
	cmp	ah,dh
	jz	@@e2
	mov	dl,0FFh
@@nolong:
	and	[wo di],0	;auch: Eintrag lîschen
if USEXP
;XP uses bits 3 & 4 of the Reserved byte to indicate the name and/or extension
;is lower case.
	mov	ah,[(TDirEnt bx).resv]
	and	ah,8+16
	jz	@@e3
	push	di
	 call	Copy_FCB_8P3	;leaves DI at NUL
	pop	si
	cmp	ah,16
	ja	@@lwr		;whole name is lower
	mov	ax,0
xpdot = wo $-2
	je	@@ext
	xchg	di,ax		;stop at the extension
	db	0b0h		;MOV AL,nn
@@ext:	xchg	si,ax		;start at the extension
@@lwr:	lodsb
	cmp	al,'A'
	jb	@@lwr1
	cmp	al,'Z'
	ja	@@lwr1
	or	[by si-1],20h
@@lwr1: cmp	si,di
	jb	@@lwr
	call	store_longpos	;long = short
	jmp	@@e3
endif ;USEXP
@@e2:	mov	si,di
@@l2:	lodsw
	call	Uni2Oem		;Es wird bestenfalls kÅrzer!
	jnz	@@l2
@@e3:	mov	di,ofs shortname
	;call	Copy_FCB_8P3
	;clc			;(above will clear carry)
	;ret
endp

proc Copy_FCB_8P3
;Kopiert FCB-Dateiname in 8.3-Form nach DI, auch fÅr FCB mit Leerzeichen!
;PE: BX=Zeiger auf Directory-Eintrag
;    ES:DI=Ziel (bei BX<>FCB_Name E5h am Anfang in '?', 05h in E5h wandelnd)
;    DS=CS (benîtigt KEIN ES=DS wegen/fÅr ax=71A8h)
;PA: DI vorgerÅckt (auf die Null), String nullterminiert und ohne Backslash
;VR: AL,CX=0,SI,DI
	mov	si,bx
Copy_FCB_8P3_from_SI:
	push	bx
	 mov	cx,'?'
	 cmp	si,ofs FCB_Name
	 lodsb
	 je	@@1		;aus lokalem FCB-Puffer NICHT wandeln!
	 call	Change_First_FCB_Byte
@@1:	 mov	bx,di		;Ein Leerzeichen vor dem Punkt zulassend...
	 mov	cl,8
	 call	Copy_Term_Spaces_1
if USEXP
	 mov	[xpdot],di
endif
	 mov	al,'.'
	 stosb			;Der Punkt lîscht sich wieder, wenn keine Ext
	 mov	cl,3
	 call	Copy_Term_Spaces
	pop	bx
@@e:	and	[by es:di],ch	;set NUL and clear carry for Locate_DirEnt
	ret
endp

proc Copy_Term_Spaces
;Hilfsroutine fÅr Copy_FCB_8P3
@@l:	lodsb
Copy_Term_Spaces_1:		;Einsprung fÅr modifiziertes AL
	stosb
	cmp	al,' '
	je	@@f
	mov	bx,di		;Mîglicher Ende-Zeiger (vorrÅcken)
@@f:	loop	@@l
	mov	di,bx		;bei Trailing Spaces zurÅckstellen
	ret
endp

proc noentry_StrIComp	;StringCompare mit UpCase
;PE: SI=Maske
;    DI=Name
;    CLD
;PA: CY=1: String DI grî·er als String SI
;    Z=0: Strings ungleich
;    Z=1: Strings gleich, AX=0
;    SI und DI zeigen hinter das erste ungleiche Zeichen
;    oder hinter die Null(en)
;VR: SI,DI,AX,Flags
@@2:
	das			;one byte AL == 0 (but corrupts AL, needs NC)
	jz	@@e		;Beide Strings zu Ende
StrICompFS:
	nop			;Replaced with SEGFS for lfn_move
StrIComp:
	lodsb
	mov	ah,[di]
	inc	di
	call	UpCase2
	cmp	ah,al
	jz	@@2
@@e:
	ret
endp

proc Match_Attr
;PrÅft ob Attribut mit [SearchAttr] passt
;PE: AL=Attribut
;PA: Z=1: passt
;    CY=0 (immer)
;VR: AL
	test	al,[by LOW  SearchAttr]
	jnz	@@e		;pa·t leider nicht
Match_MM_Attr:			;Einstieg: Nur Must-Match-Attribut testen
	not	al
	test	al,[by HIGH SearchAttr]
@@e:	ret
endp

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;++ Neue, "objektorientierte" FindFirst/FindNext-Routine ++
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;Match&Stop-Routinen mit folgenden Parametern:
;PE: BX=DirEnt-Zeiger fÅr aktuelles DirEnt
;    [CurSector]=Aktuelle Sektornummer
;    DX=User-Daten (frei verwendbar)
;PA: CY=1: Such-Ende einleiten (AX=Fehlercode 9912h)
;    Z=1: Treffer
;    DX=User-Daten (beim nÑchsten Aufruf wieder aktuell)
;VR: AX,CX,DX,SI,DI (BX darf au·er bei CY=1 NICHT verÑndert werden!)

proc Check_Virtual_Remove
;PE: [CurSector]:BX=Verzeichniseintrag
;PA: Z=1 wenn Eintrag virtuell gelîscht
;VR: AX,SI,DI
	cmp	[FuncNum],56h
	jne	@@e
	mov	di,[SearchAttr]
	cmp	di,1
	jc	@@e		;mit NZ
	mov	si,ofs CurSector
	cmpsd
	jne	@@e
	cmp	[di],bx
@@e:	ret
endp

proc Match_LFN_Proc
;FU: Sucht fÅr FAT lange UND kurze Namen
;PE: BX=Anfang irgend eines Verzeichniseintrags (LFN, SFN, gelîscht)
;    [CurPathComp]=Zu vergleichende Pfad-Komponente
;    [xxx]=(bei MOVE) zu ignorierender Verzeichnis-Eintrag
;PA: CY=1: Fehler: BX ist kein Verzeichniseintrag
;    BX=Anfang eines SFN-Verzeichniseintrags
;    weitere Ergebnisparameter wie bei Locate_DirEnt
;    Z=1: Name passt
;    Z=0: Verzeichniseintrag ist Label oder passt nicht
	call	Locate_DirEnt
	jc	@@e		;raus bei Fehler
;Bugfix 11/02: Volume Labels nicht verfolgen!
	test	[(TDirEnt bx).attr],8
	jnz	@@e		;raus bei Label
;Fix 12/02: Zu lîschender Eintrag bei lfn_move Åbergehen
	call	Check_Virtual_Remove
	jnz	@@1
	inc	ax		;nie -1, daher Z=0
@@e:	ret
@@1:
;	cmp	dl,1		;LFN vorgefunden?
;	jne	@@cmpshort	;unnîtig weil longname[0]=0 ohne LFN
	mov	si,[Longname]
	call	Match_Current
	jz	@@e		;Treffer!
@@cmpshort:
	mov	si,ofs ShortName
Match_Current:
	mov	di,[CurPathComp]
	call	StrIComp
	clc			;nie Fehler:-)
	ret
endp

proc DirScan pascal
;Allgemeine Routine zum "Scannen" eines Verzeichnisses
;dank Pointer zur Match&Stop-Routine
;PE: [CurSector]=Startsektor des Verzeichnisses
;    BX=MatchProc-Zeiger (bei NextDirScan muss dieser in [MatchPtr] stehen!)
;PA: CY=1: Nicht gefunden
;VR: AX,BX,CX,DX,SI,DI
	mov	[MatchPtr],bx
	call	ReadSec_setBX
	jc	@@e
@@l:	call	[MatchPtr]
	jbe	@@e		;bei CY=1 (Fehler) oder Z=1 (gefunden)
NextDirScan:
	call	Next_DirEnt
	jnc	@@l
@@e:	ret
endp

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

proc Is_FCB_Equal
;FU: Testet momentanen DirEnt mit Gleichheit zu FCB_Name
;PE: BX=DirEnt-Zeiger (mit 1. Byte =05 fÅr E5)
;    [FCB_Name] mit Vergleichsstring gefÅllt
;PA: Z=1 wenn gleich
;VR: AL,DI,CX (CH=0)
	lea	di,[FCB_Name]
Is_FCB_Equal_DI:
	mov	si,bx
	xor	cx,cx
	lodsb			;aus Festplatten-Sektor entnehmen
	call	Change_First_FCB_Byte
	scasb
	jne	@@e
	mov	cl,5		;CH ist schon null
	repe	cmpsw		;Die restlichen 10 Bytes brauchen kein Extra
@@e:	ret
endp


;**** Hilfsprogramme fÅr TRUENAME ****

proc IsEnd		;Testet AL auf Ende von Pfad-Komponente
	or	al,al
	jz	@@e
IsBS:	cmp	al,'\'
	jz	@@e
	cmp	al,'/'
@@e:	ret
endp

proc IsInvalidLfnChar
	push	di cx
	 mov	di,ofs Invalid_Lfn_Chars
	 mov	cx,8
	 repne	scasb
	pop	cx di
	ret
endp

if USEDBCS
proc HandleDBCS
;PE: AL=Zeichen, AH Bit 7 = Trailbyte-Flag
;PA: CY=1 wenn Trailbyte
;    NO RETURN mit AX=2 wenn falsches Trailbyte <40h (Notbremse)
;VR: DL(=AL), AH Bit 7
	shl	ah,1
	mov	dl,al
	jc	@@1
	call	IsDbcsLeadByte	;NC wenn's so ist!
	cmc
	rcr	ah,1		;Hinein das Bit! CY=0
	ret			;NC wenn kein Trail-Byte
@@1:	cmp	al,40h
	jc	SetErr2		;UngÅltiges Trail-Byte (Parsen nicht mîglich)!
				;Ist 3, wenn \/ folgt? (hmpf)
	shr	ah,1		;0 einschieben
	stc
	ret
endp
endif ;USEDBCS

proc noentry_SwapSlashes
;FU: String parsen und DBCS-sicher \ zu / machen, 05h zurÅck zu E5h machen
;PE: DS:SI=Zeiger auf String
;    DH=0: bei Leerstring Ergebnis-SI auf letztes Zeichen, sonst auf '\0'
;    DH=1: Ergebnis-SI stets auf '\0'
;PA: SI vorgerÅckt entsprechend DH
;    Zeichen im Puffer entsprechend geÑndert
;    NO RETURN bei falschem Trail-Byte
;VR: SI,DX,AX (AH Bit 7 =0, andere Bits unverÑndert)
@@pal:
if USEDBCS
	call	HandleDBCS
	jc	@@paf		;bei Trailbyte nicht auf \ testen!
endif
	inc	dh		;1 Zeichen mitzÑhlen
	cmp	al,'\'
	jne	@@paf
	mov	[by si-1],'/'   ;auf Unix drehen, damit es kein Trail-Byte ist
SwapSlashes:
	cmp	[by si],05h
	jne	@@paf
	mov	[by si],0E5h	;Unsinn von DOS' TRUENAME rÅckgÑngig machen
@@paf:	lodsb
	or	al,al
	jnz	@@pal
	sub	dh,1		;CY setzen lassen, wenn Wurzelverzeichnis
	sbb	si,1		;auf die Null oder auf letzten /
	ret
endp

proc GetSubstRoot
;Ermittelt Startverzeichnis fÅr geSUBSTetes Laufwerk oder schlicht X:\
;PE: FS:SI=Dateiname
;    DS=ES:DI=Puffer
;PA: Puffer gefÅllt
;    [subst_drive]=DL=virtuelles Laufwerk, DH=0
;    BX=DI=Zeiger auf letzten '\' oder #0 im Puffer
;    SI um 2 vorgerÅckt, wenn Laufwerk angegeben
;    AX=Pfadquelle, Puffer+3 (normalerweise), grî·er bei UNC-Pfad
;    NO RETURN bei Fehler
;    [PFlags]???
;VR: EAX,BX,CX,DX,SI,DI
;N:  DOS' TRUENAME liefert bei IFS-Laufwerken (CDROM, Netzwerk) einen
;    Netzwerkpfad. Da IFS-Laufwerke nicht SUBST-bar sind, wird in diesem Fall
;    einfach 'Laufwerksbuchstabe:\' zurÅckgegeben
;    Der Pfad C:\DEV\NUL wird zu C:/NUL (mit Forward-Slash!) aufgelîst.
	push	di
	 mov	ax,[fs:si]
	 or	al,al
	 jz	SetErr3		;GÑnzlich leer ist ein FEHLER!
	 cmp	ah,':'		;Laufwerk gegeben?
	 je	@@take_drive
	 mov	ah,19h		;aktuelles Laufwerk beschaffen
	 call	CallOld
	 add	al,'A'
	 jmp	@@2
@@take_drive:
	 segfs
	 movsw			;Laufwerk Åbertragen, SI+=2, DI+=2
	 call	upcase
@@2:	 movzx	dx,al		;DH=0
	 mov	ax,[fs:si]
	 call	IsBS
	 jnz	@@normal
	 mov	al,ah
	 call	IsBS
	 jnz	@@normal
	 mov	dl,0		;Kennung UNC-Laufwerk!
	pop	di
	stc
	jmp	@@e
@@normal:
	 mov	ax,'\'		;TRUENAME kein Backslash anhÑngen lassen
	 stosw
	pop	di
	push	si
	 mov	si,di		;Darf lt. RBIL auch Åbereinander liegen
	 mov	ah,60h
	 call	CallOldAndThrow	;So funktioniert's auch geSUBSTet
	 mov	ax,'\\'		;Netzwerkpfad? (Kann auch MSCDEX sein!)
	 scasw
	 jne	@@3
	 mov	eax,'\:?'       ;'?' wird ersetzt
drvcolbk = dwo $-4
	 mov	al,dl
	 mov	[si],eax
	 call	strlenp1	;Ende von "\\S.\A." suchen
	 dec	di
@@3:	 inc	di
	 push	di dx
	  mov	dh,-3		;Kode in SwapSlashes arbeiten lassen!
	  call	SwapSlashes	;Terminierende Null oder Backslash suchen
	 pop	dx ax
	 mov	di,si
	pop	si
@@e:	mov     bx,di
	mov	[subst_drive],dl
	ret
endp

proc Truename
;DE: Kopiert DOS-Dateinamen in <longbuffer> und macht dabei ein TRUENAME:
;    * PrÅft auf ungÅltige LFN-Zeichen ab
;    * holt KEINE Laufwerksdaten
;    * ermittelt ggf. das aktuelle Verzeichnis
;    * lîst ..-Referenzen auf
;    * schneidet nachlaufende Leerzeichen von Komponenten ab
;    * schneidet nachlaufende Punkte ab, au·er bei "*" in Komponente
;    * * und ? sind ungÅltige Zeichen vor \
;    * " \" wirkt wie "."
;    * wandelt alle '\' in '/' (wegen DBCS)
;    * fasst mehrere '\' '/' zusammen zu einem
;    * wandelt E5h NICHT zu 05h, wie das DOS' TRUENAME (AH=60h) tut! (brrr)
;BUG: interpretiert Netzwerkpfad "\\maschine\freigabe\pfadname" nicht
;     Der Pfad C:\DEV\NUL wird ohne PF_Lfn_Input zu C:/NUL aufgelîst (OK),
;     nicht aber bei gesetztem PF_Lfn_Input.
;
;PE: FS:SI=Dateiname, CLD
;    [PFlags]:PF_LFN_Input=Schalter, ob Dateiname "lang" oder "kurz"
;PA: <longbuffer> gefÅllt mit TRUENAME entspr. Int21/7160/CX=0
;    NO RETURN bei Fehler
;    [subst_root]=Anzahl zu Åbergehender Zeichen fÅr SUBST
;    [subst_drive]=virtuelles Laufwerk, =LongBuffer[0] wenn kein SUBST
;VR: EAX,BX,CX,DX,SI,DI (=alle)
	mov	di,[longbuffer]
	BTST	[PFlags],PF_LFN_Input
	jnz	@@lfn_truename
	push	si di
	 call	GetSubstRoot
	pop	di si
@@unc:	push	ax ds
	 LD	ds,fs
	 mov	ah,60h
	 call	CallOld		;DOS noch einmal werkeln lassen (kein THROW)
	pop	ds si
	jc	Throw
	cmp	[by di],'\'	;Netzwerkpfad oder CDROM? (Kein Laufwerk?)
	jne	@@sfn1
	mov	al,dl		;nicht SUBSTbar, Laufwerk Åbernehmen
	or	al,al
	jz	@@sfn1		;Netzwerkpfad, nicht behandeln!
	push	di
	 stosb
	 mov	ax,'\:'
	 stosw
	 call	strcpy		;UNC-Netzwerkpfad killen - Rest vorkopieren
	pop	di
@@sfn1:	mov	si,di
	call	SwapSlashes
	jmp	@@ee
@@lfn_truename:
	call	GetSubstRoot	;liefert DH=0
	jc	@@unc
@@l0:	inc	dh
	segfs
	lodsb			;DBCS-sicher: FÅhrungs-Backslashes weg!
	call	IsBS
	jz	@@l0		;kein aktuelles Verzeichnis holen!
	dec	si		;also auf ersten Nicht-Backslash
	dec	dh
	jnz	@@0
	mov	al,'/'
	stosb
	xchg	si,di
	sub	dl,'@'		;fÅr GetCurDir: 'A:'=1 usw.
	mov	ah,47h
	call	CallOldAndThrow	;Aktuelles Vrz. nach <longbuffer>
	call	SwapSlashes	;SI ans Ende rÅcken, dabei \ zu / machen
	xchg	di,si
@@0:	movzx	ax,[by fs:si]
;AH Bit 0 = ?*-Speicher (File_Flag_Wildcards) - um falschen Pfad auszuwerfen
;   Bit 2 = *-Speicher (File_Flag_Has_Star) - um Punkt rechts stehen zu lassen
;   Bit 3 = .-Speicher (File_Flag_Has_Dot) - um Leer-Pfade ("/ /") zu killen
;   Bit 7 = LeadByte-Speicher - um 5Ch ('\') als TrailByte durchzulassen
@@new0:	or	al,al		;Folgen Zeichen? (Mit Sicherheit kein \/)
	jnz	@@new_name	;nein, so stehen lassen
	cmp	di,[longbuffer2] ;Root-Backslash?
	jne	@@e
	inc	di		;stehen lassen!
@@e:	stosb
	;und als letztes alles vor dem letzten Backslash upcasen (eigentlich)
@@ee:	xchg	ax,bx
	sub	ax,[longbuffer2]
	mov	[subst_root],ax
	ret

@@scandot:
;Name, der mit '.' anfÑngt, kînnte nur aus Punkten bestehen, und ist
;dann aktuelles, Åbergeordnetes usw. Verzeichnis!
	sub	cx,cx		;Punkte-ZÑhler
	push	si		;Startzeiger retten
@@scn:	 inc	cx
	 segfs
	 lodsb
	 cmp	al,'.'
	 je	@@scn
	 call	IsEnd
	 jz	@@rmb
	 mov	al,'.'
	pop	si
	jmp	@@setd		;ist ein "normaler" Name, von vorn
;Ende einer Punktkette erreicht, in CX=Anzahl Punkte

@@rmb:	pop	dx		;Zeiger verwerfen
@@rl:	dec	di		;CX Ebenen aufsteigen, AL enthÑlt '\' oder 0
	cmp	[by di],'/'	;DBCS-sicher
	jne	@@rl
	cmp	di,bx		;Der SUBST-Pfadanteil ist "heilig"!
	loopnz	@@rl
	jcxz	@@new0		;wenn CX<>0 dann ging es nicht "hoch genug"
	jmp	SetErr3

@@new_name:
	BTST	ah,File_Flag_Wildcards
	jnz	@@err2		;Vor / sind keine ?* erlaubt!
	mov	al,'/'		;ja, jetzt Pfad-Trenner setzen
	stosb		;öberlauf-öberwachung unnîtig, Reserve am Puffer-Ende
@@l1:	segfs
	lodsb
	call	IsBS
	jz	@@l1		;mehrfache Slash/Backslash zusammenfassen
	and	ax,0FFh		;AH: wenigstens das Has_Dot lîschen
	jz	@@e
	cmp	al,'.'
	jz	@@scandot
	jmp	@@be
	;Klappt nicht mit Unterprogramm wegen neuer Globbing-Routine
@@l3a:	cmp	al,'?'		;PrÅfbits in AH setzen
	jne	@@3b
	BSET	ah,File_Flag_Wildcards
@@3b:	cmp	al,'.'
	jne	@@3a
@@setd:	BSET	ah,File_Flag_Has_Dot
@@3a:	cmp	al,'*'
	jne	@@l3
	dec	si
@@3al:	inc	si
	cmp	[fs:si],al	;Mehrere Sterne zusammenfassen
	je	@@3al
	BSET	ah,File_Flag_Has_Star or File_Flag_Wildcards
@@l3:	;normaler Name
	cmp	di,[longbuffer_end]
@@err2:	jnc	SetErr2
	stosb

	segfs
	lodsb
@@be:
if USEDBCS
	call	HandleDBCS
	jc	@@l3		;bei Trail-Byte unverÑndert speichern
endif
	call	IsInvalidLfnChar
	jnz	@@l3a		;erlaubt, kopieren
	call	IsEnd
	clc
	jnz	@@err2		;unerlaubtes Zeichen = "Datei nicht gefunden"
	mov	dh,al		;Pfad-Trenner oder Ende nach DH retten
@@l2:	;Ende erreicht, rÅckwÑrts Punkte und Leerzeichen lîschen
	dec	di
	mov	al,[di]
	cmp	al,' '
	je	@@l2		;Leerzeichen sofort weg!
	cmp	al,'/'
	je	@@sla		;nur Leerzeichen: noch kein Fehler!
	cmp	al,'.'
	jne	@@t2e		;Nicht lîschen, wenn * enthalten, zusammenfas.
	BTST	ah,File_Flag_Has_Star	;Stern enthalten?
	jz	@@l2		;nein, der Punkt muss weg
	cmp	[di-1],al	;Punkt davor?
	je	@@l2		;dann muss der Punkt doch noch weg
@@t2e:	inc	di
@@t2f:	mov	al,dh
	jmp	@@new0

@@sla:	BTST	ah,File_Flag_Has_Dot	;Irgendwo ein Punkt gewesen?
	jz	@@t2f		;der Slash bleibt! (Nicht auf @@t2e gehen.)
	jmp	SetErr5		;Das ist ein ganz besonderer Fall!
			;An dieser Stelle hat Win95a noch richtige Bugs!
			;Die zu emulieren habe ich keine Lust.

endp

proc start_stuff
;das langweilige TRUENAME und Laufwerksparameter beschaffen...
;PE: FS:SI=Dateiname
;    [PFlags]:PF_LFN_Input=Schalter, ob Dateiname "lang" oder "kurz"
;PA: NO RETURN bei Fehler
;    CY=0 && Z=1: OK, Wurzelverzeichnis
;    CY=0 && Z=0: OK, Unterverzeichnis, TRUENAME steht in longbuffer
;    SI=longbuffer+3
;    DI=shortbuffer+3 (Laufwerk:\ schon hineinkopiert)
;    [CurSector] gefÅllt mit Startsektor des Hauptverzeichnisses
	call	Truename		;THROWt bei Fehler
	mov	si,[longbuffer]
	mov	al,[si]
	sub	al,40h
	call	GetDrvParams		;egal was dabei rauskommt!
	mov	di,[shortbuffer]
	movsd				;Laufwerk:\NULL
	dec	si			;bleiben im Ziel stehen
	dec	di
Set_Root:
;"Current"-Sektor(en) auf "Hauptverzeichnis" setzen, fÅr MakeLongName
ifdef PATHLOOK
	push	di
	mov	di,[path_ptr]
	cmp	di,ofs path_ptr
	jae	@@full
	mov	[by di],':'
	inc	[path_ptr]
@@full:
	pop	di
endif
	BSET	[PFlags],PF_Follow	;immer mit Verfolgung ansetzen
	call	_set_root_sector
	call	Check_CDFS
	jz	@@nocd
	call	CD_Set_Root
@@nocd:	cmp	[by si],0		;CY immer 0, Z setzen
@@e:	ret
endp

proc same_stuff
;fÅr file_locate und path_locate
;Funktioniert auch im RÅckfallmodus; da wird einfach der Dateiname in FCB_Name
;nach ShortBuffer (DI) kopiert, d.h. da wird ein echter 8.3-Name draus
;PE: PF_Follow=0: Cache umgehen und Sektor nicht "verfolgen"
;    (fÅhrt zum Setzen von [Longpos_s]:[Longpos_a])
;PA: CY=1 wenn nicht gefunden, AL=2 oder 3 je nach Funktionsklasse
;    DI=Short-Buffer-Zeiger vorgerÅckt (nur wenn nicht NIL gewesen)
	push	si di
	  call	Check_FB
	  jc	@@fallback
	  call	find_in_cache
	  jnc	@@shortcut
@@nocache:
	  test	[File_Flags],File_Flag_NDevice
	  jz	@@fallback		;dirty hack 11/01
	  call	Check_CDFS
	  jnz	@@cdfs
	  mov	bx,ofs Match_LFN_Proc
	  call	DirScan
	  jc	@@e
	  push	[SuchSektor]
	   push [CurSector]
	   test [PFlags],PF_Follow
	   jz	$+5
	   call Pick_Sector_From_DirEnt
	   pop	edx			;sector containing current entry
@@catshort:
	   call Get_Attr
	   and	ax,16
	   xchg cx,ax
	  pop	eax			;sector containing parent directory
	  call	Check_Slash
	  jnc	@@nd
	  jcxz	@@e
@@nd:	  call	put_to_cache
@@shortcut:
	 pop	di
	 or	di,di
	 jz	@@skip_copy		;bei Ziel=NIL nicht kopieren!
	 call	ShortNamecpy		;gewonnenen Namen nach DI (ShortBuffer)
	 dec	di
@@skip_copy:
	pop	si
	ret

@@fallback:
	  call	Copy_FCB_8P3_from_FCB_to_ShortName
	  mov	di,[LongName]		;nie langen Namen liefern
	  mov	[by di],0
	  jmp	@@shortcut

@@cdfs:
	  push	[Search.jol.i.sect]
	   call CD_Ping_DirScan_Match
	   jnc	@@catshort		;gefunden!
	   call CD_Pong_DirScan
	   jnc	@@catshort		;Konsistenzfehler
	  pop	eax
@@e:	pop	di si
	mov	al,[FuncNum]
	cmp	al,3Ch			;LFN-Funktion mit Verzeichnissen?
	mov	al,3			;"path not found"
	jc	@@e1
	call	Check_Slash
	adc	al,-1			;modify to "file not found"
	;stc				;(ADC will CY)
@@e1:	ret
endp

proc file_locate
;verfolgt angegebenen Pfad bis zum Schluss
;Wird ziemlich selten gebraucht, weil diese Funktion nicht zur Manipulation
;des DirEnts zu gebrauchen ist! (lfn_chdir, lfn_attr, lfn_shortname)
;PE: FS:SI=Dateiname
;    [PFlags]:PF_LFN_Input=Schalter, ob Dateiname "lang" oder "kurz"
;PA: NO RETURN bei Fehler (THROW zu "Pfad nicht gefunden")
;    [ShortBuffer] gefÅllt mit 8.3-Pfad
;A:  [Longpos_s]:[Longpos_a] sind nicht immer gesetzt!
	call	start_stuff
	jz	@@e			;ist root (und OK)

@@l:	call	Gen_Alias
	call	same_stuff
	jc	SetError
	call	MakeBSlash
	jnz	@@l
	inc	ax			;Z=0
@@e:	ret
endp

proc path_locate
;verfolgt angegebenen Pfad, aber nicht den Dateinamen
;PE: FS:SI=Dateiname
;    [PFlags]:PF_LFN_Input=Schalter, ob Dateiname "lang" oder "kurz"
;PA: NO RETURN bei Fehler (z.B. Pfad nicht gefunden)
;    [ShortBuffer] gefÅllt mit 8.3-Pfad und abschlie·endem Backslash
;    [CurPathComp]=Zeiger auf Dateiname
;BUG: Check_Device ist Sache von TRUENAME!
	call	start_stuff
	jnz	@@l		;nur root ist hier auch Fehler!
	mov	al,[FuncNum]
	cmp	al,4Eh
	;"Keine weiteren Dateien" meldet DOS bei FindFirst auf "c:\"
	je	SetErr18
	cmp	al,43h
@@e5:	jne	SetErr5 	;ansonsten "Zugriff verweigert"
	mov	ax,10h
	cmp	[Client_BL],ah	;Get Attribute of root is OK
	jne	@@e5
	mov	[Client_CX],ax
	jmp	Throw

@@n:	call	same_stuff
	jc	SetError
	call	MakeBSlash
@@l:	call	Gen_Alias
	call	Check_Slash
	jc	@@n		;fertig gefunden, in [CurPathComp]...
;	jmp	Check_Device
endp

proc Check_Device
;D: If file name is a DOS device, DOSLFN should work in FallBack mode
;   and let DOS handle these special files
;I: [FCB_Name]=file name to check
;   [File_Flags]=plausibility bits before comparing
;   [DriverChain]=const FAR pointer to DOS device driver chain
;O: [File_Flags].NDevice=0 if device, unchanged if not
;   CY always clear
;M: CX
	test	[File_Flags],(File_Flag_Is_LFN or File_Flag_Wildcards or File_Flag_Has_Dot)
	jnz	@@e		;cannot be a DOS device
	push	es bx si di
	 mov	bx,ofs DriverChain
@@l:	 les	bx,[es:bx]
	 inc	bx		;was xxxx:FFFF
	 jz	@@ex		;documented end of chain
	 dec	bx
	 ;BTST	[wo es:bx+4],8000h	;character device?
	 ;jz	@@l		;no, continue with next driver
	 mov	cx,4
	 cmp	[es:bx+5],ch
	 jns	@@l
	 lea	di,[bx+10]
	 lea	si,[FCB_Name]
	 repe	cmpsw
	 jne	@@l		;no match, continue with next driver
	 BRES	[File_Flags],File_Flag_NDevice
	 pop	di
	 LD	es,ds
	 mov	di,[ShortBuffer]
	 mov	[CurPathComp],di
	 push	di
	 call	Copy_FCB_8P3_from_FCB_to_DI
@@ex:	pop	di si bx es
@@e:	clc
	ret
endp

proc dirent_locate
;ermittelt DirEnt-Zeiger bx fÅr Datei
;PA: NO RETURN bei Fehler mit "path_locate"
;    CY=1 wenn Datei nicht gefunden (AL=2) oder AL=3 bei Verzeichnis-Fkt.
;    [ShortBuffer] gefÅllt mit 8.3-Pfad und abschlie·endem Backslash (?)
;    BX=DirEnt-Zeiger
;    [longpos_s]+[longpos_a]=LFN-DirEnt-Zeiger (auch bei CY=1 verÑndert!)
;N:  Ein nachlaufender Backslash wird hier nicht angesetzt!
	call	path_locate
File_DirEnt_Locate:
	BTST	[File_Flags],File_Flag_Wildcards
	jnz	SetErr3			;an dieser Stelle nicht erlaubt
	BRES	[PFlags],PF_Follow
	push	di
	 call	same_stuff		;jetzt ohne Cache!
	 jc	@@e
	 call	MakeBSlash
	 call	Check_FB		;FallBack-Modus?
	 jnc	@@e
	 BTST	[File_Flags],File_Flag_Is_LFN
	 jnz	SetErr5			;im Fallback-Modus unzulÑssig!
	 BRES	[File_Flags],File_Flag_LowerCase	;kein LFN erzeugen!
	 mov	ax,4300h
	 call	SFN_CallOld		;Existenz-Test
	 jnc	@@e
	pop	di			;Zeiger stehen lassen!
	ret

@@e:	pop	cx
	ret
endp

proc MakeLongName
;Erzeugt "langen" Dateinamen, nur fÅr lfn_pwd und lfn_longname
;PE: SI=Zeiger auf kurzen Dateinamen (LW-Parameter schon geladen)
;    FS:DI=Ziel (langer Dateiname im Anwender-Adressraum)
;    [subst_root]=Zeichenzahl fÅr SUBST
;PA: CY=1: da ging was schief!
;VR: alle, [subst_root]
	cmp	[by si],0	;Sonderfall fÅr lfn_pwd und lfn_longname
	jz	@@ez		;nichts zu tun im Wurzelverzeichnis!
	add	[subst_root],si
	call	Set_Root

@@l:	call	Gen_Alias
	push	di
	 xor	di,di		;hier: keinen "kurzen Pfad" bauen
	 call	same_stuff
	 jc	SetError
	pop	di
	cmp	si,[subst_root]	;noch vor den auszugebenden Komponenten?
	jbe	@@1
	push	fs di
	push	ds
	mov	bx,[LongName]
	cmp	[by bx],1
	jnc	@@havelong
	mov	bx,ofs ShortName	;Zeiger auf kurzen Namen
@@havelong:
	push	bx
	call	fstrcpy		;Name kopieren
	add	di,ax
	call	Check_Slash
	jnc	@@2
	mov	[by fs:di],'\'
	inc	di
@@1:	call	Check_Slash
	jnc	@@2
	inc	si
@@2:	cmp	[by si],0
	jnz	@@l
@@ez:	mov	[by fs:di],0
@@e:	ret
endp

verteiler:	DVT	39h,lfn_mkdir	;w DS:DX
		DVT	3Ah,lfn_rmdir	;w DS:DX
		DVT	3Bh,lfn_chdir	;r DS:DX
		DVT	41h,lfn_unlink	;w DS:DX       CX SI
		DVT	43h,lfn_attr	;? DS:DX BL    CX SI DI
		DVT	47h,lfn_pwd	;r DS:SI DL
		DVT	4Eh,lfn_ffirst	;r DS:DX ES:DI CX SI
		DVT	4Fh,lfn_fnext	;r BX    ES:DI    SI
		DVT	56h,lfn_move	;w DS:DX ES:DI
		DVT	60h,lfn_name	;r DS:SI ES:DI CX
		DVT	6Ch,lfn_creat	;? DS:SI    BX CX DX DI
		DVT    0A0h,lfn_volinfo	;- DS:DX ES:DI BX CX DX
		DVT    0A1h,lfn_fclose	;r BX
		DVT    0A7h,lfn_timeconv;- DS:SI       BX CX DX
		DVT    0A8h,lfn_genshort;- DS:SI ES:DI DX
		DVT    0AAh,lfn_subst	;- DS:DX BH(=0,1,2) BL(=LW)
		db	0
		_CASE

;Programm-Verteiler-Tabelle fÅr <lfn_attr>
pvt_attr	dw	ofs attr_getattr
		dw	ofs attr_setattr
		dw	ofs attr_getphyssize
		dw	ofs attr_settimem
		dw	ofs attr_gettimem
		dw	ofs attr_settimea
		dw	ofs attr_gettimea
		dw	ofs attr_settimec
		dw	ofs attr_gettimec
;Programm-Verteiler-Tabelle fÅr <lfn_attr bei RÅckfallmodus>
fb_pvt_attr	dw	ofs fb_attr_getattr
		dw	ofs fb_attr_setattr
		dw	ofs SetErr1
		dw	ofs fb_attr_settimem
		dw	ofs fb_attr_gettimem

;Alle Verteiler-Funktionen werden mit Stapelrahmen sowie verÑnderten
;Registern AX=7100h, DS=ES=CS, BP=Rahmenzeiger und DI=?? aufgerufen.
;Bei Aufruf ist das Richtungsflag gelîscht (aufsteigend)
;Sie mÅssen in AX den RÅckgabewert liefern und ansonsten auf den Stapel
;zugeifen.

proc lfn_mkdir
	;1. Finden des LFN-Eintrags
	mov	si,dx
	call	dirent_Locate
	jnc	@@Err5		;Existiert bereits: Fehler!
	call	Check_CDFS_Throw	;auf CD schlecht mîglich:-)
	;2. geeigneten, nicht bereits vorhandenen FCB-Namen ermitteln
	call	build_unique_fcb_name_start_1
	call	SFN_AL_CallOld
	jc	SetError
	call	InvalSector
	;sollte an Cache angehangen werden! (hier noch nicht)
	call	ResetDrv
	;4. LFN dazubasteln
	call	install_long_filename
	jc	@@del
	ret
@@del:	call	DriveClean	;Sektor doch nicht schreiben
	mov	ah,3Ah
	call	SFN_CallOld	;Verzeichnis lîschen
@@Err5: jmp	SetErr5
endp

proc lfn_chdir
	mov	si,dx		;noch unzerstîrt...
	call	file_locate
	jz	@@1		;Root
	call	Check_Slash	;12/02
	jnc	@@1		;kein Backslash am Ende
	mov	[by di-1],ah	;Backslash am Ende entfernen (so tut es 9x)
@@1:	mov	di,[ShortBuffer]
	call	ModifyBuffer	;Nie auf dem Hostlaufwerk!
	mov	dx,di
	mov	ah,3Bh
	jmp	CallOld
endp

proc lfn_pwd
;etwas brutal den User-Puffer missbrauchen, dann TRUENAME werkeln lassen
	sub	ax,ax
	push	si
	 add	al,dl
	 jz	@@1
	 add	ax,':@'
	 mov	[fs:si],ax
	 lodsw			;SI += 2
@@1:	 mov	[wo fs:si],'.'  ;das beschafft das aktuelle Verzeichnis!
	pop	si
	call	start_stuff	;macht den Rest und kÅmmert sich ums SUBST
	mov	si,[LongBuffer2]
	inc	si
	mov	di,[Client_SI]	;FS steht noch
	jmp	MakeLongName
endp

;+++++++++++ 3 Unterprogramme fÅr LFN_Create ++++++++++++++++
proc Copy_FCB_8P3_from_FCB_to_ShortName
	mov	di,ofs ShortName
Copy_FCB_8P3_from_FCB_to_DI:
	push	si di
	 mov	si,ofs FCB_Name
	 call	Copy_FCB_8P3_from_SI
	pop	di si
	ret
endp

proc build_unique_fcb_name_start_1
	mov	si,1
build_unique_fcb_name:
;FU: Erstellt eindeutigen, neuen FCB-Namen
;PE: [FCB_Name]=bereits vom LFN abgeleiteter kurzer Name ohne Schlange
;    [File_Flags]=Schalter fÅr Schlangen-Erzeugung (mit [ctrl])
;    SI=Hint fÅr Schlange
;    [ShortBuffer] gefÅllt mit Pfad
;    DI=Zeiger ans ShortBuffer-Ende (hinter Slash, dort soll der Name hin)
;PA: [FCB_Name] geeignet modifiziert (garniert mit "~1" o.Ñ.)
;    [ShortBuffer] voll gefÅllt
;    NO RETURN bei Alias-öberlauf, AL=5, oder unzulÑssiges Wildcard, AL=3
;VR: AX,BX,CX,DX,DI
;BUG: Sollte bei RENAME den zu entfernenden Dateinamen beachten (strcmp)
	call	Copy_FCB_8P3_from_FCB_to_DI
	mov	al,[File_Flags]
	test	al,(File_Flag_Is_LFN or File_Flag_Lowercase) ;wieso LC???
	jz	@@e		;gar nicht "typisch lang": fertig!
	test	al,File_Flag_Wildcards
	jnz	SetErr3
	mov	bx,ofs FCB_Name+31	;Scratch-Byte fÅr's erste Mal
	test	al,File_Flag_Is_LFN
	jz	@@no_tilde	;nur wegen Kleinbuchstaben noch keine Tilde!
	BTST	[ctrl],CTRL_Tilde
	jz	@@no_tilde	;nicht mit Tilde starten
@@put_tilde:
	mov	[by bx],' '	;Vorherige ErgÑnzung im FCB_Name lîschen
	call	Poke_Number_Over_FCB
	call	Copy_FCB_8P3_from_FCB_to_DI
@@no_tilde:
	start_profile exist
	mov	ax,4300h	;Dateiattribute holen (als Existenz-Test)
	call	SFN_CallOld
	end_profile
	jc	@@e		;nicht existent: fertig!
	inc	si
	jnz	@@put_tilde	;nÑchster Versuch, sonst Umrundungs-Fehler
	jmp	SetErr5
@@e:	call	strlenp1	;ans Ende rÅcken
	dec	di
;	jmp	MakeBSlash	;falls da, sollte es spÑter schîn krachen
endp

proc MakeBSlash
;FU: Backslash und \0 an ES:DI anhÑngen, wenn [PFlags]:PF_Slash
;    gesetzt ist
;PE: DI=Zielpuffer
;    [PFlags]:PF_Slash
;    SI=Quellpuffer (um auf 0 zu testen)
;PA: SI und DI inkrementiert falls Flag gesetzt
;    AX=005Ch
;VR: AX, DI
	mov	ax,'\'			;Backslash und Null
	call	Check_Slash
	jnc	@@1
	stosw
	dec	di
	inc	si
@@1:	cmp	[si],ah			;Null? (CY=0)
	ret
endp

proc strlenp1
;FU liefert String-LÑnge+1 (also Alloc-LÑnge), max. 200h
;PE: ES:DI=Stringzeiger
;PA: AX=String-LÑnge+1
;    DI=Zeiger hinter die terminierende Null
;VR: AX,CX,DI
	mov	ax,200h
	mov	cx,ax
	repne	scasb
	sub	ax,cx		;String-LÑnge +1
	ret
endp

proc Alloc_Cluster
;FU: Clusterkette verlÑngern, neues Cluster lîschen (mit Nullen fÅllen)
;PE: [SuchSektor]=1. Sektor des zu verlÑngernden Verzeichnisses
;    [num_cluster]=Anzahl Cluster des zu verlÑngernden Verzeichnisses
;PA: [sektor] geladen mit erstem Sektor des neuen Clusters
;    BX=Sektor-Zeiger
;    CY=1 bei Fehler
;    (Festplatte voll, volles Hauptverzeichnis [FAT16], DOS will nicht o.Ñ.)
;VR: [sektor] zerstîrt
	call	sec2usr
	jc	@@e1	;geht nicht im Hauptverzeichnis! (au·er FAT32)
	;Find a deleted or unused entry in the root directory
	mov	eax,[DPB_DirSec]
	call	ReadSecEAX_setBX
@@find_loop:
	mov	al,[bx]
	sub	al,0E5h
	jz	@@found
	add	al,0E5h
	jz	@@found
	call	Next_DirEnt
	jnc	@@find_loop
@@err:	stc
@@e1:	mov	[LastError],2	;"couldn't expand directory"
	ret
@@found:
	;BX=DirEnt, modifizieren
	mov	di,bx
	dec	ax		;AL=255
	stosb			;make a fairly safe assumption that no one
	mov	al,' '          ; will have a "\xff" filename
	mov	cx,10
ten = wo $-2
	rep	stosb
	mov	al,0
	mov	cl,21
	rep	stosb
	mov	ax,[num_cluster]
	mov	cl,[DPB_Shift]
	shl	ax,cl		;AX=Sektoren Verzeichnis
	shl	ax,1		;AX=Bytes Verzeichnis / 256
	mov	[wo (TDirEnt bx+1).fsize],ax
	call	sec2usr
	shr	eax,cl		;Cluster draus
	add	eax,2
	push	eax
	pop	[(TDirEnt bx).ClusL]
	pop	[(TDirEnt bx).ClusH]	;Kreuzverbundene Cluster erzeugen
	push	bx
	 call	WriteNow
	 ;mov	si,0		;WriteNow doesn't actually return with carry
	 ;jc	@@unhook
	 ;Datei îffnen, verlÑngern und schlie·en
	 mov	si,[ShortBuffer]
	 mov	di,bx
	 movsw			;Laufwerksbuchstabe:
	 mov	ax,0FF5Ch	;'\',255
	 stosw
	 mov	ax,3D02h	;zum Schreiben îffnen
	 mov	dx,bx
	 xor	si,si
	 call	CallOld
	 jc	@@unhook
	 cwd			;DX = 0 (assume Handle is < 8000h)
	 xchg	bx,ax		;Handle
	 xor	cx,cx
	 mov	ax,4202h	;ans Ende seeken
	 call	CallOld
	 jc	@@do_close
	 xor	ax,ax
	 lea	di,[Sektor]
	 mov	dx,di
	 mov	ch,1		;CX = 100h (CL still zero from above)
	 rep	stosw		;Sektor lîschen
	 call	InvalSector

	 call	two2shift
	 mov	cx,200h		;sektorweise
@@wr_loop:
	 mov	ah,40h		;schreiben
	 call	CallOld
	 jc	@@do_close
	 cmp	ax,cx
	 jc	@@do_close
	 dec	di
	 jns	@@wr_loop
@@do_close:
         adc    si,si           ;CY retten
	 mov	ah,3Eh
	 call	CallOld
@@unhook:
	 adc	si,si		;CY einschieben
	pop	bx
	pushf
	;Datei hart lîschen (Cluster-Kette nicht freigeben)
	call	ReadSec_subBX
	mov	[(TDirEnt bx).FName],0E5h	;einfach lîschen
	call	WriteNow
	popf
	jnz	@@err
	;ret			;save a byte and fall through - will CLC

sec2usr:
	mov	eax,[SuchSektor]
	sub	eax,[DPB_UsrSec]
	ret
endp

proc mark_del
;FU: mark the directory entry as deleted and make the drive dirty
;PE: BX=entry
	mov	[by bx],0E5h
DriveDirty:
	or	[DriveType],DT_Dirty
_mfde:
	ret
endp

proc make_free_dirent_space
;FU: Freien Speicher im Verzeichnis finden bzw. bereitstellen
;PE: [CurPathComp]=ASCIIZ langer Dateiname
;    [SuchSektor]=Startsektor aktuelles Verzeichnis
;    [FCB_Name]=zu suchender kurzer Dateiname
;PA: CY=1 wenn kein freier Platz vorhanden
;    (DOS-Fehler oder Hauptverzeichnis voll oder Festplatte voll)
;    [longname]=Unicode-Dateiname
;    [longpos_s]:[longpos_a]=LFN-Sektoradresse
;    [DirEnt_Copy]=Kopie des (gelîschten) "kurzen" Verzeichnis-Eintrags
;    Verzeichnis-Eintrag gelîscht (markiert oder schon geschrieben)
;    [LFN_DirEnts]=Anzahl nîtiger LFN-VerzeichniseintrÑge (etwa: LÑnge/13)
;VR: alle, [num_cluster],[sektor]
	mov	eax,[SuchSektor]
	call	ReadSecEAX_setBX
	jc	_mfde		;wenn's schief geht
	mov	si,[CurPathComp]
	mov	di,[LongName]	;Kann zu kurz sein!!!
	mov	cx,-2
@@le:	inc	cx
	call	Oem2Uni
	stosw
	or	ax,ax
	jnz	@@le
	push	cx		;= String-LÑnge -1
	 dec	ax
	 mov	cl,12		;CH=0 wenn mindestens 1 Zeichen(!)
	 rep	stosw		;12x FFFF, wie es Win9x tut, hintenan
	pop	ax
	inc	cx
	mov	[num_cluster],cx
	mov	cl,13		;Unicode-Zeichen pro Eintrag
	div	cl		;Anzahl EintrÑge in AL
	bt	[wo PFlags],6	;PF_Install_Short
	setc	dl		;pretend the FCB has been found
	adc	al,ch		;extra entry needed for 8.3 name (CH = 0)
	mov	[LFN_DirEnts],al ;1..13->0, 14..26->1 usw.
	;4.2: Freiraum suchen, dabei "eigenen" DirEnt herausrechnen
	;DL=Scan-Flags	Bit0	"eigenen" DirEnt gefunden (zur Kontrolle)
	;		Bit1	genÅgend zusammenhÑngenden Freiraum gefunden
	;		Bit2	Ende (00) gefunden, nur noch Freiraum suchen
	;		Bit3	Clusterketten-Ende wurde erreicht
	;DH=ZÑhler freie DirEnts
	mov	dh,-1
@@l1:
	BTST	dl,bit 2
	jnz	@@f_eol		;end-of-loop?
	mov	al,[bx]
	or	al,al		;Ketten-Ende
	jz	@@f_end
	cmp	al,0E5h
	jz	@@f_era
	BTST	[(TDirEnt bx).attr],bit 3 ;Volume Label (oder LFN-Eintrag)?
	jnz	@@f_vol 	;FCB-Vergleich zwecklos oder sogar falsch
	;test	[PFlags],PF_Install_Short	;save a few bytes - the FCB
	;jnz	@@f_vol 			; will never be equal
	call	Is_FCB_Equal
	jnz	@@f_vol
@@f_fcb:
	bts	dx,0		;setzen, schon gesetzt?
	jc	_mfde		;Fehler, wenn 2x gefunden (sollte nie sein)
	mov	si,bx
	mov	di,ofs DirEnt_Copy
	mov	cx,10h
	rep	movsw		;als Kopie sicherstellen
	call	mark_del
@@f_era:
	BTST	dl,bit 1	;Schon genÅgend Freiraum gefunden?
	jnz	@@to_next
@@f_era1:
	or	dh,dh
	jns	@@f_oldspace
	mov	dh,[LFN_DirEnts]	;ZÑhler laden
	call	store_longpos
	db	0b8h		;mov ax,nnnn
@@f_vol:mov	dh,-1		;Schluss mit Leerraum
@@to_next:
	mov	al,dl
	not	al
	test	al,3		;Freiraum UND DirEnt gefunden?
	jz	mfde_ret	;ja, fertig
	push	dx
	 call	Next_Dirent
	pop	dx
	jnc	@@l1		;nÑchste Runde
	BSET	dl,bit 3
@@f_end:
	BSET	dl,bit 2
@@f_eol:
	BTST	dl,bit 0
	stc
	jz	mfde_ret	;Fehler: FCB nicht gefunden!
	BTST	dl,bit 1
	jnz	mfde_ret	;Freiraum wurde schon gefunden!
	BTST	dl,bit 3	;schon kein DirEnt mehr Platz im Cluster?
	jz	@@f_era1	;doch!
	push	dx
	push	[CurSector]
	 call	FlushDirty
	 call	Alloc_Cluster	;mit Nullen gefÅllt und bereitgestellt
	pop	eax
	pop	dx
	jc	mfde_ret	;z.B. wenn Festplatte rappelvoll
	and	dx,not bit 3	;weiter mit normalem Next_DirEnt
@@l1_:	jns	@@l1		;(clears bit 3 of DL, tests sign of DH)
	call	Calc_Next_Cluster	;there was no room for the longname
	jc	mfde_ret		; so need to point to the new cluster
	call	_set_cur
	mov	bx,[Sektorp]
	jmp	@@l1_		;Calc_Next_Cluster will clear sign
@@f_oldspace:
	dec	dh
	jns	@@to_next
	BSET	dl,bit 1	;OK, gefunden
	jmp	@@to_next
endp

proc CTRL_write_test
	;BTST	[ctrl],CTRL_Write
	;jnz	@@e
	clc			;STC with "w-" switch
	ret			;NOP
	mov	[LastError],1	;Verbotener Schreibzugriff
mfde_ret:
ilfn_retu:
@@e:	ret
endp

proc install_long_filename
;FU: Baut langen Dateinamen in Verzeichniseintrag ein,
;    wenn es die Art des "langen" Dateinamens erforderlich macht
;PE: [CurPathComp]=ASCIIZ langer Dateiname
;    [SuchSektor]=Startsektor aktuelles Verzeichnis
;    [FCB_Name]=zu suchender kurzer Dateiname
;PA: [longpos_s]:[longpos_a]=LFN-Sektoradresse
;    Sektorinhalt wird sofort ausgeschrieben
;VR: ?,[longname],[num_cluster],[sektor]
	test	[File_Flags],(File_Flag_Is_LFN or File_Flag_Lowercase)
	jz	ilfn_retu	;nicht basteln!
install_long_filename_noflagtest:
	call	CTRL_Write_test
	jc	ilfn_retu	;Bastelverbot
	;1: Anzahl der notwendigen LFN-VerzeichniseintrÑge berechnen
	call	make_free_dirent_space
	jc	ilfn_retu	;Fehler!
	;2: alles OK fÅr LFN-Eintragung
	call	ReadSec_long
	jc	ilfn_retu	;Fehler!
	;3: Langen Dateinamen einsetzen
	mov	si,ofs FCB_Name
	call	calc_check
	xchg	dh,ah
	mov	dl,[LFN_DirEnts]
	bt	[wo PFlags],6	;PF_Install_Short
	sbb	dl,cl		;don't count the 8.3 entry
;Schleife mit DL=Eintrags-Nummer, DH=Checksumme
	mov	cl,41h		;fÅr den Anfang (calc_check sets CX=0)
@@l2:	mov	al,13*2
	mul	dl
	mov	si,[LongName]
	add	si,ax
	mov	di,bx
	mov	al,dl
	add	al,cl		;am Anfang 41h, spÑter 1
	stosb
	mov	cl,5		;CH ist bereits 0
	rep	movsw
	mov	ax,0Fh
	stosw			;Attribut
	mov	al,dh
	stosb			;PrÅfsumme
	mov	cl,6
	rep	movsw
	xor	ax,ax
	stosw			;Startcluster 0
	movsw
	movsw
	call	DriveDirty
	push	dx
	 call	Next_DirEnt
	pop	dx
	jc	ilfn_retu
	mov	cx,1
	dec	dl
	jns	@@l2
	;4: Kurzen Dateinamen (mit Creation_Time) eintragen
	cmp	[DirEnt_Copy.timec],0
	jnz	@@k2
	mov	eax,[DirEnt_Copy.timem]
	mov	[DirEnt_Copy.timec],eax
@@k2:	mov	si,ofs DirEnt_Copy
	mov	di,bx
	mov	cl,10h
	rep	movsw
	jmp	WriteNow
endp

proc lfn_creat
	;1. Finden des LFN-Eintrags
	call	path_locate
;Vermeidung von zuviel "locate_dirent", wenn der VC einfach seine
;drei DIRINFO-Dateien sucht...
	mov	ah,[Client_DL]
	mov	al,[File_Flags]
	test	al,File_Flag_NDevice
	jz	SFN_6C_CallOld
@@nd:	shr	ah,4
	push	ax
	 test	al,(File_Flag_Is_LFN or File_Flag_Char_High)
	 jnz	@@locate_dirent ;Suche muss sein
	 dec	ah		;Create als Option?
	 jnz	@@pop_open_only	;nein, blo· Name kopieren reicht
	 test	al,File_Flag_LowerCase	;Nur Gro·buchstaben?
	 jz	@@pop_open_only	;dann nicht erst suchen, sofort erzeugen
@@locate_dirent:
	 INT3
	 call	File_DirEnt_Locate	;verÑndert [CurSector] auf momentanen
	pop	ax
	jnc	@@open		;Nur îffnen: ganz einfach!
	dec	ah
	jnz	SetErr2		;oberes Nibble muss 1 sein (sonst Code 2)!
	call	Check_CDFS_Throw ;auf CD ist CREAT schlecht mîglich:-)
	call	CTRL_Write_test
	jc	@@open_only	;8.3-Name erzeugen lassen (ohne Schlange?!)
	;2. geeigneten, nicht bereits vorhandenen FCB-Namen ermitteln
	mov	si,1
	test	[Client_BH],4	;Wirklich DI als Hint benutzen?
	jz	@@no_DI_hint
	mov	si,[Client_DI]
@@no_DI_hint:
	test	[File_Flags],(File_Flag_Is_LFN or File_Flag_Lowercase)
	jz	@@creat 	;no long entry necessary
	enable_profile exist
	call	build_unique_fcb_name
	disable_profile
	start_profile install
	mov	al,0			;zero out the directory entry
	mov	di,ofs DirEnt_Copy+11	;truncate will fill in time and attr.
	mov	cx,32-11
	rep	stosb
	or	[PFlags],PF_Install_Short
	call	install_long_filename_noflagtest
	end_profile
	jc	SetErr5
;Noch mal îffnen
	start_profile open
	mov	dx,2		;Aktion = "truncate" - das Attribut wirkt!
	call	SFN_6C_CallOld_DX
	mov	[Client_CX],dx	;file was actually created
	end_profile
	lea	si,[((TDirEnt bx).timem)-1+(Sektor-PSPOrg)]
	sub	si,[Sektorp]	;high byte of cluster <= 15, so 10ms okay
	jmp	@@wt
@@pop_open_only:
	pop	ax
@@open_only:
	call	Copy_FCB_8P3_from_FCB_to_DI
@@open:	;3. Aufruf des OldInt21
	lea	si,[(TDirEnt bx).timec10ms]	;copy the creation time
	lea	di,[DirEnt_Copy.timec10ms]	; (6C wipes it out)
	mov	cx,5
	rep	movsb
	mov	[File_Flags],File_Flag_NDevice
@@creat:
	call	SFN_6C_CallOld	;die Universalfunktion rufen
	cmp	cx,3		;If the file was truncated
	jne	@@e		; put the creation time back
	lea	si,[DirEnt_Copy.timec10ms]
@@wt:	push	si
	 call	InvalSector
	 call	ReadSec_subBX
	pop	si
	lea	di,[(TDirEnt bx).timec10ms]
	mov	cx,5
	rep	movsb
	call	WriteNow
@@e:	;jmp	InvalSector	;ensure reading updated entry after close
endp

proc InvalSector
;FU: Gelesenen Sektor-Inhalt fÅr ungÅltig erklÑren
;    (weil Schreibzugriff auf Verzeichnis erfolgte u.Ñ.)
	or	[by HIGH rwrec.sect],-1 ;"falscher Sektor" laden
	ret
endp

proc SFN_6C_CallOld
;FU: OldInt21/AX=6C00 (Extended Open/Create) aufrufen, fÅr lfn_creat
;PE: AX=Attribute, DX=CreateFlags
	mov	dx,[Client_DX]	;Aktion (unverÑndert)
SFN_6C_CallOld_DX:
	mov	si,[ShortBuffer]
	push	bx
	 mov	cx,[Client_CX]	;create-Attribut
	 mov	bx,[Client_BX]	;Access/Share-Flags
         test   bl,3            ;work around Win9X incompatibility
	 jnz	@@rw
	 cmp	dx,1		; work around DR-DOS 7.03 incompatibility
	 jne	@@ok		; if opening existing file read-only
	 mov	cl,2eh		; change attribute to match everything
	 inc	cx		; assume high-bit is not used
@@rw:	 jpo	@@ok		;1 or 2
	 dec	bx		;3: change read/write+write-only to read/write
@@ok:	 mov	ax,6C00h
	 call	CallOldAndThrow
	 mov	[Client_AX],ax	;Datei-Handle
	 mov	[Client_CX],cx	;gemachte Aktion
	pop	bx
retu1:	ret
endp

proc ESDI_from_Client
	mov	es,[Client_ES]
	mov	di,[Client_DI]
	ret
endp

proc lfn_move
;Vorgehensweise:
;Bildung des SFN fÅr beide Dateinamen (also zwei ShortBuffer
; erforderlich, dafÅr muss der Heap herhalten,
;Vormerken: Lîschposition (wie bei SFN_unlink), FCB-Name und LFN
; fÅr neuen Namen
;Aufruf der DOS-Funktion RENAME
;alten DirEnt lîschen; SFN-LFN-VerknÅpfung NICHT in Tunnel schieben!
;neuen DirEnt setzen
;Sonderfall:
;Bilden beide (unterschiedlichen) LFN den gleichen SFN,
;wird _nicht_ die DOS-Funktion gerufen, sondern alles von Hand gemacht!
;(Zurzeit wird aber schlichtweg zu einem anderen Schlangen-ZÑhler umbenannt)
;1. Quelldatei in SFN umwandlen
	and	[SearchAttr],0
;Determine if the names only differ by case.
	mov	bx,ofs StrICompFS
	mov	si,dx
	mov	[by bx],64h	;SEGFS
	push	ds
	 mov	ds,[Client_ES]
	 mov	di,[Client_DI]
	 call	bx		;FS:SI == DS:DI
	pop	ds
	mov	[by bx],90h	;NOP
	jne	@@ren
	mov	fs,[Client_ES]
	mov	dx,[Client_DI]
	BRES	[ctrl],CTRL_SmartOS	;ensure the short name is deleted (?)
	call	Find_Longname_For_Deletion
	mov	si,bx		;Reuse the current alias
	mov	di,ofs FCB_Name
	movsd
	movsb
	jmp	@@6
@@ren:
	call	Find_Longname_For_Deletion
;2. Quelldatei-SFN wegkopieren
	mov	di,[ShortBuffer]
	mov	ax,6		;Platz fÅr Quell-LFN-Lîsch-Info
	call	strallocn
	jc	retu1		;kein Platz!
	mov	[SearchAttr],di ;ZWECKENTFREMDUNG
	mov	[throw_fi],ofs EMessage	;bei Fehler Speicher freigeben
	mov	si,ofs longpos_s
	push	si di
	movsd			;longpos_s
	movsw			;longpos_a
	mov	si,[ShortBuffer]
	push	si
	call	strcpy		;hinein in den Speicher!
;3. Zieldatei in SFN umwandeln
	mov	fs,[Client_ES]
	mov	si,[Client_DI]
	call	dirent_Locate
	jnc	SetErr5		;Existiert bereits: Fehler!
;4. geeigneten, nicht bereits vorhandenen FCB-Namen ermitteln
	call	build_unique_fcb_name_start_1
;5. SFN-Funktion aufrufen
	pop	di ;[ShortBuffer]
	pop	si ;[SearchAttr]
	lea	dx,[si+6]
	mov	ah,56h
	call	CallOldAndThrow
	call	ResetDrv
;6. Quell-LFN entfernen, SI steht noch
	pop	di ;ofs longpos_s
@@6:	movsd			;longpos_s
	movsw			;longpos_a
	call	Loesch_longpos	;evtl. vorhandenen Dateinamen killen!
;7. Ziel-LFN dazubasteln
	call	install_long_filename
;Und was tun, wenn's schiefging?

FreeSA:
	mov	ax,[SearchAttr]
FreeFind:
	call	LocalFreeAX	;lîscht CY, wenn Zeiger OK
	clc
	ret
endp

proc EMessage
;FU: Fehler-Ausstieg nur fÅr lfn_move
	push	ax
	 call	FreeSA
	pop	ax
	stc
	ret
endp

proc lfn_rmdir
	call	Find_Longname_For_Deletion
	call	SFN_AL_CallOld
	jc	Throw
	jmp	loesch_longpos
endp

proc lfn_unlink
	cmp	[Client_SI],1
	je	@@wild
	jc	lfn_rmdir
@@err2: jmp	SetErr2 		;Win98 uses 5, XP succeeds (SI != 0)
@@wild:
	push	dx
	 call	Start_FindFirst
	pop	dx
	mov	al,[File_Flags]
	test	al,File_Flag_NDevice
	jz	@@err2
	test	al,File_Flag_Wildcards
	jz	lfn_rmdir
	call	Check_FB
	jc	fbw_unlink

;	INT3
	push	di
	 mov	bx,ofs Glob_LFN_Proc
	 call	DirScan		;auf FAT ganz einfach!
	pop	di
	jc	@@err2
	mov	[wo @@err-2],ofs SetErr5 - ofs @@err
@@l:	push	di
	 call	ShortNamecpy
	 call	SFN_AL_CallOld	;Auch bei Fehler weitermachen
	 jc	@@sk
	 mov	[wo @@err-2],ofs InvalSector - ofs @@err
	 push	bx
	  call	terminate_cache ;evtl. vorhandenen Dateinamen killen!
	 pop	bx
	 test	[ctrl],CTRL_SmartOS
	 jnz	@@sk		;Turbo: Sektor nicht invalidieren
	 mov	di,[LongName]
	 cmp	[by di],0
	 jz	@@sk		;nichts zu lîschen
	 call	Loesch_longpos1 ;SOO einfach darf's wohl nicht sein!
@@sk:	 call	NextDirScan
	pop	di
	jnc	@@l
	clc
	jmp	InvalSector	;or SetErr5 if nothing deleted
@@err:
endp

proc fbw_unlink
;FU: wildcard delete in fallback mode
	push	di
	 call	Start_FB_ffirst
	pop	di
	jc	DTA_Done	;wenn's nichts zu finden gab
	mov	[by @@rc],90h
@@l:	push	di
	 call	DTANamecpy
	 call	SFN_AL_CallOld	;Auch bei Fehler weitermachen
	 jc	@@sk
	 mov	[by @@rc],0c3h	;at least one file deleted - return success
@@sk:	 call	FB_Find_Next
	pop	di
	jnc	@@l
	call	DTA_Done
	clc
@@rc:	ret			;NOP if nothing was deleted
	jmp	SetErr5 	;assume Access Denied
endp

proc Find_Longname_For_Deletion
;FU: Kopf-Funktion fÅr SFN/LFN-unlink/rmdir/move
;PE: FS:DX=zu lîschender Dateiname
;    [PFlags]:PF_LFN_Input=Schalter, ob Dateiname "lang" oder "kurz"
;PA: [longpos_s]:[longpos_a]=Sektoradresse LFN-Eintrag
;    [ShortBuffer]=kurzer Datei-Pfad (durchaus mit Kleinbuchstaben)
;    [ShortName]=kurzer Dateiname (so wie vorgefunden, also Gro·buchstaben)
;    [LongName]=langer Dateiname (so wie vorgefunden)
;    [CurSector]:BX=Sektoradresse SFN-Eintrag
;    NO RETURN wenn zu lîschender Name nicht gefunden wurde
	mov	si,dx
	call	dirent_locate
	jc	SetError
	call	Check_CDFS_Throw	;auf CD schlecht mîglich:-)
	mov	di,[longname]
	cmp	[by di],0	;wirklich mit langem Namen?
	jz	@@w		;nein
	test	[ctrl],CTRL_SmartOS	;hat das OS bereits einmal gelîscht?
	jz	@@e		;nein, mÅssen's vielleicht selber tun
@@w:	or	[longpos_a],-1	;nichts anschlie·end zu lîschen
_te:
@@e:	ret
endp

proc Tunnel_Save2
;Einfach ShortBuffer und LongName retten, die von Find_Longname_For_Deletion
;Åbrig geblieben sind
	xor	ax,ax
	mov	si,ofs Tunnel2
	mov	di,[LongName]
	mov	[si],ax
	cmp	[di],al 	;Ist da Åberhaupt einer?
	jz	_te
	mov	al,11+5
	call	strallocn
	jc	_te		;kein Speicher? Nicht so schlimm...
	mov	[si],di
	mov	si,ofs FCB_Name
	call	mov11
	mov	si,ofs DPB_drive
	movsb
	mov	si,ofs SuchSektor
	movsd
LongNamecpy:
	mov	si,[LongName]
	jmp	strcpy

Tunnel_Save:
	xor	cx,cx
	xchg	[tunnel2],cx
	jcxz	_te
	xchg	ax,cx
@@tunnel_free:
	lea	di,[tunnel]
	jmp	XchgDIPtr	;kÅmmert sich um Null-Zeiger
;@@e:	ret			;Ansprung-Return in der Mitte

Tunnel_Restore:
;Getunnelten langen Dateinamen bei Passung zum kurzen dazusetzen
;VR: alle
	mov	cx,0
tunnel = wo $-2
	jcxz	_te		;Nichts zu wollen!
	mov	si,[Client_DX]
	cmp	[FuncNum],56h	;sfn_move?
	jne	@@ok
	mov	fs,[Client_ES]
	mov	si,[Client_DI]
Tunnel_Restore_1:
@@ok:	call	InvalSector	;kînnte noch falsches DirEnt enthalten
	call	DirEnt_Locate	;muss existieren! Ansonsten: Alternativ-THROW
	jc	_te		;DirEnt nicht gefunden
	mov	si,[longname]
	cmp	[by si],0
	jnz	_te		;Hat schon langen Dateinamen (open_existing)
	mov	di,[tunnel]
	mov	si,ofs FCB_Name	;WÑre schîner alles hinteinander
	mov	cx,11
	repe	cmpsb
	jne	_te
	mov	si,ofs DPB_Drive
	cmpsb
	jne	_te
	mov	si,ofs SuchSektor
	cmpsd
	jne	_te
	mov	[CurPathComp],di
	call	install_long_filename_noflagtest
	xor	ax,ax
	jmp	@@tunnel_free	;Tunnel "verbrauchen"
endp

proc sfn_create			;AH=3Ch
	mov	si,12h
	;jmp	@@1
	db	8ah		;8A BE nn nn = mov bh,[bp+nnnn]
sfn_createnew:			;AH=5Bh
	mov	si,10h
@@1:	xchg	si,dx
	mov	bx,2		;read/write access, compatibility mode
sfn_createex:			;AH=6Ch
	mov	[SearchAttr],cx
	pushf			;Remember function test flag
	call	@@try		;Stattdessen stets DOS4+ Extended Open rufen!
	;cmp	[FuncNum],6Ch
	popf			;3C & 5B are ZR, 6C is NZ
	je	@@2
	mov	[Client_CX],cx	;bedingt CX setzen
@@2:	dec	cx
	;clc			;Cleared by the function test
	;dec	cx		;"created"? (war =2?)
	loop	@@e		;nein, kein LFN ansetzen (CY=0)
	mov	cx,[tunnel]
	jcxz	@@e		;Nichts zu wollen!
	push	bx si		;Dateiname und OpenMode retten
	 xchg	bx,ax
	 mov	ah,3Eh
	 call	CallOldAndThrow	;Schlie·en!
	 call	Tunnel_Restore_1
	pop	si bx
	mov	cx,[SearchAttr]
	btr	cx,0		;SchreibgeschÅtzt?
	jnc	@@3		;nein, SetFAttr Åberspringen
	mov	ax,4301h	;Attribut muss entfernt werden!
	mov	dx,si
	call	PushedCallOld
	BSET	cx,bit 0
@@3:	mov	dx,0002h	;TRUNCATE, CX wird eingesetzt (wurde erprobt)
@@try:	mov	ax,6C00h	;Nochmals îffnen, diesmal CX _nicht_ setzen!
PushedCallOld:
	push	ds
	 mov	ds,[Client_DS]
	 call	CallOld
	 mov	[Client_AX],ax	;Handle oder Fehlerkode
	pop	ds
	jc	Throw		;bei Fehler muss alles so bleiben
@@e:	ret
endp

proc sfn_process
;UnabhÑngig von der Stellung des Schalters "Schreiben" muss beim
;Lîschen von Dateien und Verzeichnissen _immer_ der LFN-Eintrag
;mit gelîscht werden!
;Ansonsten blieben im Verzeichnis LFN-EintrÑge zurÅck, die das Lîschen
;des Verzeichnisses verhindern, und das wÑre weitaus schlimmer.
;GlÅcklicherweise wird Int21 immer sequentiell (im GÑnsemarsch)
;gerufen, dadurch sollten Reentranzprobleme unter Windows vom Tisch sein.
;Beim Lîschen in der NT-DOS-Box kommt das NT zuvor (dieses lîscht
; selbstÑndig den LFN-Teil, genauso auch das (nackte) MS-DOS7)
;BUG: Da fehlen noch die FCB-Funktionen fcb_unlink (AH=13h),
;     fcb_creat (AH=16h), fcb_move (AH=17h)
	xchg	al,ah
	mov	[FuncNum],al	;fÅr Tunnel_Restore und sfn_createXX
	call	InvalSector
	;0. ExtrawÅrste fÅr handle-liefernde Funktionen
	cmp	al,3Ch
	je	sfn_create
	cmp	al,5Bh
	je	sfn_createnew
	;cmp	al,6Ch			;6C is the only higher one
	ja	sfn_createex
	;1. Finden des LFN-Eintrags
	test	ah,PF_Tunnel_Save	;AH=[PFlags]
	jz	@@1
	call	Find_Longname_For_Deletion
@@1:	;2. Aufruf des OldInt21
	mov	ax,[Client_AX]	;rmdir oder unlink oder rename
	mov	dx,[Client_DX]	;Dateiname
	push	es
	 call	ESDI_from_Client;nur fÅr move/rename
	 call	PushedCallOld	;Throw geht nicht, falsches DS
	pop	es
	test	[PFlags],PF_Tunnel_Save
	jz	@@e1
	test	[ctrl],CTRL_Tunnel
	jz	Loesch_longpos	;Wenn's nicht erst in den Tunnel kommt...
	call	Tunnel_Save2	;Ergebnis in <tunnel2> "parken"
Loesch_longpos:
	call	terminate_cache	;evtl. vorhandenen Dateinamen killen!
Loesch_longpos1:
	;Dieser muss genaugenommen in den "Tunnel" geschoben werden!
	;3. Lîschen des LFN-Eintrags
	call	InvalSector	;ist nun auf jeden Fall ungÅltig!
	cmp	[longpos_a],-1
	jz	@@e1		;nichts zu tun!
	call	ReadSec_long
	mov	al,[(TLfnDirEnt bx).count]
	cmp	al,0E5h		;Schlaues Betriebssystem am Werk?
	jne	@@nosmart
	or	[ctrl0],CTRL_SmartOS	;nie mehr nachfummeln mÅssen!
@@nosmart:
	test	al,80h
	jnz	@@e1		;hat das OS (z.B. WinNT) schon gelîscht o.Ñ.!
	test	al,40h		;Letztes StÅckel?
	jz	@@e1		;irgendwas ist faul
	and	al,3Fh		;Nummer
@@loesch:
	cmp	[(TLfnDirEnt bx).attr],0Fh
	jne	@@ep		;wieder ist was faul (aber doch schreiben)
	call	mark_del
	dec	al
	jz	@@ep		;Ende erreicht
	push	ax
	 call	Next_DirEnt
	pop	ax
	jc	@@ep		;sollte eigentlich nie passieren
	cmp	al,[(TLfnDirEnt bx).count]	;Folge-Glied?
	je	@@loesch	;alles noch in Ordnung!
@@ep:	call	FlushDirty	;sicherheitshalber sofort schreiben (Diskette!)
@@e1:
	test	[PFlags],PF_Tunnel_Restore
	jz	@@2
	call	Tunnel_Restore
@@2:	test	[PFlags],PF_Tunnel_Save
	jz	@@e
	call	Tunnel_Save	;EndgÅltig in <tunnel> retten
	clc
@@e:	ret
endp

proc Get_Attr
;FU: get the attribute of the current file
;PE: BX=directory entry
;PA: AL=attribute (AH=0 if CD)
	call	Check_CDFS
	jnz	CD_Get_Attr
	mov	al,[(TDirEnt bx).attr]
	ret
endp

;<lfn_attr>-Unterprogramme
;PE: BX=DirEnt-Zeiger
;    CY=0
;N: DOS6.2: although SFN GetAttr of "X:\" fails on a CD drive,
;   LFN GetAttr never fails (was bug until 0.22d)
proc lfn_attr_subroutines
attr_getphyssize:
	mov	cl,[DPB_Shift]	;fÅr max. 64K-Cluster
	add	cl,9		;2^9=512 Bytes pro Sektor
getphyssize:
	mov	eax,[(TDirEnt bx).fsize] ;mit Clusterverschwendung...
	call	two2CL
	jz	@@FullCluster
	or	ax,di
	inc	eax		;aufrunden
@@FullCluster:
	push	eax
	pop	[Client_AX]
	pop	[Client_DX]
	ret			;TEST & OR clear carry, INC no effect
@@op:
	mov	ah,3dh		;AL = 0 on entry
	call	SFN_CallOld
	jc	SetError
	xchg	bx,ax
	mov	ax,5700h
	ret
fb_attr_gettimem:
	call	@@op
	call	@@gt
	jc	@@cl
	mov	[Client_DI],dx
@@cl:	pushf
	 mov	ah,3eh
	 call	CallOld
	 lahf
	pop	bx
	or	ah,bl
	sahf
@@e1:	ret
fb_attr_settimem:
	call	@@op
	inc	ax
	mov	cx,[Client_CX]
	mov	dx,[Client_DI]
	call	CallOld
	jmp	@@cl
fb_attr_getattr:
	mov	ax,4300h
@@gt:	call	SFN_CallOld	;also GetAttr
	jc	@@e1
	xchg	ax,cx
	jmp	@@wrcx
fb_attr_setattr:
	mov	cx,[Client_CX]
	mov	ax,4301h
	jmp	SFN_CallOld

attr_settimec:
	mov	ax,[Client_SI]
	cmp	[(TDirEnt bx).timec10ms],al
	je	@@tc
	mov	[(TDirEnt bx).timec10ms],al
	mov	[wo (TDirEnt bx+2).timec],ax	;in case only 10ms are being set
	;Adjust BX so timem will point to timec
@@tc:	add	bx,ofs (TDirEnt).timec - ofs (TDirEnt).timem
attr_settimem:
;Fehlt noch: Anpassung der VerzeichniseintrÑge "." und ".."
;im untergeordneten Verzeichnis (falls Verzeichnis), oder was macht Win9x?
	push	[Client_DI]
	push	[Client_CX]
	pop	eax
	cmp	[(TDirEnt bx).timem],eax
	je	@@retu
	mov	[(TDirEnt bx).timem],eax
	jmp	@@wn
attr_settimea:
	mov	ax,[Client_DI]
	cmp	[(TDirEnt bx).timea],ax
	je	@@retu
	mov	[(TDirEnt bx).timea],ax
	jmp	@@wn
cd_attr_getattr:
attr_getattr:			;via DOS ohne spezielle (CD-)Verrenkungen
	call	Get_Attr
@@wrcx: mov	[Client_CX],ax
@@e:	ret
attr_setattr:
	mov	al,[by LOW Client_CX]
	mov	ah,al
	and	al,11011000b		;mask out unused, directory and label
	jnz	Err5			;(should really test high byte, too)
	mov	al,[(TDirEnt bx).attr]
	and	al,00010000b		;keep directory
	or	al,ah
	cmp	[(TDirEnt bx).attr],al
	je	@@e
	mov	[(TDirEnt bx).attr],al
@@wn:	jmp	WriteNow
attr_gettimem:
	mov	eax,[(TDirEnt bx).timem]
	jmp	eax2dicx
attr_gettimea:
	mov	ax,[(TDirEnt bx).timea]
	jmp	@@ax2di
attr_gettimec:
	mov	dl,[(TDirEnt bx).timec10ms]
	mov	eax,[(TDirEnt bx).timec]
_cd_attr_gettimec:
	mov	dh,0
	mov	[Client_SI],dx
eax2dicx:
	mov	[Client_CX],ax		;LOW
	shr	eax,16
@@ax2di:
cd_attr_gettimea:
	mov	[Client_DI],ax		;HIGH
@@retu:	clc
	ret
endp lfn_attr_subroutines

ifdef PROFILE
proc lfn_attr
	start_profile attr
	call _lfn_attr
	end_profile
	ret
endp
else
lfn_attr equ _lfn_attr
endif

proc _lfn_attr
	mov	si,dx
	xchg	ax,bx
	cmp	al,8
@@e1:	ja	SetErr1 	;Fehler: falsche Subfunktion
	call	CTRL_Write_test
	jnc	@@1		;Schreiben erlaubt
	test	al,1
Err5:	jnz	SetErr5 	;verbotener Schreibzugriff!
@@1:	call	InvalSector	;getting attr whilst file is open then closing
				; file & setting attribute corrupts dir entry
	call	dirent_locate	;also je nach [Client_BL]
	jc	SetError
	test	[File_Flags],File_Flag_NDevice
	jz	SetErr2
	mov	al,[Client_BL]
	mov	si,ofs cd_pvt_attr
	cbw
	call	Check_CDFS
	jnz	@@iscd
	mov	si,ofs pvt_attr
	call	Check_FB
	jnc	@@a
	cmp	al,4
	ja	@@e1
	mov	si,ofs fb_pvt_attr
@@a:	add	ax,ax
@@iscd: test	al,1		;ungerade Nummer?
	jnz	Err5
	add	si,ax
	xor	ax,ax
	jmp	[wo si]
endp

proc InitFill
;FU: Win32_Find_Data-Record-Zeiger laden und EAX lîschen; CH laden;
;    Client_CX lîschen (return OEM oder?)
	call	ESDI_from_Client
	mov	ch,[by LOW Client_SI]
	xor	eax,eax
	mov	[(TW32FindData es:di).sname],al
	mov	[Client_CX],ax
	ret
endp

proc PutValues
;Routine fÅr FindFirst/FindNext: Handle-Puffer fÅllen
;PE: DI=Handle-Puffer
;    [SearchAttr]=Such-Attribut
;    BX=DirEnt-Zeiger
;    [CurSector]=Sektornummer
;PA: Handle-Puffer gefÅllt
;VR: EAX,DX,SI,DI,CX
	mov	al,MAGIC_hFind		;Magic fÅr "gÅltiges Handle"
	stosb
	mov	al,[DPB_Drive]
	stosb
	mov	ax,[SearchAttr]
	stosw
	call	Check_CDFS
	jz	@@ncd
	lea	si,[Search.jol]
	mov	cx,11
	rep	movsw
	db	81h			;81 E8 nn nn = sub ax,nnnn
@@ncd:	call	store_entry
CurPathcpy:
	mov	si,[CurPathComp]
	;jmp	strcpy			;den String hinterher!
endp

proc strcpy
	lodsb
	stosb
	or	al,al
	jnz	strcpy
	ret
endp

proc strcpyu
	lodsb
	call	UpCase
	stosb
	or	al,al
	jnz	strcpyu
	ret
endp

proc Check_Valid_BX
;Testet ob BX=FindFirst/FindNext-Handle gÅltig ist
;PA: NO RETURN wenn ungÅltig (AL=6)
;    SI=BX+1
;    Z=0 fÅr Fallback-Modus
;    CY=1 if no wildcards (no memory allocated)
	stc
	dec	bx
	jz	@@ok
	inc	bx		;Nullhandle extra (wegen VC-Fehler)
	jz	@@f_vc		;AX (=7100h) belassen!
	mov	si,bx
	lodsb
	cmp	al,MAGIC_hFind
	jz	@@ok
	cmp	al,MAGIC_FB_hFind
	jz	@@ok_Z0
@@f_vc:	mov	al,6		;invalid handle (s.a. Int21/AH=59)
	jmp	SetError
@@ok_Z0:inc	ax
@@ok:	ret
endp

proc Alloc_Find_Handle
;FU: Speicherreservierung fÅr FindFirst
;PE: [CurPathComp]=Suchausdruck (wegen Speicherplatzbedarf spÑter!)
;PA: DI=[Client_AX]=Zeiger auf entsprechend Platz
;    NO RETURN AL=4=handle table full
	mov	ax,2+2+22
	call	Check_CDFS
	jnz	_Alloc_Find_Handle
	mov	al,SIZE TFindInfo	;zz. unabhÑnging FAT/Joliet
_Alloc_Find_Handle:		;Einstieg fÅr RÅckfall...
	mov	di,[CurPathComp]
	call	strallocn
_Alloc_Find_Handle_:		;Einstieg fÅr RÅckfall...
	mov	al,4		;handle table full
	jc	SetError
	mov	[Client_AX],di	;return Handle
	ret
endp

proc FB_Alloc_Find_Handle
;FU: Speicherreservierung fÅr FindFirst im RÅckfallmodus
;PE: [CurPathComp]=Suchausdruck (wegen Speicherplatzbedarf spÑter!)
;PA: DI=[Client_AX]=Zeiger auf entsprechend Platz
;    CY=1: AX=9904=handle table full
	mov	ax,SIZE TFB_FindInfo
	test	[File_Flags],File_Flag_Is_LFN
	jnz	_Alloc_Find_Handle	;keinen Dateinamen einbeziehen!
	call	LocalAlloc
	jmp	_Alloc_Find_Handle_
endp

proc FB_FillFD
	call	InitFill	;liefert CH(!)
	mov	al,[DTA.attr]
	stosd
	call	stosq0
	call	stosq0
	mov	eax,[DTA.time]
	call	evtl_time_dos_win_dl0	;verwendet CH
	xor	eax,eax
	stosd			;SizeHigh
	mov	eax,[DTA.fsize]
	stosd
	call	stosq0		;2 langweilige reservierte Felder
DTANamecpy:
	lea	si,[DTA.fname]
	jmp	strcpy
endp

proc noentry_FB_Check_Found
;FU: Testet Dateinamen und Attribut im DTA gegen zu suchenden
;    "langen" Suchausdruck (der z.B. die Suche nach "*1" unterstÅtzt)
;    sowie gegen das noch ausstehende Must-Match-Attribut.
;    Bei Fehltreffer Auslîsung von FindNext bis zum Treffer oder CY=1
;    Das Attribut 0Fh wird hier extra herausgeworfen...(???)
;PE: DOS DTA auf [DTA] gesetzt und gefÅllt
@@l:	mov	al,[DTA.attr]
	cmp	al,0Fh		;ein LFN (auf FAT)?
	je	@@retry
	call	Match_MM_Attr
	jnz	@@retry
	test	[File_Flags],File_Flag_Is_LFN
	jz	@@e		;kein Dateiname zu vergleichen
	lea	si,[DTA.fname]
	call	GlobbingEx
	jz	@@e		;OK, Name geht durch
FB_Find_Next:			;Einstieg fÅr FB_fnext
@@retry:mov	ah,4Fh		;FindNext
FB_Find_First:			;Einstieg mit AH=4Eh
	call	CallOld
	jnc	@@l
@@e:	ret
endp

proc DTA_Init
;VR: AX,DX(=ofs dta)
	call	InvalSector
	push	es bx
	 mov	ah,2Fh
	 call	CallOld
	 SES	[old_dta],bx
	pop	bx es
	mov	dx,ofs dta
s_dta:	mov	ah,1Ah
	jmp	CallOld
endp

proc Store_DTA
;FU: 21 Bytes des DTA nach ES:DI kopieren
;PA: DI entsprechend erhîht
;VR: CX,SI,DI
	lea	si,[DTA]
Copy_DTA:
	mov	cx,21
	rep	movsb		;die 21 "undokumentierten" Bytes der DTA
	ret
endp

proc Start_FindFirst
;FU: Gemeinsame Routine fÅr lfn_ffirst und lfn_unlink mit Platzhalterzeichen
;PE: FS:DX=Suchmaske
;    [Client_CX]=Such-Attribute
;    [PFlags]:PF_LFN_Input=1
;PA: [File_Flags]=Eigenschaften der letzten Komponente
;    [DriveType]=Laufwerkstyp
;    CX=[SearchAttr]=bearbeitete Such-Attribute
;    CY=Pfad nicht gefunden
	mov	si,dx
	call	path_locate
@@n:	BRES	[PFlags],PF_Follow
	mov	ax,[Client_CX]	;Attribute
	cmp	al,8		;Nur Volume Label?
	jne	@@1
	mov	ah,al		;dann gilt hier eine Must-Match-Ausnahme!
	BRES	[File_Flags],File_Flag_Wildcards ;only one label
@@1:	or	al,21h		;ARCHIVE und READONLY immer "durchlassen"
	not	al		;als "Auswerf-Maske" umdrehen
	mov	[SearchAttr],ax
	xchg	cx,ax		;fÅr's (lange) Label der CD
@@e:	ret
endp

proc Start_FB_ffirst
	call	same_stuff	;hier: Suchmaske (meist ????????.???)
	call	DTA_Init
	mov	cx,[SearchAttr]
	not	cl
	mov	dx,[ShortBuffer]
	mov	ah,4Eh
	jmp	FB_Find_First
endp

proc FB_ffirst
;FU: FindFirst im RÅckfallmodus
	call	Start_FB_ffirst
	jc	DTA_Done	;wenn's nichts zu finden gab
	call	FB_Alloc_Find_Handle
	jc	DTA_Done	;kein Platz im Heap (pardon!)
	mov	al,MAGIC_FB_hFind
	stosb
	call	Store_DTA
	mov	al,[by HIGH SearchAttr]
	stosb
	mov	al,[File_Flags]
	stosb
	test	al,File_Flag_Is_LFN
	jz	@@no_name
	call	CurPathcpy	;liefert CY=0
@@no_name:
	jmp	FD_Fill
endp

proc FB_fnext
;FU: FindNext im RÅckfallmodus
;PE: BX=(SI-1)=Heap-Zeiger (Such-Handle)
	call	DTA_Init
	mov	di,ofs DTA
	call	Copy_DTA	;eigentlich kînnte die DTA auch ganz gut
				;im Heap residieren, aber ich bin ja geizig..
	lodsb
	mov	[by HIGH SearchAttr],al
	lodsb
	mov	[File_Flags],al
	mov	[CurPathComp],si	;hier: egal ob Name gespeichert ist!
	call	FB_Find_Next
	jc      DTA_Done
	mov	di,bx		;BX (=Handle) bis dahin nicht geÑndert(?)
	inc	di
	call	Store_DTA	;die 21 Bytes als AufhÑnger zum Weitersuchen
FD_Fill:
	call	FB_FillFD
	;jmp	DTA_Done
endp

proc DTA_Done
;VR: DX; Flags (speziell CY) werden gerettet!
	pushf
	push	ds ax
	 lds	dx,[old_dta]
	 call	s_dta
	pop	ax ds
	popf
lff_ret:
	ret
endp

proc lfn_ffirst
	INT3
	call	Start_FindFirst
	jc	lff_ret

	call	Check_FB
	jc	FB_ffirst	;das ganze im RÅckfallmodus
	mov	al,[File_Flags]
	test	al,File_Flag_NDevice
	jz	FB_ffirst
	test	al,File_Flag_Wildcards
	jnz	@@w
	and	[Client_AX],2	;714E -> 0002
	push	di cx
	 call	find_in_cache
	pop	cx di
	jnc	@@f
@@w:	call	Check_CDFS
	jnz	CD_ffirst
@@nocd: mov	bx,ofs Glob_LFN_Proc
	call	DirScan		;auf FAT ganz einfach!
CD_ffirst_ret:
	jc	SetErr2 	;file not found
@@f:	;Eintrag gefunden, mit bx=DirEnt-Zeiger
	dec	[Client_AX]	;714E -> 714D = pe
	jpo	FillFD		;0002 -> 0001 = po
	call	Alloc_Find_Handle
	call	PutValues
	;jmp	FillFD		;clears carry (OR from strcpy)
endp

proc FillFD
;Routine fÅr FindFirst/FindNext: W32FindData-Record fÅllen
;PE: [Client_ES]:[Client_DI]=FindData-Zeiger
;    BX=DirEnt-Zeiger
;    [Client_SI]=DateTime_Format (Bit 0)
;PA: FindData gefÅllt; Zeitformat=DOS
;    [Client_CX]=0 oder 1 (Unicode_Conversion_Flags)
;VR: ES,DI,SI,EAX,EDX,CH
	call	InitFill		;liefert CH(!)
	call	Get_Attr
	stosd
	call	Check_CDFS
	jnz	CD_FillFD
	mov	eax,[(TDirEnt bx).timec];creation time
	mov	dl,[(TDirEnt bx).timec10ms]
	call	evtl_time_dos_win
	mov	eax,[dwo ((TDirEnt bx).timea)-2];access time (nur Datum)
	sub	ax,ax
	call	evtl_time_dos_win_dl0
	mov	eax,[(TDirEnt bx).timem];modification time
	call	evtl_time_dos_win_dl0
	movzx	eax,[(TDirEnt bx).resv] ;FAT+ uses bits 0-2,5-7 for 38-bit
	mov	ah,al			; file size
	and	ax,0e007h		;AH=bits 5-7, AL=bits 0-2
	shr	ah,2
	or	al,ah
	cbw
CD_FillFD_ret:
	mov	edx,[(TDirEnt bx).fsize];Dateigrî·e (max. 2GB)
	call	stosq			;Hi first, then Low
	call	stosq0			;res
	mov	si,[LongName]
	cmp	[by si],al
	jz	ShortNamecpy
	push	di
	 call	strcpy			;"Langer" Dateiname
	pop	di
	mov	al,[PFlags]		;evtl. Konvertierungsfehler?
	and	al,PF_Fail_Uni2Oem	;muss Bit 0 sein!
	mov	[Client_CL],al		;Konvertierungsfehler mitteilen
	add	di,260			;auf "kurzen" Namen
ShortNamecpy:
	mov	si,ofs ShortName
	jmp	strcpy
endp

proc lfn_fnext
	call	Check_Valid_BX
	jnz	FB_fnext
	jc	@@alldrives	;no wildcards, only one name possible
	lodsb
	inc	ax
	call	GetDrvParams	;tut meist nichts, wenn AL gleich geblieben
	lodsw
	mov	[SearchAttr],ax	;Attribute
	call	Check_CDFS
	jz	@@ncd
	;weiter mit CDFS (Joliet)
	call	CD_FNext
	sub	bx,[Sektorp]
	jmp	@@gem

@@ncd:	;weiter mit FAT
	mov	[MatchPtr],ofs Glob_LFN_Proc
	lea	di,[CurSector]
	movsd			;Sektor-Nummer
	lodsw
	xchg	bx,ax		;Sektorzeiger
@@gem:
	mov	[CurPathComp],si	;Maske folgt (Zeiger in Heap)
	call	ReadSec_addBX
	jc	@@alldrives
	call	NextDirScan	;Bei CDROM liegt der Hase im Pfeffer...
	jc	@@alldrives
	call	Check_CDFS
	jz	@@alldrives	;Was fÅr eine GÅlle hier!
	call	CD_FNextSFN
@@alldrives:
	jc	SetErr18	;no more files

	mov	di,[Client_BX]	;find handle
	call	PutValues
	mov	ah,4Fh		;"undokumentierter" Returnwert
	mov	[Client_AX],ax
	jmp	FillFD
endp

proc lfn_fclose
	call	Check_Valid_BX
	xchg	ax,bx
	jmp	FreeFind	;Handle-Tabellen-Eintrag freigeben
endp

proc CheckModifyBuffer
;PE: DI=Pufferadresse
;PA: Puffer und Pufferadresse zu virtuellem Laufwerk modifiziert,
;    wenn Bit 7 von Client_CH gesetzt ist
;VR: AX,DI
	BTST	[Client_CH],bit 7
	jz	@@e		;Nicht modifizieren
ModifyBuffer:
	mov	al,[subst_drive]
	or	al,al		;Netzlaufwerk?
	jz	@@e		;Nicht patchen!!
	add	di,[subst_root]
	push	di
	 mov	ah,':'
	 stosw
	 mov	ax,'\'
	 cmp	[by di],ah	;Backslash kînnte entfernt sein
	 jnz	@@1
	 stosw			;terminiert nachsetzen
@@1:	pop	di
@@e:	ret
endp

proc lfn_name
public lfn_name
	cmp	cl,2		;nur 0..2
	je	lfn_longname
	ja	SetErr1
	or	cl,cl
	jnz	lfn_shortname
endp

proc lfn_truename
	call	Truename
	mov	di,[longbuffer]
	jmp	_copy_to_client
endp

proc lfn_shortname
	call	file_locate
	mov	di,[shortbuffer]
_copy_to_client:
	call	CheckModifyBuffer
	push	[Client_ES] [Client_DI]
	push	ds di
	call	fstrcpyBS
	ret
endp

proc lfn_longname
	push	si		;locate the file first, to prevent
	 call	file_locate	; overwriting the user's buffer in
	pop	si		; case it doesn't exist (better way?)
	call	start_stuff
	mov	si,[longbuffer]
	cmp	[by si],'/'	;UNC?
	mov	ax,'\\'
	je	@@2
	lodsw
	BTST	[Client_CH],bit 7
	jnz	@@1
	and	[subst_root],0	;Hostpfad liefern
	;jmp	@@2
	db	84h		;84 A0 nn nn = test [bx+si+nnnn],ah
@@1:	mov	al,[subst_drive];virtuelles Laufwerk liefern
@@2:	mov	fs,[Client_ES]
	mov	di,[Client_DI]
	mov	[fs:di],ax	;Laufwerk:
	inc	si		;hinter den Root-Backslash
	scasw			;=add di,2
	mov	[by fs:di],'\'
	inc	di
	jmp	MakeLongName
endp

SetErr1:
	mov	al,1		;invalid subfunction
	jmp	SetError

proc lfn_genshort
;Aus Dateiname (ohne Pfad) kurzen Dateinamen (Alias) generieren
;Seiteneffekt: arbeitet bis zum Backslash (Pfad-Komponente)
	cmp	[Client_DL],11h		;nur OEM->OEM wird unterstÅtzt!
	jne	SetErr1
	cmp	[Client_DH],2		;nur 0 (FCB) oder 1 (8.3)
	jnc	SetErr1 		;XP succeeds (DH != 0)
	mov	si,[longbuffer]
	push	ds si
	push	[Client_DS] [Client_SI]
	call	fstrcpy			;lokal kopieren

	call	Gen_Alias		;nach FCB_Name

	call	ESDI_from_Client
	cmp	[Client_DH],0
	mov	bx,ofs FCB_Name
	jne	Copy_FCB_8P3	;hier mit ES<>DS!
@@want_fcb:
	mov	si,bx
mov11:
	mov	cx,11
	rep	movsb
	ret
endp

proc evtl_time_dos_win_dl0
;FU: Wandelt je nach CH die Dateizeit ins Win-Format
;    oder macht nichts au·er EDX zu lîschen; fÅr FindFirst/FindNext
;PE: EAX=DOS-Dateizeit
;    DL=DOS-10-ms-Schritte (nur bei Einsprung evtl_time_dos_win)
;    CH=Schalter DOS (<>0) oder Win (=0)
;    ES:DI=Speicherort fÅr Win32-Zeit
;PA: EDX:EAX=DOS- oder Win-Dateizeit
;VR: EAX,EDX,DI
	mov	dl,0
evtl_time_dos_win:
	or	ch,ch
	jz	time_dos_win
	xor	edx,edx
	jmp	stosq
endp

proc lfn_timeconv
public lfn_timeconv
	cmp	[Client_BL],1
	je	@@towin
	ja	SetErr1
@@todos:
	segfs
	lodsd
	mov	edx,[fs:si]
	jmp	time_win_dos
@@towin:
	mov	eax,[Client_CXDX]
	rol	eax,16		;Hi<->Lo
	mov	dl,[Client_BH]
	call	ESDI_from_Client
	;jmp	time_dos_win	;versagt nie
endp

proc time_dos_win
;FU: Zeit-Umwandlung DOS->WIN
;    Die Implementierung wÑre geradezu Luxus; deshalb einfach eine
;    "Abbildung", die zumindest eine korrekte Sortierung ermîglicht,
;    und eine RÅckkonvertierung zum vorhergehenden FAT-Format ermîglicht
;PE: EAX=DOS-Dateizeit
;    DL=DOS-10-ms-Schritte
;    [TimeOffset]=Zeitzonen-Umrechnungszahl
;    ES:DI=Speicher zum Schreiben der Zeit (stosq)
;PA: EAX:EDX=Win-Dateizeit (100-ns-Schritte seit 1.1.1601)
;    CY=1: fehlerhafte Angaben (z.B. 13. Monat o.Ñ.)
;VR: EAX,EDX
;Heavily adapted from the routine by Bill Currie (from his djasm lfn driver).
;Wrong after 28.2.2100 (it treats 2100 as a leap year, which it is not)
ife USEWINTIME
	xchg	edx,eax
	shl	eax,24		;stimmt ungefÑhr (Faktor 500)
else
	push	ebx
	movzx	ebx,al
	and	bl,1fh		; extract seconds/2
	shl	bx,1		; ebx*=2
	push	eax		; save date and time
	and	ax,7e0h 	; extract minutes * 32
	; need to multiply minutes by 60 (3*4*5)
	shr	ax,3		; eax/=8 (4)
	imul	ax,15
	;lea	ax,[eax+eax*4]	; eax*=5 (20)
	;lea	ax,[eax+eax*2]	; eax*=3 (60)
	add	bx,ax
	; add in the hours
	pop	ax
	shr	ax,11
	cwde
	; need to multiply hours by 3600 (5*5*9*16)
	imul	eax,3600
	;shl	ax,4		; eax*=16  (16)
	;lea	ax,[eax+eax*4]	; eax*=5   (80)
	;lea	ax,[eax+eax*4]	; eax*=5  (400)
	;lea	eax,[eax+eax*8] ; eax*=9 (3600)
	add	ebx,eax
	; convert seconds to 10ms units (hundredths) (4*5*5)
	imul	ebx,100
	;shl	ebx,2		; ebx*=4 (4)
	;lea	ebx,[ebx+ebx*4] ; ebx*=5 (20)
	;lea	ebx,[ebx+ebx*4] ; ebx*=5 (100)
	; add in the hundredths
	movzx	eax,dl
	add	ebx,eax
	; ebx now holds the time of day in 10ms units

	; get number of days since 1980/1/1
	pop	ax
	push	ebx
	movzx	edx,ax
	and	dx,1fh
	mov	bx,ax
	shr	ax,9
	shr	bx,4
	and	bx,1eh		; bx holds month (jan=1) * 2
	add	dx,[month_start+bx] ;add in start of month
	cmp	bl,3*2
	jb	@@no_leap
	test	al,3		;ignores 2100 (which is not a leap year)
	jnz	@@no_leap
	inc	dx
@@no_leap:
	imul	bx,ax,365	; days per year
	dec	ax
	sar	ax,2
	add	ax,bx		; plus leap days
	add	dx,ax
	; edx now holds the number of days since 1980/1/1
	mov	eax,24*60*60*100 ; hundredths in a day
	mul	edx
	pop	ebx
	add	eax,ebx
	adc	edx,0
	; edx:eax now holds number of 10ms intervals since 1980/1/1 0:00:00
	mov	ebx,10*1000*10	; convert from 10ms to 100ns
ns100 = dwo $-4
	imul	edx,ebx
	push	edx
	mul	ebx
	pop	ebx
	add	edx,ebx
	; normalise to UTC 1601/1/1
	add	eax,[TimeOffset]
	adc	edx,[TimeOffset+4]
	; edx:eax now holds number of 100ns intervals since 1601/1/1
	pop	ebx
endif ;USEWINTIME
stosq:
	stosd
	xchg	edx,eax
	jmp	_stosd
endp

proc stosq0
	xor	eax,eax
	stosd
_stosd: stosd
	ret
endp

proc time_win_dos
;FU: Zeit-Umwandlung WIN->DOS
;PE: EDX:EAX=Win-Dateizeit (100-ns-Schritte seit 1.1.1601)
;    [TimeOffset]=Zeitzonen-Umrechnungszahl
;PA: [Client_CX]=DOS-Zeit
;    [Client_DX]=DOS-Datei
;    [Client_BH]=DOS-10-ms-Schritte
;    CY=1: au·erhalb des Bereiches 1980..2107
;VR: EAX,EDX
;Zur Zeit einfach als "KomplementÑrfunktion" implementiert
;Since it's wrong after 28.2.2100, fail at that point.
ife USEWINTIME
	shr	eax,24
	xchg	edx,eax
	ret
else
	sub	eax,[TimeOffset] ;normalise to local time 1980/1/1
	sbb	edx,[TimeOffset+4]
	jc	@@e
	cmp	edx,0086b820h
	jb	@@ok
	ja	@@e
	cmp	eax,5bedc000h
	jb	@@ok
@@e:	mov	al,13		;data invalid
	jmp	SetError
@@ok:
	push	edi
	mov	edi,1000*1000*10*2 ;convert to seconds / 2
	div	edi
	push	eax
	xchg	eax,edx
	cdq
	div	[ns100]
	mov	[Client_BH],al	;hundredths
	pop	ax dx		;DX:AX = seconds / 2
	mov	di,24*60*60/2	;two-seconds per day
	div	di
	push	dx		;seconds / 2
	;mov	dx,ax
	;shr	dx,14
	;shl	ax,2		;DX:AX = days * 4
	mul	[four]
	mov	di,365*4+1
	div	di
	shl	ax,9		;year (1980 = 0)
	mov	[Client_DX],ax
	shr	dx,2		;days
	test	ah,6
	jnz	@@no_leap
	cmp	dx,59
	je	@@feb29
	adc	dx,-1
@@no_leap:
	xchg	ax,dx
	cwd			;DX = month number
	inc	ax		;one-based
	mov	di,ofs month_start+4
@@mon:	inc	dx
	scasw
	ja	@@mon
	sub	ax,[di-4]	;AX = day
@@pack:
	shl	dx,5		;month
	or	ax,dx
	or	[Client_DX],ax	;packed date

	pop	ax
	mov	di,60*60/2	;two-seconds per hour
	sub	dx,dx
	div	di
	shl	ax,11		;hours
	mov	[Client_CX],ax
	xchg	ax,dx
	mov	di,60/2 	;two-seconds per minute
	cwd
	div	di
	shl	ax,5		;minutes
	or	ax,dx		;seconds
	or	[Client_CX],ax	;packed time

	;clc			;(cleared by OR)
	pop	edi
	ret

@@feb29:
	mov	al,29
	mov	dl,2
	jmp	@@pack
endif ;USEWINTIME
endp

proc lfn_volinfo
public lfn_volinfo
;Laufwerks-Informationen beschaffen
	mov	si,dx
	call	start_stuff
	xor	eax,eax
	mov	[Client_DXBX],260*65536+4006h
		;LÑnge Pfad (DX), BX=4007h wÑre mit case-sensitiver Suche
	dec	al			;255
	xchg	[Client_AXCX],eax	;LÑnge Dateiname<->LÑnge VolType
	sub	ax,4			;zu kleiner Puffer?
four = wo $-2
	jc	@@novolinf		;Nicht einschreiben!
	xchg	cx,ax
	call	ESDI_from_Client
	call	Check_CDFS
	jnz	@@cd
	mov	al,'?'
	call	Check_FB
	jc	@@unk
	mov	ax,'AF'                 ;lies: "FAT",0
	stosw
	mov	al,'T'
	test	[DriveType],DT_FAT32
	jz	@@unk
	cmp	cx,2
	jb	@@unk
	mov	ah,'3'
	stosw
	mov	al,'2'
@@unk:	stosb
@@0:	mov	al,0
	stosb
@@novolinf:
	clc
	ret
@@cd:	jcxz	@@novolinf
	mov	eax,'SFDC'              ;lies: "CDFS"
	stosd
	jmp	@@0
endp

proc lfn_subst		;nur "Query Subst"
;Die anderen Funktionen, "Create Subst" (BH=0, DS:DX=Zu verbindender Pfad)
;und "Terminate Subst" (BH=1) erfordern das Patchen in DOS-Strukturen
	cmp	bh,2
	stc
	mov	ax,7100h
	jnz	@@e	;DurchlÑufer: "Nicht unterstÅtzte Funktion"
;etwas brutal den User-Puffer missbrauchen
	mov	si,dx
	mov	eax,[drvcolbk]	;das beschafft das SUBST-Verzeichnis!
	mov	al,bl
	add	al,'@'
	mov	[fs:si],eax
	call	Truename	;spuckt bei falschem Laufwern
	push	fs [Client_DX]
	push	ds [longbuffer]
	call	fstrcpyBS
@@e:	ret
endp

;******************************************************************
;** FastOpen-Cache
;**  Cache the most-recently-used names. There are two separate
;**  caches, one for directories and one for names (directory entries).
;**  Each cache always stores the drive and "parent" sector (the
;**  first sector of the directory containing the entry) and the
;**  short and long names. The directory cache also stores the
;**  first sector of the directory, whilst the name cache stores the
;**  sector and offset of the directory entries (short & long).
;******************************************************************

ifdef PROFILECACHE
proc put_to_cache
	start_profile putc
	call _put_to_cache
	end_profile
	ret
endp
proc terminate_cache
	start_profile termc
	call _terminate_cache
	end_profile
	ret
endp
proc find_in_cache
	start_profile findc
	call _find_in_cache
	end_profile
	ret
endp
else
put_to_cache	equ _put_to_cache
terminate_cache equ _terminate_cache
find_in_cache	equ _find_in_cache
endif

struc TDirCache 		;32 bytes (if it grows, modify cache_temp)
 longname	dw	0	;0 = no long name
				;1 = longname is in shortname
				;otherwise pointer to longname in heap
 shortname	db	13 dup (0) ;the shortname (might need to upcase)
 drive		db	-1	;drive containing name
 parent 	dd	-1	;beginning sector of directory containing name
 start		db	12 dup (0) ;cache data
 ;directory:
 ;  FAT:	dd	?	;sector containing start of directory (FAT)
 ;
 ;  CD: 	dd	?	;sector containing start of directory (ISO)
 ;		dw	?	;number of sectors of directory
 ;		dd	?	;sector containing start of directory (Joliet)
 ;		dw	?	;number of sectors of directory
 ;
 ;name:
 ;  FAT:	dw	?	;offset of short entry
 ;		dd	?	;sector of short entry
 ;		dd	?	;sector of long entry
 ;		dw	?	;offset of long entry
 ;
 ;  CD: 	dw	?	;offset of ISO entry
 ;		dd	?	;sector of ISO entry
ends

cachebx 	equ	(TDirCache bx)
cachesi 	equ	(TDirCache si)
cachedi 	equ	(TDirCache di)

proc to_front
;FU: Move a cache entry to the front of the queue.
;PE: SI=cache
;    BX=entry
;PA: BX=new position of entry
;VR: SI,DI,CX=0
	lea	cx,[si + (CACHE_ENTRIES-1) * size TDirCache]
	sub	cx,bx
	mov	di,ofs cache_temp
	push	di
	 push	cx
	  mov	si,bx
	  call	@@mov
	  mov	di,bx
	 pop	cx
	 rep	movsb
	pop	si
	mov	bx,di
@@mov:	mov	cx,size TDirCache / 2
	rep	movsw
@@e:	ret
endp

proc _terminate_cache
;FU: Remove the head of the name cache from both caches.
	mov	si,ofs name_cache
	mov	bx,ofs name_cache + (CACHE_ENTRIES-1) * size TDirCache
	mov	edx,[cachebx.parent]
	call	to_back
	;cmp	[FuncNum],3ah	;rmdir
	;jne	@@e
	mov	si,ofs path_cache
	call	search_cache_EDX
	jne	@@e

to_back:
;FU: Move a cache entry to the back of the queue and invalidate it.
;PE: SI=cache
;    BX=entry
;VR: AX,DI,CX=0
	lea	di,[cachebx.longname]
	call	FreeDIPtr
	std
	push	si
	 mov	cx,bx
	 sub	cx,si
	 lea	si,[bx-1]
	 lea	di,[bx-1 + size TDirCache]
	 rep	movsb
	pop	si
	cld
	mov	[cachesi.drive],-1
	mov	[cachesi.longname],cx
@@e:	ret
endp

proc _put_to_cache
;Tut beide Dateinamen in Puffer mit Startsektor, Abschluss mit Doppelnull
;PE: [CurSector]=Startsektor (bei CDFS: [Search.jol.{i,j}.sect])
;	öber die Link-Tabelle ist eigentlich nur das Speichern EINES Sektors
;	bei CD erforderlich!
;    [LongName] =langer Dateiname (ggf. leer)
;    [ShortName]=kurzer Dateiname (Zeiger)
;    [DPB_Drive] current drive
;    EAX=sector of parent directory
;    CX=0 for file, 16 for directory
;    PF_Follow = 0 (or filename, not directory)
;      FAT: EDX:BX = sector & offset of shortname directory entry
;	    [longpos_s]:[longpos_a] = sector & offset of longname entry
;      CD:  [Search.jol.i.entry & .sect] = offset & sector of dir. entry
;VR: SI,DI,EAX,CX,EDX
	mov	si,ofs name_cache
	jcxz	@@go
	test	[PFlags],PF_Follow
	jz	@@go
	mov	si,ofs path_cache
@@go:	push	bx
	mov	bx,si
	call	to_front
	mov	[cachebx.drive],-1	;in case strallocn fails
	mov	[cachebx.parent],eax
	lea	di,[cachebx.longname]
	call	FreeDIPtr

	mov	si,ofs ShortName
	mov	di,[LongName]
	push	si di
	 call	StrIComp
	 je	@@same
	pop	di si
	sub	ax,ax
	cmp	[di],al
	jz	@@short
	push	dx
	 call	strallocn
	pop	dx
	jc	@@e
	mov	[cachebx.longname],di
	push	si
	 call	LongNamecpy
	pop	si
	jmp	@@short
@@same:
	pop	si			;longname
	pop	di			;shortname (unused)
	inc	[cachebx.longname]	;made zero from free
@@short:
	lea	di,[cachebx.shortname]
	call	strcpy

	mov	al,[DPB_Drive]
	mov	[cachebx.drive],al

	lea	di,[cachebx.start]
	cmp	bx,ofs name_cache
	jae	@@ent
	lea	si,[CurSector]
	call	Check_CDFS
	jz	@@nocd
	lea	si,[Search.jol.i.sect]
	movsd			;Startsektor
	movsw			;LÑnge in Sektoren
	lea	si,[Search.jol.j.sect]
@@ce:	movsw			;naja, auch 6 Bytes
@@nocd: movsd
@@e:	pop	bx
	ret

@@ent:	call	Check_CDFS
	jz	@@ncd
	lea	si,[Search.jol.i.entry] ;CDs only need ISO entry
	jmp	@@ce
@@ncd:	pop	bx
	call	store_offset	;offset of short directory entry
	xchg	eax,edx
	stosd			;sector containing short directory entry
	lea	si,[longpos_s]
	movsd			;sector containing long directory entry
	movsw			;offset of long directory entry
	ret
endp

proc search_cache
;FU: Search the cache for the matching name
;PA: [CurPathComp] name to match
;    [SuchSektor] or [Search.jol.i.sect] parent dir. sector containing name
;    [DPB_Drive] current drive
;    SI=cache
;PE: Z=1: found, BX=cache entry
;    Z=0: not found, BX destroyed
;VR: AX,EDX,CL,DI
	mov	edx,[Search.jol.i.sect]
	call	Check_CDFS
	jnz	search_cache_EDX
	mov	edx,[SuchSektor]
search_cache_EDX:
	mov	cl,[DPB_Drive]
	lea	bx,[si + (CACHE_ENTRIES-1) * size TDirCache]
@@find:
	push	si
	cmp	[cachebx.drive],cl
	jne	@@next
	cmp	[cachebx.parent],edx
	jne	@@next
	lea	si,[cachebx.shortname]
	call	Match_Current
	je	@@found
	mov	si,[cachebx.longname]
	cmp	si,1
	jbe	@@next
	call	Match_Current
	je	@@found
@@next:
	pop	si
	sub	bx,size TDirCache
	cmp	bx,si
	jnb	@@find
	db	0ch		;OR AL,5eh = clz
@@found:
	pop	si
	ret
endp

proc _find_in_cache
;Vergleicht [CurPathComp] mit [fastopen_ptr]
;Wenn das klappt, kopiert langen Dateinamen nach [longname] ???
; und CurPathComp nach shortbuffer (AnhÑngen an DI)
;Wenn nicht, vergleicht [CurPathComp] mit vorgerÅcktem [fastopen_ptr]
;Wenn das klappt, kopiert Alias nach [shortbuffer] (AnhÑngen an DI)
;Startsektor nach [CurSector] schreiben
;PA: C=0: gefunden
;	PF_Follow=1
;	  [CurSector]=Startsektor (FAT), [CD_?FN_Cur]=Startsektoren (Joliet)
;	PF_Follow=0
;	  [SuchSektor]=first sector of parent directory
;	  [CurSector]=sector containing shortname entry
;	  BX=offset of entry
;	  FAT: [longpos_s]:[longpos_a]=sector & offset of longname entry
;	[ShortName]=kurzer Dateiname
;	[LongName] =langer Dateiname
;    C=1: nicht gefunden
;VR: EAX,CX,SI,DI
ifdef PATHLOOK
	mov	di,[CurPathComp]
	call	strlenp1
	neg	ax
	add	ax,ofs path_ptr
	mov	di,[path_ptr]
	cmp	di,ax
	ja	@@1
	call	CurPathcpy
	mov	[by di-1],'\'
	mov	[path_ptr],di
@@1:
endif
	test	[PFlags],PF_Follow
	jz	@@name
	mov	si,ofs path_cache
	call	Check_Slash
	jc	@@dir
	call	search_cache
	je	@@found
@@name: mov	si,ofs name_cache
@@dir:	call	search_cache
	je	@@found
@@err:	stc
	ret

@@found:
ifdef PATHLOOK
	mov	di,[path_ptr]
	mov	[by di-1],'/'
endif
	call	to_front

	mov	di,[LongName]
	mov	si,[cachebx.longname]
	cmp	si,1
	je	@@same
	ja	@@both
	mov	[di],si
	jmp	@@short
@@same:
	lea	si,[cachebx.shortname]
@@both:
	call	strcpy
@@short:
	lea	si,[cachebx.shortname]
	mov	di,ofs ShortName
	call	strcpyu

	lea	si,[cachebx.start]
	test	[PFlags],PF_Follow
	jz	@@ent
	lodsd
	call	_set_cur_and_such	;belanglos bei CDFS
	call	Check_CDFS
	jz	@@nocd
	lea	di,[Search.jol.i.sect]
	stosd			;Start und LÑnge Åbertragen
	movsw
	lea	di,[Search.jol.j.sect]
	movsd			;2x
	movsw
@@nocd:
	;clc				;cleared by TEST in Check_CDFS
@@e:	ret

@@ent:	mov	eax,[cachebx.parent]
	call	_set_cur_and_such
	lodsw
	xchg	bx,ax
	lodsd
	call	Check_CDFS
	jz	@@ncd
	sub	bx,[Sektorp]
	jmp	@@ce
@@ncd:	lea	di,[longpos_s]
	movsd
	movsw
@@ce:	jmp	ReadSecEAX_addBX
endp

;******************************************************************
;** LocalAlloc-Speicher (Heapverwaltung)
;** fÅr die kleineren Allozierungen bei FindFirst/FindNext usw.
;** Speichervergabe erfolgt in 4-Byte-StÅckelung.
;** Der Freispeicher ist in einer verketteten Liste:
;** 1 WORD Next-Pointer
;** 1 WORD Grî·e dieses Freispeicher-Blocks (inkl. der beiden WORDs)
;** Belegter Speicher hat am Anfang:
;** 1 WORD Grî·e dieses belegten Blocks (inkl. dieses WORDs)
;** und zurÅckgegeben wird ein Zeiger DAHINTER
;******************************************************************

strallocn:
;PE: DI=string to duplicate
;    AX=additional storage required
	push	ax
	 call	strlenp1
	pop	cx
	add	ax,cx

proc LocalAlloc pascal
;PE: AX=geforderte Speichermenge in Bytes
;PA: CY=1: kein Speicher mehr frei!
;    CY=0 und DI=Zeiger auf Speicherblock (fertig fÅr STOSx)
;VR: CX,DX,DI,AX(=tatsÑchliche Alloc-Grî·e inkl. Grî·en-WORD)
uses si
	inc	ax		;an additional two bytes are required
	inc	ax		; to store the size
	mov	si,[LocalHeap]
@@l2:	mov	di,si
	mov	si,[si] 	;si=erster (oder weiterer) Freispeicher
	cmp	si,1		;Ende erreicht?
	jc	@@nomem
	mov	cx,[si+2]
	sub	cx,ax		;Block hat genug Platz?
	jc	@@l2		;nein, nÑchsten Freispeicher suchen
	jz	@@ganz		;Block ganz aufbrauchen (aushÑngen)
	cmp	cx,4
	jb	@@fit
	mov	dx,si
	add	dx,ax		;auf neue Position
	mov	[di],dx
	mov	di,dx
	mov	[di+2],cx	;neue (kleinere) Grî·e
	db	0b9h
@@fit:	add	ax,cx		;increase allocation to fit free block
@@ganz: movsw			;Next-Pointer
	lea	di,[si-2]
	stosw			;Grî·e allozierter Block eintragen
	ret
@@nomem:mov	[LastError],4	;"not enough memory"
	ret
endp

proc JoinMem
;FU: Zwei Freispeicher zusammenziehen, wenn mîglich
;PE: DI=Zeiger auf ersten Freispeicher
;VR: AX,SI,DI
	mov	si,[di]
	mov	ax,[di+2]
	add	ax,di
	cmp	si,ax		;kînnen zusammengezogen werden?
	jne	@@e		;nein (CY=1: fataler Fehler!)
	movsw			;Next-Pointer vorziehen
	lodsw
	add	[di],ax		;Grî·en addieren
@@e:	ret
endp

proc FreeDIPtr
;PE: DI=Zeiger auf WORD mit dem Heap-Zeiger
;PA: PWORD nullgesetzt, CY=1: ungÅltiger oder Null-Zeiger
;VR: AX,CX,DI
	xor	ax,ax
XchgDIPtr:
	xchg	[di],ax
LocalFreeAX:
	xchg	di,ax
	;jmp	LocalFree
endp

proc LocalFree pascal
;PE: DI=Speicherblock-Zeiger
;## "Freispeicher-Umgebung" auf mîgliche "Blasenbildung" abtesten,
;## dabei ggf. nach vorn UND nach hinten verbinden!
;PA: CY=1: Versuch, freien Speicher freizugeben (m.a.W.: ungÅltiger Zeiger)
;VR: AX,CX
uses bx,si
	sub	di,2		;auf das Grî·en-WORD
	jc	@@e		;war wohl NIL-Zeiger
	mov	cx,[LocalHeap]
@@l:	mov	bx,cx
	mov	cx,[bx]
	jcxz	@@nomem		;wird einziger oder letzter Freispeicher!
	cmp	cx,di
	jc	@@l		;wenn hier Gleichheit rauskommt, wÑr's Fehler!
	stc
	jz	@@e
@@nomem:
	mov	ax,[bx+2]	;Grî·e des Vorblocks
	add	ax,bx
	cmp	di,ax		;DI muss nun grî·er/gleich AX sein
	jc	@@e		;sonst: Versuch der Freigabe von freiem Speicher
	mov	[bx],di
	xchg	[di],cx
	mov	[di+2],cx	;nun CX=Grî·e Speicherblock
	call	JoinMem		;rechts
	mov	di,bx
	call	JoinMem		;links
@@e:	ret
endp

;LocalInit -> see transient code area!

proc IncInDosFlag		;must be called in pairs for this to work
DecInDosFlag:
	pushf			;modified by "i" switch to RET
	 neg	[cs:InDosDelta]
@@1:	 push	ds
	  push	8086		;modified by installation
InDosFlagSeg = wo $-2
	  pop	ds
	  add	[by 8086],-1	;modified by installation
InDosFlagOfs = wo $-3
InDosDelta = by $-1
	 pop	ds
	popf
	ret
endp

;==========================================================================

;path cache - the order of all these entries is utilised
CACHE_ENTRIES = 16
path_cache	TDirCache CACHE_ENTRIES dup (<>)
name_cache	TDirCache CACHE_ENTRIES dup (<>)

if USEFREESPC
label cache_temp TDirCache
		dw	?		;size of below
exDPB		TExDpb	<?>		;storage for extended DPB
else
cache_temp	TDirCache <?>
endif

ifdef PATHLOOK
path_buf	db	2048 dup (?)
path_ptr	dw	path_buf
endif

Sektorp 	dw	Sektor
SektorEnde	dw	Sektor+512
Sektor		db	4*512 dup (?)	;2K Platz fÅr Festplattensektor

DefLocalHeap_FATONLY dw	2 dup (?)
ISRE_FATONLY:

	org Sektor
;nur fÅr RÅckfallmodus benutzt
old_dta 	dd	?
dta		TSearchRec <?>
ife USEFREESPC
		dw	?		;size of below
exDPB		TExDpb	<?>		;storage for extended DPB
endif


;============ cutting line, CDROM only code follow this line ================

	org Sektor
CD_Sektor	db	2048 dup (?)	;2K fÅr CDFS-Sektor
CD_SektorEnde	db	0		;sentinel for directory scanning


;**************************
;** CDROM initialization **
;**************************

;CD_VD_ID	db	'CD001',1	;Erkennung fÅr ISO-Volume
;JLT$:		dz	'.JLT'          ;Erweiterung fÅr Link-Tabelle
CD_VSN		dd	0		;Volume Serial Number of current CD

;Programm-Verteiler-Tabelle fÅr <lfn_attr bei CDFS, nur Lesezugriffe>
cd_pvt_attr	dw	ofs cd_attr_getattr	;via DOS
		dw	ofs cd_attr_getphyssize
		dw	ofs cd_attr_gettimem
		dw	ofs cd_attr_gettimea	;liefert 0
		dw	ofs cd_attr_gettimec	;liefert 0-0-0

proc CD_ReadSec
	cmp	eax,[rwrec.sect]
	je	@@e		;nichts tun!
	mov	si,ofs CD_Sektor
	mov	di,ofs CD_Backup
	mov	cx,1024
	cmp	eax,[CD_BackupSektor]
	xchg	eax,[rwrec.sect]
	mov	[CD_BackupSektor],eax
	je	@@swap
	push	bx
	 mov	bx,si
	 rep	movsw		;Make backup
	 push	[rwrec.sect]
	 pop	di
	 pop	si
	 movzx	cx,[DPB_Drive]
	 mov	dx,1		;nur 1 Sektor!
	 MUX	1508h		;MSCDEX: Sektor lesen
	pop	bx
@@e:	ret
@@swap:
	mov	ax,[si]
	xchg	[di],ax
	mov	[si],ax
	cmpsw			;einfach si+=2 und di+=2
	loop	@@swap
	clc
	ret
endp

IF 0 ;SHSUCDX always read sector 16, so why should DOSLFN be any different?
proc IoctlRead
;FU: FÅhrt einen "IOCTL READ" auf das CD-Laufwerk aus
;PE: BX=Pufferzeiger (28+7 Bytes)
;    CX=Laufwerk (0=A:)
;    DX=1. und 2. Byte des Datenpuffers
;PA: DI=BX+30 (hinter dem 2. Byte des Puffers)
;    CY=1 bei Fehler
;VR: AX,DX,DI
	mov	di,bx
	mov	ax,28
	stosw			;len,sub
	mov	al,3
	stosw			;cmd,LOBYTE(status)
	mov	al,0
	stosw			;HIBYTE(status)..mediadescriptor
	stosw
	stosw
	stosw
	stosw
	lea	ax,[bx+28]
	stosw			;LOWORD(bufferptr)
	mov	ax,es
	stosw			;HIWORD(bufferptr)
	mov	ax,7
	stosw			;buffersize
	mov	al,0
	stosw			;startsector
	stosw
	stosw			;volumeptr
	stosw
	xchg	ax,dx
	stosw
	MUX	1510h
	mov	al,[bx+4]
	add	al,al		;shift out ERROR bit (status bit 15)
	ret
endp

proc DetermineVolStart
;FU: Wo ist der Anfang der letzten Session?
;    (MSCDEX liefert diese Info leider NICHT bei Int2F/1505!)
;PE: CX=Laufwerk (0=A:)
;PA: CY=1 Fehler
;    CY=0: EAX=Volume-Start
;VR:
	mov	bx,ofs CD_Sektor
	mov	dl,10		;GetAudioDiskInfo
	call	IoctlRead
	jc	@@e
	mov	dx,[bx+28+1]	;dl=first, dh=last
@@l:	push	dx
	 mov	dl,11		;GetAudioTrackInfo
	 call	IoctlRead
	pop	dx
	jc	@@e
	test	[by bx+28+6],40h	;Data track?
	jnz	@@ok
	dec	dh		;from back to front
	cmp	dh,dl		;(at least MSCDEX hides all non-last sessions
	jnc	@@l		; and returns first==last)
@@e:	ret
@@ok:
	mov	al,60
	imul	[by bx+28+4]	;min
	xchg	dx,ax
	mov	al,[bx+28+3]	;sec
	sub	al,2
	cbw
	add	ax,dx
	cwde
	imul	eax,75
	movsx	edx,[by bx+28+2]	;frame
	add	eax,edx
cd_init_retu:
	ret
endp
ENDIF ;0

proc CD_Init	;HIER GIBTS ARBEIT
;weitere Informationen per Sektorzugriff beschaffen!
;Solange Volume-Deskriptoren einlesen, bis Schluss-Deskriptor...
;FU: CD (als solche) und Joliet-CD erkennen
;PE: [DPB_Drive]=Laufwerk (0=A:)
;PA: CY=1: Fehler, kein MSCDEX, kein CD-Laufwerk oder eben kein Joliet
IF 0
	movzx	cx,[DPB_drive]
	call	DetermineVolStart
	jc	cd_init_retu	;Sprungdistanz klein halten
	add	eax,15
ELSE
	sub	eax,eax
	mov	al,15
ENDIF
	call	_set_cur	;beginnend mit erstem Volume-Deskriptor
	or	[DriveType],DT_CDFS
	lea	bx,[(CD_Sektor+156)]	;Hauptverzeichnis Little Endian
	mov	[by HIGH Sektorp],HIGH (CD_Sektor - PSPOrg)
@@next_vtoc:
	call	ReadNextSec	;nÑchstes VTOC
	jc	@@e		;nichts zu lesen!
	mov	si,ofs CD_Sektor
	lodsb
;	mov	di,ofs CD_VD_ID
	;push	cx		;ReadNextSec will set CX to drive
;	 mov	cl,3		;CH (Laufwerk) sowieso 0
;	 rep	cmpsw		;gleiche ID enthalten?
	;pop	cx
	cmp	[dwo si],'00DC' ;assume '1',1 follows (FreeDOS/mkisofs seems
				; to have an SVD with '1',2)
	jne	@@err		;falscher Aufbau der VTOC
	cbw
	lea	di,[Medium.jol.isotree]
	dec	ax
	jz	@@gem		;PVD gefunden!
	dec	ax
	jz	@@s
	sub	al,0FDh		;war FFh?
	jnz	@@next_vtoc	;alle anderen Deskriptoren ignorieren
				;FF = Abschluss
	cmp	[DriveType],(DT_CDFS or DT_Joliet) ;Beide Deskriptoren OK?
	je	@@read_jlt
@@err:	stc
@@e:	ret

@@s:	;SVD gefunden!
	cmp	[wo si-1+88],'/%'	;Joliet-SVD?
	jne	@@next_vtoc		;nein, diesen ignorieren
	mov	al,[si-1+90]
	sub	al,'@'
	je	@@jo
	sub	al,'C'-'@'
	je	@@jo
	sub	al,'E'-'C'
	jne	@@next_vtoc
@@jo:	cwd			;Calculate the VSN
@@sl:	add	dl,[si-1]
	add	dh,[si-1+1]
	add	al,[si-1+2]
	add	ah,[si-1+3]
	add	si,4
	cmp	si,ofs CD_SektorEnde+1
	jb	@@sl
	push	ax
	push	dx
	pop	eax
	or	[DriveType],DT_Joliet
	cmp	eax,[CD_VSN]	;Same VSN?
	je	@@e		;Done (equal is also NC)
	mov	[CD_VSN],eax	;Caller will zero it if there's no table
	mov	di,[argv0file]
	mov	cl,8
@@sd:	rol	eax,4
	push	ax
	and	al,0fh
	cmp	al,10
	sbb	al,69h
	das
	stosb
	pop	ax
	loop	@@sd
	;mov	si,ofs JLT$
	;call	strcpy
	mov	[dwo di],'TLJ.'
	mov	[di+4],cl
	lea	di,[Medium.jol.joltree]
@@gem:
	call	CD_SecRetrieveDirInfo	;Rootsektor und LÑnge Åbertragen
	jmp	@@next_vtoc

@@read_jlt:
	call	CD_Done 	;Free the previous link table
	mov	dx,[argv0]
	DOS	3D00h		;open .JLT file (can recurse!)
	jc	@@nojlt
	xchg	bx,ax
	mov	dx,ofs CD_Sektor
	mov	cx,45
	DOS	3Fh		;_lread
	cmp	ax,cx
	jne	@@cl
	cmp	[dwo CD_Sektor+35],'1TLJ'
	jne	@@cl
	mov	ax,[wo CD_Sektor+39]
	push	ax
	 add	ax,4
	 call	LocalAlloc
	 mov	[Medium.jol.linktbl],di
	pop	cx
	jc	@@cl
	mov	eax,[dwo CD_Sektor+41]
	stosd			;number & size of links
	mov	dx,di
	DOS	3Fh		;_lread
@@cl:
	pushf
	 DOS	3Eh		;_lclose
	popf
	ret
@@nojlt:
if USECE
	;cmp	[CurSector],32	;Erste Session?
	;jnc	@@will_nicht	;Link-Tabelle ist (sicherlich) falsch!
	call	ReadNextSec ;Nachfolgenden Sektor lesen (ist Link-Tabelle!?)
	mov	si,ofs CD_Sektor+2ch
	cmp	[wo si-2ch],'eC'        ;start of "CeQuadrat"
	jne	@@will_nicht
	lodsd			;Anzahl Verzeichnisse
	mov	bx,ax
	shl	bx,2		;DWORD-Offset
	jz	@@ex		;TemporÑre Notbremse
	push	bx
	push	ax
	 shl	ax,3		;8 Bytes pro Verzeichnis
	 add	ax,14		;und 2 Bytes fÅr die Anzahl, 2 bytes for the
				; table offset and 10 bytes for the code
	 call	LocalAlloc
	 mov	[Medium.jol.linktbl],di
	pop	eax
	jc	@@ex		;Speichermangel!!
	stosd
	xchg	cx,ax
@@l:
	lodsd			;Joliet
	mov	[di+bx],eax	;hinten
	movsd			;ISO vorn
	loop	@@l		;Link-Tabelle OK
	add	di,bx
	mov	si,ofs @@dword	;Write the DWORD scanning code
	mov	cl,5
	rep	movsw
@@ex:	ret
@@will_nicht:
endif ;USECE
	mov	[LastError],3	;"can't find link table"
	stc
_cdd_e: ret

@@dword:
	repne	scasd
	jne	@@dwe
	mov	eax,[di+bx-4]
@@dwe:	ret
endp

proc CD_Done
	;call	Check_CDFS	;currently only called within CD code
	;jz	_cdd_e
	lea	di,[Medium.jol.linktbl]
	jmp	FreeDIPtr
endp

proc CD_Set_Root
	push	si di
	 lea	si,[Medium.jol.joltree.rootdir]
	 lea	di,[Search.jol.j.sect]
	 movsd			;Startsektor
	 movsw			;LÑnge
	 lea	si,[Medium.jol.isotree.rootdir]
	 lea	di,[Search.jol.i.sect]
	 movsd			;Startsektor
	 movsw			;LÑnge
	pop	di si
	ret
endp

;******************
;** CDROM access **
;******************

proc CD_CheckRootDot
;06/02: filter out "." and ".." entries from root directory
;PE: BX=CD_DirEnt-Zeiger
;    [CurSector]=momentaner CD-Sektor
;PA: CY=0: Ist "." oder ".." im Hauptverzeichnis, dazu Z=0 (no match)
;    CY=1: Ist nicht der Fall
;VR: -
	push	eax
	 mov	eax,[CurSector]
	 cmp	eax,[Medium.jol.isotree.rootdir]
	 je	@@1
	 cmp	eax,[Medium.jol.joltree.rootdir]
@@1:	pop	eax
	stc
	jne	@@e
	;cmp	[(TCD_DirEnt bx).fnamelen],1
	;stc
	;jne	@@e
	;cmp	[(TCD_DirEnt bx).fname],2
	;cmc
	;The shortcut directories are always first, each of length 22h
	cmp	bx,ofs CD_Sektor+22h+1
	cmc
@@e:	ret
endp

proc CD_check_updir
;FU: LÑdt SI auf Name-Zeiger
;    Testet auf '.' und '..' (LÑnge 1 und Name=(binÑr)0 bzw. (binÑr)1)
;PE: BX=CD_DirEnt-Zeiger
;    DI=wo der Name hin soll
;PA: CY=0: normales DirEnt,
;	CX=LÑnge Name (in Bytes)
;	SI=Zeiger Name in CD_DirEnt
;	VR: SI,AL
;    CY=1: DirEnt='.' oder '..'
;	[DI] gefÅllt mit "." oder ".." (noch nicht nullterminiert!)
;	VR: SI,DI,AL=0
	lea	si,[(TCD_DirEnt bx).fnamelen]
	lodsb
	movzx	cx,al
	cmp	al,2		;LÑnge 1?
	jnc	@@e
	cmp	[by si],1	;Null oder Eins?
	ja	@@e
	mov	al,'.'
	stosb
	jnz	@@1
	stosb			;Zwei Punkte wenn's 1 war
@@1:	add	al,-'.'		;AL=0 und CY setzen
	;stosb
@@e:	ret
endp

proc CD_Longname
;Kopiert Joliet-Namen des Directory-Eintrags BX in [Longname]
;Vereinfachende Annahme: Verzeichnisse haben kein AnhÑngsel,
;Dateien haben immer das AnhÑngsel ";1" (Versionsnummer)
;PE: BX=CD_DirEnt-Zeiger
;PA: SI=ofs Longname (also fertig fÅr Vergleich)
;VR: AX,CX,SI,DI
	mov	di,[Longname]
	push	di
	 call	CD_check_updir
	 jc	_termAL
	 shr	cx,1		;bei CY=1 offensichtlich Fehler, ignorieren
@@l:	 lodsw
	 call	BE_Uni2Oem	;hier: Motorola-Interpretation
@@1:	 loopnz	@@l
	 jmp	_terminate
endp

proc CD_Shortname
;Kopiert ISO-Namen des Directory-Eintrags BX in [ShortName]
;Da Zeichen >80h ohnehin nicht ISO-konform sind, werden sie vereinfachend
;als OEM angenommen
;Vereinfachende Annahme: Verzeichnisse haben kein AnhÑngsel,
;Dateien haben immer das AnhÑngsel ";1" (Versionsnummer), also 2 Zeichen
;PE: BX=CD_DirEnt-Zeiger
;PA: SI=ofs ShortName (also fertig fÅr Vergleich)
;VR: AX,CX,SI,DI
	mov	di,ofs ShortName
	push	di
	 call	CD_check_updir
	 jc	_termAL
	 MIN	cl,20		;Notbremse!! Nicht perfekt!!
				;Besser: KÅrzung (TRUENAME) zu 8.3
	 rep	movsb
_terminate:
	 cmp	[by di-1],';'   ;semicolon without version number
	 je	@@1
	 cmp	[by di-2],';'   ;assume version number follows
	 jne	@@0
	 dec	di
@@1:	 dec	di
@@0:	 xchg	cx,ax		;effektiv AX=0
_termAL:
	 stosb			;Null-Terminierung
	pop	si
	ret
endp

proc cd_attr_getphyssize
	;adjust BX for the CD size offset relative to the FAT.
	add	bx,ofs (TCD_DirEnt).fsize - ofs (TDirEnt).fsize
	mov	cl,11			;2^11=2048
	jmp	getphyssize
endp

proc CD_Get_Attr
;FU: Liefert DOS-Attribut fÅr CD-Verzeichniseintrag
;    Liefert nur die Bits DIRECTORY (10h), HIDDEN (02h) aus DirEnt
;    und READONLY (01h) aus ctrl-Bit
;PE: BX=CD_DirEnt-Zeiger
;PA: AL=AX=Attribut
;VR: AX (AH=0)
	mov	al,[(TCD_DirEnt bx).flags]
	mov	ah,al
	and	ax,0201h	;AH = dir, AL = hidden
	shl	ah,2		;dazwischen 2 Bit Luft
	jnz	@@1		;niemals schreibgeschÅtzt wie MSCDEX
	;bt	[wo ctrl],1	;CTRL_RoBit-->CY
CDRO:	stc			;modified by "r" switch
@@1:	adc	ax,ax		;shift to DOS attribute values, add in RO-bit
	or	al,ah
	cbw
	ret
endp

cd_attr_gettimec:
	push	ofs _cd_attr_gettimec
	jmp	CD_Get_Time
cd_attr_gettimem:
	push	ofs eax2dicx

proc CD_Get_Time
;FU: Liefert DOS-Zeit von CD (das ist i.d.R. die Zeit der letzten énderung)
;PE: BX=CD_DirEnt-Zeiger
;PA: EAX,DL=Zeit im DOS-Format (DH=Zeitzone)
;VR: EAX,DX
	mov	al,[(TCD_DirEnt bx).year]
	sub	al,80		;ISO is from 1900, DOS is from 1980
	jnc	@@y
	mov	al,0
@@y:	shl	ax,4
	or	al,[(TCD_DirEnt bx).month]
	shl	ax,5
	or	al,[(TCD_DirEnt bx).day]
	shl	eax,16
	mov	al,[(TCD_DirEnt bx).hour]
	shl	ax,6
	mov	dx,[wo (TCD_DirEnt bx).minu]	;DL = minutes, DH = seconds
	or	al,dl
	shl	ax,5
	shr	dh,1		;DOS only has room for two-second interval
	sbb	dl,dl		;all 0 bits if even, all 1 bits if odd
	or	al,dh
	and	dl,100		;use 100 hundredths if odd number of seconds
	ret
endp

proc SetSuchSektor_LFN
;PE: BX=DirEnt-Zeiger ISO
;PA: [SuchSektor]=EAX=zu suchender Joliet-Sektor
;VR: EAX,CX
	db	0B9h		;mov cx,nnnn
SetSuchSektor_SFN:
;PE: BX=DirEnt-Zeiger Joliet
;PA: [SuchSektor]=EAX=zu suchender ISO-Sektor
;VR: EAX,CX
	xor	cx,cx		;2 bytes
	mov	eax,[(TCD_DirEnt bx).sect]
	BTST	[(TCD_DirEnt bx).flags],bit 1
	jz	@@e		;don't search for files!
	push	di bx
	 mov	di,[Medium.jol.linktbl]
	 test	di,di
	 jz	@@2
	 mov	bx,[di+2]	;offset between
	 lea	dx,[di+4+bx]
	 add	dx,bx		;pointer to scan function
	 or	cx,cx
	 mov	cx,[di]
	 jnz	@@1
	 add	di,bx
	 neg	bx
@@1:	 scasd			;DI += 4
	 call	dx
@@2:	pop	bx di
@@e:	mov	[SuchSektor],eax
	ret
endp

IF 0
;This code is on the heap, as part of the link file.
;PE: EAX=sector to find
;    DI=table
;    BX=offset to other table
;    CX=number of links
;PA: EAX=new sector (or unchanged if not found)
;VR: EDX,DI,CX
	;byte
	repne	scasb
	jne	@@be
	mov	al,[di+bx-1]
@@be:	ret
	;word
	repne	scasw
	jne	@@we
	mov	ax,[di+bx-2]
@@we:	ret
	;triple-byte (optimised for speed)
@@tl:	push	eax
	pop	dx
	pop	dx		;DL = low byte of high word
@@tc:	cmp	[di],ax
	je	@@tlf
@@tn:	add	di,3
	dec	cx
	jnz	@@tc
	ret
@@tlf:	cmp	[di+2],dl
	jne	@@tn
	mov	dl,[di+2+bx]
	push	dx
	push	[wo di+bx]
	pop	eax
	ret
	;dword
	repne	scasd		;fast scan for sector
	jne	@@dwe		;if not found (error!)
	mov	eax,[di+bx-4]	;get the companion
@@dwe:	ret
endif

proc CD_ffirst
	push	di
	 lea	si,[Search.jol.i.sect]
	 lea	di,[Search.jol.restart]
	 movsd
	 movsw
	pop	di
	test	ch,8			;Volume Label requested?
	jnz	CD_Make_Volume_Label
	mov	bx,ofs CD_Glob_LFN_Proc
	call	CD_Ping_DirScan ;auf CDFS ungleich komplizierter!
	jmp	CD_ffirst_ret
endp

proc CD_Make_Volume_Label
;Jede CD habe ein Volume Label... oder?
	mov	eax,[Medium.jol.joltree.voldesc]
	call	ReadSecEAX
	call	InitFill
	mov	al,8		;Attribut "Volume Label"
	stosd
	mov	al,ah
	mov	cx,20
	rep	stosw		;10 DWords nur Nullen
	mov	si,ofs CD_Sektor+28h
@@l:	lodsw
	call	BE_uni2oem	;"langes" Label (ist nullterminiert)
	jnz	@@l
	;Backtrack to remove trailing spaces (it might not be NUL-terminated)
@@b:	dec	di		;The NUL
	cmp	[by es:di-1],' '
	je	@@b
	mov	[es:di],al	;Replace last space with NUL
	LD	es,ds
;	call	Alloc_Find_Handle
;	mov	[Search.jol.j.entry],ofs CD_Sektor	;zurÅckstellen!
;	jmp	PutValues	;clears carry (OR from strcpy)
	dec	[Client_AX]
	;clc			;should be cleared by above CMP
	ret			;from lfn_ffirst
endp

proc CD_SecRetrieveDirInfo
	mov	eax,[CurSector]
	stosd
endp
proc CD_RetrieveDirInfo
;PE: BX=CD-Verzeichniseintrag
;    DI=Struktur aus Sektor (DWORD) und Anzahl (WORD)
;VR: EAX,DI (um 6 nach hinten)
	mov	eax,[(TCD_DirEnt bx).sect]
	stosd
	mov	eax,[(TCD_DirEnt bx).fsize]
	dec	eax
	shr	eax,11		;genauer: durch SektorlÑnge (krumm!) teilen
	stosw
	ret
endp

proc CD_LFN_Follow
	push	di
	 lea	di,[Search.jol.j]
_CD_Follow:
	 mov	dx,ofs CD_SaveDirInfoFull
	 test	[PFlags],PF_Follow
	 jz	@@1
	 BTST	[(TCD_DirEnt bx).flags],bit 1
	 jz	@@1		;files don't have dir info
	 mov	ax,bx
	 stosw
	 mov	dx,ofs CD_RetrieveDirInfo
@@1:	 call	dx
	pop	di
	ret
endp

proc CD_SFN_Follow
	push	di
	 lea	di,[Search.jol.i]
	 jmp	_CD_Follow
endp

proc CD_LoadDirInfoFull
;PE: SI=Struktur aus Sektor (DWORD) und Anzahl (WORD)
;PA: BX, [CurSector] und [CD_Residual] gefÅllt
	lodsw			;Sektorzeiger
	xchg	bx,ax
	lodsd
	call	_set_cur
	lodsw
	mov	[CD_Residual],ax
	ret
endp

proc CD_FNextSFN
	call	SetSuchSektor_SFN
	push	di
	 lea	di,[Search.jol.j]
	 call	CD_SaveDirInfoFull	;neuer Zeiger fÅr PutValues
	pop	di
	call	CD_SFN_Load
	mov	[MatchPtr],ofs Match_CD_Sectorpointer_Proc
	call	CD_NextDirScan_Circular
	jc	_cd_nosfn		;Konsistenzfehler!
	call	CD_Shortname
	lea	di,[Search.jol.i]
	;call	CD_SaveDirInfoFull	;Doesn't affect carry
	clc
endp

proc CD_SaveDirInfoFull
;PE: DI=Struktur aus Sektor (DWORD) und Anzahl (WORD)
	mov	ax,bx
	stosw
CD_SaveDirInfo:
	mov	eax,[CurSector]
	stosd
	mov	ax,[CD_Residual]
	stosw
	ret
endp

proc CD_FNext
	lea	di,[Search.jol]
	mov	cx,11
	rep	movsw
	mov	[MatchPtr],ofs CD_Glob_LFN_Proc
	;jmp	CD_LFN_Load
endp

proc CD_LFN_Load
;PA: BX, [CurSector] und [CD_Residual] mit Joliet-Suchdaten gefÅllt
	push	si
	 lea	si,[Search.jol.j]
_CD_Load:
	 call	CD_LoadDirInfoFull
_cd_nosfn:				;discard return address of CD_FNextSFN
	pop	si
	ret
endp

proc CD_SFN_Load
;PA: BX, [CurSector] und [CD_Residual] mit ISO-Suchdaten gefÅllt
	push	si
	 lea	si,[Search.jol.i]
	 jmp	_CD_Load
endp

proc CD_FillFD
	call	CD_Get_Time		;auf 1 Sekunde genau
	call	evtl_time_dos_win	;creation time
	xchg	edx,eax
	push	eax
	 call	stosq0			;access time unbekannt
	pop	eax
	call	stosq			;modification time
	;adjust BX for the CD size offset relative to the FAT.
	add	bx,ofs (TCD_DirEnt).fsize - ofs (TDirEnt).fsize
	xor	eax,eax 		;high dword of size
	jmp	CD_FillFD_ret
endp

proc CD_Match_LFN_Proc
	mov	ax,ofs CD_LongName
	db	84h		;84 B8 nn nn = test [bx+si+nnnn],bh
endp
proc Match_CD_SFN_Proc
	mov	ax,ofs CD_Shortname
	cmp	[(TCD_DirEnt bx).r],SIZE TCD_DirEnt
	jc	_mcde
	call	CD_CheckRootDot
	jnc	_mcde		;mit Z=0
	call	ax
	jmp	Match_Current
endp

CD_Ping_DirScan_Match:
	mov	bx,ofs CD_Match_LFN_Proc
proc CD_Ping_DirScan
;FU: Bei CDFS mu· zweimal gesucht werden! Entweder von lang nach kurz
;    (Regel) oder von kurz nach lang (Sonderfall)
;PE: BX=Vergleichsmethode fÅr DirScan [GLOBBING reicht eigentlich!]
;PA: CY=1 fataler Fehler
;    CY=0 und Z=0: Nicht gefunden
;    CY=0 und Z=1: gefunden
	push	bx
	 call	CD_LFN_Load ;setze Suchdaten auf Joliet (warum BX verwerfen?)
	pop	bx
	call	DirScan
	jc	@@e
	call	CD_LFN_Follow		;Falls nÑchstes Verzeichnis...
	call	SetSuchSektor_SFN
	call	CD_SFN_Load
	mov	bx,ofs Match_CD_Sectorpointer_Proc
	call	DirScan			;mit DX=Nummer
	jc	@@e			;Fehler! (Konsistenzfehler)
	call	CD_SFN_Follow
	call	CD_Shortname
	clc
_mcde:
@@e:	ret
endp

proc CD_Pong_DirScan
;PA: CY=1 fataler Fehler oder nicht gefunden
;    CY=0 gefunden
	call	CD_SFN_Load
	mov	bx,ofs Match_CD_SFN_Proc
	call	DirScan
	jc	@@e
	call	CD_SFN_Follow
	call	SetSuchSektor_LFN
	call	CD_LFN_Load
	mov	bx,ofs Match_CD_Sectorpointer_Proc
	call	DirScan			;mit DX=Nummer
	jc	@@e			;Fehler!
	call	CD_LFN_Follow
	call	CD_Longname
	clc
@@e:	ret
endp

proc CD_Next_DirEnt
	add	bl,[(TCD_DirEnt bx).r]
	adc	bh,0
	cmp	[(TCD_DirEnt bx).r],SIZE TCD_DirEnt ;sector not filled up?
	jnc	@@e
@@cknext:
	dec	[CD_Residual]		;sector follows?
	stc
	js	@@e
	call	ReadNextSec		;hier keine FAT-érgernisse!
	mov	bx,ofs CD_Sektor
@@e:	ret
endp

proc CD_NextDirScan_Circular
	push	bp
	mov	bp,sp
	push	[CurSector]	;bp-4
	push	bx		;bp-6
	call	ReadSec
	jc	@@e
@@2:	call	CD_Next_DirEnt
	jnc	@@1
	mov	eax,[Search.jol.restart]
	call	ReadSecEAX_setBX
	mov	ax,[Search.jol.restlen]
	mov	[CD_Residual],ax
@@1:	cmp	bx,[bp-6]
	jne	@@l
	mov	eax,[CurSector]
	cmp	eax,[bp-4]
	je	@@n
@@l:	call	[MatchPtr]
	jnbe	@@2		;bei CY=1 (Fehler) oder Z=1 (gefunden)
	db	0b0h		;mov al,nn
@@n:	stc
@@e:	leave
	ret
endp

proc Match_CD_Sectorpointer_Proc
;Nicht einfach DirEnts (DX) abzÑhlen!
	cmp	[(TCD_DirEnt bx).r],SIZE TCD_DirEnt
	jc	@@e
	mov	eax,[SuchSektor]
	cmp	eax,[(TCD_DirEnt bx).sect]	;Treffer?
	clc
_globe:
@@e:	ret
endp

proc CD_Glob_LFN_Proc
;Bug oder Feature? Unter Win9x trifft der Suchausdruck "*1" sowohl
;"Programme von 1991" (LFN) als auch "WURSTE~1" (SFN fÅr "Wurstegal")
;Wegen der Bereitstellung beider Namen erfordert die Funktion
;FindFirst/FindNext das stÑndige Bereithalten zweier Sektoren.
;Aber leider ist die Reihenfolge der DirEnts nicht zwangsweise gleich:-(,
;sodass der Aufwand, um ein DirEnt nicht zweimal zu finden, immens steigt!
	cmp	[(TCD_DirEnt bx).r],SIZE TCD_DirEnt
	jc	_globe
	call	CD_CheckRootDot		;12/02
	jnc	_globe
	call	CD_Longname
	call	CD_Get_Attr
	call	Match_Attr
	jnz	_globe
	jmp	GlobbingEx
endp

;================ common buffer (to be moved into heap) ================

label Residente_Puffer byte

CD_Backup	db	2048 dup (?)
CD_BackupSektor	dd	?

CD_Residual	dw	?	;count of directory sectors

DefLocalHeap	dw	2 dup (?)
ISRE:

;==========================================================================
	org Sektor
;==== BEGIN CRITICAL INITIALIZATION SECTION - MUST OVERLAY BUFFERS ====
String_Table	dw	?
LocalHeapSize	dw	?	;Angabe bei /M
		dw	600	;1 Sektor und noch etwas Platz (nicht fÅr CD)
		dw	50000	;>50KB ist bei 64KB Segment kaum mîglich
ShortSize	dw	80	;/MS - size of shortbuffer - longest short path
		dw	3+12+1	;d:/filename.ext\0
		dw	128+12+1;DOS seems to allow 128 just for the path
LongSize	dw	260	;/ML - size of longbuffer
		dw	3+12+1
		dw	1024	;allow for future expansion
NameSize	dw	256	;/MN - size of longname
		dw	13
		dw	512
WorkDir		dd	?	;Arbeitsverzeichnis: .JLT/.TBL/.386 (/P)

if USEWINTIME
Epoch		dd	0e1d58000h ;100-ns intervals from
		dd	001a8e79fh ; 1 Jan 1601 0:00:00 UTC to 1 Jan 1980
endif

ife USECP
NewCP		dw	0	;wird bei Int2F gesetzt
TblFileName$:	dz	"CP000UNI.TBL"

	chcp_code install
endif

proc LocalInit pascal
;PE: AX = size of local heap in bytes, including four "wasted" bytes
;    DI = start address of local heap
	mov	[shortbuffer],di
	add	di,3
	mov	[shortbuffer3],di
	sub	di,3
	add	di,[ShortSize]
	mov	[longbuffer],di
	add	di,2
	mov	[longbuffer2],di
	sub	di,3
	add	di,[LongSize]
	mov	[longbuffer_end],di
	add	di,2		;one byte extra for longbuffer
	mov	[longname],di
	sub	di,13*2
	mov	[longname_26],di
	add	di,13*2
	add	di,[NameSize]
	add	di,[NameSize]	;doubled for Unicode
	add	di,28		;plus 28 for 0FFh fillers
	add	ax,0Fh		;Bis zum Paragrafen-Ende aufrunden
	add	ax,di
	jnc	@@1
	mov	ax,0fff0h	;begrenzen auf berechenbare 64K-16
@@1:	shr	ax,4
	xchg	bx,ax
	DOS	4Ah		;Speicherblockgrî·e verÑndern
	jnc	@@2
	DOS	4Ah		;noch einmal (bei Fehler max. Grî·e so!)
@@2:	xchg	ax,bx
	shl	ax,4		;wieder Bytes
	sub	ax,di
	mov	[LocalHeap],di
	mov	[LocalHeapSize],ax
	push	ax
	 lea	ax,[di+4]
	 stosw			;Erster Freispeicher-Zeiger
	 xor	ax,ax
	 stosw			;strategische Null
;verhindert auf einfache Weise das ungewollte "Zusammenfassen nach links"
	 stosw			;NIL-Pointer, kein weiterer Freispeicher
	pop	ax
	sub	ax,4
	stosw			;ZusammenhÑngender Freispeicher
;initialise some variables
	mov	[tunnel2],0
	ret
endp

proc CopyWorkDir
;Kopiert [WorkDir] nach ES:DI und hÑngt ein Backslash dran,
;PA: DI=Zeiger hinter Backslash
	push	es
	push	di
	push	[WorkDir]
	call	fstrcpy		;liefert glÅcklicherweise AX=Zeichenzahl
	add	di,ax
	mov	al,'\'
	stosb
	ret
endp

proc fstrlen pascal
arg @s:dword
uses es,di
	les	di,[@s]
	xor	ax,ax
	mov	cx,-1
	repne	scasb
	mov	ax,-2
	sub	ax,cx
	ret
endp

proc CriticalInit
;"Kritischer Abschnitt" der Initialisierung (wegen Speicher-öberlappungen)
	call	LocalInit
;Arbeitsverzeichnis in Heap kopieren
	push	[WorkDir]	;gleich als DWord!
	call	fstrlen
	add	al,14		;(<255)
	call	LocalAlloc
	jc	@@noload	;darf hier nie passieren!
	mov	[argv0],di
	call	CopyWorkDir
	mov	[argv0file],di
;Unicodetabelle automatisch oder wie angefordert laden (nach Heap-Init!)
	mov	dx,0
UserUniFile = wo $-2		;Angabe bei /Z
	or	dx,dx
	jnz	@@userload	;Von Hand laden
	DOS	6601h
	jc	@@noload	;DOS wei· nichts Åber Codeseiten
	push	[argv0]		;Dateiname (mit Pfad) fÅr Fehlermeldung
	 call	LoadCP
	 jmp	@@el1
@@userload:
	push	dx		;fÅr Fehlermeldung
	 call	LoadUniFile
@@el1: 	 jnc	@@el2
	 call	AusgabeStringNr
	 call	AusgabeNL
@@el2:	pop	dx
@@noload:
;Zeiger verbiegen (Int21 und Int2F)
	mov	dx,ofs NewInt21
	DOS	2521h		;Set Int21
if USEWIN or USECP
	mov	dx,ofs NewInt2F
	mov	al,2Fh
	DOS			;Set Int2F
endif
;Environment freigeben
	push	es
	 mov	es,[2ch]	;Segment Environment
	 DOS	49h		;ENV-Speicher ab es freigeben
	pop	es
;Test des Hochladens und Anzeige
	mov	ax,cs
	cmp	ah,0a0h
	mov	bl,1		;$HOCH
	jc	@@NoHi		;unten
	call	AusgabeStringNr
@@NoHi:	inc	bl		;Installiere
;DosLFN aktivieren und Speicherverbrauch anzeigen
Activate:
	or	[es:Ctrl0],80h	;setzen
	mov	ax,[LocalHeap]
	add	ax,[LocalHeapSize]
	add	ax,10h		;hier: inklusive MCB
	;BL-numerierten Text ausgeben
	P8086
TXTOut:	push	ax
	call	AusgabeStringNr	;Textausgabe
	pop	ax
	;Programm beenden
	mov	bh,bl
	call	AusgabeNL
	cmp	bh,2		;Meldung "Resident"?
	jnz	@@exi		;nein, normales Programmende
	P386
	mov	dx,[LocalHeap]
	add	dx,[LocalHeapSize]
	shr	dx,4		;Speicherbedarf in Paragrafen umrechnen
	DOS	3100h		;Resident beenden
@@exi:
	P8086
	call	PrintLastError
	DOS	4C00h
endp

proc LoadString
;FU: String-ID (BL) in String-Zeiger (SI) und LÑngen-Info (CX) umsetzen
;VR: AX,BL,CX,SI
	push	es di
	 inc	bl
	 xor	al,al
	 mov	di,[String_Table]	;deutsch oder englisch
	 LD	es,ds
@@l:	 mov	si,di			;immer Anfang merken
	 mov	cx,-1
	 repne	scasb			;Null suchen und LÑnge bestimmen
	 dec	bl
	 jnz	@@l
	 not	cx
	 dec	cx			;jetzt CX=String-LÑnge
	pop	di es
ple_ret:ret
endp

proc PrintLastError
;PE: ES = resident segment
;PA: LastError=0
;VR: AX,BL
	xor	ax,ax
	xchg	[es:LastError],al
	or	al,al
	jz	ple_ret
	mov	bl,FIRSTERRORSTRING
	push	ax
	 call	AusgabeStringNr		;"Fehler: %d "
	pop	ax
	add	bl,al
	call	AusgabeStringNr		;Fehlerbeschreibung
;	jmp	AusgabeNL
;@@e:	ret
endp

;*****************************
;** printf() Marke Eigenbau **
;*****************************

	P286
AusgabeNL:
	mov	bl,0
proc AusgabeStringNr c
;FU: String aus String-Tabelle mit Nummer BL ausgeben,
;    dabei Formatierung mit einer Mini-PRINTF-Funktion und 0A->0D0A-Expansion
local @@numberpuffer:BYTE:34,@@flags,@@space,@@preci
	pusha
	call	LoadString
	push	es
	 LD	es,ds
	 mov	di,ofs printf_buffer
	 lea	bx,[bp+4]
@@l:	 lodsb
	 or	al,al
	 jz	@@e
	 cmp	al,'%'
	 je	@@esc
	 cmp	al,0ah
	 je	@@0a
	 stosb
	 jmp	@@l
@@0a:
	 mov	ax,0a0dh
	 stosw
	 jmp	@@l
@@esc:
	 xor	ax,ax
	 mov	[BP-6],ax
	 mov	[BP-4],ax
	 mov	[BP-2],ax
	 call	EasyPrintfHandler
	 jmp	@@l
@@e:
	 mov	cx,di
	 mov	dx,ofs printf_buffer
	 sub	cx,dx			;Anzahl Zeichen
	 mov	bx,1			;stdout
	 DOS	40h			;schreiben (BlockWrite)
	pop	es
	popa
	ret
endp

;************ PRINTF: Komplette %-Behandllung ***************

SwitchChars	db	'LFNhl0.-+# '

	P386
proc PreprocessHandler
;NUR FöR TINY-MODELL und 386
;verarbeitet eine Sequenz, zum Verketten gemacht!
;Kann alle PrÑprozessor-Sachen: #,0,-,*,Feldbreite,PrÑzision,h,l,N,F
;
;PE: DS:SI=Eingabedaten
;    ES:DI=Ausgabedaten
;    SS:BP-8=PRINTF-Daten: OLen,Flags,Space,Precis
;    SS:BX=Externe Daten (hier: fÅr "*"-Feldbreiten-Platzhalter)
;PA: DS:SI->da geht's weiter
;    AL=(unbekanntes) Zeichen
;    CY=1 = konnte kein End-Zeichen umsetzen
@@l:	lodsb
	mov	cx,11
	push	di
	 mov	di,ofs SwitchChars
	 repne	scasb	;any known switch character?
	pop	di
	jne	@@nf
	bts	[bp-6],cx
	jmp	@@l
@@nf:
	cmp	al,'*'
	je	@@st
	cmp	al,'0'
	jc	@@gu
	cmp	al,'9'
	ja	@@gu
@@nu:			;scan the number
	dec	si
	push	bx
	 mov	bx,10
	 call	inw	;DS:SI->AX, DS:SI moved forward
	pop	bx
	jmp	@@nu0
@@st:
	mov	ax,[bx]	;get number from arglist
	inc	bx
	inc	bx
@@nu0:
	test	[by bp-6],bit 4
	jnz	@@pr
	mov	[bp-4],ax	;field width
	jmp	@@l
@@pr:
	mov	[bp-2],ax	;precision (not used if prec bit not given)
	jmp	@@l
@@gu:			;give up, unknown character (including zero)
	ret
endp

proc printf_FillChar
;PE: AX=number of characters
	xchg	cx,ax
	mov	al,' '
	test	[by bp-6],bit 5
	jz	@@1
	mov	al,'0'
@@1:	rep	stosb
	ret
endp

proc printf_strlen
;PE: DS:SI=String, AX=MaxLen (=precis oder 0FFFFh)
	push	di
	 mov	di,si
	 mov	cx,ax
	 push	ax
	  mov	al,0
	  repne	scasb
	  inc	cx
	 pop	ax
	 sub	ax,cx
	pop	di
	ret
endp

proc printf_postfill
	xor	[by bp-6],bit 3	;Bit kippen
endp
proc printf_prefill
;PE: AX=auszugebende Zeichenzahl
	test	[by bp-6],bit 3
	jnz	@@e		;left aligned: do nothing!
fill0:
	push	ax
	 sub	ax,[bp-4]
	 jnc	@@e0
	 neg	ax		;free width
	 call	printf_FillChar
@@e0:	pop	ax
@@e:	ret
endp


proc printf_itoa
;BL=Zahlenbasis; negativ wenn Zahl vorzeichenbehaftet
;EAX=Zahl
;[BP-6]=Flags, Bit 15=1 fÅr gro·e Hex-Buchstaben
;DI=ASCII-Puffer
;PA:DI=Ende Puffer (nicht terminiert!)
	mov	dx,[bp-6]
	xchg	ecx,eax
	or	bl,bl
	jns	@@1
	neg	bl		;jetzt positiv machen
	or	ecx,ecx
	mov	al,'-'
	js	@@putn
	test	dl,bit 2	;Merker "+"
	mov	al,'+'
	jnz	@@put
	test	dl,bit 0	;Merker " "
	mov	al,' '
	jnz	@@put
	jmp	@@1
@@putn: neg	ecx
@@put:	stosb
@@1:	test	dl,bit 1	;Merker "#"
	jz	@@2
	cmp	bl,8
	mov	al,'0'
	jne	@@no_8
	stosb
@@no_8:	cmp	bl,2
	mov	ah,'b'
	je	@@do_2
	cmp	bl,16
	mov	ah,'x'
	jne	@@2
@@do_2:	stosw
@@2:	xchg	ecx,eax		;wieder zurÅck!
	xor	cx,cx		;ZÑhler der PUSHes
	movzx	ebx,bl
@@l1:	inc	cx
	xor	edx,edx
	div	ebx
	push	dx		;eine Ziffer
	or	eax,eax
	jnz	@@l1
@@l2:	pop	ax		;herausholen in umgekehrter Reihenfolge
	add	al,'0'		;(Alternative: Puffer von hinten fÅllen!)
	cmp	al,'9'
	jbe	@@3
	add	al,7
	test	[by bp-5],bit 7
	jnz	@@3
	add	al,20h		;Kleinbuchstaben
@@3:	stosb
	loop	@@l2
	ret
endp

proc EasyPrintfHandler
	call	PreprocessHandler
	cmp	al,'%'		;muss als Extrawurst gebraten werden!
	je	@@perc
	push	si
	 cmp	al,'s'
	 je	@@s
	 lea	si,[bp-34-6]
	 cmp	al,'c'
	 je	@@c
	 mov	dl,-10
	 cmp	al,'d'
	 je	@@num
	 cmp	al,'i'
	 je	@@num
	 mov	dl,10
	 cmp	al,'u'
	 je	@@num
	 mov	dl,8
	 cmp	al,'o'
	 je	@@num
	 mov	dl,2
	 cmp	al,'b'		;Nicht Standard, aber sehr nÅtzlich!
	 je	@@num
	 mov	dl,16
	 cmp	al,'x'
	 je	@@num
	 or	[by bp-5],bit 7
	 cmp	al,'X'
	 je	@@num
	 cmp	al,'p'		;Zeiger als gro·e Hex-Zahlen ausgeben
	 je	@@num
	pop	si
	dec	si
	stc
	ret

@@perc:	stosb
	ret

@@num:	 mov	eax,[bx]
	 test	[by bp-6],bit 6
	 jnz	@@long
	 movzx	eax,ax
	 or	dl,dl
	 jns	@@nume
	 movsx	eax,ax
	 jmp	@@nume
@@long:	 inc	bx
	 inc	bx
@@nume:	 push	di bx
	  mov	di,si
	  mov	bx,dx
	  call	printf_itoa
	  sub	di,si		;Anzahl Zeichen
	  xchg	di,ax		;nach AX
	 pop	bx di
	 jmp	@@stout
@@c:
	 mov	si,bx		;Diese Adresse ist Quelle
	 mov	ax,1
	 jmp	@@stout
@@s:
	 mov	ax,[bx]
	 or	ax,ax		;NULL-Pointer?
	 jz	@@stout		;Dann nichts ausgeben!
	 xchg	si,ax
	 mov	ax,0FFFFh
	 test	[by bp-6],4	;precis given?
	 jz	@@1
	 mov	ax,[bp-2]	;use precis as maximum length!
@@1:	 call	printf_strlen
@@stout:	;Einsprung mit DS:SI=Stringzeiger, AX=String-LÑnge
	 inc	bx
	 inc	bx
	 call	printf_prefill
	 mov	cx,ax
	 rep	movsb
	 call	printf_postfill
	pop	si
	ret
endp
printf_buffer	=	$
;der Hilfe-String ist zwar wesentlich lÑnger, aber damit endet das Programm,
;und nachfolgender Code wird nicht mehr benutzt.

Alt_String_Table =	$+80	;einige Strings im "kritischen Bereich"
;==== END CRITICAL INITIALIZATION SECTION ====

	org Residente_Puffer		;keine Null-Orgien!
;==== dieser Init-Code wird von printf() Åberschrieben! ====
proc InstChk
;FU: Installations-Test
;PA: Bit7(CH)=0: Installationscheck erfolgreich, dann:
;    ES: Segmentadresse der residenten Routine, sonst =DS
;    Bit0(CH)=0: Zeiger Int21 nicht von anderen verbogen
;    Bit1(CH)=0: Zeiger Int2F nicht von anderen verbogen
;    DS:[OldInt21], DS:[OldInt2F]: gelesene Zeiger
;VR: AX,BX,CH,DX(=ES)
;Au·erhalb von InstChk: Bit6(CH)=1 wenn irgendein Schalter akzeptiert
		mov	dx,REQcode
		DOS	REQfunc		;Install-Test
		xor	ch,ch
		cmp	ax,ANScode	;gleich?
		jz	@@T21I
		BSET	ch,bit 7
		mov	dx,ds
@@T21I:
		DOS	3521h		;Get Int21
		SES	[OldInt21],bx
		cmp	bx,ofs NewInt21
		jnz	@@T21FLT
		mov	bx,es
		cmp	bx,dx
		je	@@T21OK
@@T21FLT:	inc	ch		;Bit 0 setzen
@@T21OK:
if USEWIN or USECP
		DOS	352Fh		;Get Int2F
		SES	[OldInt2F],bx
		cmp	bx,ofs NewInt2F
		jnz	@@T2FFLT
		mov	bx,es
		cmp	bx,dx
		je	@@T2FOK
@@T2FFLT:	BSET	ch,bit 1
@@T2FOK:
endif
		mov	es,dx
		ret
endp

proc getargv0
;PA: [workdir] gesetzt
;    Eigener Programmname auf Pfad ohne Backslash gekÅrzt
;    AX=0
;VR: AX,CX,SI,DI
	push	es
	 mov	es,[2ch]	;Segment Environment
	 xor	di,di
	 xor	ax,ax
	 db	0B9h		;mov cx,< irgendeine Zahl > 7FFF >
@@such:	  repne	scasb
	 scasb
	 jnz	@@such
	 scasw			;number of "extensions"
	 jz	@@cannot	;no extension (DOS <3)
	 call	set_workdir
	 mov	si,di
	 repne	scasb
	 dec	di
	 mov	al,'\'
	 std
	 repne	scasb
	 cld
	 inc	di
	 mov	al,0
	 stosb			;make a path from file name
@@cannot:
	pop	es
	ret
endp

if USEWINTIME
proc FindTZ
;Find the TZ environment variable
;PE: Z=1, TZ found at ES:DI
;    Z=0, no TZ in the environment (or possibly it was first)
	mov	ax,[2ch]	;Segment Environment
	push	ax
	dec	ax		;MCB
	mov	es,ax
	mov	cx,[es:3]	;size of environment (paras)
	shl	cx,4		;size in bytes
	pop	es
	xor	di,di
	mov	eax,'=ZT' shl 8
@@such: repne	scasb		;search for NUL of previous variable
	jne	@@e		; (assume TZ is not first)
	cmp	[es:di-1],eax
	jne	@@such
@@e:	ret
endp

proc CalcTZ
;Convert TZ string to decimal and adjust [TimeOffset] accordingly
;PA: DS:SI -> TZ string
;PE: [TimeOffset] adjusted, SI at end of string
@@let:	lodsb			;skip the letters
	cmp	al,'9'
	ja	@@let
	cmp	al,'-'
	je	@@ok
	cmp	al,'0'
	jb	@@let
	dec	si
@@ok:	mov	di,si
	mov	bl,10
	call	InW
	movzx	ecx,ax
	imul	cx,60		;hours to minutes
	cmp	[by si],':'
	jne	@@nomin
	inc	si
	call	InW
	add	cx,ax		;timezone in minutes
@@nomin:
	cmp	[by di-1],'-'
	jne	@@plus
	neg	ecx
@@plus: mov	eax,60*1000*1000*10	;minutes to 100-ns
	imul	ecx
	add	[cs:TimeOffset],eax	;DS might be the environment
	adc	[cs:TimeOffset+4],edx
	ret
endp

proc gettz
;PA: [TimeOffset] adjusted to compensate for UTC times
;VR: alle
	push	ds es
	 call	FindTZ
	 jnz	@@e
	 LD	ds,es
	 lea	si,[di+3]
	 call	CalcTZ
@@e:	pop es ds
	ret
endp

proc PrintTimeZone
;Display the current timezone (opposite sign to TZ variable)
	push	cx
	mov	eax,[Epoch]
	mov	edx,[Epoch+4]
	sub	eax,[es:TimeOffset]
	sbb	edx,[es:TimeOffset+4]
	mov	ecx,60*1000*1000*10	;minutes to 100-ns
	idiv	ecx
	mov	cl,60
	idiv	cl
	push	ax
	mov	cl,100
	imul	cl
	pop	cx
	sar	cx,8
	add	ax,cx
	push	ax
	mov	bl,41		;"Timezone is"
	call	LoadString
	push	si
	mov	bl,42
	call	AusgabeStringNr
	pop	cx cx
	pop	cx
	ret
endp
endif ;USEWINTIME

proc transient
;== 1. Meldung ==
	PRINT	Text0		;Meldung sofort
;== 2. Installations-Test ==
	call	InstChk		;setzt ggf. ES auf Fremdroutine
	;nun ch=Statusregister:
	;Bit0&1: Deinstallation nicht mîglich
	;Bit4: Option Z gegeben
	;Bit5: Option M gegeben
	;Bit6: Schalter angegeben
	;Bit7:   Noch nicht installiert
	test	ch,bit 7
	jz	@@nostartup	;resident
;== 3. Standard-Sprache festlegen ==
	push	cx
	 mov	dx,ofs fname_buffer
	 DOS	3800h		;Land-Info holen
	 jc	@@k
	 xchg	bx,ax		;AX ist besser im Zugriff!
	 or	ah,ah
	 jnz	@@k
	 cmp	al,41		;Schweiz
	 je	@@de
	 cmp	al,43		;ôsterreich
	 je	@@de
	 cmp	al,49		;Deutschland
	 jne	@@k
@@de:	 mov	[language],'D'
@@k:
;== 4. argv[0] extrahieren, daraus Pfad fÅr WorkDir basteln ==
	 call	getargv0
;== 5. set appropriate timezone ==
if USEWINTIME
	 call	gettz
endif
;== 6. Determine the presence of the FAT32 API ==
	 mov	ax,7302h	;extended get DPB
	 mov	dl,0		;current drive
	 mov	cx,3fh		;length of buffer
	 mov	di,ofs CD_Backup;buffer
	 stc			;for pre-DOS7
	 int	21h
	 jnc	@@ext
	 cmp	ax,7300h	;did it fail because there's no such call?
	 jne	@@ext		;no, it didn't like the drive
	 mov	si,ofs dgroup:Fat_RW_std ;copy the standard routines
	 mov	di,ofs Fat_RW
	 mov	cx,std_size
	 rep	movsb
	 mov	[wo FAT_R],25b0h
	 mov	[by FAT_W],0b8h
	 mov	[wo FAT_W+1],26h
@@ext:
;== 7. Anwesenheit von MSCDEX prÅfen und Vorgabe stellen ==
	 mov	ax,[wo test_cd+1] ;remember correct call offset
	 mov	[wo cdok+1],ax
	 xor	bx,bx
	 MUX	1500h
	 or	bx,bx
	 jz	@@nomscdex
	 BSET	[ctrl0],CTRL_CDROM
	 jmp	@@cddone
@@nomscdex:
	 mov	[wo test_cd],9090h	;NOP
	 mov	[by test_cd+2],90h
@@cddone:
	pop	cx
@@nostartup:
	mov	al,[es:language]
	call	SetStringResourcePointer
;== 8. Kommandozeile parsen und Aktionen durchfÅhren ==
	mov	si,81h
	cld
;==== HIERHIN DARF DER LéNGSTE STRING REICHEN! ====
@@scancl:
	lodsb
	call	Upcase
	push	es
	 push	ds
	 pop	es
	 mov	di,ofs cmd_verteiler
	 call	case
	pop	es
	jc	@@scancl
	call	[wo di]
	jmp	@@scancl
endp

;all diese Routinen dÅrfen SI (oder nur nach weiterer Parameter-
;Auswertung) und CH nicht verÑndern!
cmd_verteiler:	dvt	0dh,Install
		dvt	'?',help
		dvt	'H',help
		dvt	'U',UnInst
		dvt	'D',DisActiv
		dvt	'W',SetWrite
		dvt	'~',SetTilde
		dvt	'T',SetTunnel
		dvt	'C',SetCDROM
		dvt	'I',SetInDOS
		dvt	'R',SetRoBit
if USEWINTIME
		dvt	'O',SetTimeZone
endif
		dvt	'Z',LoadUni
		dvt	'M',SetHeapSize
		dvt	'L',SetLang
		dvt	'P',SetWorkDir
		dvt	'S',ShowStatus
		db	0

;**************************************
;* Kommandozeilen-Schalter-Behandlung *
;**************************************
	_INW3

proc skip_one_equal_colon_space
	lodsb
	cmp	al,':'
	je	@@e
	cmp	al,'='
	je	@@e
	cmp	al,' '
	je	@@e
	dec	si
@@e:	ret
endp

proc Expect_ASCIIZ
;FU: Parst Kommandozeile nach einem Dateinamen
;PE: SI=Zeiger nach Schalterzeichen
;PA: DX=Zeiger auf Dateiname
;    SI=Zeiger nach Nullterminierung des Dateinamens
;    Kommandozeile fÅr Nullterminierung modifiziert
	call	skip_one_equal_colon_space
	mov	dx,si		;Dateiname (kurz)
@@l1:	lodsb
	cmp	al,21h		;Ende suchen
	jnc	@@l1
	mov	[by si-1],0	;terminieren!
	cmp	al,0Dh		;war letztes Argument?
	jne	@@1
	mov	[si],al		;0Dh verschieben nach hinten
@@1:	ret
endp

proc LoadUni
;BE: Unicode-Tabelle im Volkov-Commander-Tabellenformat (siehe TBL.TXT) laden
;    Hier noch nicht, erst nach Heap-Initialisierung mîglich!
	call	Expect_ASCIIZ
	mov	[UserUniFile],dx
	BTST	ch,bit 7	;Resident?
	jnz	@@ex		;Nein, erst Heap initialisieren!
	push	dx		;fÅr Fehlermeldung
	 DOS	3D00h		;zum Lesen îffnen
	 mov	bl,3		;"Kann nicht îffnen"
	 jc	@@e		;Datei nicht gefunden o.Ñ.
	 push	si cx ds
	  LD	ds,es
	  call	ReadUniFile
	 pop	ds cx si
@@e:	pop	ax
	jc	TxtOut0
@@ex:	BSET	ch,bit 4	;Merker, verhindert Auto-Load
	ret
endp

proc SetHeapSize
	mov	bl,29
	test	ch,bit 7	;Installiert?
	jz	txtout2 	;ja, kann HeapSize (noch) nicht verÑndern!
	lodsb
	BRES	al,bit 5
	mov	di,offset ShortSize
	cmp	al,'S'
	je	@@1
	mov	di,offset LongSize
	cmp	al,'L'
	je	@@1
	mov	di,offset NameSize
	cmp	al,'N'
	je	@@1
	mov	di,offset LocalHeapSize
	dec	si
@@1:	call	skip_one_equal_colon_space
	call	InW3		;Zahl einlesen
	mov	bl,23
	jc	txtout0
	cmp	ax,[di+2]
	jc	txtout0
	cmp	ax,[di+4]
	ja	txtout0
@@s:	mov	[di],ax
	BSET	ch,bit 5
	ret
endp

proc txtout2
	call	AusgabeStringNr
	mov	bl,31		;Hinweis
txtout0:jmp	txtout
endp

proc SetWorkDir
ifdef PROFILE
	cmp	[by si],'c'
	jne	@@nc
	cmp	[by si+1],' '
	jbe	calibrate
@@nc:
endif
	mov	bl,28
	test	ch,bit 7
ifdef PROFILE
	jz	DoProfile
else
	jz	txtout2
endif
	call	Expect_ASCIIZ
	mov	bl,27
	push	cx
	 mov	di,ofs truename_buf
	 push	si
	  mov	si,dx
	  DOS	60h
	 pop	si
	 jc	txtout0
	 mov	dx,di
	 DOS	4300h		;attrib->PrÅfen auf Verzeichnis
	 jc	txtout0
	 test	cl,10h
	 jz	txtout0
	 push	di		;leidiges nachlaufendes Backslash entfernen,
	  call	strlenp1	;insbesondere wegen Interpretation von
	  sub	di,2		;"C:\\xyz" als Netzwerkressource xyz!
	  cmp	[by di],'\'	;Auch wenn jetzt nur "C:" Åbrig bleibt,
	  jne	@@1		;ein Backslash setzt die Software noch dran.
	  mov	[di],ah
@@1:	 pop	di
	pop	cx
set_workdir:
	SES	[WorkDir],di
	ret
endp

ifdef PROFILE
proc DoProfile
	mov	bl,ProfileNr
	mov	cx,ofs p_display
	cmp	[by si],'r'
	jne	@@s
	mov	cx,ofs p_reset
	inc	bx
@@s:	call	AusgabeStringNr
	mov	bx,ofs profile_data
	sub	eax,eax
@@l:	call	cx
	add	bx,size Tprofile
	cmp	bx,ofs profile_stop
	jne	@@l
	DOS	4C00h
endp

proc p_display
	push	bx
	lea	ax,[(Tprofile es:bx).desc]
	push	ax
	mov	eax,[(Tprofile es:bx).ticks]
	movzx	edx,[(Tprofile es:bx).tick_h]
	mov	esi,2596000	;replace with your timing constant
	div	esi
	mov	esi,1000
	sub	edx,edx
	div	esi
	push	dx
	push	ax
	push	[(Tprofile es:bx).count]
	mov	bl,ProfileNr+2
	call	AusgabeStringNr
	add	sp,10
	pop	bx
	ret
endp

proc p_reset
	mov	[(Tprofile es:bx).count],eax
	mov	[(Tprofile es:bx).ticks],eax
	mov	[(Tprofile es:bx).tick_h],ax
	ret
endp

profile_calibrate Tprofile <>

proc calibrate
	mov	bl,ProfileNr+3
	call	AusgabeStringNr
	mov	ah,86h		;BIOS Wait
	mov	cx,16		;1.048576 seconds
	sub	dx,dx
	start_profile calibrate
	int	15h
	end_profile
	mov	bl,ProfileNr+5
	jc	@@o
	mov	eax,[profile_calibrate.ticks]
	movzx	edx,[profile_calibrate.tick_h]
	shrd	eax,edx,20
	dec	bx
@@o:	push	eax
	call	AusgabeStringNr
	add	sp,4
	DOS	4C00h
endp
endif ;PROFILE

if USEWINTIME
proc SetTimeZone
	push	cx
	mov	eax,[Epoch]	;Discard the TZ found on startup
	mov	[TimeOffset],eax
	mov	eax,[Epoch+4]
	mov	[TimeOffset+4],eax
	mov	cx,ofs CalcTZ
	cmp	[by si],' '
	ja	$+5
	mov	cx,ofs gettz	;No timezone specified, read TZ variable
	push	si
	 call	cx
	pop	si
	mov	eax,[TimeOffset]
	mov	[es:TimeOffset],eax
	mov	eax,[TimeOffset+4]
	mov	[es:TimeOffset+4],eax
	pop	cx
	BSET	ch,bit 6	;irgendein Schalter
	ret
endp
endif ;USEWINTIME

proc SetCDROM	;Schalter fÅr CD-ROM-UnterstÅtzung
	mov	bl,30
	test	ch,bit 7
	jz	txtout2
	mov	cl,CTRL_CDROM
	call	SetPlusMinus
	cmp	al,'+'
	mov	cl,0e8h 	;CALL near
cdok:	mov	ax,0		;patched by CD test
	je	@@set
	mov	ax,9090h
	mov	cl,al
@@set:	mov	[wo test_cd+1],ax
	mov	[by test_cd],cl
	ret
endp
proc SetWrite	;Schalter fÅr Schreibzugriff
	mov	cl,CTRL_Write
	call	SetPlusMinus
	cmp	al,'+'
	mov	ax,[wo Ctrl_write_test]
	je	@@set
	mov	ax,090f9h		;AL = STC, AH = NOP
@@set:	mov	[wo es:Ctrl_write_test],ax ;Code patchen
	ret
endp
proc SetTilde	;Schalter fÅr Schlangen
	mov	cl,CTRL_Tilde
	jmp	SetPlusMinus
endp
proc SetTunnel	;Schalter fÅr Tunneleffekt
	mov	cl,CTRL_Tunnel
	jmp	SetPlusMinus
endp
proc SetInDOS	;Schalter fÅr InDOS-Flag-Benutzung
	mov	cl,CTRL_InDOS
	call	SetPlusMinus
	cmp	al,'+'
	mov	ax,909ch		;AL = PUSHF, AH = NOP
	je	@@set
	mov	ax,0c3c3h		;RET
@@set:	mov	[by es:IncInDosFlag],al ;Code patchen
	mov	[by es:ResetDrv],ah	;Code patchen
	ret
endp
proc SetRoBit	;Schalter fÅr ReadOnly-Attribut bei CDFS
	mov	cl,CTRL_RoBit
	call	SetPlusMinus
	cmp	al,'+'
	je	@@ro
	mov	[by es:CDRO],0f8h	;CLC
	ret
@@ro:	mov	[by es:CDRO],0f9h	;STC
	ret
endp
proc SetPlusMinus
	lodsb
	cmp	al,'+'
	je	@@set
	cmp	al,'-'
	jne	help		;sonst Hilfeseite
	not	cl
	and	[es:ctrl0],cl
	jmp	@@e
@@set:	or	[es:ctrl0],cl
@@e:	BSET	ch,bit 6	;irgendein Schalter
	ret
endp

proc SetLang
	lodsb
	call	Upcase
	mov	[es:language],al
SetStringResourcePointer:
	cmp	al,'D'
	mov	ax,ofs Texte_deutsch
	je	@@de
	mov	ax,ofs Texte_englisch
@@de:	mov	[String_Table],ax
	ret
endp
	P8086

proc help	;Hilfe Option "H" oder "?", kein Return
	mov	ax,ofs djmh$
	push	ax		;8086!
	mov	ax,ofs Downl$
	push	ax		;8086!
	mov	ax,ofs ejmh$
	push	ax
	mov	ax,ofs Email$
	mov	bl,10
	jmp	TXTO1
endp

;********************
;** Deinstallation **
;********************

proc UnInst	;Deinstallation(sversuch) Option "U", kein Return
	mov	bl,7		;"noch nicht installiert"
	test	ch,bit 7
	jnz	TXTO1		;Wenn nicht nîtig!
	test	ch,3
	jz	Raus
	mov	bl,5		;"deaktiviert"
	call	AusgabeStringNr
	inc	bl		;"Interrupt gestohlen"
disab:	and	[es:Ctrl0],not 80h	;lîschen
	jmp	TXTOut
DisActiv:;Deaktivieren Option "D" oder Dirs ein/aus mit D+/D-
	test	ch,bit 7	;Schon installiert?
	mov	bl,7
	jnz	TXTO1
	mov	bl,5		;"deaktiviert"
	jr	disab
	;Deinstallation
Raus:	push	ds
	 lds	dx,[es:OldInt21]
	 DOS	2521h
if USEWIN or USECP
	 lds	dx,[es:OldInt2F]
	 mov	al,2Fh
	 DOS
endif
	pop	ds
	DOS	49h		;den Speicher ab es freigeben
	mov	bl,13		;"removed..."
TXTO1:	jmp	TXTOut
endp

;***********************
;** Statistik-Ausgabe **
;***********************

proc ShowStatus	;Status-Anzeige, kein Return
	test	ch,bit 7
	mov	bl,7		;"Noch nicht installiert"
	jnz	TXTOut
	P386
	mov	cl,[es:ctrl0]
	test	cl,80h
	mov	bl,5		;"deaktiviert"
	jz	TXTOut
	mov	bl,11
	call	AusgabeStringNr
	call	AusgabeNL
	call	AusgabeSchalter
if USEWINTIME
	call	PrintTimeZone
endif
	mov	bl,14
	mov	si,ofs counter_read
	seges
	lodsd
	call	AusgabeZaehler
	inc	bl
	seges
	lodsd
	call	AusgabeZaehler
	inc	bl
	seges
	lodsd
	call	AusgabeZaehler
	call	AusgabeHeap
	call	PrintLastError
	DOS	4C00h
endp

proc AusgabeSchalter
;Alle Schalter ausgeben
	mov	cl,[es:ctrl0]
	mov	ch,40h
	mov	bl,17
@@l:	push	bx
	 call	AusgabeSch
	pop	bx
	ror	ch,1
	inc	bl
	cmp	bl,23
	jne	@@l
	ret
endp

proc AusgabeZaehler
;PE: BL=String-Nummer
;    EAX=ZÑhlerstand
	push	bx
	 push	eax
	 call	AusgabeStringNr
	 pop	eax
	 call	AusgabeNL
	pop	bx
	ret
endp

proc GetOnOffPtr
;PE: Z=0=EIN, Z=1=AUS
;PA: SI=String-Zeiger
;VR: AX,CX,SI
	push	bx
	 mov	bl,24		;"EIN"
	 jnz	@@1
	 inc	bl		;"AUS"
@@1:	 call	LoadString
	pop	bx
	ret
endp

proc AusgabeSch
	push	bx cx
	 test	cl,ch
	 call	GetOnOffPtr
	 push	si
	 call	LoadString
	 push	si
	 mov	bl,26		;"%xxs %s\n"
	 call	AusgabeStringNr
	 pop	cx
	 pop	cx
	pop	cx bx
	ret
endp

proc AusgabeHeap
;Einfacher HeapWalker, geht nur den freien Bereich durch!
	mov	si,es
	dec	si
	mov	ds,si		;MCB-Zeiger
	mov	ax,[3]		;Paragrafen
	shl	ax,4		;Bytes
	inc	si
	mov	ds,si
	mov	si,[LocalHeap]
	sub	ax,si
	sub	ax,4		;Zwangsbytes nicht mitzÑhlen
	push	ax		;SIZE
	xor	bx,bx		;USED
	xor	cx,cx		;FREE
	xor	dx,dx		;MAXAVAIL
@@l:	lodsw
	xchg	di,ax
	lodsw
	add	cx,ax
	cmp	dx,ax
	jnc	@@1
	mov	dx,ax		;Maximum
@@1:	or	di,di
	jz	@@e
	or	ax,ax
	je	@@2
	sub	si,4
	add	si,ax
@@2:	mov	ax,[si]
	add	bx,ax
	add	si,ax
	cmp	si,di
	jb	@@2
	jmp	@@l
@@e:	sub	si,4		;see if anything is allocated after the
	add	si,ax		; last free block
	pop	ax
	push	ax
	mov	di,[LocalHeap]
	add	di,ax		;DI -> end of heap
	jmp	@@3a
@@3:	mov	ax,[si]
	add	bx,ax
	add	si,ax
@@3a:	cmp	si,di
	jb	@@3
	LD	ds,cs
	pop	ax
	push	dx
	push	cx
	push	bx
	push	ax
	mov	bl,34
	call	AusgabeStringNr
	add	sp,8
	ret
endp
	P8086

;********************************
;** Installations-Vorbereitung **
;********************************

proc GetLocalHeapSize
;Berechnet erforderliche(?) Heap-Grî·e anhand der grî·ten .JLT-Datei,
;die im Arbeitsverzeichnis von DOSLFN liegt
;PA: AX=Heap-Grî·e
	PUSHSTATE
	P386
	mov	ax,[LocalHeapSize]
	or	ax,ax
	jnz	@@e		;angegebene Grî·e (root wei·, was sie tut)
	lea	dx,[StdDTA]
	DOS	1Ah		;DTA nach hinten setzen
	lea	di,[fname_buffer]
	push	di
	 call	CopyWorkDir
	 mov	dx,[UserUniFile]
	 or	dx,dx
	 jnz	@@userload
	 DOS	6601h		;Codeseite holen
	 jc	@@noload
	 push	di
	  call	MakeTblFileName
	 pop	di
	 lea	dx,[fname_buffer]
@@userload:
	 mov	cx,7
	 DOS	4Eh		;FindFirst
	 jc	@@noload
	 mov	eax,[StdDta.fsize]
	 cmp	eax,50000	;Zu gro·?
	 jna	@@load
@@noload:
	 xor	ax,ax
@@load:
	 add	ax,DEFHEAPSIZE	;"Pflichtteil" dazu
	pop	dx		;fname_buffer
	BTST	[ctrl0],CTRL_CDROM
	jz	@@e		;nur mit .TBL berechnet
	push	ax
	 lea	si,[jltfilter$]	;mit grî·ter .JLT dazu
	 call	strcpy
	 mov	di,DEFHEAPSIZE_CD-DEFHEAPSIZE	;zusÑtzlicher "Pflichtteil"
	 mov	cx,7		;Versteckte Dateien gehen auch!
	 mov	ah,4Eh		;FindFirst
	 jmp	@@f
@@l:	 mov	eax,[StdDTA.fsize]
	 cmp	eax,32000	;Irreales Ma·!
	 ja	@@1		;Ignorieren
	 cmp	ax,di
	 jc	@@1
	 xchg	di,ax		;neues Ma·
@@1:	 mov	ah,4Fh		;FindNext
@@f:	 DOS
	 jnc	@@l
	pop	ax
	add	ax,di
@@e:	ret
	POPSTATE
endp

proc CheckWinVer
	MUX	160Ah		;Windows-Versionsnummer
	or	ax,ax
	jnz	@@e
	cmp	bh,4		;Zu hoch?
	mov	bl,33
	jc	@@e
_out:	jmp	TXTOut
@@e:	ret
endp

proc Install	;Installation oder Aktivierung, kein Return
	test	ch,bit 7
	jnz	@@test
	call	CheckWinVer
	mov	bl,12		;"reaktiviert"
	test	ch,bit 6	;irgendein Schalter auf Kommandozeile gewesen?
	jz	@@setab		;ohne, "reaktiviert"
	mov	bl,9		;mit,  "Schalter angenommen"
@@setab:jmp	Activate
@@test:				;hier: ES=DS
;Auf Mindest-Prozessor und -Betriebssystem testen
	mov	bp,cx		;retten
	IS386
	mov	bl,8		;"Test386 versagt"
	jc	_out
	P386
	DOS	30h		;DOS-Versionsnummer
	cmp	al,4		;wegen Int21/AH=6Ch
	mov	bl,32
	jc	_out
	call	CheckWinVer
;Zeiger auf InDOS-Flag und GerÑtetreiber-Kette beschaffen
	push	es		;Brauch ich's?
	 DOS	34h		;InDOS-Flag-Adresse beschaffen
	 mov	[InDosFlagOfs],bx
	 mov	[InDosFlagSeg],es
	 DOS	52h		;get NUL device driver address
	 add	bx,22h
	 cmp	[dwo es:bx+10],' LUN'	;Is there actually a NUL header?
	 je	@@okdev
	 mov	bx,0FFFFh	;let scan for devices auto-terminate
@@okdev: SES	[DriverChain],bx
	pop	es
;Hand-Relokation im residenten Bereich
	mov	[wo high rwrec.addr],cs
	mov	[wo DPB_Drive],0FFh	;kein Laufwerk beim Start
	;mov	[DriveType],0	;Um Gottes Willen keinen Flush machen!
	and	[Medium.jol.linktbl],0	;no link table
	and	[wo high DPB_FAT1Sec],0 ;these three may only be WORDs
	and	[wo high DPB_UsrSec],0	;but they are always used as DWORDs
	and	[wo high DPB_DirSec],0	;so clear the high word once only
;Zeiger auf "filename uppercase table" beschaffen
	mov	bx,0FFFFh
	mov	cx,5
	mov	dx,bx
	mov	di,5Dh
	DOS	6504h
	mov	eax,[5Eh]
	sub	ax,7Eh
	mov	[uppercase_table],eax
;Zeiger auf "DBCS lead byte table" beschaffen
	DOS	6507h
	mov	eax,[5Eh]
	inc	ax
	inc	ax		;LÑnge Åbergehen
	mov	[lead_byte_table],eax
;5 kritische Strings umsetzen (in Sektor-Bereich)
	mov	bx,ofs String_Table
	mov	si,[bx]
	mov	di,ofs Alt_String_Table
	mov	[bx],di		;String_Table neu setzen
	mov	cx,5
@@l:	call	strcpy
	loop	@@l
;Initialisierung des Lokalen Heap vorbereiten
	call	GetLocalHeapSize
			;sollte auf Paragrafengrenze aufgerundet werden!
	mov	di,ofs DefLocalHeap
	BTST	[ctrl0],CTRL_CDROM
	jnz	@@a1
	mov	di,ofs DefLocalHeap_FATONLY
@@a1:	jmp	CriticalInit
endp

jltfilter$:	dz	"*.JLT"

;***********************
;** String-Ressourcen **
;***********************
;Die einzelnen Strings sind einfach durch \0-Zeichen voneinander getrennt
;und dicht an dicht hintereinander.
;Die ersten 5 Strings werden in einen sicheren Bereich kopiert,
;bevor der Heap (Åber die Strings hinweg) initialisiert wird.

FIRSTERRORSTRING = 35

Email$: dz	"henrik.haftmann@e-technik.tu-chemnitz.de"
ejmh$:	dz	"jadoxa@yahoo.com.au"
Downl$:	dz	"http://www.tu-chemnitz.de/~heha/hs_freeware/doslfn.zip"
djmh$:	dz	"http://doslfn.adoxa.cjb.net/"

Text0	db	"DOSLFN 0.34d (haftmann#software & jmh 10/06): $"

Texte_deutsch:
 dz	10							;0
 dz    "hoch"							;1
 dz    "geladen, verbraucht %u Bytes."				;2
 dz 10,"Kann Unicode-Datei %s nicht finden/îffnen!"		;3
 dz 10,"Falscher Inhalt der Datei %s oder Lese-Fehler!"		;4
 dz    "deaktiviert."						;5
 dz 10,"(Andere TSR stahl Int21 und/oder Int2F)"		;6
 dz    "Noch nicht installiert!"				;7
 dz    "Benîtigt mindestens einen 386er Prozessor!"		;8
 dz    "Schalter angenommen."					;9
 db    "	(386+)	++ FREEWARE ++",10			;10
  db   "Programm fÅr lange Dateinamen unter nacktem DOS.",10
  db   "Aktionen:	- (nichts)	TSR laden oder aktivieren",10
  db   "		- h oder ?	diese Hilfe",10
  db   "		- d		DOSLFN deaktivieren",10
  db   "		- s		Status und Einstellungen",10
ifdef PROFILE
  db   "                - p             show profile data",10
  db   "                - pr            reset profile data",10
  db   "                - pc            calibrate profile timing",10
endif
  db   "		- u		TSR entfernen",10
  db   "Schalter:	- w{+|-}	* Schreibzugriffe",10
  db   "		- ~{+|-}	* Tilde (ich hasse Schlangen)",10
  db   "		- t{+|-}	* Tunneleffekt (fÅr Editoren)",10
  db   "		- c{+|-}	* CDROM-UnterstÅtzung",10
  db   "		- i{+|-}	* InDOS-Flag-Wiederaufrufsperre fÅr TSRs",10
  db   "		- r{+|-}	* Schreibschutz-Attribut fÅr CDROM-Dateien",10
if USEWINTIME
  db   "                - o[N]          * set time zone N or read TZ if absent",10
endif
  db   "		- z[:|=]table	Unicode-Tabelle (.TBL-Volkov-Format) laden",10
  db   "		- m[:|=]bytes	Grî·e des internen Heaps festlegen, 600..50000",10
  db   "                - ms[:|=]bytes  declare size of short path, 16..141",10
  db   "                - ml[:|=]bytes  declare size of long path, 16..1024",10
  db   "                - mn[:|=]bytes  declare size of long name, 13..512",10
  db   "		- p[:|=]path	Arbeitsverzeichnis (.TBL/.JLT/.386) festlegen",10
  db   "		- l{d|e}	Sprache setzen (deutsch|englisch)",10
  db   "Umgebung: 	TZ=xxxNyyy	Zeitzone N fÅr Zeitumrechnung, ohne DST",10
  db   "Email:    %s",10
  db   "          %s",10
  db   "Download: %s",10
  dz   "          %s"

 dz    "aktiv"							;11
 dz    "reaktiviert."						;12
 dz    "vom Speicher entfernt."					;13
 dz    "%7lu Lesezugriffe"                                      ;14
 dz    "%7lu Schreibzugriffe"                                   ;15
 dz    "%7lu Int21/AH=71-Aufrufe"                               ;16
 dz    "Schreibzugriffe"					;17
 dz    "Schlangen"						;18
 dz    "Tunneleffekt"						;19
 dz    "CDROM-UnterstÅtzung"					;20
 dz    "InDOS-Flag-Verriegelung + RESET Laufw."                 ;21
 dz    "Schreibschutz-Attribut fÅr CD-Dateien"			;22
 dz    "UngÅltige Heap-Grî·e"					;23
 dz    "EIN"							;24
 dz    "AUS"							;25
 dz    "%37s %s",10						;26
 dz    "Verzeichnis existiert nicht!"				;27
 dz    "Kann Verzeichnis nicht setzen."				;28
 dz    "Kann Heap-Grî·e nicht verÑndern."			;29
 dz    "Kann Schalter nicht annehmen."				;30
 dz 10,"Dazu vorher TSR entfernen."				;31
 dz    "DOS4+ erforderlich!"					;32
 dz 10,"In einem DOS-Fenster dieser Windows-Version ist DOSLFN sinnlos!";33
 dz    "Heap: gesamt=%u, used=%u, frei=%u, grî·ter Block=%u Bytes",10   ;34
 dz    "Letzter Fehler: %u - "                                  ;35  =   0
 dz			"Verbotener Schreibzugriff"			;1
 dz			"Konnte Verzeichnis nicht expandieren"		;2
 dz			"Konnte Joliet-Link-Tabelle nicht finden"	;3
 dz			"Nicht genug Speicher - bitte vergrî·ern"	;4
 dz			"Konnte Unicode-Datei nicht laden"              ;5
if USEWINTIME
 dz    "Zeitzone ist"                                           ;41
 dz    "%37s UTC%+d",10                                         ;42
endif
ifdef PROFILE
 dz    "Profile.",10                                            ;ProfileNr
 dz    "Profile reset.",10                                      ;+1
 dz    "%7lu %2d.%03d %s",10                                    ;+2
 dz    "Calibrating profile.",10                                ;+3
 dz    "Profile timing constant = %lu000",10                    ;+4
 dz    "Error running calibration",10                           ;+5
 if USEWINTIME
 ProfileNr = 43
 else
 ProfileNr = 41
 endif
endif

texte_englisch:
 dz	10							;0
 dz    "high "							;1
 dz    "loaded consuming %u bytes."				;2
 dz 10,"Cannot find/open Unicode table file %s!"		;3
 dz 10,"Wrong content of file %s or cannot read!"		;4
 dz    "disabled."						;5
 dz 10,"(Another TSR grabbed Int21 and/or Int2F)"		;6
 dz    "Not yet installed!"					;7
 dz    "Requires at least a 386 processor!"			;8
 dz    "switch(es) taken"					;9
 db    "	(386+)	++ FREEWARE ++",10			;10
  db   "Program that supports long filenames in pure DOS.",10
  db   "USE THIS PROGRAM AT YOUR OWN RISK, DATA LOSS MAY BE POSSIBLE",10
  db   "Actions:	- (nothing)	load and/or enable TSR",10
  db   "		- h or ?	this help",10
  db   "		- d		disable DOSLFN",10
  db   "		- s		show status and settings",10
ifdef PROFILE
  db   "                - p             show profile data",10
  db   "                - pr            reset profile data",10
  db   "                - pc            calibrate profile timing",10
endif
  db   "		- u		unload TSR",10
  db   "Switches:	- w{+|-}	* write access",10
  db   "		- ~{+|-}	* NameNumericTail - tilde usage (I hate snakes)",10
  db   "		- t{+|-}	* PreserveLongNames - tunnel effect",10
  db   "		- c{+|-}	* CDROM support",10
  db   "		- i{+|-}	* reenter lock via InDOS flag + RESET DRIVE",10
  db   "                - r{+|-}        * read-only bit for CDROM files",10
if USEWINTIME
  db   "                - o[N]          * set time zone N or read TZ if absent",10
endif
  db   "		- z[:|=]table	load Unicode table (format Volkov .TBL)",10
  db   "		- m[:|=]bytes	declare size of internal heap, 600..50000",10
  db   "		- ms[:|=]bytes	declare size of short path, 16..141",10
  db   "		- ml[:|=]bytes	declare size of long path, 16..1024",10
  db   "		- mn[:|=]bytes	declare size of long name, 13..512",10
  db   "		- p[:|=]path	declare working directory for .TBL/.JLT/.386",10
  db   "		- l{d|e}	set language (german|english)",10
  db   "Environment: 	TZ=xxxNyyy	time zone N for time conversion, no DST usage",10
  db   "Email:    %s",10
  db   "          %s",10
  db   "Download: %s",10
  dz   "          %s"

 dz    "active"							;11
 dz    "enabled."						;12
 dz    "removed from memory."					;13
 dz    "%7lu read accesses"                                     ;14
 dz    "%7lu write accesses"                                    ;15
 dz    "%7lu Int21/AH=71 calls"                                 ;16
 dz    "write access"						;17
 dz    "tilde usage"						;18
 dz    "tunnel effect"						;19
 dz    "CDROM support"						;20
 dz    "InDOS flag and RESET drive usage"			;21
 dz    "Read-Only bit set on CD files"				;22
 dz    "invalid heap size"					;23
 dz    "ON"							;24
 dz    "OFF"							;25
 dz    "%35s %s",10						;26
 dz    "directory doesn't exist!"				;27
 dz    "cannot set workdir"					;28
 dz    "cannot resize heap"					;29
 dz    "switch rejected"					;30
 dz			 " - unload TSR first"			;31
 dz    "requires at least DOS version 4!"			;32
 dz 10,"This program is useless in a DOS box of this Windows version!";33
 dz    "Heap: size=%u, used=%u, free=%u, max-avail=%u Bytes",10 ;34
 dz    "Last error: %u - "                                      ;35  =   0
 dz			"user had denied write access"			;1
 dz			"couldn't expand FAT directory"			;2
 dz			"couldn't find a Joliet Link Table"		;3
 dz			"not enough memory - increase heap"		;4
 dz			"couldn't auto-load Unicode table"              ;5
if USEWINTIME
 dz    "Timezone is"                                            ;41
 dz    "%35s UTC%+d",10                                         ;42
endif
ifdef PROFILE
 dz    "Profile.",10                                            ;ProfileNr
 dz    "Profile reset.",10                                      ;+1
 dz    "%7lu %2d.%03d %s",10                                    ;+2
 dz    "Calibrating profile.",10                                ;+3
 dz    "Profile timing constant = %lu000",10                    ;+4
 dz    "Error running calibration",10                           ;+5
endif

Texte_franzoesisch:
;	include	"francais.inc"

Texte_japanisch:
;	include	"nihongo.inc"


StdDTA		TSearchRec <>		;im transienten Teil
fname_buffer	db	80 dup (?)	;fÅr Heapgrî·enbestimmung
truename_buf	db	64 dup (?)	;fÅr WorkDir

	endc
;**************************************************************************

