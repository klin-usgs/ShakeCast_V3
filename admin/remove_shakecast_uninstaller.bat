@echo off

echo Removing ShakeCast Applications and Directories...

net stop sc_dispd
net stop sc_notify
net stop sc_notifyqueue
net stop sc_polld
net stop sc_rssd
net stop sc_watcherd

net stop Apache2.4
net stop MySQL56

echo Removing Server Services
sc delete Apache2.4
sc delete MySQL56

echo uninstalling Perl
wmic product where name="ActivePerl 5.16.3 Build 1604 (64-bit)" call uninstall /nointeractive

echo uninstalling MySQL
wmic product where name="MySQL Server 5.6" call uninstall /nointeractive
wmic product where name="MySQL Installer - Community" call uninstall /nointeractive

cd "C:\"

echo remove Apache
rmdir /S /Q "C:\Program Files\Apache24"
rmdir /S /Q "C:\Program Files (x86)\Apache Software Foundation"

echo remove MySQL data
::rmdir /S /Q "C:\ProgramData\MYSQL"

echo remove Perl data
rmdir /S /Q "C:\Perl"
rmdir /S /Q "C:\Perl64"

echo Removing ShakeCast Services
sc delete sc_dispd
sc delete sc_notify
sc delete sc_notifyqueue
sc delete sc_polld
sc delete sc_rssd
sc delete sc_watcherd

echo uninstalling ShakeCast

echo Removing ShakeCast files
rmdir /S /Q "C:\Shakecast"

pause


