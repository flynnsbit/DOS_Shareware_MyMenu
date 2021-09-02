@ECHO off

if not exist %DOSDIR%\BIN\VECHO.COM goto SIMPLEMSG
if not exist %NLSPATH%\NUL goto SIMPLEMSG

set LANGFILE=%NLSPATH%\WELCOME.%LANG%
if not exist %LANGFILE% set LANGFILE=%NLSPATH%\WELCOME.EN
if not exist %LANGFILE% goto SIMPLEMSG

vecho /g/p /t %LANGFILE% AUTO_DONE %cfgfile% %autofile%
if not exist %DOSDIR%\BIN\HELP.EXE goto NoHelp
vecho /g/p /t %LANGFILE% AUTO_HELP HELP
:NoHelp
vecho /g/p /t %LANGFILE% AUTO_WELCOME %OS_NAME% %OS_VERSION% "http://www.freedos.org"
vecho /g
goto DONE

:SIMPLEMSG
echo.
echo Done processing startup files %cfgfile% and %autofile%
echo.
if not exist %DOSDIR%\BIN\HELP.EXE goto NoSimpleHelp
echo Type HELP to get support on commands and navigation.
:NoSimpleHelp
echo Welcome to the %OS_NAME% %OS_VERSION% operating system (http://www.freedos.org)
echo.
goto DONE

:DONE
set LANGFILE=
