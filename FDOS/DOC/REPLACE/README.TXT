FreeDOS REPLACE command
-----------------------
Replaces files in the destination directory with files from the source
directory that have the same name.

REPLACE [drive1:][path1]filename [drive2:][path2] [/switches]

  [drive1:][path1]filename    Specifies the source file or files.
  [drive2:][path2]            Specifies the directory where files are to be
                              replaced.
  /A    Adds new files to destination directory. Cannot use with /S or /U
        switches.
  /H    Adds or replaces hidden and system files as well as unprotected files.
  /N    Preview mode - does not add or replace any file.
  /P    Prompts for confirmation before replacing a file or adding a source
        file.
  /R    Replaces read-only files as well as unprotected files.
  /S    Replaces files in all subdirectories of the destination directory.
        Cannot use with the /A switch.
  /W    Waits for you to insert a disk before beginning.
  /U    Replaces (updates) only files that are older than source files. Cannot
        use with the /A switch.


Exit codes
----------
 0   No error
     REPLACE successfully replaced or added the files.
 1   Function number invalid
     The computer has a version of DOS that is incompatible with
     REPLACE. (Not implemented at the moment!)
 2   File not found
     REPLACE could not find the source files.
 3   Path not found
     REPLACE could not find the source or destination path.
 5   Access denied
     The user does not have access to the source or destination files.
 8   Insufficient memory
     There is insufficient system memory to carry out the command.
     (Not implemented because not possible to handle in a high level
     language like C!)
11   Format invalid
     The user used the wrong syntax on the command line.
29   Write fault
     REPLACE could not write the destination files.
30   Read fault
     REPLACE could not read the source files.
39   Insufficient disk space
     There is insufficient disk space in the destination path.


Compiling the source code
-------------------------
Compiling the source code is possible with the following compilers:
- Borland C++ (tm) 3.0 or higher
- Borland Turbo C++ (tm) 3.0 or higher
- DJGPP 2.02 or higher

To compile with Borland C++ type "make -fmakefile.bc".
To compile with Borland Turbo C++ type "make -fmakefile.tc".


Contacting the author
---------------------
e-mail address: rene.ableidinger@gmx.at


Copyright
---------
(C)opyright 2001 by Rene Ableidinger

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
