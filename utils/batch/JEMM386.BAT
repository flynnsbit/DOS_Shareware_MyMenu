@echo off
Echo Swapping to JEMM386 and Rebooting
copy c:\configs\fdconfig.386 c:\fdconfig.sys
fdapm warmboot

