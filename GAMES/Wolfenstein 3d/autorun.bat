:menu
@echo off
cls
echo.
echo Press 1 for Wolfenstein 3D w/ SoundBlaster
echo Press 2 for Wolfenstein 3D w/ MIDI
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 3 goto quit
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
cls
@wolf3d
goto quit

:MIDI
mt32-pi -g -v
cls
@wolf3dsw
goto quit

:quit
exit