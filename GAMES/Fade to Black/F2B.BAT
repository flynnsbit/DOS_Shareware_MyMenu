@echo off
rem 
rem Run Game without virtual memory. It will run faster than with it.
rem
set oldgvm=%DOS4GVM%
set old16m=%DOS16M%
set DOS4GVM=
set DOS16M=
echo Running the game Fade To Black ...
delphine %1 %2 %3 %4 %5 %6 %7 %8
set DOS4GVM=%oldgvm%
set oldgvm=
set DOS16M=%old16m%
set old16m=
