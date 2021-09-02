@echo off
REM DOS Games Archive DOSBox launch script
REM 
REM Game: Oxyd Shareware 3.B
REM Configuration: standard
REM 
REM config -set "cpu cycles=auto 7800 100%% limit 26800"
cd OXYD
REM loadfix
REM might require eating memory by 64k
CALL OXYD.BAT
REM loadfix -f
cd..
cls
echo Thank you for playing Oxyd!
echo.
echo To play again, type OXYD and press Enter
echo.
@echo on