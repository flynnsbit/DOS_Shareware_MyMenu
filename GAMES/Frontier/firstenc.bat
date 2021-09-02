@echo off
cls
type game\screen.txt
type game\screen2.txt
game\yn.com
if errorlevel 49 goto quit
if errorlevel 21 goto rungame

goto quit

:rungame
cd game
ren firstenc.dat firstenc.exe
firstenc
ren firstenc.exe firstenc.dat
cd ..
goto quit2

:quit
cls

:quit2
