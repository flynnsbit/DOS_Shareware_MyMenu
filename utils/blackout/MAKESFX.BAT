del \blackout.exe
del *.bak
del *.obj
rar a -r -s -mm -m5 -av -sfxc:\rar\idos.sfx -zu6.s -x*.bak -xu6.s -xmakesfx.bat \blackout *.*
rar k -av \blackout.exe
