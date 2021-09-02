@echo off
choice /C:. /T:.,1 /N "Systeemanalyse..."
if errorlevel 1 goto Start
echo.
echo Fout: CHOICE.COM niet gevonden op dit systeem.
echo.
pause
goto TheEnd

:Start
cls
echo.
echo HELP-MENU VOOR CHARLIE DE EEND
echo.
echo    1  Documentatie
echo    2  Licentie
echo    3  CHARLIE DE EEND opstarten
echo    4  Hoe versla je de grote vis?
echo    5  Problemen met geluid
echo    6  CHARLIE DE EEND registreren
echo    7  Wiering Software op het Internet
echo    8  Einde
echo.
choice /C:12345678 /N "Keuze [1-8]? "
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
type leesmij.txt | more
echo.
pause
goto Start

:License
type licentie.txt | more
echo.
pause
goto Start

:RunGame
charlie -n
goto Start

:FishDemo
charlie -h
goto Start

:Sound
echo PROBLEMEN MET GELUID
echo.
echo    1  MPU401 geluid werkt niet, probeer Adlib
echo    2  Adlib geluid werkt niet, probeer PC-speaker
echo    3  Terug
echo.
choice /C:123 /N "Keuze [1-3]? "
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
echo CHARLIE DE EEND REGISTREREN
echo.
echo    1  Registratiecode invoeren
echo    2  Direct beginnen bij wereld 1, 2 of 3
echo    3  Terug
echo.
choice /C:123 /N "Keuze [1-3]? "
echo.
if errorlevel 3 goto Start
if errorlevel 2 goto NextWorld
if not errorlevel 1 goto Start
charlie -r
goto Start

:NextWorld
if not exist REGISTER.KEY goto NotRegistered
echo    Gewoonlijk kun je de tweede of derde wereld niet spelen voor je de eerste
echo    uitgespeeld hebt. Met deze optie kun je echter een nieuwe CHARLIE.CFG
echo    bestand aanmaken waarmee je bij SPEL LADEN in het hoofdmenu kunt kiezen
echo    uit WERELD 1, 2 of 3. Let op: alle topscores worden gewist.
echo.
choice /C:JN /N "Doorgaan [J/N]? "
echo.
if errorlevel 2 goto Start
if not errorlevel 1 goto Start
charlie -w
goto Start

:NotRegistered
echo    Dit kan alleen bij de geregistreerde versie!
echo.
pause
goto Start

:NoWin95
echo    Deze optie vereist Windows 95 of hoger!
echo.
pause
goto Start

:Internet
if X%windir%X == XX goto NoWin95
choice /C:JN /N "Je browser wordt opgestart. Doorgaan [J/N]? "
echo.
if errorlevel 2 goto Start
if not errorlevel 1 goto Start
start http://www.wieringsoftware.nl/
goto Start

:TheEnd
