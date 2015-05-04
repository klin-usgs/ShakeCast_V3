@echo off
set OPENSSL_CONF=C:\Program Files\Apache24\conf\openssl.cnf
cd "C:\Program Files\Apache24\bin"
openssl genrsa -out server.key 1024
openssl req -config "C:\Program Files\Apache24\conf\openssl.cnf" -new -key server.key -out server.csr
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
