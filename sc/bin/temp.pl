#!/usr/local/sc/sc.bin/perl


use strict;

use FindBin;
use lib "/usr/local/sc/lib";
use LWP::Simple;
use File::Basename;
use File::Path;
use IO::File;
use Getopt::Long;
use Carp;
use SC;
use SC::Server;
use XML::Simple;
use Data::Dumper;

#######################################################################
# Stuff to handle command line options and program documentation:
#######################################################################

SC->initialize;
my $config = SC->config;
my $USER_AGENT = "ShakeCast/$SC::VERSION";

open (FH, "< get_building_ids.txt") or die "couldn't open file get_building_ids.txt";
my @lines = <FH>;
close (FH);

shift @lines;

#print @lines;
my %buildings;
my ($building_id, $building_name);
foreach my $line (@lines) {
	next unless ($line =~ /<li>/i);
	($building_id, $building_name) = $line =~ /<li>(\d+)\.\s+(.*?)<\/li>/;
	$buildings{$building_id} = $building_name;
}

#foreach $building_id (keys %buildings) {
#	print "$building_id -> $buildings{$building_id}\n";
#}

open (FH, "< get_building.txt") or die "couldn't open file get_building_ids.txt";
my @lines = <FH>;
close (FH);

shift @lines;

my $building = XMLin(join '', @lines);
print Dumper($building->{Identity});
print Dumper($building->{Location});
print Dumper($building->{Design});
my ($building_type, $building_id);
my $year_built = $building->{Design}->{year_built};
my $num_stories = $building->{Design}->{num_stories};
my $latitude = $building->{Location}->{latitude};
my $longitude = $building->{Location}->{longitude};
my $desc = $building->{Location}->{address}.', '.$building->{Location}->{city}
	.', '.$building->{Location}->{state}.' '.$building->{Location}->{zipcode};
foreach my $type (keys %{$building->{Design}->{buildingtype}}) {
	next unless ($building->{Design}->{buildingtype}->{$type} =~ /false/i);
	$building_type = $type;
}

my $building_name = $building_type.'_'.$building_id
	.'_'.$building->{Identity}->{name};
$building_name =~ s/\s+/_/g;
$building_name =~ s/_+/_/g;

print "Building Type: $building_type\n";
print "Year Built: $year_built\n";
print "Num Stories: $num_stories\n";
print "Latitude: $latitude\n";
print "Longitude: $longitude\n";
print "Building Name: $building_name\n";
print "Desc: $desc\n";
&rss_send();

exit 0;

sub rss_send {
    my ($self) = @_;
    my ($status, $message, $rv);

    # avoid sucking all this in for clients that don't need to send messages
    require LWP::UserAgent;
    #require HTTP::Request;
    #require MIME::Base64;

    my $server = 'http://' . SC->config->{'ROVER'}->{'Server'};
    my $screener = SC->config->{'ROVER'}->{'Screener'};
    my $pw = SC->config->{'ROVER'}->{'PW'};
    my $url = "$server/Rover/api/get_building_ids?screener=$screener&pw=$pw";
    print "$url\n";
    #SC->log(3, "server->send($url)");
    my $ua = new LWP::UserAgent();
    $ua->agent($USER_AGENT);
	$ua->proxy(['http'], SC->config->{'ProxyServer'})
		if (defined SC->config->{'ProxyServer'});

    my $resp = $ua->get($url);
    #SC->log(3, "response:", $resp->status_line);
    print "response: ", $resp->status_line,"\n";
    return unless ($resp->is_success);
    my @lines = $resp->content;
    foreach my $line (@lines) {
      next unless ($line =~ /<li>/i);
      ($building_id, $building_name) = $line =~ /<li>(\d+)\.\s+(.*?)<\/li>/;
      $buildings{$building_id} = $building_name;
    }
    
    foreach $building_id (sort keys %buildings) {
      $url = "$server/Rover/api/get_building?screener=admin&pw=rover&id=$building_id&info=identity,location,design";
      $resp = $ua->get($url);
      next unless ($resp->is_success);
      print "$building_id -> $buildings{$building_id}\n";
      print "$url\n";

      my $building = XMLin($resp->content);

      my ($building_type, $building_id);
      my $year_built = (ref $building->{Design}->{year_built} eq 'HASH') ? 
	'N/A' : $building->{Design}->{year_built};
      my $num_stories = (ref $building->{Design}->{num_stories} eq 'HASH') ? 
	 'N/A' : $building->{Design}->{num_stories};
      my $latitude = (ref $building->{Location}->{latitude} eq 'HASH') ? 
	 'N/A' : $building->{Design}->{latitude};
      my $longitude = (ref $building->{Location}->{longitude} eq 'HASH') ? 
	 'N/A' : $building->{Design}->{longitude};
      my $desc = $building->{Location}->{address}.', '.$building->{Location}->{city}
	.', '.$building->{Location}->{state}.' '.$building->{Location}->{zipcode};
      foreach my $type (keys %{$building->{Design}->{buildingtype}}) {
	next unless ($building->{Design}->{buildingtype}->{$type} =~ /false/i);
	$building_type = $type;
      }

      my $building_name = $building_type.'_'.$building_id
	.'_'.$building->{Identity}->{name};
      $building_name =~ s/\s+/_/g;
      $building_name =~ s/_+/_/g;

      print "Building Type: $building_type\n";
      print "Year Built: $year_built\n";
      print "Num Stories: $num_stories\n";
      print "Latitude: $latitude\n";
      print "Longitude: $longitude\n";
      print "Building Name: $building_name\n";
      print "Desc: $desc\n";
      
    }

    return;
}
