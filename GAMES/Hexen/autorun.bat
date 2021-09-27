:menu
@echo off
cls
echo.
echo Press 1 for Hexen w/ SoundBlaster
echo Press 2 for Hexen w/ General MIDI
echo Press 3 for Hexen w/ Sound Canvas
echo Press 4 to Quit
echo.
jchoice /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto SC
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
copy .\sb\*.* .\
cls
@hexen
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@hexen
goto quit

:SC
mt32-pi -g -v
copy .\sc\*.* .\
cls
@hexen
goto quit

:quit
exit