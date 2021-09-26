:menu
@echo off
cls
echo.
echo Press 1 for Charlie the Duck w/ SoundBlaster
echo Press 2 for Charlie the Duck w/ General MIDI
echo Press 3 for Charlie the Duck Demo (Level 1-4)
echo Press 4 to Quit
echo.
jchoice /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto DEMO
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB

:Sb
@charlie -M
goto quit

:MIDI
mt32-pi -g -v
@charlie
goto quit

:DEMO
mt32-pi -g -v
@charlie -H
goto quit

:quit
exit