@ECHO OFF

::DOS Variables
SET PATH=%dosdir%\BIN;c:\utils;c:\tools\lbx;c:\tools;c:\tools\wbat;c:\mymenu;c:\tdraw;c:\tools\pictview;c:\TP7\BIN
SET DOSDIR=C:\FDOS
SET SOUND=C:\SOUND
SET BLASTER=A220 I5 D1 T4
REM SET DIRCMD=/P /OGN /Y
SET COPYCMD=/-Y
SET DOS32A=C:\FDOS\BIN /QUIET /EXTMEM:12288 /NOC


::CD SUPPORT
C:\FDOS\BIN\SHSUCDX /D:FDCD001 /L:D /V

:HARDWARE
LOADHIGH CTMOUSE /O

:UNIVBE
REM C:\UNIVBE51\UNIVBE.EXE

:END
@ECHO OFF
SET AUTOFILE=%0
SET CFGFILE=C:\FDCONFIG.SYS

::Alias remaps
alias reboot=fdapm warmboot
alias reset=fdisk /reboot
alias halt=fdapm poweroff
alias shutdown=fdapm poweroff
alias cfg=edit %cfgfile%
alias auto=edit %0


:: Eating XMS down to 10MB to fix core issue
REM cd tools
REM eatxms 50000000

::MyMenu
cd games

C:\UTILS\BLACKOUT\BLACKOUT.EXE
MODE CO80

mymenu

echo Type "menu" to return to MyMenu 

