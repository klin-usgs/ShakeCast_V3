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
net stop MariaDB10.2

cd "C:\"

echo remove Apache
rmdir /S /Q "C:\Program Files\Apache24"
rmdir /S /Q "C:\Program Files (x86)\Apache Software Foundation"

echo remove Perl data
rmdir /S /Q "C:\Perl"
rmdir /S /Q "C:\Perl64"

echo removing services
sc delete Apache2.4
sc delete MariaDB10.2
sc delete MySQL56
sc delete sc_dispd
sc delete sc_notify
sc delete sc_notifyqueue
sc delete sc_polld
sc delete sc_rssd
sc delete sc_watcherd

echo uninstalling ShakeCast
wmic product where name="Shakecast" call uninstall /nointeractive

echo Removing ShakeCast files
rmdir /S /Q "C:\Shakecast"

pause


