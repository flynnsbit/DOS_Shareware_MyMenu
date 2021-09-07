:menu
@echo off
cls
echo.
echo Press 1 for Doom w/ SoundBlaster
echo Press 2 for Doom w/ General MIDI
echo Press 3 for Doom w/ Doom Eternal Soundtrack (MP3)
echo Press 4 to Quit
echo.
jchoice /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto MP3
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit


:mp3
copy .\MP3\*.* .\
echo on
mode COM1 BAUDHARD=1152
echo mpg123 --list /media/fat/mp3/doom/doom.pls > COM1
cls
@DOOM
echo q > COM1
echo off
cls
goto quit

:Sb
copy .\sb\*.* .\
cls
@DOOM
goto quit

:MIDI
mt32-pi -g -v
copy .\gm\*.* .\
cls
@DOOM
goto quit

:quit
exit