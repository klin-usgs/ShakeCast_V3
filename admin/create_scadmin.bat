@echo off
set P="c:\Apache24\bin\htpasswd"
set F="..\sc\userdbs\sc-users"

%P% -c -b %F% scadmin scadmin
