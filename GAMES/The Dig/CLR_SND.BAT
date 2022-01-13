@echo off
CLS
ECHO "Clear The Dig Audio Configuration?"
JCHOICE N
if ERRORLEVEL = 2 goto exit
if ERRORLEVEL = 1 goto clear_snd
if ERRORLEVEL = 0 goto exit
:clear_snd
DEL LECDEMOS\DIG\IMUSE.INI 
goto exit;
:exit


