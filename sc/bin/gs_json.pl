#!/ShakeCast/perl/bin/perl

# $Id: gs_json.pl 478 2008-09-24 18:47:04Z klin $

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
use File::Basename;
use File::Path;
use IO::File;
use Getopt::Long;
use Carp;
use SC;
use SC::Server;
use LWP::UserAgent;
use JSON -support_by_pp;
use Time::Local;

use SC::Event;

#######################################################################
# Stuff to handle command line options and program documentation:
#######################################################################

SC->initialize;
my $config = SC->config;
my $perl = $config->{perlbin};
my $mag_cutoff = ($config->{MAG_CUTOFF}) ? $config->{MAG_CUTOFF} : 3.0;
my $json_dir = $config->{DataRoot}.'/eq_product';
mkpath( $json_dir ) if not -d $json_dir;
my $ua = new LWP::UserAgent();
$ua->agent('ShakeCast');
$ua->proxy(['http'], $config->{'ProxyServer'})
	if (defined $config->{'ProxyServer'});


#######################################################################
# Run the program
#######################################################################
my @servers = SC::Server->servers_to_rss;
SC->log(scalar @servers);
SC->log($servers[0]);
my $rc = 0;
if (@servers) {
	foreach my $server (@servers) {
		# http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml
		#my $url = "http://" . $server->dns_address . "/earthquakes/feed/geojson/1.0/week";
		my $url = "http://" . $server->dns_address . "/earthquakes/feed/geojson/1.0/day";
		#my $url = "http://" . $server->dns_address . "/earthquakes/feed/geojson/1.0/hour";
		my $event_list = fetch_json_page($server->dns_address, $url);
		#print ref $event_list;
		next if (ref $event_list ne 'ARRAY');
		foreach my $event (@$event_list) {
			my $evt_url = $event->{url} . '.json';
			fetch_evt_json($server->dns_address, $evt_url, $event);
		}
	}
} elsif ($SC::errstr) {
	SC->error($SC::errstr);
}

exit $rc;

sub fetch_evt_json
{
	my ($server, $json_url, $event) = @_;

	#get current json

	#my $resp = $ua->get($json_url);
	my $evt_mirror = $json_dir.'/'.$event->{net}.$event->{code};
	mkpath( $evt_mirror ) if not -d $evt_mirror;
	$evt_mirror = $evt_mirror.'/event.json';
	#get current json
	my $resp = $ua->mirror($json_url, $evt_mirror);
	return 0 unless ($resp->is_success);
	open (FH, "< $evt_mirror") or return 0;
	my @contents = <FH>;
	close (FH);
	my $content = join '', @contents;
	#my $content = $resp->content;

	eval{
    my $json = new JSON;
 
    # these are some nice json options to relax restrictions a bit:
    my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);
 
	#exit unless (ref $json_text->{features} eq 'ARRAY');
    # iterate over each feature in the JSON structure:
    while (my ($key, $product) = each(%{$json_text->{products}})){
		my ($rv, $parms);
		eval {
			no strict 'refs';
			$key =~ s/-/_/g;
			($rv, $parms) = &{ 'parse_'.$key }($server, $product, $event);
	    };
    }
	&check_duplicated_event($json_text->{'summary'}, $event);
	};
	
  # catch crashes:
  if($@){
	$SC::errstr = $@;
	SC->error($SC::errstr);
	return undef;
  }
  
  return 1;
}

sub check_duplicated_event
{
	my ($summary, $event) = @_;
	my $rv;
	
	my $evids = $summary->{'properties'}->{'eventids'};
	my $auth_id = $event->{'net'}.$event->{'code'};
	$evids =~ s/^,//;
	$evids =~ s/,$//;

	my @evids = split(/,/, $evids);
	return 0 unless (scalar @evids > 1);
	
	my @cancelled_evids;
	my $sth_update_cancel = SC->dbh->prepare(qq{
		UPDATE event 
		SET event_status='CANCELLED', event_version=99
		WHERE event_id = ?});

	foreach my $id (@evids) {
		$sth_update_cancel->execute($id)
			unless ($id eq $auth_id);
		$rv=1;
	}
	
	return $rv;
}

sub parse_shakemap
{
	my ($server, $products, $event) = @_;
	my $mirror_dir = $config->{DataRoot}.'/'.$event->{net}.$event->{code};
	mkpath( $mirror_dir ) if not -d $mirror_dir;
	my $rv;
	
	foreach my $product (@$products) {
		while (my ($mirror, $shakemap) = each( %{$product->{'contents'}})) {
			next unless ($mirror =~ /^download\//i);
			$mirror =~ s/^download\///;
			#my $content_url = "http://" . $server . $shakemap->{'url'};
			my $content_url = $shakemap->{'url'};
			my $resp = $ua->mirror($content_url, $mirror_dir.'/'.$mirror);
			$rv=1 if ($resp->is_success);
		}
		#print ref $product,"\n";
		my $perl = SC->config->{perlbin};
		my $root = SC->config->{RootDir};
		my $cmd = "$perl $root/bin/scfeed_local.pl -event ".$event->{net}.$event->{code};
		my $rv = `$cmd`;
	}
	
	return $rv;
}

sub parse_dyfi
{
	my ($server, $products, $event) = @_;
	my $mirror_dir = $json_dir.'/'.$event->{net}.$event->{code};

	foreach my $product (@$products) {
		while (my ($mirror, $dyfi) = each( %{$product->{'contents'}})) {
			#my $content_url = "http://" . $server . $dyfi->{'url'};
			my $content_url = $dyfi->{'url'};
			my $resp = $ua->mirror($content_url, $mirror_dir.'/'.$mirror);
			return 0 unless ($resp->is_success);
		}
		#print ref $product,"\n";
	}
}

sub parse_losspager
{
	my ($server, $products, $event) = @_;
	my $mirror_dir = $json_dir.'/'.$event->{net}.$event->{code};

	foreach my $product (@$products) {
		while (my ($mirror, $losspager) = each( %{$product->{'contents'}})) {
			#my $content_url = "http://" . $server . $losspager->{'url'};
			my $content_url = $losspager->{'url'};
			my $resp = $ua->mirror($content_url, $mirror_dir.'/'.$mirror);
			return 0 unless ($resp->is_success);
		}
		#print ref $product,"\n";
	}
}

sub parse_eq_location_map
{
	my ($server, $products, $event) = @_;
	my $mirror_dir = $json_dir.'/'.$event->{net}.$event->{code};

	foreach my $product (@$products) {
		while (my ($mirror, $eq_location_map) = each( %{$product->{'contents'}})) {
			#my $content_url = "http://" . $server . $eq_location_map->{'url'};
			my $content_url = $eq_location_map->{'url'};
			my $resp = $ua->mirror($content_url, $mirror_dir.'/'.$mirror);
			return 0 unless ($resp->is_success);
		}
		#print ref $product,"\n";
	}
}

sub parse_geoserve
{
	my ($server, $products, $event) = @_;
	my $mirror = $json_dir.'/'.$event->{net}.$event->{code}.'/geoserve.json';

	foreach my $product (@$products) {
		#my $nearby_url = "http://" . $server . 
		my $nearby_url = $product->{'contents'}->{'geoserve.json'}->{'url'};
		my $resp = $ua->mirror($nearby_url, $mirror);
		return 0 unless ($resp->is_success);
		#print ref $product,"\n";
	}
}

sub parse_historical_moment_tensor_map
{
	my ($server, $products, $event) = @_;
	my $mirror = $json_dir.'/'.$event->{net}.$event->{code}.'/historicMoments.jpg';

	foreach my $product (@$products) {
		#my $nearby_url = "http://" . $server . 
		my $nearby_url = $product->{'contents'}->{'historicMoments.jpg'}->{'url'};
		my $resp = $ua->mirror($nearby_url, $mirror);
		return 0 unless ($resp->is_success);
		#print ref $product,"\n";
	}
}

sub parse_historical_seismicity_map
{
	my ($server, $products, $event) = @_;
	my $mirror_dir = $json_dir.'/'.$event->{net}.$event->{code};

	foreach my $product (@$products) {
		while (my ($mirror, $hist_seism_map) = each( %{$product->{'contents'}})) {
			#my $content_url = "http://" . $server . $hist_seism_map->{'url'};
			my $content_url = $hist_seism_map->{'url'};
			my $resp = $ua->mirror($content_url, $mirror_dir.'/'.$mirror);
			return 0 unless ($resp->is_success);
		}
		#print ref $product,"\n";
	}
}

sub parse_tectonic_summary
{
	my ($server, $products, $event) = @_;
	my $mirror = $json_dir.'/'.$event->{net}.$event->{code}.'/tectonic_summary.html';
	#get current rss

	foreach my $product (@$products) {
		#my $nearby_url = "http://" . $server . 
		my $nearby_url = $product->{'contents'}->{'tectonic-summary.inc.html'}->{'url'};
		my $resp = $ua->mirror($nearby_url, $mirror);
		return 0 unless ($resp->is_success);
		#print ref $product,"\n";
	}
}

sub parse_moment_tensor
{
	my ($server, $products, $event) = @_;
	#get current rss

}

sub parse_cap
{
	my ($server, $products, $event) = @_;
	#get current rss

}

sub parse_scitech_link
{
	my ($server, $products, $event) = @_;
	#get current rss

}

sub parse_nearby_cities
{
	my ($server, $products, $event) = @_;
	my $mirror = $json_dir.'/'.$event->{net}.$event->{code}.'/nearby_cities.json';
	#get current rss

	foreach my $product (@$products) {
		#my $nearby_url = "http://" . $server . 
		my $nearby_url = $product->{'contents'}->{'nearby-cities.json'}->{'url'};
		my $resp = $ua->mirror($nearby_url, $mirror);
		return 0 unless ($resp->is_success);
		#print ref $product,"\n";
	}
}

sub parse_origin
{
	my ($server, $products, $event) = @_;
	my $mirror = $json_dir.'/'.$event->{net}.$event->{code}.'/event.xml';
	my $version;
	my $epicenter;
	my $mrkcenter;
	
	foreach my $product (@$products) {		
		my $ts = ts($product->{eventtime}/1000);	
		$version = $product->{indexid};	
		#$version = ($product->{version} =~ /[a-zA-Z]/) ?
		#			ord($product->{version}) - 55 : $product->{version};
		my $xml_text =<<__SQL1__ 
<event
	event_id="$event->{net}$event->{code}"
	event_version="$version"
	event_status="NORMAL"
	event_type="ACTUAL"
	event_name=""
	event_location_description="$event->{place}"
	event_timestamp="$ts"
	event_region="$event->{net}"
	event_source_type=""
	external_event_id=""
	magnitude="$event->{mag}"
	mag_type="$product->{'properties'}->{'magnitude-type'}"
	lat="$product->{eventlatitude}"
	lon="$product->{eventlongitude}"
	depth="$product->{eventdepth}"
/>
__SQL1__
;
	eval{
	open(FH, "> $mirror");
	print FH $xml_text;
	close(FH);
	};
	my $xml = SC->xml_in($xml_text) or return($SC::errstr);
	return (1) unless (event_filter($xml->{'event'}));
	
    my $event = SC::Event->new(%{ $xml->{'event'} }) or die "error processing XML for Event";
    # store and pass along to downstream servers
    $event->process_new_event or die $SC::errstr;

	eval{
    require Dispatch::Client;

    Dispatch::Client::set_logger($SC::logger);

    Dispatch::Client::dispatch(
	SC->config->{'Dispatcher'}->{'RequestPort'},
	"map_tile", SC::Server->this_server->server_id, $event->{event_id}, 'event_tile');   
	SC->log(0,"Event Tile ".$event->{event_id});
 
	};
	
	$epicenter = $product->{eventlatitude}.",".$product->{eventlongitude};
	$mrkcenter = ($product->{eventlatitude}-6).",".$product->{eventlongitude};
	}
	
	my $gm_epicenter = $json_dir.'/'.$event->{net}.$event->{code}.'/gm_epicenter.png';
	return if (-e $gm_epicenter);
	my $gm_url = "http://maps.google.com/maps/api/staticmap?center=".$epicenter.
			"&zoom=1&size=72x72&maptype=terrain&sensor=false".
			"&markers=icon:http://shakecast.awardspace.com/images/epicenter.png|".$mrkcenter;
	$ua->mirror($gm_url, $gm_epicenter);

}

sub ts
{
	my ($time) = @_;

	my ($sec, $min, $hr, $mday, $mon, $yr) = gmtime $time;
	return sprintf("%04d-%02d-%02d %02d:%02d:%02d", $yr+1900, $mon+1, $mday, $hr, $min, $sec);												
}

sub fetch_json_page
{
	my ($server, $json_url) = @_;

	my $mirror = $json_dir.'/'.$server.'.json';
	#get current rss
	my $resp = $ua->mirror($json_url, $mirror);
	#SC->error("Fetch JSON feed error from $server") unless ($resp->is_success);
	return 0 unless ($resp->is_success);
	open (FH, "< $mirror") or return 0;
	my @contents = <FH>;
	close (FH);
	my $content = join '', @contents;
    my @evt_list;
  eval{
    my $json = new JSON;
 
    # these are some nice json options to relax restrictions a bit:
    my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);
 
	#exit unless (ref $json_text->{features} eq 'ARRAY');
    # iterate over each feature in the JSON structure:
    foreach my $feature (@{$json_text->{features}}){
		my $prop = $feature->{properties};
		next if ($prop->{mag} < $mag_cutoff);
		# print episode information:
		push @evt_list, $prop;
    }
  };
  # catch crashes:
  if($@){
	$SC::errstr = $@;
	SC->error($SC::errstr);
	return undef;
  }
  
  return \@evt_list;
}

# returns a list of all products that should be polled for new events, etc.
sub event_filter {
	my ($xml) = @_;
	my $rc = 0;
	
	return ($rc) if ($xml->{'event_region'} =~ /pt|at|dr/i);
	
	my $time_window = (SC->config->{'rss'}->{'TIME_WINDOW'}) ? 
						SC->config->{'rss'}->{'TIME_WINDOW'} : 30;
	my $eq_time = SC->ts_to_time($xml->{'event_timestamp'});
	my $time_cutoff = $eq_time + $time_window * 86400;

	return ($rc) unless ($time_cutoff > time() );

	use Graphics_2D;
	my $sth_lookup_poly = SC->dbh->prepare(qq{
		select profile_name, geom
		  from geometry_profile});

    my $idp = SC->dbh->selectcol_arrayref($sth_lookup_poly, {Columns=>[1,2]});
	return ($rc) unless (scalar @$idp >= 1);
	while (@$idp) {
		my $profile_name = shift @$idp;
		my $geom = shift @$idp;

		my $polygon = load_geometry($profile_name,$geom);
		#print "$facility::$lon::$lat\n";
		if ($polygon->{POLY}->crossingstest([$xml->{'lon'}, $xml->{'lat'}])) {
			$rc=1;
			last;
		}
	}

	return $rc;
}

sub load_geometry {
  #----------------------------------------------------------------------
  #	@boxes = [ { 'ZONE'    => zone,
  #	             'COORDS' => [ [ lat1, lon1 ], ..., [ latN, lonN ] ],
  #                  'POLY'   => polygon_reference },
  #                  { ... }, ... ];
  #----------------------------------------------------------------------
  my ($zone, $geom)   = @_;
  my ($nc, $poly, $lat, $lon, $north_b, $south_b, $east_b, $west_b);
  my $box    = {};
  my $coords = [];
  my @args = split /,/, $geom;

  $box->{ZONE}    = $zone;
  $box->{COORDS} = $coords;

  return 0 if (($nc = @args) % 2 != 0);
  $nc /= 2;
  return 0 if $nc < 3;
  while (@args) {
    $lat = shift @args;
	$north_b = _max($lat, $north_b);
	$south_b = _min($lat, $south_b);
	
    $lon = shift @args;
	$east_b = _max($lon, $east_b);
	$west_b = _min($lon, $west_b);
    push @$coords, [ $lon, $lat ];
  }
  $box->{POLY} = Polygon->new(@$coords);
  $box->{EAST} = $east_b;
  $box->{WEST} = $west_b;
  $box->{NORTH} = $north_b;
  $box->{SOUTH} = $south_b;

  return $box;
}

sub _min {
    (defined $_[0] && (!defined $_[1] || $_[0] <= $_[1])) ? $_[0] : $_[1];
}

sub _max {
    (defined $_[0] && (!defined $_[1] || $_[0] >= $_[1])) ? $_[0] : $_[1];
}

