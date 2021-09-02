@echo off
Echo Swapping to JEMMEX and rebooting
copy c:\configs\fdconfig.EMX c:\fdconfig.sys
fdapm warmboot

