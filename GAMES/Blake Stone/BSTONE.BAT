@echo off
bs_aog %1 %2 %3 %4 %5 %6 %7
if not errorlevel == 1 goto exit
jamerr -fbs_aog.err
:exit