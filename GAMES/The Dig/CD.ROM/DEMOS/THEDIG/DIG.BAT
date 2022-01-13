@echo off
echo LucasArts Presents The Dig Demo
echo This demo will create a file ..\..\LECDEMOS\DIG\IMUSE.INI
echo To change sound card settings, delete this file and start the demo again.
jchoice
if exist ..\..\..\LECDEMOS\DIG skipmkdir
mkdir ..\..\..\LECDEMOS
mkdir ..\..\..\LECDEMOS\DIG
:skipmkdir
if exist ..\..\..\LECDEMOS\DIG\IMUSE.INI goto rundemo
imuse.exe . imuse.exe ..\..\..\lecdemos\dig\imuse.ini
:rundemo
thedig.exe i..\..\..\lecdemos\dig\