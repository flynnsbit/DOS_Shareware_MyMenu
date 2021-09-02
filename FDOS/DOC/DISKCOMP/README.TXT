	Free DiskComp

	Copyright (C) 1999 Michal Meller
	Changes 2003 by Eric Auer, eric -at- coli.uni-sb.de

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License,
	or (at your option) any later version. 

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
	General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the
	Free Software Foundation,
	Inc., 59 Temple Place - Suite 330,
	Boston, MA 02111-1307, USA.

	Contact : maceman@priv4.onet.pl, mellerm@witual.pl

	How does it all works?
	Well it's pretty simple. The program reads side of the disk
	and genetares a checksum of it using the des_encrypt fuction.
	When the checksums are identical that means the disk are identical too

	Changes:
	0.74: heavy code cleanup (by EA). Harddisks no longer accepted.
	0.73: cleaned up drive detection a bit and increased buffer size in
	      DOS mode (not in BIOS mode) from 1 to 32 sectors. Sector size
	      now fixed at 512 bytes. Smaller stack footprint.
	      Changed directory structure again, to match FreeDOSes.
	      *** (by Eric Auer / EA).
	0.72: changed directory structure, added makefile, fixed bug within
	      biosreaddriveinfo, now it compiles with tc 2.01 too; with TINY
	      memory model it's almost 10 kilos lighter than 0.71!
	0.71: added ability to compare hard drive, zips etc.
	0.7 : int13h is back and /1 /8 /40 options too. BIOS is used only when
	      you use one of these options.
	      *** Note EA: BIOS format detection or user-specified geometry
	      *** would be an idea for non-DOS disk formats. /1 /8 /40 less.
	0.65: does not uses int13h anymore; everything is done through int25;
	      temporary (I hope) removed /1 /8 and /40 options. Checged the disk
	      format detection fuction again
	0.6 : uses md5 algorithm
	      *** Note EA: How about RIPEMD / RIPEMD128? Or no checksum, just
	      *** XMS for comparison of all data?
	0.55: not official version: added some fireworks, new disk
	      identification function, which support 160K 180K 320K
	      360K 720K 1,2M and 1,44M diskes (I hope), '/40' option,
	      better error handling, and the GNU public license in
	      the beginning
	0.5 : initial release

	P.S. Sorry for my poor English ...
