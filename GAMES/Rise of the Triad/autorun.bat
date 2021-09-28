:menu
@echo off
cls
echo.
echo Press 1 for Rise of the Triad w/ SoundBlaster
echo Press 2 for Rise of the Triad w/ General MIDI
echo Press 3 for Rise of the Triad w/ Sound Canvas
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
@rott
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@rott
goto quit

:SC
mt32-pi -g -v
copy .\sc\*.* .\
cls
@rott
goto quit

:quit
exit