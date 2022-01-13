@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: The Dig Demo
REM Configuration: standard
REM 
REM Please refer to the DOSBox manual and Wiki
REM for an explanation of commands
REM 
cd CD.ROM
cd DEMOS
cd THEDIG
SYSCTL.EXE SYS 90MHZ L2- L1+
CALL DIG.BAT
SYSCTL.EXE MENU
C:
cd\
cls
echo Thank you for playing The Dig Demo!
echo.
echo To play again, type THEDIG and press Enter
echo.
echo Your DOS Games Archive http://www.dosgamesarchive.com/
@echo on