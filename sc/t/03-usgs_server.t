#!perl 



use strict;

use FindBin;

use lib "$FindBin::Bin/../lib";

use Test;

use Data::Dumper;



BEGIN { plan tests => 19 }



use LWP::UserAgent;

use JSON -support_by_pp;



use SC;

use SC::Server;

use SC::Product;



{

    my $server;



    SC->initialize('sc_test.conf');

    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";



    # create given a server ID

    $server = SC::Server->from_id(1302);

    ok defined $server;

    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";

    ok $server->dns_address eq 'earthquake.usgs.gov';

    SC->log(0, "Server tests for ", $server->dns_address);



    my $config = SC->config;

    my $ua = new LWP::UserAgent();

    ok defined $ua;

    $ua->agent('ShakeCast');

    $ua->ssl_opts('verify_hostname' => 0);

    $ua->proxy(['http', 'https'], $config->{'ProxyServer'}) if (defined $config->{'ProxyServer'});

	my $url = "https://" . $server->dns_address . "/earthquakes/feed/v1.0/summary/1.0_day.geojson";

	my $header = $ua->head($url);

    ok defined $header;



	ok $header->{'_rc'} eq '200';

    SC->log(0, 'last modified: ', $header->{'_headers'}->{'last-modified'});

    

	my $resp = $ua->get($url);

    ok defined $resp->is_success;

    #SC->log(0, $resp->content);

    my $json = new JSON;

    ok defined $json;

    # these are some nice json options to relax restrictions a bit:

    my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($resp->content);

    ok defined $json_text;

	ok ref $json_text->{features} eq 'ARRAY';



    my $feature = @{$json_text->{features}}[0];

    ok defined $feature;

    SC->log(0, 'EQ List [0]', Dumper($feature));

    my $prop = $feature->{properties};

    ok defined $prop;

    my $geom = $feature->{geometry};

    ok defined $geom;



    my $evt_url = $prop->{detail};

    ok defined $evt_url;

	$resp = $ua->get($evt_url);

    ok defined $resp->is_success;

    $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($resp->content);

    ok defined $json_text;

	$json_text = $json_text->{properties};

    ok defined $json_text;

    SC->log(0, 'Event feed', Dumper($json_text));



    my $product = $json_text->{products}->{'origin'};

    ok defined $product;

}



# vim:syntax=perl

