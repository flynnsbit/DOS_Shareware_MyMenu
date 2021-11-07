@echo off
if "%1" == "" then goto Help
copy %1 ft2_play.me >nul
ft2_play
del ft2_play.me >nul
goto End
:Help
echo.
echo Usage:
echo   FT2_PLAY <FILENAME.EXT>
:End
