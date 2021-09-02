@echo off
@rem  Apache Demo Installation Batch File v. 0.9
@echo Installing Apache Demo...
@apchdemo -d
@if errorlevel 1 goto fail
@Installation succesfull.
@You can now delete the files apchdemo.exe and apchdem1.exe if you wish.
@goto end

:fail
@echo Installation failed!

:end

