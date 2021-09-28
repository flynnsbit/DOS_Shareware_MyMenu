:menu
@echo off
cls
echo.
echo Press 1 for Wacky Wheels w/ SoundBlaster
echo Press 2 for Wacky Wheels w/ General MIDI
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 3 goto quit
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
copy .\sb\*.* .\
cls
@ww
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@ww
goto quit

:SC
mt32-pi -g -v
copy .\sc\*.* .\
cls
@heretic
goto quit

:quit
exit