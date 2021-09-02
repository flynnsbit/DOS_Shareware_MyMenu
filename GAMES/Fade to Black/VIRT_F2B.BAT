@echo off
rem 
rem Delphine Software International, France
rem
rem Run Game with virtual memory on disk (for 4 Mb RAM)
rem
rem Game is slower, if you have enough memory, run go.bat instead.
rem 
set oldgvm=%DOS4GVM%
set old16M=%DOS16M%
set DOS4GVM=swapname#c:\dos4gvm.swp virtualsize#8192
set DOS16M=^0x40
delphine %1 %2 %3 %4 %5 %6 %7 %8
set DOS4GVM=%oldgvm%
set oldgvm=
set DOS16M=%old16M%
set old16M=
