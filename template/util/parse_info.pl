#!/usr/local/bin/perl

# $Id: sync_conf.pl 445 2008-08-14 20:41:34Z klin $

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
use warnings;

use Data::Dumper;
use IO::File;
use Config::General;

use Getopt::Long;
use FindBin;
use XML::Simple;
use JSON;
use lib "$FindBin::Bin/../lib";

use SC;
use SC::Server;

use Time::Local;

sub epr;
sub vpr;
sub vvpr;
sub parse_time;
sub parse_size;

my $sth_clear_dispatch;
my $json = new JSON;
my $json_text;
my $JSON;

my $mode;
my $config_file ='sc.conf';
my $config_path = "$FindBin::Bin/../conf/";
my $sc_dir = "$FindBin::Bin/../data/";

my %options;
GetOptions(\%options,
    'list=s',	# export smtp from db to sc.conf
    'from_date=s',	# export smtp from db to sc.conf
    'to_date=s'	# export smtp from db to sc.conf
);

SC->initialize()
    or die "could not initialize SC: $@";

my $config = SC->config;

my ($evid) = @ARGV;

print Dumper(parse_info($evid, $options{'list'}));

exit;



sub vpr {
    if ($options{'verbose'} >= 1) {
        print @_, "\n";
    }
}

sub vvpr {
    if ($options{'verbose'} >= 2) {
        print @_, "\n";
    }
}

sub epr {
    print STDERR @_, "\n";
}

sub usage {
    my $rc = shift;

    print qq{
task_tweak -- Modify task workers in SC database
Usage:
  task_tweak  

};
    exit $rc;
}

sub parse_json {
  	my ($file) = @_;
	open ($JSON, "<", $file);
	my @contents = <$JSON>;
	close($JSON);
	my $content = join '', @contents;
	my $json_hash = $json->allow_nonref->utf8->relaxed->decode($content) if ($content);

	#print "JSON: $file\n";
	#print Dumper($json_hash);
	return $json_hash;
}

sub time_to_ts {
    my $time = (@_ ? shift : time);
    my ($sec, $min, $hr, $mday, $mon, $yr);
    if (SC->config->{board_timezone} > 0) {
		($sec, $min, $hr, $mday, $mon, $yr) = localtime $time;
	} else {
		($sec, $min, $hr, $mday, $mon, $yr) = gmtime $time;
	}
    sprintf ("%04d-%02d-%02d %02d:%02d:%02d",
	     $yr+1900, $mon+1, $mday,
	     $hr, $min, $sec);
}


### SAVE ROOM AT THE TOP ###
sub parse_info {
  my ($evid, $list) = @_;
  my (@rows, $sth, @cell_props);

	use Data::Dumper;
	undef $SC::errstr;
	#eval {
		if ($list eq 'version') {
			push @cell_props, [map { {} } (0 .. 3)];
			$sth = SC->dbh->prepare(qq/
				select su.username, n.queue_timestamp, n.delivery_timestamp, timediff(n.delivery_timestamp, e.event_timestamp) as time_diff, sm.shakemap_version 
					from event e
					inner join shakemap sm on e.event_id = sm.event_id
					inner join grid g on g.shakemap_id = sm.shakemap_id and g.shakemap_version = sm.shakemap_version
					inner join notification n on n.grid_id = g.grid_id 
					inner join shakecast_user su on su.shakecast_user = n.shakecast_user
					where e.event_id = ?
					group by g.grid_id, n.shakecast_user;
					/);
			$sth->execute($evid);

            my %shakemap_version;
			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				my $event_xml = XMLin("$sc_dir/$evid-".$p->{'shakemap_version'}.'/event.xml');
				push @rows, [$p->{'username'}, $p->{'queue_timestamp'}, $p->{'delivery_timestamp'}, 
					$p->{'time_diff'}, $p->{'shakemap_version'}, $event_xml->{'magnitude'}];
				push @cell_props, [];
                $shakemap_version{$evid}->{$p->{'shakemap_version'}}=$p;
                $shakemap_version{$evid}->{$p->{'shakemap_version'}}->{'event'}=$event_xml;
			}
            return \%shakemap_version;
		} elsif ($list eq 'facility') {
			my %facility;
			push @cell_props, [map { {} } (0 .. 4)];
			$sth = SC->dbh->prepare(qq/
				select count(facility_id) as facility_count, facility_type 
					from facility 
					group by facility_type;
					/);
			$sth->execute();

			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				$facility{$p->{'facility_type'}} = $p;
			}

			$sth = SC->dbh->prepare(qq/
				select count(f.facility_id) as facility_count, count(fa.attribute_name) as facility_attribute, f.facility_type from facility f 
					left join facility_attribute fa on fa.facility_id = f.facility_id
					group by f.facility_type;
					/);
			$sth->execute();

			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				$facility{$p->{'facility_type'}}->{'facility_attribute'} = $p->{'facility_attribute'};
			}

			$sth = SC->dbh->prepare(qq/
				select count(f.facility_id) as facility_count, ff.damage_level, count(ff.damage_level) as damage_level_count, f.facility_type from facility f 
					left join facility_fragility ff on ff.facility_id = f.facility_id
					group by f.facility_type, ff.damage_level;
					/);
			$sth->execute();

			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				$facility{$p->{'facility_type'}}->{'damage_level'}->{$p->{'damage_level'}} = $p->{'damage_level_count'};
			}

			$sth = SC->dbh->prepare(qq/
				select count(f.facility_id) as facility_count, ffm.damage_level, count(ffm.component) as fragility_model, f.facility_type from facility f 
					left join facility_fragility_model ffm on ffm.facility_id = f.facility_id
					group by f.facility_type, ffm.damage_level;
					/);
			$sth->execute();

			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				$facility{$p->{'facility_type'}}->{'fragility_model'}->{$p->{'damage_level'}} = $p->{'fragility_model'};
			}

			foreach my $facility_type (keys %facility) {
				push @rows, [$facility_type, $facility{$facility_type}->{'facility_count'}, $facility{$facility_type}->{'facility_attribute'}, 
					$facility{$facility_type}->{'damage_level'}, $facility{$facility_type}->{'fragility_model'}];
				push @cell_props, [];
			}
            return \%facility;
		} elsif ($list eq 'damage') {
			push @cell_props, [map { {} } (0 .. 6)];
			$sth = SC->dbh->prepare(qq/
				select sm.shakemap_version from event e
					inner join shakemap sm on e.event_id = sm.event_id
					inner join grid g on g.shakemap_id = sm.shakemap_id and g.shakemap_version = sm.shakemap_version
					where e.event_id = ?
					order  by g.grid_id;
					/);
			$sth->execute($evid);
            
            my %facility_damage;
			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				my $event_xml = XMLin("$sc_dir/$evid-".$p->{'shakemap_version'}.'/event.xml');
				my $json_hash = parse_json("$sc_dir/$evid-".$p->{'shakemap_version'}.'/fac_damage.json');
				my $damage_summary = $json_hash->{'damage_summary'};
				push @rows, [$p->{'shakemap_version'}, $event_xml->{'magnitude'}, 
					$damage_summary->{'GREEN'}, $damage_summary->{'YELLOW'}, $damage_summary->{'ORANGE'}, $damage_summary->{'RED'}];
				push @cell_props, [{},{},
					{background_color => 'green'},
					{background_color => 'yellow'},
					{background_color => 'orange'},
					{background_color => 'red'},
					 ];
                $facility_damage{$evid}->{$p->{'shakemap_version'}}->{'event'}=$event_xml;
                $facility_damage{$evid}->{$p->{'shakemap_version'}}->{'facility_damage'}=$json_hash->{'damage_summary'};
			}
            return \%facility_damage;
		} elsif ($list eq 'event') {
			push @cell_props, [map { {} } (0 .. 11)];
			my $from_date = $options{'from_date'} ? $options{'from_date'} : time_to_ts(time() - 24 * 7 * 60 * 60);
			my $to_date = $options{'to_date'} ? $options{'to_date'} : time_to_ts(time());

			$sth = SC->dbh->prepare(qq/
				select e.event_id, e.event_timestamp, e.event_location_description, e.lat, e.lon, e.depth, e.magnitude, s.shakemap_id, max(s.shakemap_version) as shakemap_version
					from event e left join shakemap s on e.event_id = s.event_id 
					where e.event_timestamp between date(?) and date(?) 
						and e.event_type='ACTUAL'
					group by e.event_id
					order by e.event_timestamp;
						/);
			$sth->execute($from_date, $to_date);

            my %event_shakemap;
			my $index = 0;
			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
                $event_shakemap{$p->{'event_id'}}->{'event'}=$p;
				my ($json_hash, $damage_summary);
				if ($p->{'shakemap_version'}) {
					$json_hash = parse_json("$sc_dir/".$p->{'shakemap_id'}."-".$p->{'shakemap_version'}.'/fac_damage.json');
					$damage_summary = $json_hash->{'damage_summary'};
                    $event_shakemap{$p->{'event_id'}}->{'damage_summary'}=$damage_summary;
				}
				next unless ($p->{'shakemap_version'} || !$options{'skip'});
				$index++;
				push @rows, [$index, $p->{'event_id'}, $p->{'event_timestamp'}, $p->{'event_location_description'},
					$p->{'lat'}, $p->{'lon'}, $p->{'depth'}, $p->{'magnitude'},
					$damage_summary->{'GREEN'}, $damage_summary->{'YELLOW'}, $damage_summary->{'ORANGE'}, $damage_summary->{'RED'}];
				push @cell_props, [{},{},{},{},{},{},{},{},
					($p->{'shakemap_version'}) ? {background_color => 'green'} : {},
					($p->{'shakemap_version'}) ? {background_color => 'yellow'} : {},
					($p->{'shakemap_version'}) ? {background_color => 'orange'} : {},
					($p->{'shakemap_version'}) ? {background_color => 'red'} : {},
					];
			}
            return \%event_shakemap;
		} elsif ($list eq 'group') {
			push @cell_props, [map { {} } (0 .. 4)];
			$sth = SC->dbh->prepare(qq/
				select distinct su.shakecast_user, su.username, count(fnr.facility_id) as facility_count from notification_request nr inner join facility_notification_request fnr on fnr.notification_request_id = nr.notification_request_id
					inner join shakecast_user su on su.shakecast_user = nr.shakecast_user
					group by nr.notification_request_id;				
				/);
			$sth->execute();

			my %group_facility;
			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				$group_facility{$p->{'shakecast_user'}} = $p;
			}

			$sth = SC->dbh->prepare(qq/
				select s.shakecast_user, s.full_name, s.email_address, s.user_type, g.profile_id from shakecast_user s join geometry_user_profile g on s.shakecast_user = g.shakecast_user
					where s.shakecast_user in (select gup.shakecast_user from geometry_user_profile gup inner join shakecast_user su on gup.profile_id = su.shakecast_user)
					order by g.profile_id;
				/);
			$sth->execute();

			my %group_user;
			while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
				$group_user{$p->{'profile_id'}}->{$p->{'shakecast_user'}} = $p;
			}

			foreach my $group_id (keys %group_facility) {
				foreach my $user (keys %{$group_user{$group_id}}) {
					push @rows, [
						$group_facility{$group_id}->{'username'}, $group_facility{$group_id}->{'facility_count'},
						$group_user{$group_id}->{$user}->{'full_name'}, $group_user{$group_id}->{$user}->{'user_type'}, 
						$group_user{$group_id}->{$user}->{'email_address'},
						];
					push @cell_props, [];
				}
			}
            return (\%group_facility, \%group_user);
		}
	#};

  return (\@rows, \@cell_props);
}


