:menu
@echo off
cls
echo.
echo Press 1 for Realms of Chaos w/ SoundBlaster
echo Press 2 for Realms of Chaos w/ General MIDI
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto SC
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
copy .\sb\*.* .\
cls
@rocsw
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@rocsw
goto quit

:quit
exit