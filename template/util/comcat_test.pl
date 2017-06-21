#!/usr/local/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Carp;

use JSON::XS;
use Data::Dumper;
use File::Copy;
use File::Path;

use SC;
use API::APIUtil;

SC->initialize;

print "Content-Type: application/json\n\n";

	my $json =  comcat_list();
	print JSON::XS->new->utf8->encode(API::APIUtil::stringfy($json));
    #};

exit;

    # Authenticated
sub comcat_list {
	use JSON -support_by_pp;
	use LWP::UserAgent;
	my $ua = new LWP::UserAgent();
	$ua->agent('ShakeCast');
	$ua->ssl_opts('verify_hostname' => 0);
	$ua->proxy(['http'], SC->config->{'ProxyServer'})
		if (defined SC->config->{'ProxyServer'});
	my $url = "https://earthquake.usgs.gov/fdsnws/scenario/1/query?format=geojson";

    my @events;
    my $count;
	my $mirror = SC->config->{DataRoot}.'/eq_product/comcat.json';
	#get current rss
	my $resp = $ua->mirror($url, $mirror);
	#SC->error("Fetch JSON feed error from $server") unless ($resp->is_success);
	return 0 unless ($resp->is_success);
	open (FH, "< $mirror") or return 0;
	my @contents = <FH>;
	close (FH);
	my $content = join '', @contents;

	#eval{
		my $json = new JSON;
	
		# these are some nice json options to relax restrictions a bit:
		my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);
	
		exit unless (ref $json_text->{features} eq 'ARRAY');
		foreach my $feature (@{$json_text->{features}}){
			my $prop = $feature->{properties};
			my $geom = $feature->{geometry}->{'coordinates'};

			#my $ts =SC->time_to_ts($prop->{'time'}/1000);
			my $eq_geom = {
				'id' => $feature->{id},  
				'event_id' => $prop->{code},  
				'magnitude' => $prop->{mag}, 
				'shakemap_id' => $prop->{code},  
				'shakemap_version' => 1, 
				'event_location_description' => $prop->{title},
				#'event_timestamp' => $ts,
				'event_region' => $prop->{net},
				'lat'	=>	$geom->[1],
				'lon'	=>	$geom->[0],
			};
			push @events, $eq_geom;
		}
	#};


	return \@events;
}

