@echo off
del adt2play.exe >nul
echo Compiling ADT2PLAY...
tmtpc -$MAP+ -$W- adt2play >!log
