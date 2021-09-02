@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: Fire & Ice Shareware
REM Configuration: standard
REM 
REM Please refer to the DOSBox manual and Wiki
REM for an explanation of commands
REM 
REM DOSBox: configure CPU cycles
config -set "cpu cycles=auto 7800 100%% limit 26800"
REM DOSBox: disable aspect ratio correction
config -set "render aspect=false"
cd FIRE&ICE
loadfix
FIRE.EXE /VGA /KEY /BLASTER /SPEED=5 /PORT=220 /DMA=1 /IRQ=7
loadfix -f
cd..
cls
echo Thank you for playing Fire & Ice Shareware!
echo.
echo To play again, type FIREICE and press Enter
echo.
echo Your DOS Games Archive http://www.dosgamesarchive.com/
@echo on