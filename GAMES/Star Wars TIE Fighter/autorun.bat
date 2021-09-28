:menu
@echo off
cls
echo.
echo Press 1 for Star Wars TIE Fighter w/ SoundBlaster
echo Press 2 for Star Wars TIE Fighter w/ General MIDI
echo Press 3 for Star Wars TIE Fighter w/ MT-32
echo Press 4 to Quit
echo.
jchoice /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto MT32
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
copy .\sb\*.* .\
cls
@run
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@run
goto quit

:MT32
mt32-pi -m -v
copy .\mt32\*.* .\
cls
@run
goto quit

:quit
exit