#!c:/perl/bin/perl.exe
#!/usr/local/sc/sc.bin/perl

# $Id: poll.pl 64 2007-06-05 14:58:38Z klin $

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
# U.S. Geological Survey (USGS) and Gatekeeper Systems have no
# obligations to provide maintenance, support, updates, enhancements or
# modifications. In no event shall USGS or Gatekeeper Systems be liable
# to any party for direct, indirect, special, incidental or consequential
# damages, including lost profits, arising out of the use of this
# software, its documentation, or data obtained though the use of this
# software, even if USGS or Gatekeeper Systems have been advised of the
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
# cbworden@usgs.gov.  
#
#############################################################################


# For each item type the requestor will supply a hwm; all items newer
# than the value specified in the request will be returned in the 
# response.

use strict;
use warnings;

use SC;
use SC::ScriptUtil;
use SC::Server;
use SC::Event;
use SC::Shakemap;
use SC::Product;
use XML::Simple;

use vars qw(%ENV);

my ($status, $message, $rv);

eval { ($status, $message, $rv) = process_query() };
$status = SC_FAIL, $message = $@ if $@;
$message = '' unless defined $message;
if ($status eq SC_OK) {
    SC->log(2, "poll request processed: $status, $message");
} else {
    SC->error($message);
}
reply($status, $message, $rv);

# end of main

# process_query does the top level request processing.  It will either return
# the query result as XML or it will die.
sub process_query {
    my ($xml, $remote, $q);
    my ($event_hwm, $shakemap_hwm, $product_hwm);
    my $msg = '';	# default success message is an empty string
    my $site;

    # Initialize SC (read config, open log, connect to database)
    SC->initialize('', 'query') or die $SC::errstr;
    SC->log(2, "poll from $ENV{REMOTE_USER}");

    $remote = SC::Server->from_id($ENV{REMOTE_USER}) or die $SC::errstr;

    # Got a valid remote server, so update server status
    $remote->update_status(1);

    # make sure the remote is authorized to query us for events
    $remote->permitted('Q') or die "Query is not from an authorized server";

    # Get serialized request (XML)
    $xml = read_xml_input();
    SC->log(2, $xml);

    # Deserialize the query
    $q = SC->xml_in($xml) or die "error processing XML for query";

    # Validate query parameters
    die 'query element not found' unless exists $q->{'query'};
    $q = $q->{'query'};
    die 'required attribute event_hwm not found'
	unless exists $q->{'event_hwm'};
    $event_hwm = $q->{'event_hwm'} || 0;
    die 'required attribute shakemap_hwm not found'
	unless exists $q->{'shakemap_hwm'};
    $shakemap_hwm = $q->{'shakemap_hwm'} || 0;
    die 'required attribute product_hwm not found'
	unless exists $q->{'product_hwm'};
    $product_hwm = $q->{'product_hwm'} || 0;

    # Optional date that suppresses older items
    my $oldest = $q->{'oldest'};

    # retrieve results
    my $ep = SC::Event->newer_than($event_hwm, $oldest);
    die $SC::errstr unless defined $ep;
    my $sp = SC::Shakemap->newer_than($shakemap_hwm, $oldest);
    die $SC::errstr unless defined $sp;
    my $pp = SC::Product->newer_than($product_hwm, $oldest);
    die $SC::errstr unless defined $pp;
    
    # return the true HWMs even if we are not sending back the data (might
    # be older than the threshold).
    my $local = SC::Server->this_server;
    $event_hwm    = $local->event_hwm;
    $shakemap_hwm = $local->shakemap_hwm;
    $product_hwm  = $local->product_hwm;

    # build response XML
    $xml = qq{<query_result event_hwm="$event_hwm" shakemap_hwm="$shakemap_hwm" product_hwm="$product_hwm">\n};
    $xml .= join("\n", (map { $_->to_xml } (@$ep, @$sp, @$pp)));
    $xml .= "\n</query_result>";
    
    SC->log(2, $xml);
    return (SC_OK, '', $xml);

}
    
__END__

=head1 NAME

poll.pl -- script that asks for new event, shakemap, and product metadata

=head1 SYNOPSIS

  http://myserver/scripts/poll.pl [POST]

=head1 DESCRIPTION

This script is used by a remote server to ask for event, shakemap, and product
metadata that has been received since the last request.  The XML document
specifies the high-water mark for each of the three types that the requestor
has already received from the local server.  The local server replies with
all metadata records whose sequence numbers are greater than the high-water
mark and returns the new hwm values.

=cut
