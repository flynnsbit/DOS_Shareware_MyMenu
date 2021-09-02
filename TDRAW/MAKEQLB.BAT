ECHO OFF

IF NOT "%1"=="" GOTO START
ECHO ÿ
ECHO MAKEQLB takes TheDraw QuickBasic object files and incorporates them into a
ECHO QuickBasic Library (for use in the integrated environment), plus a parallel
ECHO link library (.LIB) file.  Non-TheDraw object files and libraries may also
ECHO be included if you desire.
ECHO ÿ
ECHO The following files must be present in the same directory:
ECHO   LINK.EXE, LIB.EXE, BQLB40.LIB or BQLB45.LIB, QB4UTIL.LIB, and
ECHO   the object files you want in the libraries.
ECHO ÿ
ECHO ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÿ
ECHO ÿ
ECHO Usage:    MAKEQLB library [file1] [file2] [file3] etc...
ECHO ÿ
ECHO           Do not put a file extension in the "library" parameter, as
ECHO           the extensions .QLB and .LIB are assumed.
ECHO ÿ
ECHO ÿ
ECHO Example:  MAKEQLB test image1.OBJ image2.OBJ image3.OBJ mycode.LIB
ECHO ÿ
ECHO           Produces TEST.QLB -and- TEST.LIB containing the three object
ECHO           files plus the contents of the library file MYCODE.LIB.
ECHO ÿ
GOTO DONE

:START
IF NOT EXIST LINK.EXE GOTO MISSINGFILE
IF NOT EXIST LIB.EXE GOTO MISSINGFILE
IF NOT EXIST QB4UTIL.LIB GOTO MISSINGFILE
IF EXIST BQLB40.LIB GOTO GOTFILES
IF EXIST BQLB45.LIB GOTO GOTFILES

:MISSINGFILE
ECHO ÿ
ECHO Error!  MAKEQLB needs all of the following files in the current directory:
ECHO   LINK.EXE
ECHO   LIB.EXE
ECHO   BQLB40.LIB (for QuickBasic v4.0) or BQLB45.LIB (for QuickBasic v4.5)
ECHO   QB4UTIL.LIB
ECHO   TheDraw object files (.OBJ) to include in libraries
ECHO ÿ
ECHO Processing halted.
GOTO DONE

:GOTFILES
ECHO ÿ
ECHO Processing TheDraw Quick Library...
SET libname=%1
IF NOT EXIST %libname%.LIB GOTO NEWLIB
ECHO Updating:  %libname%.LIB
GOTO LIBLOOP

:NEWLIB
ECHO Creating:  %libname%.LIB
LIB %libname%.LIB+QB4UTIL.LIB; >ERRLOG
IF ERRORLEVEL==1 GOTO LIBERROR
GOTO LIBLOOP

:LIBOK
SHIFT
:LIBLOOP
IF "%2"=="" GOTO QLBMAKE
IF EXIST %2 GOTO LIBADD
IF EXIST %2.OBJ GOTO LIBADD
IF NOT EXIST %2.LIB GOTO INVALIDPARAM

:LIBADD
ECHO   Adding:  %2
LIB %libname%.LIB -%2; >ERRLOG
LIB %libname%.LIB +%2; >ERRLOG
IF NOT ERRORLEVEL==1 GOTO LIBOK

:LIBERROR
ECHO ÿ
ECHO Fault occured while attempting to add "%2" to library "%libname%.LIB".
TYPE ERRLOG
IF EXIST ERRLOG DEL ERRLOG
ECHO ÿ
ECHO To end processing, press [CTRL-C] or
PAUSE
GOTO LIBOK

:INVALIDPARAM
ECHO ÿ
ECHO Aborting.  Unable to find any object file or library named: %2
GOTO Done

:QLBMAKE
IF EXIST %libname%.QLB ECHO Updating:  %libname%.QLB
IF NOT EXIST %libname%.QLB ECHO Creating:  %libname%.QLB
IF EXIST BQLB40.LIB LINK /Q /NOE /NOD %libname%.LIB, %libname%.QLB,ERRLOG.MAP,BQLB40.LIB; >ERRLOG
IF EXIST BQLB45.LIB LINK /Q /NOE /NOD %libname%.LIB, %libname%.QLB,ERRLOG.MAP,BQLB45.LIB; >ERRLOG
IF NOT ERRORLEVEL==1 GOTO QLBDONE

ECHO ÿ
ECHO Fault occured while creating quick library "%libname%.QLB".
TYPE ERRLOG

:QLBDONE
IF EXIST %libname%.BAK DEL %libname%.BAK
SET LIBNAME=

:DONE
IF EXIST ERRLOG DEL ERRLOG
IF EXIST ERRLOG.MAP DEL ERRLOG.MAP
