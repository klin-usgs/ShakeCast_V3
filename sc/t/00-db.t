#!perl 

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test;
use Data::Dumper;
use Config::General;
use DBI;
use DBD::mysql;

BEGIN { plan tests => 6 }

#use SC;

{
    my $conf_file = "$FindBin::Bin/../conf/sc_test.conf";
    ok (-e $conf_file);
    my $conf = new Config::General($conf_file);
    ok defined $conf;
    my %chash = $conf->getall;
    ok  %chash;
    my $config = \%chash;
    my $cxp = $config->{DBConnection};
    ok defined $cxp;

	my ($dbh, $dbtype);
	my $tries = $cxp->{RetryCount};
	if (defined $tries) { $tries = 999999 unless $tries }
	my $sleep = $cxp->{'RetryInterval'};
	while ($tries--) {
	    $dbh = DBI->connect($cxp->{'ConnectString'},
				$cxp->{'Username'},
				$cxp->{'Password'},
				{RaiseError=>1, PrintError=>1, AutoCommit=>0});
	    last if $dbh;
	}
	ok defined $dbh;
	if ($dbh) { $dbh->{RaiseError} = 1 }
	else { die $dbh->errstr } 
	$dbtype = $dbh->get_info(17) || $cxp->{'Type'};
	ok $dbtype =~ /mysql/i;

}

# vim:syntax=perl
