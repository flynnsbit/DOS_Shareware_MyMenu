:menu
@echo off
cls
echo.
echo Press 1 for Fade to Black w/ SoundBlaster
echo Press 2 for Fade to Black w/ MT-32
echo Press 3 for Fade to Black w/ General MIDI
echo Press 4 to Quit
echo.
jchoice /C:1234 /N Please Choose:

if errorlevel = 4 goto quit
if errorlevel = 3 goto MIDI
if errorlevel = 2 goto MT32
if errorlevel = 1 goto SB

:Sb
xcopy /E /Y .\sb\*.* .\
cls
@delphine
goto quit

:MIDI
mt32-pi -g -v
xcopy /E /Y .\gm\*.* .\
cls
@delphine
goto quit

:MT32
mt32-pi -m -v
xcopy /E /Y .\mt32\*.* .\
cls
@delphine
goto quit


:quit
exit