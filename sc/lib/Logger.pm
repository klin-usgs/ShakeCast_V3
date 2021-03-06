# $Id: Logger.pm 64 2007-06-05 14:58:38Z klin $

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
# shc 2003-03-14: add facility name as argumnt to new.  Add name method to
#                 get/set the facility name.
# shc 2003-03-15: add a second file handle so can log to 2 places (e.g., the
#                 log and stderr)
# dwb 2003-03-17: allow %y, %Y, %m, %d patterns in log file name; these map
# 		  to 2-digit year, 4-digit year, month (01-12), and day (01-31)
# 		  respectively

# Release notes:
# 2003-03-17: allow %y, %Y, %m, %d patterns in log file name.
#
# Encapsulated Logging behavior
# 
# $logger = new Logger('c:/temp/junk.txt', 2, 'facility_name');
# $logger = new Logger('c:/temp/junk.txt', 2);
# $logger = new Logger('c:/temp/rpt%y%m$dtxt', 2);
# $logger->log(0, 'a message that will always appear');
# $logger->log(9, 'crank logging way up to see this one');
# $logger->level(4); # log priority 4 or lower messages
# $logger->rotate;
# $logger->close;

package Logger;
use strict;
use IO::File;
use vars qw($errmsg);

# Variables:
#   file - name of log file
#   level - max level for which to log messages
#   fh - filehandle for log file
#   errmsg - error message if most recent call failed, else undef

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self->_init(@_);
    return (defined $errmsg) ? undef : $self;
}
sub _init {
    my $self = shift;
    $self->file(shift);
    $self->level(@_ ? shift : 0);
    $self->name(@_ ? shift : '');
    $self->fh(new IO::File($self->file, 'a'));
    if ($self->fh) {
	$self->fh->autoflush(1);
    } else {
	$self->errmsg("Could not open '$self->{file}': $!");
    }
}
sub log {
    my ($self, $level, @msg) = @_;
    if ($level <= $self->level) {
	my $name = $self->name;
	$name = '' unless defined $name;
	my $msg = _ts() . " $name\[$$]: ";
	$msg .= join(' ', (map {defined $_ ? $_ : 'undef'} @msg)) if @msg;
	chomp $msg;
	$self->fh->print($msg, "\n");
	$self->fh2->print($msg, "\n") if $self->fh2;
    }
}
sub close {
    my ($self) = @_;
    $self->fh->close;
    $self->fh(undef);
}
sub rotate {
    my ($self) = @_;
    my $t = _gmts();
    my ($bak, $rc, $rce, $lg, $level);

    $self->errmsg(undef);
    $self->log(3, "Closing log for rotation");
    $level = $self->level;
    $self->level(-1);
    $self->fh->close;
    $bak = $self->file . ".$t";
    $rc = rename $self->{file}, $bak;
    $self->errmsg("rename failed: $!") unless $rc;
    $self->fh(new IO::File($self->file, 'a'));
    if ($self->fh) {
	$self->fh->autoflush(1);
	$self->level($level);
	if ($rc) {
	    $self->log(2, "Log rotated; old log is '$bak'.");
	} else {
	    $self->log(0, "Log not rotated; " . $self->errmsg);
	}
    } else {
	$self->errmsg("Could not reopen '$self->{file}': $!");
    }
    return not defined $self->errmsg;
}

# get/set name of log file
sub file {
    my $self = shift;
    if (@_) {
	my $pat = shift;
	if ($pat =~ /\%/) {
	    my ($s,$i,$h,$d,$m,$y) = localtime; # XXX local or UTC ?
	    my $Y = $y + 1900;
	    $y = $y % 100;
	    $m++;
	    $d = "0$d" if $d < 10;
	    $m = "0$m" if $m < 10;
	    $y = "0$y" if $y < 10;
	    $pat =~ s/\%\%/\0/g;	# hide escaped percent
	    $pat =~ s/\%Y/$Y/g;
	    $pat =~ s/\%y/$y/g;
	    $pat =~ s/\%m/$m/g;
	    $pat =~ s/\%d/$d/g;
	    # should be no % at this point ...
	    $pat =~ s/\0/\%/g;  # put back percents
	}
	$self->{'file'} = $pat;
    }
    $self->{'file'};
}

# get/set filehandle of log file
sub fh {
    my $self = shift;
    @_ ? $self->{'fh'} = shift : $self->{'fh'};
}

sub fh2 {
    my $self = shift;
    @_ ? $self->{'fh2'} = shift : $self->{'fh2'};
}

# get/set logging level
sub level {
    my $self = shift;
    @_ ? $self->{'level'} = shift : $self->{'level'};
}

# get/set facility name         
sub name {
    my $self = shift;
    @_ ? $self->{'name'} = shift : $self->{'name'};
}

# get/set errmsg
sub errmsg {
    my $self_or_class = shift;
    if (@_) {
	$errmsg = $self_or_class->{'errmsg'} = shift;
    } elsif (not ref $self_or_class) {
	# return global errmsg
	return $errmsg;
    }
    return $self_or_class->{'errmsg'};
}

#======== CLASS METHODS ==========

# return time (now if not specified) as formatted GMT
sub _gmts {
    my $time = (@_ ? shift : time);
    my($sec, $min, $hr, $mday, $mon, $yr);

    ($sec, $min, $hr, $mday, $mon, $yr) = gmtime $time;
    sprintf ("%04d%02d%02d%02d%02d%02d",
	     $yr+1900, $mon+1, $mday,
	     $hr, $min, $sec);
}

# return time (now if not specified) as formatted localtime
sub _ts {
    my $time = (@_ ? shift : time);
    my($sec, $min, $hr, $mday, $mon, $yr);

    ($sec, $min, $hr, $mday, $mon, $yr) = localtime $time;
    sprintf ("%04d-%02d-%02d %02d:%02d:%02d",
	     $yr+1900, $mon+1, $mday,
	     $hr, $min, $sec);
}

# Close the filehandle in case the user forgot to do it.
END {
    #$self->close if $self->fh;
}

1;
