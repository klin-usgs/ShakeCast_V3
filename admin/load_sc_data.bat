@echo off

echo Loading ShakeCast Data...

set MYSQL="c:\program files (x86)\mysql\mysql server 5.6\bin\mysql"

%MYSQL% -u sc -psc sc <..\sc\db\sc-data.sql

echo Done.
