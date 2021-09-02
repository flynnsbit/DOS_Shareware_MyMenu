@echo off
stamp %1 %2 %3 %4 %5 %6 %7 %8 %9
if errorlevel 2 echo errorlevel 2!
if errorlevel 1 echo not!
if not errorlevel 1 echo yes!
