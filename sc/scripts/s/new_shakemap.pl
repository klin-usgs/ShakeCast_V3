#!c:/perl/bin/perl.exe
#!/usr/local/sc/sc.bin/perl

# $Id: new_shakemap.pl 64 2007-06-05 14:58:38Z klin $

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


# ShakeCast script to create a new shakemap on the local server.  Body of
# POST request is XML defining the shakemap.

use strict;
use warnings;

use SC;
use SC::ScriptUtil;
use SC::Server;
use SC::Shakemap;
use Dispatch::Client;
use XML::Simple;

use vars qw(%ENV);

my ($status, $message);

eval { ($status, $message) = new_shakemap() };
$status = SC_FAIL, $message = $@ if $@;
SC->log(2, "shakemap processed: $status, $message");
reply($status, $message);

# end of main

# new_shakemap does the top level request processing.  It will either return
# a two-element list of (status, message) or it will die.
sub new_shakemap {
    my ($xml, $sender, $shakemap);
    my $msg = '';	# default success message is an empty string

    # Initialize SC (read config, open log, connect to database)
    SC->initialize('', 'recv') or die $SC::errstr;
    SC->log(2, 'new shakemap');

    # make sure the sender is authorized to give us new shakemaps
    $sender = SC::Server->from_id($ENV{REMOTE_USER}) or die $SC::errstr;

    # make sure the sender is authorized to give us new shakemaps
    $sender->permitted('U') or die "Request is not from an upstream server";

    # Got a valid sender, so update server status
    $sender->update_status(1);

    # Get serialized shakemap (XML)
    $xml = read_xml_input();

    # Deserialize the SC::Shakemap
    $shakemap = SC::Shakemap->from_xml($xml)
	or die "error processing XML for Shakemap";
    
    # store and pass along to downstream servers
    $shakemap->process_new_shakemap or die $SC::errstr;

    return (SC_OK, '');
}


__END__

=head1 NAME

new_shakemap.pl -- script that delivers a new ShakeCast shakemap to a server

=head1 SYNOPSIS

 http://myserver/scripts/new_shakemap.pl [POST]

=head1 DESCRIPTION

This script is invoked by an upstream server to deliver a new ShakeCast
shakemap to a downstream server.  The http request is a POST; the body of the
post consists of an XML fragment describing the shakemap.

If the receiver already knows about the shakemap (it may have already received
the shakemap from another server) the new shakemap message is ignored.  Otherwise,
the new shakemap is recorded in the database.  The shakemap is passed on to any
other ShakeCast servers that are downstream of the receiver.
The list of notification requests is checked to see if any notifications
should be generated and sent.

=head1 SHAKEMAP XML
