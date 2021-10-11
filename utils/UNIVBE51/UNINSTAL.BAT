@echo off
echo This batch file will uninstall UniVBE by restoring your original
echo AUTOEXEC.BAT and Windows configuration files. If you have made major
echo additions to your system since you installed UniVBE, these changes will
echo also be undone.
echo.
echo This batch file will backup your current config files as AUTOEXEC.ORG,
echo WIN.ORG and SYSTEM.ORG in case you wish to reverse this operation.
echo.
echo Press any key to continue with UNINSTALL, or Ctrl-C to exit...
echo.
pause

copy c:\autoexec.bat c:\autoexec.org
copy c:\autoexec.vbe c:\autoexec.bat
copy c:\windows\win.ini c:\windows\win.org
copy c:\windows\win.vbe c:\windows\win.ini
copy c:\windows\system.ini c:\windows\system.org
copy c:\windows\system.vbe c:\windows\system.ini

echo UniVBE uninstalled! Note that the UniVBE program files have not been
echo deleted. You can delete them manually now if you wish (delete all of
echo C:\UNIVBE if you used the default installation).
echo.
echo Please reboot your system for the changes to take effect.

