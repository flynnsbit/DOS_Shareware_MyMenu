@echo off
REM starts ewj2 if ewj1 was completed, otherwise quits.
sysctl SYS 56Mhz
Ewj1.exe
IF ERRORLEVEL 1 GOTO END
Ewj2.exe
sysctl menu
:END
