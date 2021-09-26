:menu
@echo off
cls
echo.
echo Press 1 for Cannon Fodder w/ SoundBlaster
echo Press 2 for Cannon Fodder w/ MIDI
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 3 goto quit
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB

:Sb
copy .\sb\*.* .\
cls
@cannon.com
goto quit

:MIDI
mt32-pi -m -v
copy .\gm\*.* .\
cls
@cannon.com
goto quit

:quit
exit