@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: Jetpak 1.5
REM Configuration: standard
REM 
REM 
config -set "cpu cycles=auto 3550"
config -set cpu core=simple
cd JETPAK15
loadfix -25
JETPACK.EXE
loadfix -f
cd..
config -set "cpu cycles=auto 7800 max 100%% limit 26800"
config -set cpu core=auto
cls
echo Thank you for playing Jetpack!
echo.
echo To play again, type JETPAK and press Enter
echo.
echo Your DOS Games Archive http://www.dosgamesarchive.com/
@echo on