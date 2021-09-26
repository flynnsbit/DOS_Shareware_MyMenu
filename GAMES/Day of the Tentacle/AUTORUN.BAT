:menu
@echo off
cls
echo.
echo Press 1 for Day of the Tentacle w/ SoundBlaster
echo Press 2 for Day of the Tentacle w/ General MIDI
echo Press 3 to Quit
echo.
jchoice /C:123 /N Please Choose:

if errorlevel = 3 goto quit
if errorlevel = 2 goto MIDI
if errorlevel = 1 goto SB

:Sb
@dottdemo a
goto quit

:MIDI
mt32-pi -m -v
@dottdemo r
goto quit


:quit
exit