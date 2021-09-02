@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: Strife Teaser 1.1
REM Configuration: standard
REM 
REM Please refer to the DOSBox manual and Wiki
REM for an explanation of commands
REM 
REM DOSBox: configure CPU cycles
config -set "cpu cycles=auto 7800 100%% limit 26800"
REM DOSBox: set correct aspect ratio
config -set "render aspect=true"
cd STRIFE
dos32a STRIFE.EXE
cd..
cls
echo Thank you for playing Strife Teaser!
echo.
echo To play again, type STRIFE and press Enter
echo.
echo Your DOS Games Archive http://www.dosgamesarchive.com/
@echo on