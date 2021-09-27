:menu
@echo off
cls
echo.
echo Press 1 for Indiana Jones w/ SoundBlaster
echo Press 2 for Indiana Jones w/ MT32
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:


if errorlevel = 3 goto quit
if errorlevel = 2 goto MT32
if errorlevel = 1 goto SB
if errorlevel = 0 goto quit

:Sb
cls
@playfate s
goto quit

:MT32
mt32-pi -m -v
cls
@playfate r
goto quit

:quit
exit