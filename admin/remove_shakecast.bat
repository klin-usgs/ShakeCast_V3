@echo off

echo Removing ShakeCast Applications and Directories...

net stop sc_dispd
net stop sc_notify
net stop sc_notifyqueue
net stop sc_polld
net stop sc_rssd
net stop sc_watcherd

net stop Apache2.4
net stop Mysql56

wmic product where name="ActivePerl 5.16.3 Build 1604 (64-bit)" call uninstall /nointeractive
wmic product where name="MySQL Server 5.6" call uninstall /nointeractive
wmic product where name="MySQL Installer - Community" call uninstall /nointeractive

cd "C:\"

rmdir /S /Q "C:\Program Files\Apache24"
rmdir /S /Q "C:\Program Files (x86)\Apache Software Foundation"
rmdir /S /Q "C:\ProgramData\MYSQL"
rmdir /S /Q "C:\Perl"
rmdir /S /Q "C:\Perl64"

sc delete Apache2.4
sc delete sc_dispd
sc delete sc_notify
sc delete sc_notifyqueue
sc delete sc_polld
sc delete sc_rssd
sc delete sc_watcherd

wmic product where name="Shakecast" call uninstall /nointeractive
rmdir /S /Q "C:\Shakecast"

exit


