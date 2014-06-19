#!/usr/local/sc/sc.bin/perl

use File::Path;

$event = "%EVENT_ID%-%EVENT_VERSION%";
#$event =~ s/_scte.*$//;

$path = "/home/shake/DATA/ShakeCast_data/$event";
mkpath($path, 1, 0755) unless (-d $path);

my $line = "%FACILITY_NAME%";
my ($city, $pop, $unit, $mmi);
if ($line =~ /pop\./) {
    ($city, $pop, $unit) = $line
       =~ /^(.*)\s+\(pop\. [\<\s]*([\d\.]+)([KM])\)/;
} else {
    $city = $line;
}

$pop = ($unit eq 'M') ? $pop * 1000 : $pop;

open F, ">>$path/shakecast.xml" or die "Can't open: $!\n";

print F <<__XML__;
<item name="$city" fragility="%LIMIT_VALUE%" population="$pop" unit="K" latitude="%FACILITY_LAT%" longitude="%FACILITY_LON%">
	<intensity type="%METRIC%" value="%GRID_VALUE%" />
</item>
__XML__

close F;

