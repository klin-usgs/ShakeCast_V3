@echo off

echo Creating ShakeCast database schema...

set MARIADB="c:\shakecast\mariadb\bin\mysql"

%MARIADB% -u root <create_sc_db.sql

echo Done.



