#!c:/perl/bin/perl.exe
#!/usr/local/sc/sc.bin/perl

# $Id: product_file.pl 64 2007-06-05 14:58:38Z klin $

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


use strict;
use warnings;

use IO::File;

use SC;

use URI::Escape;
use vars qw(%ENV);
my %param = map { uri_unescape $_ } split /[;&=]/, $ENV{QUERY_STRING};

# Initialize SC (read config, open log, connect to database)
SC->initialize('', 'get') or die $SC::errstr;

# require ID, VER, and NAME query parameters
unless ($param{ID} and $param{VER} and $param{NAME}) {
    # Log the error, then die.  This should not happen unless someone is
    # playing games and trying to run the script by hand.
    SC->error("One or more query parameters is missing");
    die "One or more query parameters is missing";
}

my $fn =  SC->config->{'DataRoot'} . '/' .
	    $param{ID} . '-' . $param{VER} . '/' .
	    $param{NAME};

SC->log(1, "File GET: $fn, exists=", -f $fn);

if (-f $fn) {
    my $size = -s $fn;
    my $buf;
    my $fh = new IO::File($fn, 'r') or die "$!\n";
    binmode $fh;
    binmode STDOUT;

    print <<EOF;
Content-type: application/octet-stream
Content-length: $size

EOF
    while ($fh->read($buf, 8192)) {
	print $buf;
    }
    $fh->close;
} else {
    print <<EOF;
Content-type: application/octet-stream
Content-length: 0

EOF
}

__END__

=head1 NAME

product_file.pl - script to return local product file to remote server

=head1 SYNOPSIS

  http://upstream.shakecast.com/scripts/s/product_file.pl?ID=12345678;VER=1;NAME=GRID

=head1 DESCRIPTION

B<Note:> This script is not intended to be invoked directly.
See L<SC::Server/get_file> for the typical way to get a product file from
a remote server.

This script is invoked to return the contents of a product file to a remote
server.  The remote server will typically be a downstream server that has
just received new metadata for this product, either as a result of a push from
upstream or as a result of a poll by it.

The request is a C<GET>, with three required query parameters:

  ID    Shakemap ID of the product being requested
  VER   Shakemap version of the product being requested
  NAME  Type of product being requested (see product.product_type)

If present, the file contents are returned as an HTTP message with
content-type C<application/octet-stream>.  If the file does not exist
the returned message will have Content-length set to 0, otherwise it will
be set to the size of the file (d'oh!).

=head1 TODO

The protocol does not handle cases where this script fails to
initialize SC, for example if the database is not available.  The script
just dies, which is seen by the remote end as a HTTP transport failure.

=cut
