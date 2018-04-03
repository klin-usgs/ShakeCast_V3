@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
"%~dp0perl\bin\perl" -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
"%~dp0perl\bin\perl" -x -S "%0" %*
goto endofperl
@rem ';
#!perl

use FindBin;
use Win32::TieRegistry(Delimiter=>'/');
$| = 1;

my $root_dir = "$FindBin::Bin/";
$root_dir =~ s#/\w+/$##;
my $root_dir_bs = $root_dir;
$root_dir_bs =~ s#/#\\#;

my $applications = {'Apache'	=> 'ServerRoot', 
				'MySQL'	=> 'Location',
				'Perl'	=> 'BinDir', 
				'PHP'	=> 'InstallDir', 
				};

my $app_path = {'Apache'	=> '', 
				'MySQL'	=> '',
				'Perl'	=> '', 
				'PHP'	=> '', 
				};
				
my ($match_app, $match_key);
my @post_configs = (
	'sc/conf/sc.conf', 'sc/conf/httpd-sc.conf', 'sc/docs/admin/admin_process.php', 'sc/docs/sc_config.php',
	'sc/db/sc-data.sql', 'sc/bin/logstats.pl', 'sc/bin/station.pl', 'sc/lib/SC.pm',
	'sc/docs/admin/admin_process.php', 'admin/control_sc_services.pl', 'admin/configure_phpmyadmin.bat', 
	'sc/bin/scfeed_local.pl', 'sc/docs/admin/admin_cmd_utilities.php', 'sc/docs/admin/admin_config.php', 
	'sc/docs/admin/admin_event.php', 'sc/docs/admin/admin_facility.php', 'sc/docs/admin/admin_fetch.php', 
	'sc/docs/admin/admin_profile_facility.php', 'sc/docs/admin/admin_profile_notification.php', 'sc/docs/admin/admin_profile_polygon.php', 
	'sc/docs/admin/admin_server.php', 'sc/docs/admin/admin_service.php', 'sc/docs/admin/admin_test_event.php', 
	'sc/docs/admin/admin_users.php', 'sc/docs/admin/admin_user_facility.php', 'sc/docs/admin/admin_user_notifications.php', 
	'sc/docs/admin/profile_response.php', 'sc/docs/facility.php', 'sc/docs/includes/usercp_register.php', 
	'sc/docs/includes/usercp_sendpasswd.php', 'admin/ShakeCast_2.0.2_update.sql', 
	);

#
#  Check installed applications required by ShakeCast
#
print "Checking installed Applications \n";
print "Found ShakeCast installed at $root_dir\n";
if (check_content('LMachine/Software')) {
	print "Application check failed. \n\n";
} else {
	print "Looks good. \n\n";
}

#
#  Lookup PHP ini files
#
my $php_ini = $app_path->{'PHP'}.'php.ini';
my $apache_ini = $app_path->{'Apache'}.'\conf\httpd.conf';
if (-e $php_ini) {
	print "PHP ini file found $php_ini. \n\n";
} else {
	print "PHP ini file check failed. \n\n";
}

#
#  Update Apache config file
#
if (-e $apache_ini) {
	print "Apache config file found $apache_ini. \n\n";
	open (FH, "< $apache_ini") or die "couldn't update Apache config file $!\n";
	my @lines = <FH>;
	close (FH);
	open (FH, "> $apache_ini") or die "couldn't update Apache config file $!\n";
	print join '', grep {/php/i} @line;
	my $update;
	foreach $line (@lines) {
		if ($line =~ /httpd-sc/i) {
			print FH "Include\t\"".$root_dir.'/sc/conf/httpd-sc.conf"'."\n";
			$update = 1;
		} else {
			print FH $line;
		}
	}
	print FH "Include\t\"".$root_dir.'\sc\conf\httpd-sc.conf"'."\n" unless ($update);

	close (FH);
	print "Apache config file updated. \n\n";
} else {
	print "Apache config file check failed. \n\n";
}

#
#  Update SC config file
#
foreach my $sc_file (@post_configs) {
	my $sc_ini = "$root_dir/$sc_file";
	if (-e $sc_ini) {
		open (FH, "< $sc_ini") or die "couldn't update ShakeCast config file $!\n";
		my @lines = <FH>;
		close (FH);
		open (FH, "> $sc_ini") or die "couldn't update ShakeCast config file $!\n";
		foreach $line (@lines) {
			$line =~ s#c:/shakecast/#$root_dir/#ig;
			$line =~ s#c:\\shakecast\\#$root_dir_bs\\#ig;
			$line =~ s#([\s|'|"])/shakecast/sc/#$1$root_dir/sc/#ig;
			print FH $line;
		}

		close (FH);
		print "ShakeCast file $sc_ini updated. \n";
	} else {
		print "Could not find ShakeCast file $sc_ini. \n\n";
	}
}


exit 0;



sub display_reg
{
	my $hash_ref = shift;

	if (ref($hash_ref) eq "Win32::TieRegistry") {
		foreach my $hash_key (keys %$hash_ref) {
			if ($hash_key =~ m#/$#) {
				#print "SubKey $hash_key ",$hash_ref->{hash_key},"\n";
				display_reg($hash_ref->{$hash_key});
			} else {
				if ($hash_key =~ /$match_key/) {
					print "Found ", $app, " installed at ",$hash_ref->{$hash_key},"\n";
					$app_path->{$app} = $hash_ref->{$hash_key};
					$install_count++;
					return $hash_ref->{$hash_key};
				}
			}
		}
	}
}


sub check_content
{
	$install_count = 0;
	my $root = shift;
	my $diskkeys = $Registry->{$root};
	$apps = join '|', keys %$applications;
	foreach $entry ( keys %$diskkeys )
	{
		next unless ($entry =~ /$apps/i);
		foreach $app (keys %$applications) {
			next unless ($entry =~ /$app/i);
			$match_key = $applications->{$app};
			display_reg($diskkeys->{$entry});
			last;
		}
	}
	if ($install_count < scalar (keys %$applications)) {
		return 1;
	} else {
		return 0;
	}

}

:endofperl

