@echo off

echo Creating ShakeCast Tables...

set MYSQL="c:\shakecast\mysql\mysql server 5.6\bin\mysql"

%MYSQL% -u sc -psc sc <..\sc\db\sc-create.sql

echo Done.



