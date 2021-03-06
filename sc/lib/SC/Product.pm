
# $Id: Product.pm 486 2008-10-03 16:57:51Z klin $

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

package SC::Product;

use SC;
use SC::Event;
use SC::Shakemap;

use vars qw(%type_2_name);


# Build get/set accessors

sub BEGIN {
    no strict 'refs';
    for my $method (qw(
			product_id
			shakemap_id shakemap_version product_type
			product_status generating_server
			max_value min_value
			generation_timestamp receive_timestamp update_timestamp
			product_file_exists superceded_timestamp
			lat_min lon_min lat_max lon_max
			)) {
	*$method = sub {
	    my $self = shift;
	    @_ ? ($self->{$method} = shift, return $self)
	       : return $self->{$method};
	}
    }
}

# ======================================================================
# Class methods


sub new {
    my $class = shift;
    my $self = bless {} => $class;
    $self->receive_timestamp(SC->time_to_ts);
    Carp::carp "Odd (wrong?) number of parameters in new()" if $^W && (@_ & 1); 
    while (@_) {
	my $method = shift;
	my $value = shift;
	next unless (defined $value and $value ne '');
	$self->$method($value) if $self->can($method);
    }
    return $self;
}


sub from_keys {
    my ($class, $shakemap_id, $shakemap_version, $product_type) = @_;

    undef $SC::errstr;
    my $product;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
	    select *
	      from product
	     where shakemap_id = ?
	       and shakemap_version = ?
	       and product_type = ?/);
	$sth->execute($shakemap_id, $shakemap_version, $product_type);
	my $p = $sth->fetchrow_hashref('NAME_lc');
	$product = new SC::Product(%$p) if $p;
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    #} elsif (not defined $product) {
	#$SC::errstr = "No product for key $shakemap_id-$shakemap_version-$product_type";
    }
    return $product;
}

sub from_id {
    my ($class, $product_id) = @_;

    undef $SC::errstr;
    my $product;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
	    select *
	      from product
	     where product_id = ?/);
	$sth->execute($product_id);
	my $p = $sth->fetchrow_hashref('NAME_lc');
	$product = new SC::Product(%$p) if $p;
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    } elsif (not defined $product) {
	$SC::errstr = "No product for id $product_id";
    }
    return $product;
}

sub newer_than {
    my ($class, $hwm, $oldest) = @_;
    
    undef $SC::errstr;
    my @newer;
    my @args = ($hwm);
    my $sql =  qq/
	    select p.*
	      from product p
                inner join shakemap s on (p.shakemap_id = s.shakemap_id and p.shakemap_version = s.shakemap_version)
                inner join event e on (s.event_id = e.event_id and s.event_version = e.event_version)
	     where p.product_id > ?
               and e.event_type <> 'TEST'/;
    if ($oldest) {
	$sql .= qq/ and p.receive_timestamp > $SC::to_date/;
	push @args, $oldest;
    }
    eval {
	my $sth = SC->dbh->prepare($sql);
	$sth->execute(@args);
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    push @newer, $class->new(%$p);
	}
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return \@newer;
}

sub current_version {
    my ($class, $event_id) = @_;
    my @result;
    
    undef $SC::errstr;
    eval {
	my $sth = SC->dbh->prepare(qq/
	    select p.*
	      from product p
                inner join shakemap s on (p.shakemap_id = s.shakemap_id and p.shakemap_version = s.shakemap_version)
	     where s.event_id = ?/);
        $sth->execute($event_id);
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    push @result, $class->new(%$p);
	}
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return @result;
}

sub from_xml {
    my ($class, $xml_source) = @_;
    undef $SC::errstr;
    my $xml = SC->xml_in($xml_source);
    return undef unless defined $xml;
    unless (exists $xml->{'product'}) {
	$SC::errstr = 'XML error: product element not found';
	return undef;
    }
    $class->new(%{ $xml->{'product'} });
}

# ======================================================================
# Instance methods

sub to_xml {
    my $self = shift;

    # generate <shakemap attr=value ...>
    my $xml = SC->to_xml_attrs(
	$self,
	'product',
	[qw(
	    shakemap_id shakemap_version product_type
	    product_status generating_server
	    max_value min_value
	    generation_timestamp update_timestamp
	    lat_min lon_min lat_max lon_max
	   )],
	1);

    return $xml;
}

# Writes the product record to the database, unless it already exists.  Marks
# any previous versions of the product as superceded.
# 
# Returns:
#   0 - Error, $SC::errstr is also set.  Caller is responsible for logging.
#   1 - Success
#   2 - Exists, the product record already exists.
#   
sub write_to_db {
    my $self = shift;
    my $rc = 1;

    undef $SC::errstr;
    eval {
        # check for existing record
	my $sth_getkey = SC->dbh->prepare(qq/
	    select product_id
	      from product
	     where shakemap_id=?
	       and shakemap_version=?
	       and product_type=?/, {});
        my $id;
        if (($id) = SC->dbh->selectrow_array($sth_getkey, {},
                $self->{'shakemap_id'},
                $self->{'shakemap_version'},
                $self->{'product_type'})) {
            $self->{'product_id'} = $id;
	    $rc = 2;
            return;
        }

	SC->dbh->do(qq/
	    insert into product (
		shakemap_id, shakemap_version, product_type,
		product_status, generating_server,
		max_value, min_value,
		generation_timestamp, receive_timestamp, update_timestamp,
		product_file_exists,
		lat_min, lon_min, lat_max, lon_max)
	      values (?,?,?,?,?,?,?,$SC::to_date,$SC::to_date,$SC::to_date,
		      ?,?,?,?,?) /, {},
	    $self->{'shakemap_id'},
	    $self->{'shakemap_version'},
	    $self->{'product_type'},
	    $self->{'product_status'},
	    $self->{'generating_server'},
	    $self->{'max_value'},
	    $self->{'min_value'},
	    $self->{'generation_timestamp'},
	    $self->{'receive_timestamp'},
	    $self->{'update_timestamp'},
	    $self->{'product_file_exists'},
	    $self->{'lat_min'},
	    $self->{'lon_min'},
	    $self->{'lat_max'},
	    $self->{'lon_max'});
        $sth_getkey->execute(
	    $self->{'shakemap_id'},
	    $self->{'shakemap_version'},
	    $self->{'product_type'});
	$self->{'product_id'} = $sth_getkey->fetchrow_arrayref()->[0];
	SC->log(2, "id:", $self->{'product_id'});

        # Determine all potential shakemap_id's for predecessor product records.
        # This could be more than one because an event can have more than one
        # shakemap_id.
        my $sth_get_sm_ids = SC->dbh->prepare_cached(qq/
            select sp.shakemap_id
              from shakemap sp,
                   shakemap sc
             where sc.shakemap_id = ?
               and sc.event_id = sp.event_id/);
        $sth_get_sm_ids->execute($self->{'shakemap_id'});
        
	# Now mark all the other revisions of this product as superceded.
	# Because we are not necessarily working with a DB that supports
	# transactions, it is possible for this operation to fail and leave
	# us with two different revisions of the product that are both
	# considered current.
        my $sth = SC->dbh->prepare_cached(qq/
            update product
               set superceded_timestamp = $SC::to_date
             where shakemap_id = ?
               and product_type = ?
	       and product_id <> ?
               and superceded_timestamp IS NULL /);
        while (my $p = $sth_get_sm_ids->fetchrow_arrayref) {
	    $sth->execute(SC->time_to_ts(),
		$p->[0], $self->{'product_type'},
		$self->{'product_id'});
        }
        # Update HWM -- in this case the product_id doubles as sequence no
        SC::Server->this_server->update_product_hwm($self->product_id);
    };
    if ($@) {
        $SC::errstr = $@;
        $rc = 0;
	eval {
	    SC->dbh->rollback;
	};
	# Throw away any error message resulting from the rollback since
	# it would mask the original error (and mysql always complains
	# about not being able to roll back).
    }
    SC->dbh->commit;
    return $rc;
}

# returns absolute local file name, which need not exist
sub abs_file_path {
    my $self = shift;

    return $self->dir_name . '/' . $self->file_name;
}

# returns name of directory that will contain this product file
sub dir_name {
    my $self = shift;

    return SC->config->{'DataRoot'} . '/' .
	    $self->{'shakemap_id'} . '-' . $self->{'shakemap_version'};
}

# returns file name corrsponding to the product's type
# TODO error handling.
sub file_name {
    my $self = shift;

    if (scalar keys %type_2_name == 0) {
	my $sth = SC->dbh->prepare(qq/
	    select product_type, filename from product_type/);
	$sth->execute;
	while (my $p = $sth->fetchrow_arrayref) {
	    $type_2_name{$p->[0]} = $p->[1];
	}
    }
    return $type_2_name{$self->{'product_type'}};
}

sub as_string {
    my $self = shift;

    return "id=" . ($self->{'product_id'} || '') .
	", type=" . $self->{'product_type'};
}

# Tet the file for this product from teh specified remote server.
# Returns 1 for success, 0 for failure, and sets or clears $SC::errstr.
sub get_remote_file {
    my ($self, $remote) = @_;

    undef $SC::errstr;
    my @status = $remote->get_file($self);
    if ($status[0] eq SC_OK) {
	$self->set_file_exists;
	return 1;
    } else {
	$SC::errstr = $status[1];
	return 0;
    }
}


sub set_file_exists {
    my $self = shift;

    undef $SC::errstr;
    eval {
	SC->dbh->do(qq/
	    update product
	       set product_file_exists = 1,
	           update_timestamp = $SC::to_date
	     where product_id = ?/, {},
	    SC->time_to_ts(), $self->{'product_id'});
	SC->dbh->commit;
        $self->{'product_file_exists'} = 1;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub is_local_test {
    my $self = shift;
    my $shakemap = SC::Shakemap->from_id($self->shakemap_id,
        $self->shakemap_version);
    return 0 unless defined $shakemap;
    my $event = SC::Event->from_id($shakemap->event_id,
        $shakemap->event_version);
    return ($event and $event->is_local_test);
}


# Defines mapping between specific metrics and which column in the GRID_VALUE
# record contains the metric value.  As long as the grid files are in a
# fixed format we just hardcode the mapping.  At some future date the grid
# files might contain varying metrics; we'd need some way to determine the
# mappings, such as metadata in the file or varying file names.
my @metric_column_map = qw(
    PGA
    PGV
    MMI
    PSA03
    PSA10
    PSA30
);

sub process_grid_file {
    my $self = shift;
    my ($lon, $lat, @v);
    my (@min, @max);
    my ($lat_cell_count, $lon_cell_count);
    my ($lat_spacing, $lon_spacing);
    my (@cells, $cell_no);
    my ($lon_min, $lat_min, $lon_max, $lat_max);
    my ($rows_per_degree, $cols_per_degree);
    my $sth;
    my $rc;

    undef $SC::errstr;
    if ($self->{'product_type'} ne 'GRID') {
	$SC::errstr = 'not a GRID file';
	return 0;
    } elsif (!$self->{'product_file_exists'} ||
	    not -f $self->abs_file_path) {
	$SC::errstr = 'local file not found';
	return 0;
    } else {
	# see if we already loaded the grid, and just return success if so
	my $count = SC->dbh->selectrow_array(qq/
	    select count(*)
	      from grid
	     where shakemap_id=?
	       and shakemap_version=?/,
	    undef,
	    $self->{'shakemap_id'},
	    $self->{'shakemap_version'});
	if ($count == 1) {
            SC->log(3, 'grid already loaded');
            return 1;
        }
    }
    #eval {
	#require Archive::Zip;
	#require Archive::Zip::MemberRead;
    #};
    #if ($@) {
	#$SC::errstr = $@;
	#return 0;
    #}
    #my $zip = new Archive::Zip($self->abs_file_path);
    #my $fh  = new Archive::Zip::MemberRead($zip, "grid.xyz");
	my $fh  = new IO::File($self->abs_file_path);

    my $header = <$fh>;
    #my $header = $fh->getline();
    SC->log(2, "Grid file header: $header");
    # save the header to process later

    eval {
        # insert new GRID record and read back its grid_id
	SC->dbh->do(qq{
	    insert into grid (
		shakemap_id, shakemap_version,
		lon_min, lat_min, lon_max, lat_max)
	      values (
		?,?,0,0,0,0)}, {},
		$self->{'shakemap_id'}, $self->{'shakemap_version'});
        my ($grid_id) = SC->dbh->selectrow_array(qq/
            select grid_id
              from grid
             where shakemap_id = ?
               and shakemap_version = ?/, {},
		$self->{'shakemap_id'}, $self->{'shakemap_version'});
        unless ($grid_id) {
            $SC::errstr = 'No grid ID!';
            return 0;
        }

        # read grid file records and build in-memory list of shaking data
        $cell_no = 0;
        $lat_spacing = 0;
        my ($lon, $lat); # referenced outside the loop so declare outside, too
	while (defined(my $line = <$fh>)) {
	#while (defined(my $line = $fh->getline())) {
            my @v;
            # row format: lon lat metric1 metric2 ...
            #SC->log(8, "Grid file line: $line");
	    ($lon, $lat, @v) = split ' ',$line;

            # compute min/max for each metric across the entire grid
            for (my $i = 0; $i < scalar @v; $i++) {
                $min[$i] = _min($min[$i], $v[$i]);
                $max[$i] = _max($max[$i], $v[$i]);
            }
            if ($cell_no == 0) {
                $lat_max = $lat;
                $lon_min = $lon;
            } elsif ($cell_no == 1) {
                $lon_spacing = $lon - $lon_min;
            } elsif ($lat_spacing == 0 and $lon == $lon_min) {
                # starting a new row
                $lat_spacing = $lat_max - $lat;
                $lon_cell_count = $cell_no;
            }
            $cells[$cell_no++] = \@v;
	}
	$fh->close;
	
        $lat_cell_count = scalar @cells / $lon_cell_count;
        $lat_min = $lat;
        $lon_max = $lon;
        $cols_per_degree = sprintf "%d", 1/$lon_spacing + 0.5;
        $rows_per_degree = sprintf "%d", 1/$lat_spacing + 0.5;

        SC->log(2, "grid loaded, $lon_cell_count x $lat_cell_count [$lon_min/$lat_min, $lon_max/$lat_max]");
        SC->log(2, "cols/deg: $cols_per_degree, rows/deg: $rows_per_degree");
        SC->log(2, "x spacing: $lon_spacing, y spacing: $lat_spacing");

	# update GRID record

	my @hw = split ' ', $header;
	shift @hw;		# name/CUSPID
	shift @hw;		# mag
	$lat = shift @hw;
	$lon = shift @hw;
	shift @hw;		# MMM
	shift @hw;		# DD
	shift @hw;		# YYYY
	shift @hw;		# HH:MM:SS
	shift @hw;		# timezone
	$lon_min = shift @hw;
	$lat_min = shift @hw;
	$lon_max = shift @hw;
	$lat_max = shift @hw;
	SC->dbh->do(qq/
	    update grid
               set lon_min = ?,
                   lat_min = ?,
                   lon_max = ?,
                   lat_max = ?,
                   origin_lon = ?,
                   origin_lat = ?,
                   longitude_cell_count = ?,
                   latitude_cell_count = ?
             where grid_id = ?/, undef,
		$lon_min, $lat_min, $lon_max, $lat_max, $lon, $lat,
		$lon_cell_count, $lat_cell_count, $grid_id);
	
	# Update min/max values in the SHAKEMAP_METRIC records.  Note that
        # shakemap_metric.value_column_number is 1-based, not 0-based.
        my $sth_u = SC->dbh->prepare(qq{
	    update shakemap_metric
               set value_column_number=?,
                   min_value=?,
                   max_value=?
             where shakemap_id=?
               and shakemap_version=?
               and metric=?});

	for (my $i = 0; $i < scalar @min; $i++) {
            $sth_u->execute(
                $i+1,
		(defined $min[$i] ? $min[$i] : 0),
		(defined $max[$i] ? $max[$i] : 0),
                $self->{'shakemap_id'}, $self->{'shakemap_version'},
                $metric_column_map[$i]);
	}

        # construct SQL to insert FACILITY_SHAKING records
        my @fields = map { "value_$_" } ( 1 .. scalar @{$cells[0]} );
        my $sql =  "insert into facility_shaking (facility_id, grid_id," .
            join(',', @fields) . ") values (?,?," .
            join(',', ('?') x scalar @fields) . ")";
        my $sth_i = SC->dbh->prepare($sql);

        # read all the facilities that overlap the grid
        my $facpp = SC->dbh->selectall_arrayref(qq{
            select facility_id,
                   lon_min, lat_min, lon_max, lat_max
              from facility
             where ? < lon_max
               and ? > lon_min
               and ? < lat_max
               and ? > lat_min}, undef,
            $lon_min, $lon_max, $lat_min, $lat_max);

        # offset the grid origin by 1/2 cell to map from grid point to grid
        # cell centered on point
        $lat_max += 0.5 * $lat_spacing;
        $lon_min -= 0.5 * $lon_spacing;

        # for each facility compute max value of each metric and write a
        # FACILITY_SHAKING record
        foreach my $p (@$facpp) {
            # some pt features have only min
            $p->[3] = $p->[1] unless defined $p->[3];
            $p->[4] = $p->[2] unless defined $p->[4];
            #SC->log(4, sprintf("FacID: %d, bbox: %f9,%f9 - %f9,%f9", $p->[0], $p->[2], $p->[1], $p->[4], $p->[3]));
            my @summary;
            my $n = 0;
            for (my $row = _max(0, int(($lat_max-$p->[4]) * $rows_per_degree));
                    $row < $lat_cell_count; $row++) {
                last if int (($lat_max - $p->[2]) * $rows_per_degree) < $row;
                for (my $col = _max(0,int(($p->[1]-$lon_min) * $cols_per_degree));
                        $col < $lon_cell_count; $col++) {
                    last if int (($p->[3] - $lon_min) * $cols_per_degree) < $col;
                    $cell_no = $row * $lon_cell_count + $col;
                    #SC->log(4, sprintf("row=%d,col=%d,v0=%f",$row,$col,$cells[$cell_no][0]));
                    if (@summary) {
                        for (my $i = 0; $i <= $#summary; $i++) {
                            $summary[$i] = _max($summary[$i],
                                                $cells[$cell_no][$i]);
                        }
                    } else {
                        @summary = @{$cells[$cell_no]};
                    }
                    $n++;
                }
            }
            if ($n == 0) {
                # XXX should never happen
                SC->log(0, "no cell for facility $p->[0]");
                next;
            } else {
                #SC->log(4, "facility: ", join(', ', @$p));
                #SC->log(4, "last cell: $cell_no");
                #SC->log(4, "checked $n,  metrics: ", join(', ', @summary));
                $sth_i->execute($p->[0], $grid_id, @summary);
            }
        }
        SC->log(2, "grid processing complete");
    };
    if ($@) {
	$SC::errstr = $@;
	$rc = 0;
	eval {
	    SC->dbh->rollback;
	};
	# Throw away any error message resulting from the rollback since
	# it would mask the original error (and mysql always complains
	# about not being able to roll back).
    } else {
	SC->dbh->commit;
	$rc = 1;
    }
    return $rc;
}


my $count = 0;
my $tag = "";
my %grid_spec;
my @grid_metric;
my %shakemap_spec;
my %event_spec;

sub startElement {

      my( $parseinst, $element, %attrs ) = @_;
        SWITCH: {
                if ($element eq "shakemap_grid") {
                        $count++;
                        $tag = "shakemap_grid";
                        print "shakemap_grid $count:\n";
						foreach my $key (keys %attrs) {
							$shakemap_spec{$key} = $attrs{$key};
							print $key,": ", $shakemap_spec{$key}, "\n";
						}
						last SWITCH;
                }
                if ($element eq "event") {
                        $count++;
                        $tag = "event";
                        print "event $count:\n";
						foreach my $key (keys %attrs) {
							$event_spec{$key} = $attrs{$key};
							print $key,": ", $event_spec{$key}, "\n";
						}
						last SWITCH;
                }
                if ($element eq "grid_specification") {
                        $count++;
                        $tag = "grid_specification";
                        print "grid_specification $count:\n";
						foreach my $key (keys %attrs) {
							$grid_spec{$key} = $attrs{$key};
							print $key,": ", $grid_spec{$key}, "\n";
						}
						last SWITCH;
                }
                if ($element eq "grid_field") {
                        print "grid_field: $count:\n";
                        $tag = "grid_field";
						$grid_metric[$attrs{'index'}-1] = $attrs{'name'};
						print $attrs{'index'},": ", $attrs{'name'}, "\n";
						last SWITCH;
                }
                if ($element eq "grid_data") {
                        #print "grid_data: ";
                        $tag = "grid_data";
                        last SWITCH;
                }
        }

 }

sub endElement {

      my( $parseinst, $element ) = @_;

 }

sub characterData {

      my( $parseinst, $data ) = @_;

 }

sub default {

      my( $parseinst, $data ) = @_;
        # do nothing, but stay quiet

 }
 
# returns a list of all metrics that should be polled for new events, etc.
sub metric_list {
	my @metrics;
	
    undef $SC::errstr;
    eval {
		my $sth = SC->dbh->prepare(qq/
			select short_name, metric_id
			  from metric/);
		$sth->execute;
		while (my @p = $sth->fetchrow_array()) {
			push @metrics, @p;
		}
    };
    return @metrics;
}

sub process_grid_xml_file {
    my $self = shift;
    my ($lon, $lat, @v);
    my (@min, @max);
    my ($lat_cell_count, $lon_cell_count);
    my ($lat_spacing, $lon_spacing);
    my (@cells, $cell_no);
    my ($lon_min, $lat_min, $lon_max, $lat_max);
    my ($rows_per_degree, $cols_per_degree);
    my $sth;
    my $rc;

    eval {
	use Shake::Distance;
    };
    if ($@) {
	$SC::errstr = $@;
	return 0;
    }

    undef $SC::errstr;
    if ($self->{'product_type'} ne 'GRID_XML') {
	$SC::errstr = 'not a GRID XML file';
	return 0;
    } elsif (!$self->{'product_file_exists'} ||
	    not -f $self->abs_file_path) {
	$SC::errstr = 'local file not found';
	return 0;
    } else {
	# see if we already loaded the grid, and just return success if so
	my $count = SC->dbh->selectrow_array(qq/
	    select count(*)
	      from grid
	     where shakemap_id=?
	       and shakemap_version=?/,
	    undef,
	    $self->{'shakemap_id'},
	    $self->{'shakemap_version'});
	if ($count == 1) {
            SC->log(3, 'grid already loaded');
            return 1;
        }
    }
    eval {
		require XML::Parser;
    };

    if ($@) {
		$SC::errstr = $@;
	return 0;
    }

	my $parser = new XML::Parser;
	$parser->setHandlers(      Start => \&startElement,
											 End => \&endElement,
											 Char => \&characterData,
											 Default => \&default);
	$parser->parsefile($self->abs_file_path);

    #SC->log(2, "Grid file header: $header");
    # save the header to process later
	$lon_spacing = $grid_spec{'nominal_lon_spacing'};
	$lat_spacing = $grid_spec{'nominal_lat_spacing'};
	$lon_cell_count = $grid_spec{'nlon'};
	$lat_cell_count = $grid_spec{'nlat'};
	$lat_min = $grid_spec{'lat_min'};
	$lat_max = $grid_spec{'lat_max'};
	$lon_min = $grid_spec{'lon_min'};
	$lon_max = $grid_spec{'lon_max'};
	

    eval {
        # insert new GRID record and read back its grid_id
	SC->dbh->do(qq{
	    insert into grid (
		shakemap_id, shakemap_version,
		lon_min, lat_min, lon_max, lat_max)
	      values (
		?,?,0,0,0,0)}, {},
		$self->{'shakemap_id'}, $self->{'shakemap_version'});
        my ($grid_id) = SC->dbh->selectrow_array(qq/
            select grid_id
              from grid
             where shakemap_id = ?
               and shakemap_version = ?/, {},
		$self->{'shakemap_id'}, $self->{'shakemap_version'});
        unless ($grid_id) {
            $SC::errstr = 'No grid ID!';
            return 0;
        }

        # read grid file records and build in-memory list of shaking data
        $cell_no = 0;
        my ($lon, $lat); # referenced outside the loop so declare outside, too
		open (FH, "< " . $self->abs_file_path) || return 0;
		my $line;
		do {
			$line = <FH>;
		} until ($line =~ /^<grid_data>/i);
		while ($line = <FH>) {
            my @v;
			$line =~ s/\n|\t//g;
			($lon, $lat, @v) = split ' ', $line;
			next unless (scalar @v);
			#$#v = 5;
            for (my $i = 0; $i < scalar @v; $i++) {
                $min[$i] = _min($min[$i], $v[$i]);
                $max[$i] = _max($max[$i], $v[$i]);
            }
            $cells[$cell_no++] = \@v;
		}
		close(FH);
		
        $cols_per_degree = sprintf "%d", 1/$lon_spacing + 0.5;
        $rows_per_degree = sprintf "%d", 1/$lat_spacing + 0.5;

        SC->log(2, "grid loaded, $lon_cell_count x $lat_cell_count [$lon_min/$lat_min, $lon_max/$lat_max]");
        SC->log(2, "cols/deg: $cols_per_degree, rows/deg: $rows_per_degree");
        SC->log(2, "x spacing: $lon_spacing, y spacing: $lat_spacing");
        SC->log(2, "cells: $cell_no");

	# update GRID record

	SC->dbh->do(qq/
	    update grid
               set lon_min = ?,
                   lat_min = ?,
                   lon_max = ?,
                   lat_max = ?,
                   origin_lon = ?,
                   origin_lat = ?,
                   longitude_cell_count = ?,
                   latitude_cell_count = ?
             where grid_id = ?/, undef,
		$lon_min, $lat_min, $lon_max, $lat_max, $event_spec{'lon'}, $event_spec{'lat'},
		$lon_cell_count, $lat_cell_count, $grid_id);
	
	# Update min/max values in the SHAKEMAP_METRIC records.  Note that
        # shakemap_metric.value_column_number is 1-based, not 0-based.
        my $sth_u = SC->dbh->prepare(qq{
	    update shakemap_metric
               set value_column_number=?,
                   min_value=?,
                   max_value=?
             where shakemap_id=?
               and shakemap_version=?
               and metric=?});

	my %metric_column_map = metric_list();
	for (my $i = 0; $i < scalar @min; $i++) {
            $sth_u->execute(
                $metric_column_map{$grid_metric[$i+2]},
		(defined $min[$i] ? $min[$i] : 0),
		(defined $max[$i] ? $max[$i] : 0),
                $self->{'shakemap_id'}, $self->{'shakemap_version'},
                $grid_metric[$i+2]);
	}

        # construct SQL to insert FACILITY_SHAKING records
		my (@fields, @data_fields);
		for (my $i = 0; $i < scalar @{$cells[0]}; $i++) {
				if ($metric_column_map{$grid_metric[$i+2]}) {
					push @fields, "value_".$metric_column_map{$grid_metric[$i+2]};
					push @data_fields, $i;
				}
		}
        my $sql =  "insert into facility_shaking (facility_id, grid_id, dist," .
            join(',', @fields) . ") values (?,?,?," .
            join(',', ('?') x scalar @fields) . ")";
        my $sth_i = SC->dbh->prepare($sql);

        my $sql_prob =  "insert into facility_fragility_probability (
				facility_id, grid_id, facility_fragility_model_id, 
				damage_level, probability, metric) 
				select ffm.facility_id, ?, ffm.facility_fragility_model_id, ffm.damage_level, 
				lp.probability, ? 
				from lognorm_probability lp, facility_fragility_model ffm 
				where  ffm.facility_id=? 
				and ffm.metric = ?
				and ln(?/ffm.alpha)/ffm.beta >= lp.low_limit 
				and ln(?/ffm.alpha)/ffm.beta < lp.high_limit 
				";
        my $sth_prob = SC->dbh->prepare($sql_prob);

        # read all the facilities that overlap the grid
        my $facpp = SC->dbh->selectall_arrayref(qq{
            select facility_id,
                   lon_min, lat_min, lon_max, lat_max
              from facility
             where ? < lon_max
               and ? > lon_min
               and ? < lat_max
               and ? > lat_min}, undef,
            $lon_min, $lon_max, $lat_min, $lat_max);

        # offset the grid origin by 1/2 cell to map from grid point to grid
        # cell centered on point
        $lat_max += 0.5 * $lat_spacing;
        $lon_min -= 0.5 * $lon_spacing;

        # for each facility compute max value of each metric and write a
        # FACILITY_SHAKING record
		my $dist;
        foreach my $p (@$facpp) {
            # some pt features have only min
            $p->[3] = $p->[1] unless defined $p->[3];
            $p->[4] = $p->[2] unless defined $p->[4];
            #SC->log(4, sprintf("FacID: %d, bbox: %f9,%f9 - %f9,%f9", $p->[0], $p->[2], $p->[1], $p->[4], $p->[3]));
            my @summary;
			$dist = dist($event_spec{'lat'}, $event_spec{'lon'}, ($p->[2]+$p->[4])/2, ($p->[1]+$p->[3])/2);
            my $n = 0;
            for (my $row = _max(0, int(($lat_max-$p->[4]) * $rows_per_degree));
                    $row < $lat_cell_count; $row++) {
                last if int (($lat_max - $p->[2]) * $rows_per_degree) < $row;
                for (my $col = _max(0,int(($p->[1]-$lon_min) * $cols_per_degree));
                        $col < $lon_cell_count; $col++) {
                    last if int (($p->[3] - $lon_min) * $cols_per_degree) < $col;
                    $cell_no = $row * $lon_cell_count + $col;
                    #SC->log(4, sprintf("row=%d,col=%d,v0=%f",$row,$col,$cells[$cell_no][0]));
                    if (@summary) {
                        for (my $i = 0; $i <= $#summary; $i++) {
                            $summary[$i] = _max($summary[$i],
                                                $cells[$cell_no][$i]);
                        }
                    } else {
                        @summary = @{$cells[$cell_no]}[@data_fields];
                    }
                    $n++;
                }
            }
            if ($n == 0) {
                # XXX should never happen
                SC->log(0, "no cell for facility $p->[0]");
                next;
            } else {
                #SC->log(4, "facility: ", join(', ', @$p));
                #SC->log(4, "last cell: $cell_no");
                #SC->log(4, "checked $n,  metrics: ", join(', ', @summary));
                $sth_i->execute($p->[0], $grid_id, $dist, @summary);
            }
        }
	SC::Server->this_server->queue_request(
		'facility_tile', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'screen_shot', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'local_product', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'facility_damage_stat', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'facility_regulatory_level', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'facility_feature_shaking', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'facility_aebm', $self->shakemap_id, $self->shakemap_version);
	
	SC::Server->this_server->queue_request(
		'sc_pdf', $self->shakemap_id, $self->shakemap_version);
        foreach my $p (@$facpp) {
            # some pt features have only min
            $p->[3] = $p->[1] unless defined $p->[3];
            $p->[4] = $p->[2] unless defined $p->[4];
            #SC->log(4, sprintf("FacID: %d, bbox: %f9,%f9 - %f9,%f9", $p->[0], $p->[2], $p->[1], $p->[4], $p->[3]));
            my @summary;
            my $n = 0;
            for (my $row = _max(0, int(($lat_max-$p->[4]) * $rows_per_degree));
                    $row < $lat_cell_count; $row++) {
                last if int (($lat_max - $p->[2]) * $rows_per_degree) < $row;
                for (my $col = _max(0,int(($p->[1]-$lon_min) * $cols_per_degree));
                        $col < $lon_cell_count; $col++) {
                    last if int (($p->[3] - $lon_min) * $cols_per_degree) < $col;
                    $cell_no = $row * $lon_cell_count + $col;
                    #SC->log(4, sprintf("row=%d,col=%d,v0=%f",$row,$col,$cells[$cell_no][0]));
                    if (@summary) {
                        for (my $i = 0; $i <= $#summary; $i++) {
                            $summary[$i] = _max($summary[$i],
                                                $cells[$cell_no][$i]);
                        }
                    } else {
                        @summary = @{$cells[$cell_no]}[@data_fields];
                    }
                    $n++;
                }
            }
            if ($n == 0) {
                # XXX should never happen
                SC->log(0, "no cell for facility $p->[0]");
                next;
            } else {
		# read all the facilities that overlap the grid
		my $fac_metric = SC->dbh->selectall_arrayref(qq{
			select metric
			  from facility_fragility_model
			 where facility_id = ?
			 group by metric}, undef, $p->[0]);
			 
			 
			# print $p->[0]," $fac_metric\n";
		foreach my $m (@$fac_metric) {
			my $m_val = $summary[$metric_column_map{$m->[0]}-1];
			$sth_prob->execute($grid_id, $m->[0], $p->[0], $m->[0], $m_val, $m_val)
				if (grep /$m->[0]/, @grid_metric);
		}
            }
        }
	SC::Server->this_server->queue_request(
		'facility_fragility_stat', $self->shakemap_id, $self->shakemap_version);
	
        SC->log(2, "grid probability processing complete");
    };
    if ($@) {
	$SC::errstr = $@;
	$rc = 0;
	eval {
	    SC->dbh->rollback;
	};
	# Throw away any error message resulting from the rollback since
	# it would mask the original error (and mysql always complains
	# about not being able to roll back).
    } else {
	SC->dbh->commit;
	$rc = 1;
    }
    return $rc;
}


sub process_info_file {
    my $self = shift;
    my ($sth, $rc, $grid_id);

    undef $SC::errstr;
    if ($self->{'product_type'} ne 'INFO_XML') {
	$SC::errstr = 'not a stationlist xml file';
	return 0;
    } elsif (!$self->{'product_file_exists'} ||
	    not -f $self->abs_file_path) {
	$SC::errstr = 'local file not found';
	return 0;
    }
	
	my $count = SC->dbh->selectrow_array(qq/
	    select count(*)
	      from shakemap_parameter
	     where shakemap_id=?
	       and shakemap_version=?/,
	    undef,
	    $self->{'shakemap_id'},
	    $self->{'shakemap_version'});
	if ($count > 0) {
            SC->log(3, 'info xml already loaded');
            return 1;
        }

    my $xml = SC->xml_in($self->abs_file_path);
	if (!$xml) {
		$SC::errstr = "Couldn't parse ".$self->abs_file_path;
		return 0;
	}
	
	my $tag = $xml->{'info'}->{'tag'};
	$tag->{'mean_uncertainty'}->{'value'} = undef 
		unless ($tag->{'mean_uncertainty'}->{'value'} =~ /\d/);
	my $result = SC->dbh->do(qq{
		insert into shakemap_parameter (
		shakemap_id, shakemap_version, src_mech, faultfiles, 
		site_correction, sitecorr_regime, pgm2mi, miscale,
		mi2pgm, gmpe, bias, bias_log_amp, ipe, mi_bias, 
		mean_uncertainty, grade, receive_timestamp)
		  values (
		?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)}, {},
		$self->{'shakemap_id'},
		$self->{'shakemap_version'}, 
		$tag->{'src_mech'}->{'value'},
		$tag->{'faultfiles'}->{'value'},
		$tag->{'site_correction'}->{'value'},
		$tag->{'sitecorr_regime'}->{'value'},
		$tag->{'pgm2mi'}->{'value'},
		$tag->{'miscale'}->{'value'},
		$tag->{'mi2pgm'}->{'value'},
		$tag->{'GMPE'}->{'value'},
		$tag->{'bias'}->{'value'},
		$tag->{'bias_log_amp'}->{'value'},
		$tag->{'IPE'}->{'value'},
		$tag->{'mi_bias'}->{'value'},
		$tag->{'mean_uncertainty'}->{'value'},
		$tag->{'grade'}->{'value'},
		SC->time_to_ts);
		SC->log(3, "load info_xml");
		
	return 1;
}


sub process_station_file {
    my $self = shift;
    my ($sth, $rc, $grid_id);

    eval {
	use Shake::Source;
	use Shake::Station;
	use Shake::DataArray;
    };
    if ($@) {
	$SC::errstr = $@;
	return 0;
    }

    undef $SC::errstr;
    if ($self->{'product_type'} ne 'STN_XML') {
	$SC::errstr = 'not a stationlist xml file';
	return 0;
    } elsif (!$self->{'product_file_exists'} ||
	    not -f $self->abs_file_path) {
	$SC::errstr = 'local file not found';
	return 0;
    } else {
	# see if we already loaded the grid, and just return success if so
 	$grid_id = SC->dbh->selectrow_array(qq/
	    select grid_id
	      from grid
	     where shakemap_id=?
	       and shakemap_version=?/,
	    undef,
	    $self->{'shakemap_id'},
	    $self->{'shakemap_version'});
	if ($grid_id <= 0) {
            SC->log(3, 'grid needs to be loaded before station.');
            return 0;
    }
		
	my $count = SC->dbh->selectrow_array(qq/
	    select count(*)
	      from station_shaking
	     where grid_id=?/, undef, $grid_id);
	if ($count > 0) {
            SC->log(3, 'station list already loaded');
            return 1;
        }
   }

	my $data = DataArray->new($self->abs_file_path);
	if (!$data) {
		$SC::errstr = "Couldn't parse ".$self->abs_file_path;
		return 0;
	}
	
	my $src = $data->source;
	my $sta_arr = $data->stations();
	my ($sta, $lon, $lat, $netid, $code, $agency, $name, $comm_type);
	my %params = ("acc" => 1, "vel"=>2, "psa03"=>4, "psa10"=>5, "psa30"=>6);
	for (my $i = 0; $i < @$sta_arr; $i++) {
    #print "Plotting station $i. ";
		$sta = $sta_arr->[$i];
		$lon = $sta->lon();
		$lat = $sta->lat();
		$netid = $sta->netid();
		$code = $sta->code();
		$agency = $sta->agency();
		$name = $sta->name();
		$comm_type = $sta->comm_type();
	
		next if ($netid =~ /CIIM/i);
		next unless ($lon and $lat);
	
		my $count = SC->dbh->selectrow_array(qq/
			select count(*)
			  from station
			 where station_network=?
			   and external_station_id=?/,
			undef,
			$netid,
			$code);
		if ($count == 0) {
		my $result = SC->dbh->do(qq{
			insert into station (
			station_network, external_station_id,station_name, source, 
			commtype, latitude, longitude, update_timestamp)
			  values (
			?,?,?,?,?,?,?,?)}, {},
			$netid, $code, $name, $agency, $comm_type, $lat, $lon, SC->time_to_ts);
			SC->log(3, "load station information for $netid-$code");
		}
		
		my ($station_id) = SC->dbh->selectrow_array(qq/
				select station_id
				  from station
				 where station_network = ?
				   and external_station_id = ?/, {},
			$netid, $code);
		next unless ($station_id);

		#-----------------------------------------------------------------------
		# The output of mapproject must correspond one-for-one with
		# the station array, so rather than do a tricky two-index thing
		# when we write them out below, we just project all of the stations 
		# here, before the lat/lon test a couple of lines below...
		#-----------------------------------------------------------------------
		my (@sta_params, @fields);
		foreach my $param ( keys %params ) {
		  if (defined $sta->mean($param)) {
			push @sta_params, sprintf("%12.5f",$sta->mean($param));
			push @fields, "value_".$params{$param};
		  }
		}
		if (scalar @fields > 0) {
		my $sql =  "insert into station_shaking (station_id, grid_id," .
			join(',', @fields) . ") values (?,?," .
			join(',', ('?') x scalar @fields) . ")";
		my $sth_i = SC->dbh->prepare($sql);
		$sth_i->execute($station_id, $grid_id, @sta_params);
		}
	}
	return 1;
}


sub get_facilities_in_grid {
   
}


sub _min {
    (defined $_[0] && (!defined $_[1] || $_[0] <= $_[1])) ? $_[0] : $_[1];
}

sub _max {
    (defined $_[0] && (!defined $_[1] || $_[0] >= $_[1])) ? $_[0] : $_[1];
}

sub process_new_product {
    my ($self, $sender) = @_;

    SC->log(2, "process new product", $self->as_string);

    # Add it to the database.
    my $write_status = $self->write_to_db;

    if ($write_status == 0) {
	SC->error("writing product record: $SC::errstr");
	return 0;
    } elsif ($write_status == 2) {
	# product already exists, do nothing
	return 1;
    } elsif ($write_status == 1) {
	# A new product record (might be a new version of an existing product)
	
	# Attemp to remove worker
    $self->set_file_exists;
    SC->log(2, "got the file");
    if ($self->product_type eq 'GRID') {
		#if ($self->process_grid_file) {
		#	SC->log(2, "grid file processed");
		#} else {
		#	SC->error($SC::errstr);
			# XXX might not be correct.  Even though we got an error while
			# processing the grid we might want to push the file downstream.
			# Probably we should NOT inform the notifier, though, since the
			# grid hasn't been loaded into the database.
		#	return 0;
		#}
    } elsif ($self->product_type eq 'GRID_XML') {
		if ($self->process_grid_xml_file) {
			SC->log(2, "xml grid file processed");
			#SC::Server->this_server->queue_request(
			#	'notifyqueue', $self->shakemap_id, $self->shakemap_version);
    		} else {
			SC->error($SC::errstr);
			# XXX might not be correct.  Even though we got an error while
			# processing the grid we might want to push the file downstream.
			# Probably we should NOT inform the notifier, though, since the
			# grid hasn't been loaded into the database.
			return 0;
		}
	} elsif ($self->product_type eq 'STN_XML') {
		if ($self->process_station_file) {
			SC->log(2, "station file processed");
		} else {
			SC->error($SC::errstr);
			# XXX might not be correct.  Even though we got an error while
			# processing the grid we might want to push the file downstream.
			# Probably we should NOT inform the notifier, though, since the
			# grid hasn't been loaded into the database.
			return 0;
		}
	} elsif ($self->product_type eq 'INFO_XML') {
		if ($self->process_info_file) {
			SC->log(2, "info xml file processed");
		} else {
			SC->error($SC::errstr);
			# XXX might not be correct.  Even though we got an error while
			# processing the grid we might want to push the file downstream.
			# Probably we should NOT inform the notifier, though, since the
			# grid hasn't been loaded into the database.
			return 0;
		}
	}

	#eval {
            # retrieve product file from sender.  When we have the file
            # locally we will propagate the product to downstream servers.

            # If the dispatcher is not running this will fail.  However,
            # from the upstream server's perspective this is not an error,
            # so catch any problems, log them, and return success.
    #        $sender->queue_request(
    #            'get_file_for_product', $self->product_id);
    #    };
	#if ($@) {
	#    chomp $@;
	#    SC->error("$@ [Maybe the dispatcher service is not running?]");
	#}
    } else {
	SC->error("unknown status $write_status from product->write_to_db");
	die $SC::errstr;
    }
    return 1;
}

1;


__END__

=head1 NAME

SC::Product - a ShakeCast product

=head1 DESCRIPTION

Each C<SC::Product> object defines one ShakeCast product.  It is not necessary
for the product file itself to be present locally in order for a C<SC::Product>
record to exist.

=head1 METHODS

=head2 Class Methods

=over 4

=back

=head2 Instance Methods

=over 4

=back

=cut
