@echo off

echo Loading ShakeCast Data...

set MYSQL="c:\shakecast\mysql\mysql server 5.6\bin\mysql"

%MYSQL% -u sc -psc sc <..\sc\db\sc-data.sql

echo Done.
