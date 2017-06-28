#!/usr/local/bin/perl

#
# $Id: heartbeat.pl 475 2008-09-05 17:14:37Z klin $
#
##############################################################################
# 
# Terms and Conditions of Software Use
# ====================================
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Disclaimer of Earthquake Information
# ====================================
# 
# The data and maps provided through this system are preliminary data
# and are subject to revision. They are computer generated and may not
# have received human review or official approval. Inaccuracies in the
# data may be present because of instrument or computer
# malfunctions. Subsequent review may result in significant revisions to
# the data. All efforts have been made to provide accurate information,
# but reliance on, or interpretation of earthquake data from a single
# source is not advised. Data users are cautioned to consider carefully
# the provisional nature of the information before using it for
# decisions that concern personal or public safety or the conduct of
# business that involves substantial monetary or operational
# consequences.
# 
# Disclaimer of Software and its Capabilities
# ===========================================
# 
# This software is provided as an "as is" basis.  Attempts have been
# made to rid the program of software defects and bugs, however the
# U.S. Geological Survey (USGS) have no obligations to provide maintenance, 
# support, updates, enhancements or modifications. In no event shall USGS 
# be liable to any party for direct, indirect, special, incidental or 
# consequential damages, including lost profits, arising out of the use 
# of this software, its documentation, or data obtained though the use 
# of this software, even if USGS or have been advised of the
# possibility of such damage. By downloading, installing or using this
# program, the user acknowledges and understands the purpose and
# limitations of this software.
# 
# Contact Information
# ===================
# 
# Coordination of this effort is under the auspices of the USGS Advanced
# National Seismic System (ANSS) coordinated in Golden, Colorado, which
# functions as the clearing house for development, distribution,
# documentation, and support. For questions, comments, or reports of
# potential bugs regarding this software please contact wald@usgs.gov or
# klin@usgs.gov.  
#
#############################################################################

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;

use Getopt::Long;
use Sys::Hostname;

use Carp;

use SC;
use SC::Server;

SC->initialize() or die "Can't initialize: ", SC->errstr;

my $config = SC->config;

my $perl = $config->{perlbin};
my $base_dir = $config->{DataRoot};
my $root_dir = $config->{RootDir};
my $server = hostname;
my $id = 1000;
my $fname = 'heartbeat.txt';
my $sm_inject = $root_dir.'/bin/sm_inject.pl';
#print Dumper %$config;

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
my $ts = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec);												

my @timedata = gmtime(time);
my $cts = sprintf("%04d-%02d-%02d %02d:%02d:%02d", 
	$timedata[5]+1900, $timedata[4]+1, $timedata[3], 
	$timedata[2], $timedata[1], $timedata[0]);												


print "$cts\n";

#unless (open TMPLT, "| $sm_inject") {
#    SC->log(0, "Can't write heartbeat template <$fname>: $!");
#	exit -1;
#}
#print `perl c:/shakecast/sc/util/fe_1995/feregion.pl -115 33`;

#	print <<__SQL__ 
# <product
#	shakemap_id="heartbeat_${id}"
#	shakemap_version="1"
#	product_type="PAGER_PDF"
#	product_status="RELEASED"
#	generating_server="1"
#	generation_timestamp="${cts}"
#/>
#__SQL__
#;
#close TMPLT;

#exec "$perl $sm_inject $base_dir/$fname";
foreach my $key (keys %$config) {
if (ref $config->{$key} eq "HASH") {
my $service_name = $key;
my $service = $config->{$key};
print "$service_name\n";
foreach my $service_key (keys %$service) {
print "$service_key\n";
print Dumper($service->{$service_key});
my $service_value = (ref $service->{$service_key} eq 'ARRAY') ? join '::', @{$service->{$service_key}} : $service->{$service_key};
         # Delete shakemaps
         SC->dbh->do(qq/
             insert into config (service, config_name, config_value) values
              (?,?,?)/, undef, $service_name, $service_key, $service_value);
}
} else {
print "SYSTEM: $key\n";
print Dumper($config->{$key});
         # Delete shakemaps
         SC->dbh->do(qq/
             insert into config (service, config_name, config_value) values
              (?,?,?)/, undef, "SYSTEM", $key, $config->{$key});

}
}
exit 0;