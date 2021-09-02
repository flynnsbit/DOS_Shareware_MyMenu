@echo off
	echo Installing Apache 95 Demo into C:\APCHDEMO
	echo.
	pause
	mkdir c:\apchdemo
	xcopy *.* c:\apchdemo /s /e
	c:
	cd apchdemo
	echo Type "APACHE" to run Demo.
