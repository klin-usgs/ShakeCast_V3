@echo off
set P="c:\program files (x86)\Apache Software Foundation\Apache2.2\bin\htpasswd"
set F="..\sc\userdbs\sc-users"

%P% -c -b %F% scadmin scadmin
