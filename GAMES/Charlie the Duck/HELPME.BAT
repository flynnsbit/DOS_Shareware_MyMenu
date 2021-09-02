@echo off
choice /C:. /T:.,1 /N "Checking system..."
if errorlevel 1 goto Start
echo.
echo Error: CHOICE.COM not found on your system, cannot run HELPME.BAT
echo.
pause
goto TheEnd

:Start
cls
echo.
echo CHARLIE THE DUCK HELP MENU
echo.
echo    1  Documentation
echo    2  License
echo    3  Run CHARLIE THE DUCK
echo    4  How can I beat the big fish?
echo    5  Problems with sound
echo    6  Register CHARLIE THE DUCK
echo    7  Wiering Software on the Internet
echo    8  Exit
echo.
choice /C:12345678 /N "Your choice [1-8]? "
echo.

if errorlevel 8 goto TheEnd
if errorlevel 7 goto Internet
if errorlevel 6 goto Register
if errorlevel 5 goto Sound
if errorlevel 4 goto FishDemo
if errorlevel 3 goto RunGame
if errorlevel 2 goto License
if errorlevel 1 goto Documentation
goto TheEnd

:Documentation
type readme.txt | more
echo.
pause
goto Start

:License
type license.txt | more
echo.
pause
goto Start

:RunGame
charlie -e
goto Start

:FishDemo
charlie -h
goto Start

:Sound
echo SOUND PROBLEMS
echo.
echo    1  Sound doesn't work with MPU401, try Adlib
echo    2  Sound doesn't work with Adlib, try PC-speaker
echo    3  Back to main menu
echo.
choice /C:123 /N "Your choice [1-3]? "
echo.
if errorlevel 3 goto Start
if errorlevel 2 goto PCSpeaker
if errorlevel 1 goto Adlib
goto Start

:PCSpeaker
charlie -m -s
goto Start

:Adlib
charlie -m
goto Start

:Register
echo REGISTER
echo.
echo    1  Enter registration data
echo    2  Start directly at next world
echo    3  Back to main menu
echo.
choice /C:123 /N "Your choice [1-3]? "
echo.
if errorlevel 3 goto Start
if errorlevel 2 goto NextWorld
if not errorlevel 1 goto Start
charlie -r
goto Start

:NextWorld
if not exist REGISTER.KEY goto NotRegistered
echo    Normally, you cannot start at the 2nd or 3rd world before completing the
echo    first. However, using this option you can create a new CHARLIE.CFG file 
echo    with saved games at world 1, 2 and 3 (open with "Load game"). Note: this
echo    will erase your high scores.
echo.
choice /C:YN /N "Continue [Y/N]? "
echo.
if errorlevel 2 goto Start
if not errorlevel 1 goto Start
charlie -w
goto Start

:NotRegistered
echo    You have to register first!
echo.
pause
goto Start

:NoWin95
echo    This option requires Windows 95 or higher!
echo.
pause
goto Start

:Internet
if X%windir%X == XX goto NoWin95
choice /C:YN /N "This will start your browser. Continue [Y/N]? "
echo.
if errorlevel 2 goto Start
if not errorlevel 1 goto Start
start http://www.wieringsoftware.nl/
goto Start

:TheEnd
