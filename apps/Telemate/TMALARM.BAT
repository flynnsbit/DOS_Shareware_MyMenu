@echo off
rem   TMALARM.BAT %1 %2 %3 %4 %5
rem
rem    %1 = Alarm Type
rem       = 0 if Transfer success
rem       = 1 if Transfer failure
rem       = 2 if Connected to a BBS
rem       = 3 if Script alarm
rem       = 4 if Warning (not enough disk space or out of memory)
rem
rem    %2 = Alarm Sound (no. of seconds the alarm should sound)
rem    %3 = Alarm Time  (no. of seconds the alarm should display)
rem    %4 = BBS # connected to
rem    %5 = Baud rate
rem
rem   Note: External alarm is used only if
rem    1. External Alarm is turned ON
rem    2. Alarm Sound is greater than 0
rem    3. Alarm Time is greater than 0
rem    4. You can in one of the following windows:
rem          Dial, Terminal, Stack Window
rem
rolalarm alarm.rol /S%2 /T%3
