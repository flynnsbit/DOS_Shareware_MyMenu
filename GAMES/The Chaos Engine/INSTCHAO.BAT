@echo off
cls
echo Please press the letter corresponding to
echo your hard drive (C, D, E, F, and G are
echo valid drive choices)
choice /c:cdefg /n
if errorlevel 5 goto inst5
if errorlevel 4 goto inst4
if errorlevel 3 goto inst3
if errorlevel 2 goto inst2
if errorlevel 1 goto inst1

:inst1
md c:\CHAOS
xcopy *.* /s c:\CHAOS
cls
echo .
echo .
echo .
echo .
echo To play, enter the directory c:\CHAOS
echo on your HARD DRIVE and type CEDEMO
echo to start the game.
echo .
echo .
pause
%x%
CD\
goto end

:inst2
md d:\CHAOS
xcopy *.* /s d:\CHAOS
cls
echo .
echo .
echo .
echo To play, enter the directory d:\CHAOS
echo on your HARD DRIVE and type CEDEMO
echo to start the game.
echo .
echo .
pause
%x%
CD\
goto end

:inst3
md e:\CHAOS
xcopy *.* /s e:\CHAOS
cls
echo .
echo .
echo .
echo To play, enter the directory e:\CHAOS
echo on your HARD DRIVE and type CEDEMO
echo to start the game.
echo .
echo .
pause
%x%
CD\
goto end

:inst4
md f:\CHAOS
xcopy *.* /s f:\CHAOS
cls
echo .
echo .
echo .
echo To play, enter the directory f:\CHAOS
echo on your HARD DRIVE and type CEDEMO
echo to start the game.
echo .
echo .
pause
%x%
CD\
goto end

:inst5
md g:\CHAOS
xcopy *.* /s g:\CHAOS
cls
echo .
echo .
echo .
echo To play, enter the directory g:\CHAOS
echo on your HARD DRIVE and type CEDEMO
echo to start the game.
echo .
echo  .
pause
%x%
CD\
goto end

:end
