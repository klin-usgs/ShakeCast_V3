
# $Id: SC.pm 447 2008-08-15 17:42:07Z klin $

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

#
# shc 2003-03-15: add facility as arg to initialize.  Add config method to
#                 to return $config.  Add log_fh2 method.
#
# shc 2003-12-04: determine db type via get_info.
#
# shc 2004-03-07: add setids() to set euid and egid.
#
# shc 2004-03-09: add fixed final defaut for conf file.
#


use strict;

package SC;

use Data::Dumper;
use DBI;
use Config::General;
use Logger;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA       = qw(Exporter);
$VERSION   = '3.14.200';

@EXPORT    = qw(SC_OK SC_FAIL SC_UNKNOWN SC_BAD_XML SC_HTTP_FAIL);
@EXPORT_OK = qw();

my $W32_CONF_FILE = '/shakecast/sc/conf/sc.conf';
my $UNIX_CONF_FILE = '/usr/local/sc/conf/sc.conf';

my $SLEEP = 20;			# default 20 seconds between connection tries

my $TRIES = 10;			# default number of connection attempts

use constant (SC_OK       => 'SUCCESS');
use constant (SC_FAIL     => 'FAILED');
use constant (SC_UNKNOWN  => 'UNKNOWN');
use constant (SC_BAD_XML  => 'BAD_XML');
use constant (SC_HTTP_FAIL=> 'HTTP_FAIL');

use vars qw($config $logger $dbh $errstr $db_now $to_date $dbtype $conf_file);

# XXX shoud there be an option to control whether we connect to the
# database?  It would only be worthwhile if there are SC clients that
# don't need any DB connectivity.
sub initialize {
    my ($class, $cf, $facility) = @_;

    # Determine name and location of config file.  If user specifies a
    # file that exists (either relative or absolute), use that.
    # Otherwise, look for it in ../conf, first using the name the user
    # supplied (if it is relative), then using the default 'sc.conf'.
    # Note that this attempt to find the file won't work in the case
    # of PerlApp unless full paths are given so we depend on the
    # defaults in that case.
    my $parent;
    ($parent = __FILE__) =~ s#[\\/]lib[\\/].*##;
    $conf_file = $cf ? $cf : 'sc.conf';
    $conf_file = "$parent/conf/$conf_file" unless -r $conf_file;
    unless (-r $conf_file) {
	if ($^O eq 'MSWin32') { $conf_file = $W32_CONF_FILE }
	else { $conf_file = $W32_CONF_FILE }
    }

    undef $errstr;
    return if $config;	# prevent multiple initialization
    my $conf = new Config::General($conf_file);
    my %chash = $conf->getall;
    $config = \%chash;
    $logger = new Logger(
        $config->{'LogDir'}.'/'.$config->{'LogFile'}, 
        $config->{'LogLevel'},
        $facility);
    unless ($logger) {
	$errstr = Logger->errmsg;
	return 0;
    }
    return 0 unless SC->connect_db($config->{DBConnection});
    return 1;
}

sub connect_db {
    my ($class, $cxp) = @_;

    return 1 if not defined $cxp;
    eval {
	my $tries = $cxp->{RetryCount};
	if (defined $tries) { $tries = 999999 unless $tries }
	else { $tries = $TRIES }
	my $sleep = $cxp->{'RetryInterval'};
	$sleep = $SLEEP unless $sleep;
	while ($tries--) {
	    $dbh = DBI->connect($cxp->{'ConnectString'},
				$cxp->{'Username'},
				$cxp->{'Password'},
				{RaiseError=>0, PrintError=>0, AutoCommit=>0});
	    last if $dbh;
	    $logger->log(1,
			 "Can't connect to database. Sleeping for $sleep...");
	    sleep $sleep;
	}
	if ($dbh) { $dbh->{RaiseError} = 1 }
	else { die $dbh->errstr } 
	$dbtype = $dbh->get_info(17) || $cxp->{'Type'};
	unless ($dbtype) {
	    warn "Can't determine database type; assuming MySQL.";
	    $dbtype = 'mysql';
	}
	if ($dbtype =~ /oracle/i) {
	    $db_now = 'SYSDATE';
	    $to_date = q/TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS')/;
	    $dbh->do(qq/alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS'/);
	}
	elsif ($dbtype =~ /access/i) {
	    $db_now = 'Now()';
	    $to_date = '?';
	}
	elsif ($dbtype =~ /mysql/i) {
	    $db_now = 'Now()';
	    $to_date = '?';
	}
	else {
	    die "Unknown database type: '$dbtype'";
	}
        $logger->log(2, "connected to", $cxp->{'ConnectString'},
                         'as', $cxp->{'Username'});
    };
    if ($@) {
	$errstr = $@;
	return 0;
    }
    return 1;
}


sub config {
    return $config;
}

sub errstr {
    return $errstr;
}

sub dbh {
    return $dbh;
}

sub new_event {
    my $class = shift;
    my $event = shift;
    #print STDERR $event->to_xml;
    return $event->write_to_db;
}

sub quit {
    my ($class, @msg) = @_;
    $logger->log(0, "QUIT: ", @msg);
    exit 1;
}

sub error {
    my ($class, @msg) = @_;
    $logger->log(0, "ERROR: ", @msg);

    my $rc = 1;
	my $server_id = (scalar @msg > 1) ? shift @msg : 1;
	$server_id = 1 if ($server_id =~ /\D/);
	
    undef $errstr;

	# Determine whether this is the first version of this event we
	# have received or not
	SC->dbh->do(qq/
	    insert into log_message (
		LOG_MESSAGE_TYPE, SERVER_ID,  DESCRIPTION, RECEIVE_TIMESTAMP)
	      values (?,?,?,$db_now)/,
            undef,
	    'ERROR',
	    $server_id,
	    (join '', @msg));

	SC->dbh->commit;
    if ($@) {
        $errstr = $@;
        $rc = 0;
    }
    return $rc;
}

sub warn {
    my ($class, @msg) = @_;
    $logger->log(1, "WARNING: ", @msg);
}

sub log {
    my $class = shift;
    $logger->log(@_) if $logger;
}

sub log_fh2 {
    my $class = shift;
    if ($logger) {
	return @_ ? $logger->fh2(shift) : $logger->fh2;
    } else {
	return undef;
    }
}

sub log_level {
    my $class = shift;
    if ($logger) {
	return @_ ? $logger->level(shift) : $logger->level;
    } else {
	return undef;
    }
}

sub setids {
    return if $^O eq 'MSWin32';
    my $class = shift;
    die "setids called before initialize" unless $config;
    my $uid = $config->{UserID};
    my $gid = $config->{GroupID};
    unless ($uid and $uid =~ /^\d+$/) {
	my $id = (getpwnam $uid)[2];
	SC->error("unknown uid name: '$uid'") unless $id;
	$uid = $id;
    }
    unless ($gid and $gid =~ /^\d+$/) {
	my $id = (getgrnam $gid)[2];
	SC->error("unknown gid name: '$gid'") unless $id;
	$gid = $id;
    }
    if ($gid) {
	($) = "$gid $gid") == $gid or SC->error("can't set EGID to $gid: $!");
    }
    if ($uid) {
	($> = $uid) == $uid or SC->error("can't set EUID to $uid: $!");
    }
    SC->log(1, "running as euid=$>, egid='$)'");
}

sub time_to_ts {
    my $clsss = shift;
    my $time = (@_ ? shift : time);
    my ($sec, $min, $hr, $mday, $mon, $yr);
    if ($config->{board_timezone} > 0) {
		($sec, $min, $hr, $mday, $mon, $yr) = localtime $time;
	} else {
		($sec, $min, $hr, $mday, $mon, $yr) = gmtime $time;
	}
    sprintf ("%04d-%02d-%02d %02d:%02d:%02d",
	     $yr+1900, $mon+1, $mday,
	     $hr, $min, $sec);
}

sub ts_to_time {
    my ($clsss, $time_str) = @_;
	
	use Time::Local;
	my %months = ('jan' => 0, 'feb' =>1, 'mar' => 2, 'apr' => 3, 'may' => 4, 'jun' => 5,
		'jul' => 6, 'aug' => 7, 'sep' => 8, 'oct' => 9, 'nov' => 10, 'dec' => 11);
	my %fmonths = ('january' => 0, 'february' =>1, 'march' => 2, 'april' => 3, 
		'may' => 4, 'june' => 5, 'july' => 6, 'august' => 7, 'september' => 8, 
		'october' => 9, 'november' => 10, 'december' => 11);
	my ($mday, $mon, $yr, $hr, $min, $sec);
	my $timegm;
	
	if ($time_str =~ /UTC$/i) {
		# Wednesday, February 9, 2011 19:24:06 UTC
		($mon, $mday, $yr, $hr, $min, $sec) = $time_str 
			=~ /(\w+)\s+(\d+),\s+(\d+)\s+(\d+)\:(\d+)\:(\d+)\s+/;
		$mon = $fmonths{lc($mon)};
	} elsif ($time_str =~ /[a-zA-Z]+/) {
		# <pubDate>Tue, 04 Mar 2008 20:57:43 +0000</pubDate>
		($mday, $mon, $yr, $hr, $min, $sec) = $time_str 
			=~ /(\d+)\s+(\w+)\s+(\d+)\s+(\d+)\:(\d+)\:(\d+)\s+/;
		$mon = $months{lc($mon)};
	} else {
		#2008-10-04 20:57:43
		($yr, $mon, $mday, $hr, $min, $sec) = $time_str 
			=~ /(\d+)\-(\d+)\-(\d+)\s+(\d+)\:(\d+)\:(\d+)/;
		$mon--;
	}

    #if ($config->{board_timezone} > 0) {
	#	$timegm = timelocal($sec, $min, $hr, $mday, $mon, $yr-1900);
	#} else {
		$timegm = timegm($sec, $min, $hr, $mday, $mon, $yr-1900);
	#}
	return ($timegm);
}

use Data::Dumper;

sub xml_in {
    my ($class, $src) = @_;
    my $p;
    
    eval {
	require XML::LibXML::Simple;
    };
    die $@ if $@;

    eval {
	$p = XML::LibXML::Simple::XMLin($src, 'keeproot'=>1);
        SC->log(6, "xml_in($src) ->", Dumper($p));
    };
    $SC::errstr = $@, return undef if $@;
    return $p;
}

sub to_xml_attrs {
    my ($class, $href, $tag, $attrp, $close_flag) = @_;
    
    my $xml = "<$tag";
    foreach my $a (@$attrp) {
	my $av = $href->{$a};
	$av = defined $av ? SC->xml_esc($av) : '';
	$xml .= qq/ $a="$av"/;
    }
    $xml .= ($close_flag ? '/>' : '>');
    return $xml;
}

sub xml_esc {
    my ($class, $str) = @_;

    $str =~ s/</\&lt;/g;
    $str =~ s/>/\&gt;/g;
    $str =~ s/&/\&amp;/g;
    $str =~ s/\'/\&apos;/g;
    $str =~ s/\"/\&quot;/g;
    return $str;
}

sub sm_twig {
  my ($class, $xml_file) = @_;

  use XML::Twig;
  my $twig= new XML::Twig;                                   # just to be extra clean
  
  $twig->parsefile($xml_file);    # build the twig
  
  my $root= $twig->root;           # get the root of the twig (stats)
  my @tags = $root->children;    # get the player list
  
  my $xml_twig;
  $xml_twig->{$root->tag} = $root->atts;
				   
  foreach my $tag (@tags)  {
      if ($tag->tag =~ /grid_data/) {
	  $xml_twig->{$tag->tag} = $tag->text;
      } elsif ($tag->tag =~ /grid_field/) {
	  $xml_twig->{$tag->tag}->{$tag->{'att'}->{'name'}} = $tag->atts;
      } else {
	  $xml_twig->{$tag->tag} = $tag->atts;
      }
   }
  return $xml_twig;
}

sub inform_notifier {
    my ($class, $what) = @_;

    if ($^O eq 'MSWin32') {
	eval {
	    require Win32::Semaphore;
	};
	die $@ if $@;

	Win32::Semaphore->new(0, 1, 'nqscan')->release;
    }
}

sub save_to_file {
    my ($class, $str) = @_;

    my $conf = new Config::General($config);
    if (defined $str) {
		$conf->save_file($conf_file, $str);
	} else {
		$conf->save_file($conf_file);
	}
}

1;

__END__

=head1 NAME

SC - ShakeCast library

=head1 DESCRIPTION

This module contains the common code for the ShakeCast library.

Database connection strategy:

=over 4

=item *

RaiseError is set, so any DB errors will die if not handled.

=item *

PrintError is unset, so extraneous error messages don't get splattered around.

=item *

AutoCommit is unset.  Each method handles its own transactions.  Top-level
entry points should rollback first so that the DB is in a known state.

=back

=head2 Class Methods

All C<SC> methods are class methods; there is no constructor.

=over 4

=item SC->initialize

Sets up SC for use.  This method should be called before any other SC method.
The following actions are performed:

=over 4

=item *

Read the configuration file C<conf/sc.conf>.  All configuration parameters
are available via the C<$config> hashref.  B<Add more details and examples.>

=item *

Open the log file.

=item *

Connect to the SC database.

=back

Nonzero is returned if all initializations completed successfully,
zero is returned for any error, and C<$SC::errstr> contains the
error message.

=item SC->new_event( $event )

Adds a new event to the database.  The event might already exist; this is not
an error.  If the event is new then forward it on to all downstream servers.
Returns status.

=item SC->log( $level, @message )

If the current logging level is at least as great as C<$level> then a
line containing the given message elements (blank-separated) is written
to the ShakeCast log file.  Logfile location and logging level are
read from the ShakeCast configuration file during C<SC-E<gt>initialize>

This method fails silently if the log has not been opened yet.

=item SC->log_level( [$new_level] )

Gets or sets the log level.  In either case the new level is returned.

This method fails silently if the log has not been opened yet.

=item SC->time_to_ts( [$time] )

Returns the given time as a string in the ShakeCast date/time format
I<YYYY-MM-DD HH:MI:SS.FF>C<Z>; for example C<1994-02-24 15:33:02.69Z>.
If the C<$time> parameter is omitted the current server time is used.

=item SC->xml_in( $xml )

Parses XML from a string or file and returns a hashref.
Currently this is just a wrapper around C<XML::Simple::XMLin> but we
could swap it out later.

=over 4

=back

=cut
