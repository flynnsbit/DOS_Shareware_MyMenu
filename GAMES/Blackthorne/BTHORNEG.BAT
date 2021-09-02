@echo off
IF NOT "%ultrasnd%"=="" ultramid -f -q
IF NOT "%ultrasnd%"=="" ultramid -c -q
IF ERRORLEVEL 1 GOTO DONE
bthorne
IF NOT "%ultrasnd%"=="" ultramid -f -q
:DONE
