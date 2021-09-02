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
md c:\CANNON
xcopy *.* /s c:\CANNON

echo You may need to run the Setup program.
echo To play, enter the directory c:\CANNON
echo then type CANNON and press ENTER
c:
goto end

:inst2
md d:\CANNON
xcopy *.* /s d:\CANNON
echo You may need to run the Setup program.
echo To play, enter the directory D:\CANNON
echo then type CANNON and press ENTER
d:
goto end

:inst3
md e:\CANNON
xcopy *.* /s e:\CANNON
echo You may need to run the Setup program.
echo To play, enter the directory E:\CANNON
echo then type CANNON and press ENTER
e:
goto end

:inst4
md f:\CANNON
xcopy *.* /s f:\CANNON
echo You may need to run the Setup program.
echo To play, enter the directory F:\CANNON
echo then type CANNON and press ENTER
f:
goto end

:inst5
md g:\CANNON
xcopy *.* /s g:\CANNON
echo You may need to run the Setup program.
echo To play, enter the directory G:\CANNON
echo then type CANNON and press ENTER
g:
goto end

:end
