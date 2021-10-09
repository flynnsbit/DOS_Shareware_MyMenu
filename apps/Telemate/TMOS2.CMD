/* TMOS2.CMD */
/* Create Telemate program object on OS/2 desktop and modify TM.CFG */
/* Marko Kohtala 1993-07-13 */

/* For easiest installation, put this file in the same directory as the 
   Telemate executable and configuration files before you run it.

   To run this file, just type the name of this file to the OS/2 command 
   line or double click on it's icon.
*/


/* Get the operating system and path to this REXX file */
PARSE SOURCE operSystem . sourceFile

IF \(operSystem = "OS/2")
THEN DO
  SAY "This file is for OS/2 only"
  EXIT
END

'@ECHO OFF'

/* Load all RexxUtil functions */
CALL rxfuncadd 'sysloadfuncs', 'rexxutil', 'sysloadfuncs'
CALL sysloadfuncs

CALL SysCls
SAY "*************************************************************************"
SAY "*                                                                       *"
SAY "*                    TELEMATE OS/2 INSTALL PROGRAM                      *"
SAY "*                                                                       *"
SAY "*************************************************************************"
SAY ""

/* Extract the complete path to directory where TMOS2.CMD is */
TMdir = FILESPEC("drive", sourceFile)FILESPEC("path", sourceFile)

/* Check to see if TM.EXE is in the same directory */
CALL SysFileTree TMdir"TM.EXE", 'file', 'F'
IF file.0 = 0
THEN DO
  SAY "Telemate not found in the same directory as",
      FILESPEC("name", sourceFile)
  /* Ask user for right path untill TM.EXE found or user gives no path */
  DO UNTIL \(file.0 = 0)
    SAY ""
    SAY "Enter full path to Telemate files or just press ENTER to exit"
    PULL TMdir
    IF TMdir = ""
    THEN EXIT
    IF (FILESPEC("drive", TMdir) = "") | (FILESPEC("path", TMdir) = "")
    THEN SAY 'You must give full path in format "d:\path\"'
    ELSE DO
      IF \(SUBSTR(TMdir, length(TMdir), 1) = "\" )
      THEN TMdir = TMdir"\"
      CALL SysFileTree TMdir"TM.EXE", 'file', 'F'
      IF file.0 = 0
      THEN SAY "Can not find" TMdir"TM.EXE - please give the right directory"
    END
  END
  SAY ""
END

progtype = ""
DO UNTIL \(progtype = "")
  CALL CHAROUT , "Do you want Telemate to be Windowed or Full Screen (W/F) ? "
  PULL answer
  IF SUBSTR(answer, 1, 1) = "W"
  THEN progtype = WINDOWEDVDM
  IF SUBSTR(answer, 1, 1) = "F"
  THEN progtype = VDM
END

setup = 'PROGTYPE='progtype';EXENAME='TMdir'TM.EXE;STARTUPDIR='TMdir';'
setup = setup'SET DOS_BACKGROUND_EXECUTION=1;SET INT_DURING_IO=1;'
setup = setup'SET COM_RECEIVE_BUFFER_FLUSH=NONE;SET COM_HOLD=1;'
setup = setup'SET IDLE_SECONDS=0;SET VIDEO_WINDOW_REFRESH=2;'
setup = setup'ICONFILE 'TMdir'TMOS2.ICO;'

CALL CHAROUT , "Creating Telemate object... "
result = SysCreateObject('WPProgram', 'Telemate', '<WP_DESKTOP>', setup)

IF result = 0
THEN DO
  SAY ""
  SAY "Can not create! Perhaps there already is a Telemate object."
  CALL CHAROUT , "Want to update the existing object (Y/N) ? "
  PULL answer
  IF \(SUBSTR(answer, 1, 1) = "Y")
  THEN EXIT
  result = SysCreateObject('WPProgram', 'Telemate', '<WP_DESKTOP>', setup, "update")
  IF result = 0
  THEN DO
    SAY "Still can not create!"
    EXIT
  END
END

SAY "Done!"
SAY ""

tmcfg = 0

CALL SysFileTree TMdir"TM.CFG", 'file', 'F'
IF file.0 = 0
THEN DO
  SAY "TM.CFG not found for automatic modification of settings for OS/2."
  SAY ""
END
ELSE DO
  CALL CHAROUT , "Is it OK to modify TM.CFG Telemate configuration file (Y/N) ? "
  PULL answer
  IF SUBSTR(answer, 1, 1) = "Y"
  THEN DO
    /* Modify configuration file */
    cfgfile = TMdir"TM.CFG"
    oldcfgfile = SysTempFileName(TMdir"TM.???")
    'copy' cfgfile oldcfgfile '> NUL'
    CALL ON HALT NAME trapProg
    CALL SysFileDelete cfgfile
    IF \(result = 0)
    THEN DO
      SAY "Can not delete old configuration!"
      EXIT
    END
    DO WHILE LINES(oldcfgfile)
      line = LINEIN(oldcfgfile)
      PARSE VALUE line WITH variable '=' value
      SELECT
        WHEN variable = "MouseType"
          THEN line = variable'=MSMouse'
        WHEN variable = "DirTelemate"
          THEN line = variable'="'TMdir'"'
        OTHERWISE
          NOP
      END
      IF \(LINEOUT(cfgfile, line) = 0)
      THEN DO
        SAY "Error writing configuration file"
        CALL restoreOrig
        EXIT
      END
    END
    CALL LINEOUT cfgfile
    CALL LINEOUT oldcfgfile
    CALL OFF HALT
    SAY cfgfile "modified, original in" oldcfgfile"."
    SAY ""
    tmcfg = 1
  END
END

IF tmcfg = 0
THEN DO
  SAY "You should verify your mouse is set to MicroSoft."
  SAY ""
END

SAY "HINT: If you have trouble downloading in background, change MAXWAIT"
SAY "to 1 in CONFIG.SYS."

EXIT

trapProg:
  /* User pressed Ctrl-C while TM.CFG was not finished:
     Tell user about it, close the files and copy the original back on it.
  */
  SAY "Aborted while TM.CFG not finished!"
restoreOrig:
  SAY "Restoring the original" cfgfile
  CALL LINEOUT cfgfile
  CALL LINEOUT oldcfgfile
  'copy' oldcfgfile cfgfile ' > NUL'
  EXIT
