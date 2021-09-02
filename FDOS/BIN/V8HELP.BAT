@echo off

set VDOC=%DOSDIR%\DOC\V8POWER\README.TXT

if not exist %DOSDIR%\BIN\GREP.EXE goto GrepRequired
if not exist %VDOC% goto MissingDoc

if "%1" == "" goto AllHelp
grep -n ^%1 %VDOC%|vstr /b/f : 1|vstr /l 0|set /p VSTART=
grep -A 1000 ^%1 %VDOC%|grep -n ^-- |vstr /b/f : 1|vstr /l 0|set /p VCOUNT=

set /e VSTART=vmath %VSTART% - 1
set /e VCOUNT=vmath %VCOUNT% - 1

type %VDOC% | vstr /l %VSTART%:%VCOUNT%

set VSTART=
set VCOUNT=

goto Done
:AllHelp
vecho /fYellow "V8Power Tools " /fGray /n
vver ver
vecho /fGray /p Commands:
grep -A 2 ^- %DOSDIR%\DOC\V8POWER\README.TXT | grep -v ^- | vstr /b /f " " 1 | sort
goto Done

:GrepRequired
echo Grep is not installed. It is required to use V8HELP.
goto Done

:MissingDoc
echo V8Power Tools Help Documentation was not found.
goto Done

:Done
set VDOC=