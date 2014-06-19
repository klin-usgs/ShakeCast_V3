#!/usr/local/sc/sc.bin/perl

use File::Path;

$event = "%EVENT_ID%-%EVENT_VERSION%";
#$event =~ s/_scte.*$//;

$path = "/home/shake/DATA/ShakeCast_data/$event";
mkpath($path, 1, 0755) unless (-d $path);

open F, ">>$path/shakecast.xml" or die "Can't open: $!\n";

print F <<__XML__;
    </exposure>
</shakecast>
__XML__

close F;

