@echo off
IF NOT "%ultrasnd%"=="" ultramid -f -q
IF NOT "%ultrasnd%"=="" ultramid -q
IF ERRORLEVEL 1 GOTO DONE
setup
IF NOT "%ultrasnd%"=="" ultramid -f -q
:DONE
