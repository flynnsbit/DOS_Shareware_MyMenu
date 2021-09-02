@echo off
set _DOS4G=%DOS4G%
set _DOS4GVM=%DOS4GVM%
set DOS4G=quiet
set DOS4GVM=
ddsnd
dos4gw.exe dd.exe
ddsnd -r
set DOS4G=%_DOS4G%
set DOS4GVM=%_DOS4GVM%
