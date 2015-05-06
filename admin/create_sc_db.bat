@echo off

echo Creating ShakeCast database schema...

set MYSQL="c:\program files (x86)\mysql\mysql server 5.6\bin\mysql"

%MYSQL% -u root -p%1 <create_sc_db.sql

echo Done.



