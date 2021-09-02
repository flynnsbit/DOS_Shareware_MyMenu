:menu
@echo off
cls
echo.
echo Press 1 for Blackthorne w/ SoundBlaster
echo Press 2 for Blackthorne w/ General MIDI
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 3 goto quit
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB

:Sb
copy .\sb\*.* .\
cls
@BTHORNE
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@BTHORNE
goto quit

:quit
exit