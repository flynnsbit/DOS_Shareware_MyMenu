@echo off
rem Batch File for Hooking NEON and TIE Fighter DEMO Together
:top
neon
rem look for 'G' or ESC, anything else to game
if errorlevel 71 goto do_game
if errorlevel 28 goto do_game
if errorlevel 27 goto quit
rem else
:do_game
demo
tiemiss demo >foo
demo final
goto top
:quit
echo 	*** Exiting TIE Fighter Demo ***

