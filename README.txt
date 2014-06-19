SHAKCAST SERVER INFORMATION -- WINDOWS VERSION
==============================================

# $Id: README.txt 413 2008-03-24 22:11:50Z klin $
Relaese Date:  2007-11-15

If you are performing an initial installation, please see the
file:

  windows_install.txt

or the documentation at:

  http://earthquake.usgs.gov/resources/software/shakecast/downloads/instructions.php


Finalize Installation 
=====================

A few final configuration steps are required.

1. Notification.  The file c:\shakecast\sc\conf\sc.conf contains a "Notfication" section that looks like:

#Notification Configuration
<Notification>
	From                shakemaster@example.com
	EnvelopeFrom        shakemaster@example.com
	SmtpServer          smtp.example.com
	DefaultEmailTemplate        default.txt
	DefaultScriptTemplate       default.pl
	#Username	username
	#Password	password
</Notification>

Modify the "From" (what an email recipient sees), "EnvelopeFrom" (what the SMTP server uses in the protocol) and the "SmtpServer" fields to define how email notifications will be sent.
Uncomment and edit the "Username" and "Password" fields if authentication is required for your SMTP server.


2. RSS Daemon.  The file c:\shakecast\sc\conf\sc.conf contains a "RSS" daemon section that looks like:

# RSS Daemon configuration
<rss>
	AUTOSTART	1
	# the LOG & LOGGING setting only applies to messages logged out of
	# GenericDaemon; other messages from polld itself are controlled by the
	# settings of LogLevel and LogFile in the system-wide configuration above
	LOG		c:/shakecast/sc/logs/sc.log
	LOGGING	1
	MSGLEVEL	2
	POLL	60
	PORT	53458
	PROMPT	rssd>
	SERVICE_NAME rssd
	SERVICE_TITLE ShakeCast RSS Daemon
	SPOLL	10
	REGION SC CI NC NN
	#TIME_WINDOW 30
</rss>

Modify the "REION" (to download ShakeMaps only from selected regions), the "POLL" (polling interval in seconds), and the "TIME_WINDOW" (in days for triggering ShakeCast processing).
Available ShakeMap regions are:

Region_Code		Description
-----------		-----------
SC				Southern California
CI				Southern California
NC				Northern California
NN				Nevada
UT				Utah
PN				Pacific Northwest
HV				Hawaii
AK				Alaska
GLOBAL			Global and US regions not covered by the above networks (NEIC ShakeMap)
ALL				All the above


3. Restart the ShakeCast Services
To restart the actual services that perform the various ShakeCast functions:

  cd c:\shakecast\admin
  stop_sc_services
  start_sc_services


4. Custimize the ShakeCast server for facilities, profiles, users, and notification templates.  Consult ShakeCast documentation and tutorial videos in configuring ShakeCast server.


Uninstalling ShakeCast
======================


You may uninstall the ShakeCast Server Software by

   1. Stop and uninstall the services:

        cd c:\shakecast\admin
        stop_sc_services
        remove_sc_services

   2. Remove ShakeCast:

        c:\shakecast\Uninstall

      or use Ad/Remove Programs in the Control Panel.

   3. If desired, uninstall Perl, PHP, MySQL, and Apache by using Add/Remove Programs in the Control Panel.

