@echo off

echo Creating ShakeCast Tables...

set MYSQL="c:\program files (x86)\mysql\mysql server 5.6\bin\mysql.exe"

%MYSQL% -u sc -psc sc <..\sc\db\sc-create.sql

echo Done.



