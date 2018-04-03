@echo off

echo Stopping MySQL if necessary
net stop MySQL56

echo Removeing MySQL56 service if necessary
sc delete MySQL56

echo Stopping MariaDB if necessary
net stop MariaDB10.2

echo Removeing MariaDB service if necessary
sc delete MariaDB10.2

echo Setting up MariaDB...

set MariaDB="C:\Shakecast\mariadb\bin\mysqld"

@echo on
%MariaDB% --install MariaDB10.2 
@echo off

net start MariaDB10.2

pause