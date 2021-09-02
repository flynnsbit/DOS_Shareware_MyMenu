@echo off
if %3 == install goto install
echo If you wish to install IndyCar Racing II into your system,
echo please run the INSTALL.EXE program.
goto exit

rem   usage:  inst  from_drive to_drive install
rem example:  inst  d: c: install

:install

%2
md cars
cd cars
md cars95
cd cars95
copy %1\icr2\cars\cars95\*.*
cd ..
cd ..

md effects
cd effects
copy %1\icr2\effects\*.*
cd ..

md objs
cd objs
copy %1\icr2\objs\*.*
cd ..

md rol
cd rol
copy %1\icr2\rol\*.*
cd ..

md sound
cd sound
copy %1\icr2\sound\*.*
cd ..

md tracks
cd tracks

md laguna
cd laguna
copy %1\icr2\tracks\laguna\*.*
cd ..

md michigan
cd michigan
copy %1\icr2\tracks\michigan\*.*
cd ..

cd ..

copy %1\icr2\uvconfig.exe
copy %1\icr2\hmi*.386
copy %1\icr2\indycar.exe
copy %1\icr2\setup.exe
copy %1\icr2\setup.cfg
copy %1\icr2\modems.cfg
copy %1\icr2\mip.cfg
copy %1\icr2\calendar
copy %1\icr2\readme.txt
copy %1\icr2\main.dat

:exit
