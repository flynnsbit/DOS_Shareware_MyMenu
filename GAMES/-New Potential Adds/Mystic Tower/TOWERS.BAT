@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: Mystic Towers Shareware 1.1
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
cd TOWERS
REM DOSBox: loadfix (correct memory usage)
loadfix -25
TOWERS.EXE
cd..
cls
echo Thank you for playing Mystic Towers Shareware!
echo.
echo To play again, type TOWERS and press Enter
echo.
echo Your DOS Games Archive http://www.dosgamesarchive.com/
@echo on