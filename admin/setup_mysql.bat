@echo off

echo Stopping MySQL if necessary
net stop MySQL56

echo Removeing MySQL56 service if necessary
sc delete MySQL56

echo Setting up MySQL...

set MYSQLD="C:\Shakecast\MySQL\MySQL Server 5.6\bin\mysqld"

@echo on
%MYSQLD% --install MySQL56 
@echo off

net start MySQL56

pause