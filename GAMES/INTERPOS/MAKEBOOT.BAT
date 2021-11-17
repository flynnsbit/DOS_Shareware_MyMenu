@echo MAKEBOOT - Make a bootable floppy disk for Interpose(TM)
@echo (C)1996 Webfoot Technologies, Inc.  ALL RIGHTS RESERVED.
@echo ÿ
@echo Making bootable floppy now....
@echo ÿ
@echo When asked if you wish to format another, hit 'n'.
@echo ÿ
@format a: /s /v:WEBFOOT
@cd C:\GAMES\INTERPOS
@echo Please wait....
@copy CONFIG.WTI a:config.sys>nul
@copy AUTOEXEC.WTI a:autoexec.bat>nul
@echo ÿ
@echo Finished making your bootable floppy.
@echo ÿ
@echo To run the game, leave this floppy in the drive and re-start your computer.
@echo ÿ
@echo To re-start your computer from DOS, press the Ctrl-Alt-Del keys at the
@echo same time.
@echo ÿ
@echo Or, to re-start your computer from Windows 95, in Windows hit the 'Start'
@echo button and choose 'Shut Down...', then select 'Restart the computer' and
@echo hit the 'Yes' button.
