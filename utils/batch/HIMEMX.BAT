@echo off
Echo Swapping to HIMEMX and XMS only and rebooting
copy c:\configs\fdconfig.XMS c:\fdconfig.sys
fdapm warmboot

