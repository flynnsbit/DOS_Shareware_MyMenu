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
c:
cd\chaos
DEMO
%x%
CD\
goto end

:inst2
D:
cd\chaos
DEMO
%x%
CD\
goto end

:inst3
E:
cd\chaos
DEMO
%x%
CD\
goto end

:inst4
F:
cd\chaos
DEMO
%x%
CD\
goto end

:inst5
G:
cd\chaos
DEMO
%x%
CD\
goto end

:end
