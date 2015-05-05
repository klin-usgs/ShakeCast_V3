@echo off

echo change files
cd C:\Program Files\Apache24\bin

echo run httpd
httpd.exe -k install -f "c:\Program Files\Apache24\conf\httpd.conf" 

echo start apache
net start Apache2.4 

