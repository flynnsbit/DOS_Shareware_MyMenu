@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: The Dig Demo
REM Configuration: standard
REM 
REM Please refer to the DOSBox manual and Wiki
REM for an explanation of commands
REM 
REM DOSBox: disable joystick (for online play)
config -set "joystick joysticktype=none"
REM DOSBox: configure CPU cycles
config -set "cpu cycles=auto 7800 100%% limit 26800"
REM DOSBox: set correct aspect ratio
config -set "render aspect=true"
REM DOSBox: mount CD-ROM drive
mount -u d >NUL
mount D CD.ROM -t cdrom >NUL
D:
cd DEMOS\THEDIG
REM DOSBox: loadfix (correct memory usage)
loadfix -25
CALL DIG.BAT
C:
cd\
REM DOSBox: unmount CD-ROM drive
mount -u d >NUL
cls
echo Thank you for playing The Dig Demo!
echo.
echo To play again, type THEDIG and press Enter
echo.
echo Your DOS Games Archive http://www.dosgamesarchive.com/
@echo on