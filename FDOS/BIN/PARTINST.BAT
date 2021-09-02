@echo off

echo.
echo Partition Manager Install
echo.
echo This script is going to do the following steps:
echo.
echo.    1. Make a bootable system floppy.
echo.    2. Copy Partition Manager to floppy.
echo.    3. Save your MBR to the file on floppy.
echo.    4. Save information about your partitions.
echo.
echo You can stop the script at any moment by pressing Ctrl-C
echo.

if not exist part.exe goto error_missing_files
if not exist part.htm goto error_missing_files

if "%1" == "/nf" goto step2

echo Step 1: Formatting floppy
format a: /u /s /V:PART_MANAGER
if errorlevel == 1 goto error_formatting_floppy

:step2

echo Step 2: Copying Partition Manager to the floppy...

copy part.exe a:\  > nul
copy part.htm a:\  > nul

echo @echo off > a:\autoexec.bat
echo echo Type PART to run Partition Manager >> a:\autoexec.bat

echo Step 3: Saving your current MBR...

part -q -d 1 -s a:\orig_mbr.hd1 > nul
part -q -d 2 -s a:\orig_mbr.hd2 > nul
part -q -d 3 -s a:\orig_mbr.hd3 > nul
part -q -d 4 -s a:\orig_mbr.hd4 > nul

echo Step 4: Saving information about partitions...

part -i     > a:\part_ide.

if exist a:\orig_mbr.hd1  part -d 1 -p     > a:\part_p.hd1
if exist a:\orig_mbr.hd1  part -d 1 -p -r  > a:\part_p_r.hd1

if exist a:\orig_mbr.hd2  part -d 2 -p     > a:\part_p.hd2
if exist a:\orig_mbr.hd2  part -d 2 -p -r  > a:\part_p_r.hd2

if exist a:\orig_mbr.hd3  part -d 3 -p     > a:\part_p.hd3
if exist a:\orig_mbr.hd3  part -d 3 -p -r  > a:\part_p_r.hd3

if exist a:\orig_mbr.hd4  part -d 4 -p     > a:\part_p.hd4
if exist a:\orig_mbr.hd4  part -d 4 -p -r  > a:\part_p_r.hd4

echo Installation completed.
echo.
echo Please, read Partition Manager Help and FAQ before
echo making any changes on your hard disk.
echo Backing up your critical files is also a good idea.   
goto end

:error_missing_files
echo Error: One or more files is missing!
pause
goto end

:error_formatting_floppy
echo Error: There was an error formatting floppy disk!
pause
goto end

:end
