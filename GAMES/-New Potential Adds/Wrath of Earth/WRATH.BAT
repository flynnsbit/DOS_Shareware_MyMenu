@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game title: Wrath of Earth Shareware
REM Configuration: standard
REM 
REM Please refer to the DOSBox manual and Wiki
REM for an explanation of commands
REM 
REM DOSBox: disable joystick (for online play)
config -set "joystick joysticktype=none"
REM DOSBox: configure CPU cycles
config -set "cpu cycles=auto 7800 99%% limit 26800"
REM DOSBox: turn off EMS
config -set "dos ems=false"
REM DOSBox: set correct aspect ratio
config -set "render aspect=true"
cd WRATH
REM DOSBox: loadfix (correct memory usage)
loadfix -25
WOE.EXE
cd..
REM DOSBox: turn EMS back on
REM config -set "dos ems=true"
cls
echo Thank you for playing Wrath of Earth Shareware!
echo.
@echo on