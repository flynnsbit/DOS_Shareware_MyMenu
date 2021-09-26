:menu
@echo off
cls
echo.
echo Press 1 for Dark Forces w/ SoundBlaster
echo Press 2 for Dark Forces w/ General MIDI
echo Press 3 for Dark Forces w/ MT-32
echo Press 4 to Quit
echo.
jchoice /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto MT32
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB

:Sb
copy .\sb\*.* .\
cls
@DF
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@DF
goto quit

:MT32
mt32-pi -m -v
copy .\mt32\*.* .\
cls
@DF
goto quit

:quit
exit