#!/usr/local/bin/perl

# $Id: worker.pl 64 2007-06-05 14:58:38Z klin $

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

use File::Path qw(make_path remove_tree);
use Getopt::Long;
use IO::File;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Damage;
use API::GoogleMap;

use Data::Dumper;
use Image::Magick;

my ($shakemap_id, $shakemap_version) = @ARGV;
my $sc_id = "$shakemap_id-$shakemap_version";

no strict 'refs';
my $tile_type = 'facility_tile';

SC->initialize() or quit $SC::errstr;

my $icon_dir = SC->config->{'RootDir'}."/images";
my $tile_size = 256;
my $min_zoom = 5;
my $max_zoom = 8;

my $list = marker($sc_id);
my $magick_icons = facility_icon($list);
foreach my $key (keys %$list) {
	my $item = $list->{$key};
	for (my $zoom = $min_zoom; $zoom <= $max_zoom; $zoom++) {
		my $point = API::GoogleMap::toTileCoords($item->{'lat'}, 
			$item->{'lon'}, $zoom);
		facility_tile($point->{'x'}, $point->{'y'}, $zoom, $list);
	}
}

print "process product STATUS=SUCCESS\n";
exit ;

sub marker {
	my ($shakemap) = @_;
	my ($shakemap_id, $shakemap_version) = $shakemap =~ /(.*)-(\d+)$/;
	my @facility;

	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version,
			};

	use Storable;
	my ($damage, %marker);
	$damage = new API::Damage->from_id($options);
	foreach my $fac (@{$damage->{severity_index}}) {
	    $marker{$fac} = {
		'lat' => $damage->{'facility_damage'}->{$fac}->{lat_min},
		'lon' => $damage->{'facility_damage'}->{$fac}->{lon_min},
		'damage_level' => $damage->{'facility_damage'}->{$fac}->{damage_level},
		'facility_type' => $damage->{'facility_damage'}->{$fac}->{facility_type},
		'severity_rank' => $damage->{'facility_damage'}->{$fac}->{severity_rank},
		'facility_name' => $damage->{'facility_damage'}->{$fac}->{facility_name},
	    }
	}

	return \%marker;
}

sub in_bound {
	my ($rect1, $rect2) = @_;
	
	return (
		(($rect1->{'lon_min'} >= $rect2->{'lon_min'} && $rect1->{'lon_min'} <= $rect2->{'lon_max'}) ||
			($rect1->{'lon_max'} >= $rect2->{'lon_min'} && $rect1->{'lon_max'} <= $rect2->{'lon_max'})) 
		&& 
		(($rect1->{'lat_min'} >= $rect2->{'lat_min'} && $rect1->{'lat_min'} <= $rect2->{'lat_max'}) ||
			($rect1->{'lat_max'} >= $rect2->{'lat_min'} && $rect1->{'lat_max'} <= $rect2->{'lat_max'})))
		? 1 : 0 ;
}

sub facility_icon {
    my ($list) = @_;
	
	my $p;
	my (@icons, %gd_icons, %magick_icons);
	
	foreach my $key (keys %$list) {
		my $icon = $list->{$key};
		my $factype = lc($icon->{'facility_type'}.$icon->{'damage_level'});
		my $icon_file = (-e "$icon_dir/$factype.png") ? 
			"$icon_dir/$factype.png" :
			"$icon_dir/city".lc($icon->{'damage_level'})."png";

		my $magick_icon = new Image::Magick;
		$magick_icon->Read('png:'.$icon_file);
		#$magick_icon->Resize(geometry=>'50%');
		$magick_icons{$factype} = $magick_icon;
		$magick_icon->Write(lc($icon->{'facility_type'}.$icon->{'damage_level'}));
	}
	return \%magick_icons;
}

sub facility_tile {
    my ($x, $y, $zoom, $list) = @_;
	
	#my $events = new API::Event->event_list($start);
	
	#my $data_dir = SC->config->{'RootDir'}."/data/$sc_id/tiles/$zoom/$x/";
	my $data_dir = SC->config->{'RootDir'}."/data/$sc_id/tiles/$zoom/$x/";
	make_path($data_dir) unless (-d $data_dir);
	
	my $tile_path = $data_dir."${y}.png";
	#return if (-e $tile_path);

#print "$tile_path\n";
	
	my $magick_im = Image::Magick->new;
	$magick_im->Set(size=>'256x256');
	$magick_im->ReadImage('xc:purple');
	$magick_im->Transparent(color=>'purple');

	my $rect = API::GoogleMap::getTileRect($x, $y, $zoom);
	
	my $tilesAtThisZoom = 1 << $zoom;
	#$x = $x % $tilesAtThisZoom;
	
	my $extend = 360.0 / $tilesAtThisZoom / 256; 
	$extend = 0; 
	my $swlat=$rect->{'y'} - $extend;
	my $swlng=$rect->{'x'} - $extend;
	my $nelat=$swlat+$rect->{'height'} + 2*$extend;
	my $nelng=$swlng+$rect->{'width'} + 2*$extend;
	
	my (%fac_point, $fac_count, $factype, $iconwidth, $iconheight);
	foreach my $key (keys %$list) {
		my $p = $list->{$key};

		if ($fac_count <= 0) {
			$factype = lc($p->{'facility_type'}.$p->{'damage_level'});
			($iconwidth, $iconheight) = $magick_icons->{$factype}->Get('width', 'height');
		}

		my $lon = $p->{'lon'};
		my $lat = $p->{'lat'};
		my $point = API::GoogleMap::getPixelOffsetInTile($lat, $lon, $zoom);

		if (($lon+$extend) > $nelng) {
			$point->{'x'} += 256;
		} elsif (($lon-$extend) <= $swlng) {
			$point->{'x'} -= 256;
		}
		if (($lat+$extend) > $nelat) {
			$point->{'y'} += 256;
		} elsif (($lat-$extend) <= $swlat) {
			$point->{'y'} -= 256;
		}

		if ($fac_count) {
			$fac_point{'x'} = $point->{'x'};
			$fac_point{'y'} = $point->{'y'};
		} else {
			$fac_point{'x'} = $point->{'x'} + 0.5*($fac_point{'x'} - $point->{'x'});
			$fac_point{'y'} = $point->{'y'} + 0.5*($fac_point{'y'} - $point->{'y'});
		}
		$fac_count++;
		
		$magick_im->Composite(image=>$magick_icons->{$factype}, compose=>'Over',
			x=>int($point->{'x'}-$iconwidth/4), y=>$point->{'y'}-$iconheight/4);
	}

	print $magick_im->Write($tile_path);
	return 0;
}

sub usage {
    my $rc = shift;

    print qq{
manage_facility -- Facility Import utility
Usage:
  manage_facility [ mode ] [ option ... ] input-file

Mode is one of:
    --replace  Inserts new facilities and replaces existing ones, along with
               any existing fragilities and attributes
    --insert   Inserts new facilities.  Existing facilities are not
               modified; each one generates an error.
    --delete   Delete facilities. Each non-exist one generates an error.
    --update   Updates existing facilities.  Only those fields present in the
               input file are modified; other fields not mentioned are left
               alone.  An error is generated for each facility that does not
               exist.
    --skip     Inserts facilities not in the database.  Skips existing
               facilities.
  
  The default mode is --replace.

Options:
    --help     Print this message
    --verbose  Print details of program operation
    --limit=N  Quit after N bad input records, or 0 for no limit
    --quote=C  Use C as the quote character in place of double quote (")
    --separator=S
               Use S as the field separator in place of comma (,)
};
    exit $rc;
}

