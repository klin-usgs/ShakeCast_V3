#!/ShakeCast/perl/bin/perl
# $Id: tester.pl 64 2007-06-05 14:58:38Z klin $

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


use warnings;

use strict;

use Carp;

use CGI;

use DBI;

use SC;
use SC::Event;
use SC::Product;
use SC::Server;
use SC::Shakemap;

use File::Basename;
use File::Copy;
use File::Path;

sub dbquit;
sub pr;
sub quit;

my @product_types = qw(
    GRID HAZUS SHAPE STN_TXT STN_XML
    INTEN_JPG INTEN_PS
    PGA_JPG PGA_PS PGV_JPG PGV_PS
    PSA03_JPG PSA03_PS PSA10_JPG PSA10_PS PSA30_JPG PSA30_PS
    CONT_PGA CONT_PGV CONT_PSA03 CONT_PSA10 CONT_PSA30
    EVT_TXT TV_TXT TV_PS TV_JPG TVBARE_PS TVBARE_JPG);

my $VERSION = '0.1.0';
my $TABLE_ATTRS = "border=1 bordercolor=black cellpadding=5 cellspacing=0";

SC->initialize() or quit $SC::errstr;

my $config = SC->config;

my $dbh = SC->dbh;

my $script = $ENV{SCRIPT_NAME};

my $TOP = <<__EOF__
<font size=-1>
<a href="$script">Tester Home</a> |
<a href="/scripts/c/admin/admin.pl">Admin Home</a>
</font>
__EOF__
    ;

my $BOTTOM = <<__EOF__
<p>
<hr>
<center>
<font size=-1>
<a href="$script">Tester Home</a>
</font>
</center>
__EOF__
    ;


my $type;

my ($page_started, $page_ended);



my $q = new CGI;

my $event_layout =
    ['ID'       => 'EVENT_ID',
     'Date'     => 'EVENT_TIMESTAMP',
     'Mag'      => 'MAGNITUDE',
     'Lat'      => 'LAT',
     'Lon'      => 'LON',
     'Location' => 'EVENT_LOCATION_DESCRIPTION'];


my $test_dir = SC->config->{'RootDir'} . '/test_data';

if ($type = $q->param('type')) { process_by_type() }
else { gen_base_page() }

end_page();

exit;


#
### Main Processing Functions
#

sub gen_base_page {
    start_page('ShakeCast Local Tests');
    pr qq[<a href="$script?type=event_menu">Generate Local Event</a>];
    pr qq[<p><a href="$script?type=new_test">Create New Test Event</a>];
    pr qq[<p>[<font size=-1>Version: $VERSION</font>]];
}


sub process_by_type {
    if ($type eq 'event_menu') { event_menu() }
    elsif ($type eq 'new_test') { new_test() }
    elsif ($type eq 'create_test') { create_test() }
    elsif ($type eq 'inject_next') { inject_next() }
    elsif ($type eq 'inject_first') { inject_first() }
    else { quit "Invalid type request: [$type]" }
}

sub event_menu {
    start_page('Generate Local Test Event');
    pr "<table $TABLE_ATTRS>";
    pr '<tr>' . join('', (map qq{<th>$_</th>},
            qw(ID Mag Lat Lon Description &nbsp; &nbsp;))) . '</tr>';
    foreach my $event (get_test_events()) {
        my $a1 = "<a href=$script?type=inject_first;event_id=".
                $event->event_id.">version 1</a>";
        my $a2 = "<a href=$script?type=inject_next;event_id=".
                $event->event_id.">version N+1</a>";
        pr '<tr>' . join('', (map qq{<td>$_</td>},
                ($event->event_id, $event->magnitude, $event->lat,
                    $event->lon,
                    $event->event_location_description, $a1, $a2))) .'</tr>';
    }
    pr '</table>';
}

sub inject_first {
    my $event_id = $q->param('event_id');
    quit("No event id specified") unless $event_id;
    my $event = inject_test($event_id, 1);
    start_page('Local Test Injected');
    pr $event->as_string . ' has been created';
}

sub inject_next {
    my $event_id = $q->param('event_id');
    quit("No event id specified") unless $event_id;
    my $event = inject_test($event_id, 0);
    start_page('Local Test Injected');
    pr $event->as_string . ' has been created';
}

sub new_test {
	my $skip = $q->param('skip') || 0;  #kwl
	my $order = $q->param('order') || 'EVENT_TIMESTAMP';  #kwl

    start_page('Create New Test Event');
    show_table('EVENT', qq/WHERE SUPERCEDED_TIMESTAMP IS NULL AND EVENT_TYPE <> 'TEST'/, $order,
               $event_layout, $skip,  # kwl
               ['add', 'create_test', 'EVENT_ID']);
}

sub create_test {
    check_test_dir();
    my $event_id = $q->param('key');
    my $template_dir = "$test_dir/${event_id}_scte";
    if (-d $template_dir) {
        quit "Test template already exists for ID ${event_id}_scte";
    }
    mkdir $template_dir or quit("Could not create $template_dir: $!");
    my $event = SC::Event->current_version($event_id);
    quit "No event with ID $event_id" unless $event;
    my $xml = make_test_xml($event->to_xml);
    open OUT, "> $template_dir/event_template.xml" or quit "Can't create : $!";
    print OUT "$xml\n";
    close OUT;
    my $shakemap = SC::Shakemap->current_version($event_id);
    quit "No shakemap with ID $event_id" unless $shakemap;
    $xml = make_test_xml($shakemap->to_xml);
    open OUT, "> $template_dir/shakemap_template.xml" or quit "Can't create : $!";
    print OUT "$xml\n";
    close OUT;
    my @products = SC::Product->current_version($event_id);
    quit $SC::errstr if $SC::errstr;
    quit "No products" unless @products > 0;
    $xml = make_test_xml($products[0]->to_xml);
    open OUT, "> $template_dir/product_template.xml" or quit "Can't create : $!";
    print OUT "$xml\n";
    close OUT;
    foreach my $product (@products) {
        copy $product->abs_file_path, $template_dir;
    }
    start_page("New Test Event Generated");
}



sub make_test_xml {
    my ($xml) = @_;
    $xml =~ s/event_id="([^"]+)"/event_id="$1_scte"/gm;
    $xml =~ s/shakemap_id="([^"]+)"/shakemap_id="$1_scte"/gm;
    $xml =~ s/event_version="([^"]+)"/event_version="?event_version"/gm;
    $xml =~ s/shakemap_version="([^"]+)"/shakemap_version="?event_version"/gm;
    $xml =~ s/event_type="[^"]+"/event_type="TEST"/gm;
    $xml =~ s/product_type="[^"]+"/product_type="?product_type"/gm;
    return $xml;
}

sub check_test_dir {
    unless (-d $test_dir) {
        mkdir $test_dir or quit("Could not create $test_dir\: $!");
    }
}

sub get_test_events {
    my @test_events;
    my $xml;

    check_test_dir();
    opendir TESTDIR, $test_dir or quit("Can't open $test_dir\: $!");
    # exclude .* files
    my @files = grep !/^\./, readdir TESTDIR;
    # exclude non-directories
    my @dirs = grep -d, map "$test_dir/$_", @files;
    foreach my $dir (@dirs) {
        $dir =~ m#([^/\\]+$)#;     # last component only
        $xml = read_xml($1, 'event');
        SC->log(4, "event XML: $xml");
        $xml =~ s/\?event_version/1/g;
        SC->log(4, "event XML: $xml");
        eval {
            my $event = SC::Event->from_xml($xml)
                or quit("Can't instantiate Event: $SC::errstr");
            push @test_events, $event;
        };
        quit($@) if $@;
    }
    return @test_events;
}
    
sub read_xml {
    my ($event_id, $type) = @_;

    my $fname = "$test_dir/$event_id/${type}_template.xml";
    open XML, "< $fname" or quit("Can't open XML template $fname\: $!");
    my @lines = <XML>;
    close XML;
    chomp @lines;
    return join(' ', @lines);
}



#
### Support Functions
#

sub dbquit {
    quit "Database Error: ", @_, ": ", $DBI::errstr;
}


sub end_page {
    if ($page_started and !$page_ended) {
	print $BOTTOM;
	my $footer = $config->{TemplateDir}.'/web/footer.htm';
	if (-e $footer) {
		open (TEMP, "< $footer") or quit "Can't open $footer: $!";
		print <TEMP>;
		close(TEMP);
	} else {
	print <<__EOF__;
</body>
</html>
__EOF__
    ;
	}
	$page_ended = 1;
    }
}



sub make_lookup_value {
    my ($val, $lookup) = @_;
    my $v;

    my ($table, $fval, $fshow) = split /,/, $lookup;
    if ($table eq '*BOOL') {
	if (nz($val)) { $v = $fshow }
	else { $v = $fval }
    }
    elsif ($val) {
        $table = lc $table;
	$fval ||= $table;
	$fshow ||= $fval;
	my $sql = qq[SELECT $fshow FROM $table WHERE $fval = ?];
	my $sth = $dbh->prepare($sql) or dbquit "Can't prepare make_lookup_value";
	$sth->execute($val) or dbquit "Can't execute make_lookup_value ($sql)(.$val.)";
	my $r = $sth->fetchrow_arrayref;
	$sth->finish;
	if ($r) { $v = $r->[0] }
    }
    return $v;
}


sub nbs_null {
    $_[0] ? $_[0] : '&nbsp;';
}


sub ns {
    $_[0] ? $_[0] : '';
}


sub nz {
    $_[0] ? $_[0] : 0;
}


sub pr {
    start_page() unless $page_started;
    print @_, "\n";
}


sub quit {
    start_page("ShakeCast Administration Error");
    pr "<font color=red size=+2><b>", @_, "</b></font>";
    pr "<p><hr>";
    end_page();
    exit;
}


sub show_table {
    my ($table, $where, $order, $fp, $row_skip, @links) = @_;
    my (@names, @fields, %fmap);
	my $row_page = 20;
	my $target_url = qq[$script?type=$type\&order=$order];

    $table = lc $table;
    my $nrows = 0;
    my @list = @$fp;
    while (my $p = shift @list) {
	push @names, $p;
	my $f = shift(@list);
	my ($fname, $rest) = split /\//, $f;
	push @fields, $fname;
	$fmap{$fname} = $rest if $rest;
    }
    my $sql = "SELECT " . join(',', @fields) . " FROM $table";
    $sql .= " $where" if $where;
    $sql .= " ORDER BY $order" if $order;

    my $sth = $dbh->prepare($sql) or dbquit("Can't prepare table selection");
#	$sth->mysql_use_result();
    $sth->execute or dbquit("Can't execute table selection");
	my $rows = $sth->rows;

    while (my $r = $sth->fetchrow_hashref) {
	unless ($nrows++) {
	    pr "<table $TABLE_ATTRS><tr>";
		for my $ind (0 .. $#names) {
	      pr qq[<td><font size=-1><a href="$script?type=$type\&order=], $fields[$ind];
		  pr qq[">],$names[$ind], qq[</a></td>];
		  #my $s =  "<td><font size=-1>" . join('</td><td><font size=-1>', @names);  #kwl
		} 
	    pr "<td>&nbsp;</td>" x @links;  #kwl
	    pr '</tr>';  #kwl
	}
	  next unless ($nrows > $row_skip);
	  last if ($nrows > $row_page+$row_skip);
#	my $line = "<tr>";
	my $line = "<tr>";
	foreach my $fname (@fields) {
	    my $val = $r->{$fname};
	    if (exists $fmap{$fname}) {
		$line .= "<td><font size=-1>" . nbs_null(make_lookup_value($val,
							     $fmap{$fname})) . '</td>';
	    }
	    else {
		my $v = nbs_null($val);
		$line .= "<td><font size=-1>$v</td>";
	    }
	}
	foreach my $lp (@links) {
	    my ($text, $type, @keystrs) = @$lp;
	    if (ref($text) eq 'CODE') { $line .= &$text($r, $type, @keystrs) }
	    else {
		my $parms = '';
		foreach my $keystr (@keystrs) {
		    my ($keyname, $keyval) = split /=/, $keystr;
		    if ($keyval) {
			if ($keyval =~ s/^~//) { $keyval = $r->{$keyval} }
		    }
		    else {
			$keyval = $r->{$keyname};
			$keyname = 'key';
		    }
		    $parms .= ";$keyname=$keyval";
		}
		my $s = qq[<td><font size=-1><a href="$script?type=$type$parms">$text</a></td>];
		$line .= $s;
	    }
	}
	pr $line, '</tr>';
    }
    pr "</table>";
    pr "<p>";
    if ($nrows == 0) { pr "<b>There were no matching entries.</b>" }
    elsif ($nrows == 1) { pr "One matching entry." }
    else { 
	  pr "<font size=-2>$rows matching entries.<br><center>";
	    #kwl start
	  my $start_ind = int($row_skip / ($row_page*10)) * ($row_page*10);
	  my $jump_ind = $start_ind - ($row_page*10);
	  if ($jump_ind >= 0) {
	    pr qq[<font size=-1><a href="$target_url\&skip=$jump_ind"><<</a> | ];
	  }
	  if ($row_skip-$row_page >= 0) {
	    pr qq[<font size=-1><a href="$target_url\&skip=],$row_skip-$row_page,
		  qq[">Previous</a> ];
	  }
	  for (my $ind = 1; $ind <= 10; $ind++) {
	    my $show_ind = $start_ind + ($ind-1)*$row_page;
		if ($show_ind < $rows) {
	    pr qq[<font size=-1><a href="$target_url\&skip=$show_ind">], 
			$ind+$start_ind/$row_page, qq[</a> ];
	    }
	  }
	  if ($row_skip+$row_page <= $rows) {
	    pr qq[<font size=-1><a href="$target_url\&skip=],$row_skip+$row_page,
		  qq[">Next</a> ];
	  }
	  $jump_ind = $start_ind + ($row_page*10);
	  if ($jump_ind < $rows) {
	    pr qq[ | <a href="$target_url\&skip=$jump_ind">>></a> ];
	  }
	    #kwl end
	  }
}



sub start_page {
    my $title = shift;

    $title ||= 'ShakeCast Administration';
    unless ($page_started) {
	print "Content-Type: text/html\n\n";
	my $header = $config->{TemplateDir}.'/web/header.htm';
	if (-e $header) {
		open (TEMP, "< $header") or quit "Can't open $header: $!";
		print <TEMP>;
		close(TEMP);
	} else {
	print <<__EOF__;

<html>
<head>
<title>$title</title>
</head>
<body>
__EOF__
    ;
	}
	print "$TOP\n<h2>$title</h2>";
	$page_started = 1;
    }
}


sub ts {
    my $time = shift;
    my($sec, $min, $hr, $mday, $mon, $yr);

    $time = time unless defined $time;
    ($sec, $min, $hr, $mday, $mon, $yr) = localtime $time;
    sprintf ("%04d-%02d-%02d %02d:%02d:%02d",
	     $yr+1900, $mon+1, $mday,
	     $hr, $min, $sec);
}



sub inject_test {
    my ($event_id, $initial_version) = @_;
    my $xml;
    my $event_version;
    my $event;
    my $product_dir;

    # see if this event already exists in the database
    $event = SC::Event->current_version($event_id);
    if ($event) {
        if ($initial_version) {
            # must delete any existing events and related data
            SC::Event->erase_test_event($event_id) or quit $SC::errstr;
            $event_version = 1;
        } else {
            # create next version
            $event_version = $event->event_version + 1;
        }
    } else {
        $event_version = 1;
    }

    $xml = read_xml($event_id, 'event') or quit "Can't get Event XML";
    $xml =~ s/\?event_version/$event_version/g;
    $event = SC::Event->from_xml($xml) or die $SC::errstr;
    $event->event_type("TEST"); # make sure it is a TEST!
    $event->process_new_event or die $SC::errstr;
    $xml = read_xml($event_id, 'shakemap') or quit "Can't get Shakemap XML";
    $xml =~ s/\?event_version/$event_version/g;
    SC::Shakemap->from_xml($xml)->process_new_shakemap or die $SC::errstr;
    $xml = read_xml($event_id, 'product') or quit "Can't get Product XML";
    foreach my $product_type (@product_types) {
        #next;   # temporarily skip products
        my $xml2 = $xml;
        my $product;
        $xml2 =~ s/\?event_version/$event_version/g;
        $xml2 =~ s/\?product_type/$product_type/g;
        SC->log(4, $xml2);
        $product = SC::Product->from_xml($xml2) or die $SC::errstr;
        unless ($product_dir) {
            $product_dir = $product->dir_name;
            SC->log(4, "product dir: $product_dir");
            unless (-d $product_dir) {
                eval { mkpath($product_dir) };
                SC->log(4, "mkpath product dir: $product_dir");
                quit "Can't mkdir $product_dir\: $@" if $@;
            }
        }
        SC->log(4, 'product',$product->file_name,
                   'exists:',$product->product_file_exists);
        unless ($product->product_file_exists) {
            my $src = $test_dir.'/'.$product->shakemap_id.'/'.$product->file_name;
            SC->log(4, "copy from $src");
            if (-r $src) {
                copy($src, $product_dir) or SC->log(0,"Copy $src failed: $!");
            } else {
                SC->log(0, "missing product file $src");
            }
        }
        $product->process_new_product(SC::Server->this_server)
            or die $SC::errstr;
    }
    return $event;
}

#####
