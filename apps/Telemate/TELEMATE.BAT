@echo off
rem
rem     If you are using ROLALARM.EXE as your external alarm,
rem     you should run this batch file to run Telemate. It
rem     loads the TSR sound driver SOUND.COM required by
rem     ROLALARM.EXE.
rem
SOUND >nul
TM %1 %2 %3 %4 %5
