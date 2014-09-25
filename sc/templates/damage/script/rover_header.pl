#!/usr/local/sc/sc.bin/perl

use File::Path;

$event = "%EVENT_ID%-%EVENT_VERSION%";
#$event =~ s/_scte.*$//;

$path = "/home/shake/DATA/ShakeCast_data/$event";
mkpath($path, 1, 0755) unless (-d $path);

open F, ">$path/shakecast.xml" or die "Can't open: $!\n";

print F <<__XML__;
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<shakecast 
	event_id="%EVENT_ID%" 
	process_timestamp="%GENERATION_TIMESTAMP%"
	code_version="1.0" 
	version="%EVENT_VERSION%">
	
	<shakemap 
		shakemap_id="%SHAKEMAP_ID%"
		shakemap_version="%SHAKEMAP_VERSION%"
		shakemap_originator="us" 
		shakemap_event_type="actual"
		map_status="%EVENT_STATUS:|NULL|;N/A%" />
        <exposure type="%FACILITY_TYPE%">	

__XML__
close F;

