@echo off

echo Creating ShakeCast database schema...

set MYSQL="c:\shakecast\mysql\mysql server 5.6\bin\mysql"

%MYSQL% -u root <create_sc_db.sql

echo Done.



