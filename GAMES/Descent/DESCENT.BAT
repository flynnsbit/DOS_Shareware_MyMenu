@echo off
rem Batch file to run shareware version of Descent.
if exist *.swp del *.swp
dcntshr.exe %1 %2 %3 %4 %5 %6 %7 %8 %9
echo.
if exist *.swp del *.swp
