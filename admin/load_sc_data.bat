@echo off

echo Loading ShakeCast Data...

set MARIADB="c:\shakecast\mariadb\bin\mysql"

%MARIADB% -u sc -psc sc <..\sc\db\sc-data.sql

echo Done.
