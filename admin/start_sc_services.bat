@echo off
net start MariaDB10.2
net start apache2.4
rem net start sc_polld
net start sc_dispd
net start sc_notifyqueue
net start sc_notify
rem net start sc_rssd
net start sc_watcherd

pause