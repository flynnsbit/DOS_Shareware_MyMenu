:menu
@echo off
cls
echo.
echo Press 1 for Ultima Underworld w/ SoundBlaster
echo Press 2 for Ultima Underworld w/ MT-32
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 3 goto quit
if errorlevel = 2 goto MT32
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
xcopy /E /Y .\sb\*.* .\
cls
@UWDEMO
goto quit

:MT32
mt32-pi -M -v
xcopy .\MT32\*.* .\
cls
@UWDEMO
goto quit

:quit
exit