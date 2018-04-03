@echo off

echo Creating ShakeCast Tables...

set MARIADB="c:\shakecast\mariadb\bin\mysql"

%MARIADB% -u sc -psc sc <..\sc\db\sc-create.sql

echo Done.



