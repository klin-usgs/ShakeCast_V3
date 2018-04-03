@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
"%~dp0\..\strawberry\perl\bin\perl" -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
"%~dp0\..\strawberry\perl\bin\perl" -x -S "%0" %*
goto endofperl
@rem ';
#!perl

use FindBin;
$| = 1;

my $root_dir = "$FindBin::Bin/";
$root_dir =~ s#/\w+/$##;
my $root_dir_bs = $root_dir;
$root_dir_bs =~ s#/#\\#;

my ($match_app, $match_key);
my @post_configs = (
	'sc/conf/sc.conf', 'sc/conf/httpd-sc.conf', 'sc/conf/https-sc.conf', 
	'sc/db/sc-data.sql', 'sc/bin/logstats.pl', 'sc/lib/SC.pm',
	'sc/bin/scfeed_local.pl',  
	);

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
			$line =~ s#\%APPDIR\%#$root_dir/#ig;
			print FH $line;
		}

		close (FH);
		print "ShakeCast file $sc_ini updated. \n";
	} else {
		print "Could not find ShakeCast file $sc_ini. \n\n";
	}
}


exit 0;

__END__

:endofperl

