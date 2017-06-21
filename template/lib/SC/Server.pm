
# $Id: Server.pm 441 2008-08-14 18:54:49Z klin $

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

package SC::Server;

$^W = 1;

use SC;

# cache the server_id for the local server (won't change)
my $local_server_id;

my $SCRIPTLOC = '/scripts/s';
my $USER_AGENT = "ShakeCast/$SC::VERSION";


# ======================================================================
# Class methods

sub local_server_id {
    my $class = shift;
    if (@_) {
        $local_server_id = shift;
    } elsif (not defined $local_server_id) {
	eval {
	    $local_server_id = SC->dbh->selectrow_array(qq/
		select server_id
		  from server
		 where self_flag = 1/); 
	};
	$SC::errstr = $@ if $@;
    }
    return $local_server_id;
}
 
sub this_server {
    my $class = shift;

    undef $SC::errstr;
    my $server;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
	    select *
	      from server
	     where self_flag = 1/);
	$sth->execute;
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    if ($server) {
		$SC::errstr = "Multiple servers claiming to be self";
		return undef;
	    } else {
		$server = new SC::Server(%$p);
	    }
	}
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    } elsif ($sth->rows == 0) {
	$SC::errstr = "No server for self";
    }
    return $server;
}

sub from_id {
    my ($class, $server_id) = @_;

    undef $SC::errstr;
    my $server;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
	    select *
	      from server
	     where server_id = ?/);
	$sth->execute($server_id);
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    if ($server) {
		$SC::errstr = "Duplicate server_id $server_id";
		return undef;
	    } else {
		$server = new SC::Server(%$p);
	    }
	}
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    } elsif ($sth->rows <= 0) {
	$SC::errstr = "No server for server_id $server_id";
    }
    return $server;
}

sub upstream_servers {
    my $class = shift;
    my @servers = ();

    undef $SC::errstr;
    eval {
	my $sth = SC->dbh->prepare(qq/
	    select *
	      from server
	     where upstream_flag = 1/);
	$sth->execute;
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    push @servers, new SC::Server(%$p);
	}
    };
    $SC::errstr = $@, return () if $@;
    return @servers;
}

sub downstream_servers {
    my $class = shift;
    my @servers = ();

    undef $SC::errstr;
    eval {
	my $sth = SC->dbh->prepare(qq/
	    select *
	      from server
	     where downstream_flag = 1/);
	$sth->execute;
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    push @servers, new SC::Server(%$p);
	}
    };
    $SC::errstr = $@, return () if $@;
    return @servers;
}

# returns a list of all servers that should be polled for new events, etc.
sub servers_to_poll {
    my $class = shift;
    my @servers;

    undef $SC::errstr;
    eval {
	my $sth = SC->dbh->prepare(qq/
	    select *
	      from server
	     where poll_flag = 1/);
	$sth->execute;
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    push @servers, new SC::Server(%$p);
	}
    };
    $SC::errstr = $@, return () if $@;
    return @servers;
}


sub BEGIN {
    no strict 'refs';
    # Not all attributes have method accessors.  I am only generating those
    # that are used within the application.
    for my $method (qw(
			server_id dns_address ip_address 
			password server_status
                        event_hwm shakemap_hwm product_hwm
			)) {
	*$method = sub {
	    my $self = shift;
	    @_ ? ($self->{$method} = shift, return $self)
	       : return $self->{$method};
	}
    }
}


sub new {
    my $class = shift;
    my $self = bless {} => $class;
    # what was I thinking of here...
    # $self->receive_timestamp(SC::Util::time_to_ts);
    Carp::carp "Odd (wrong?) number of parameters in new()" if $^W && (@_ & 1); 
    while (@_) {
	my $method = shift; 
	my $value = shift;
	$self->can($method) ? $self->$method($value)
			    : ($self->{$method} = $value);
    }
    return $self;
}

# ======================================================================
# Instance methods

sub as_string {
    my $self = shift;
    return sprintf "ID=%d, DNS=%s, status=%s",
	map { defined $_ ? $_ : '' } (
	    $self->server_id,
	    $self->dns_address,
	    $self->server_status) ;
}

sub permitted {
    my ($self, $access) = @_;

    undef $SC::errstr;
    return $self->{'upstream_flag'}   if $access eq 'U';
    return $self->{'query_flag'}      if $access eq 'Q';
    return $self->{'downstream_flag'} if $access eq 'D';
    return $self->{'poll_flag'}       if $access eq 'P';
}

sub send {
    my ($self, $action, $content) = @_;
    my ($status, $message, $rv);

    # avoid sucking all this in for clients that don't need to send messages
    require LWP::UserAgent;
    require HTTP::Request;
    require MIME::Base64;

    my $url = 'http://' . $self->dns_address . "$SCRIPTLOC/$action.pl";
		
    SC->log(3, "server->send($url)");
    SC->log(3, "content:", $content);
    my $ua = new LWP::UserAgent();
    $ua->agent($USER_AGENT);
	$ua->proxy(['http'], SC->config->{'ProxyServer'})
		if (defined SC->config->{'ProxyServer'});
    my $req = new HTTP::Request(POST => $url ,undef, $content);
    my $pwd = (defined $self->password ?
	MIME::Base64::decode_base64($self->password) : '');
    $req->authorization_basic(SC::Server->local_server_id(), $pwd);

    my $resp = $ua->request($req);
    SC->log(3, "response:", $resp->status_line);
    if ($resp->is_success) {
	my $p;
	SC->log(3, "content:", $resp->content);
	eval {$p = SC->xml_in($resp->content)};
	# Reply should be an XML document whose root element is either
	# <shakecast_status> or <shakecast_response>.  The former is used
	# when there is no return other than status.  The latter includes
	# <shakecast_status> as one of its sub-elements, and <response_body>
	# as the other sub-element.
	if ($SC::errstr) {
	    # XML parse failed
	    $status = SC_BAD_XML;
	    $message = $SC::errstr;
	} elsif ($@) {
	    # XML parse failed
	    $status = SC_BAD_XML;
	    $message = "error parsing shakecast_response: $@";
	} elsif (exists $p->{'shakecast_response'}) {
	    # grab status sub-element
	    my $s = $p->{'shakecast_response'}->{'shakecast_status'};
	    $status = $s->{'status'};
	    $message = $s->{'content'};
	    $rv = $p->{'shakecast_response'}->{'response_body'} if $status eq SC_OK;
	} elsif (exists $p->{'shakecast_status'}) {
	    # just a status return with no payload
	    $status = $p->{'shakecast_status'}->{'status'};
	    $message = $p->{'shakecast_status'}->{'content'};
	} else {
	    $status = SC_UNKNOWN;
	    $message = 'No status returned';
	}
	$self->update_status(1);
	# TODO log the exchange
    } else {
	# TODO handle can't connect; retry with IP address
	$status = SC_HTTP_FAIL;
	$message = $resp->status_line;
	$self->update_status(0);
	# TODO log the exchange ?
	SC->log(2, "http failure: $message");
    }
    return ($status, $message, $rv);
}

# Returns a two-element list.  First element is return status: SC_OK,
# SC_FAIL, or SC_HTTP_FAIL.  Second element is detail message text.
# THe product can be specified either as a ref to a SC::Product or as the
# id of a product.
sub get_file {
    my ($self, $product) = @_;
    my @ret;

    unless (ref $product) {
	# assume we were passed an ID; look up the product
	my $id = $product;
        $product = SC::Product->from_id($id);
        if (not defined $product) {
	    return (SC_FAIL,($SC::errstr || "no product record for id=$id"));
	}
    }
    SC->log(3, "server->get_file:", $product->as_string);
    if (-f $product->abs_file_path) {
	# already have the file so we're done
	return (SC_OK, 'file already exists');
    } elsif ($self->server_id == SC::Server->local_server_id) {
        # trying to get the file from ourselves, which should only happen
        # when doing local testing and the file is missing.  Treat as a
        # failure.
        return (SC_FAIL, 'get from self but file does not exist');
    }

    # avoid sucking all this in for clients that don't need to send messages
    eval {
	require LWP::UserAgent;
	require HTTP::Request;
	require MIME::Base64;
    };

    my $ua = new LWP::UserAgent();
    $ua->agent($USER_AGENT);
	$ua->proxy(['http'], SC->config->{'ProxyServer'})
		if (defined SC->config->{'ProxyServer'});
    my $url = 'http://' . $self->dns_address . 
	    "$SCRIPTLOC/product_file.pl" .
	    '?ID=' . $product->shakemap_id .
	    ';VER=' . $product->shakemap_version .
	    ';NAME=' . $product->file_name;
    my $req = new HTTP::Request(GET => $url);
    my $pwd = (defined $self->password ?
	MIME::Base64::decode_base64($self->password) : '');
    $req->authorization_basic(SC::Server->local_server_id(), $pwd);

    my $resp = $ua->request($req);
    SC->log(3, "response:", $resp->status_line);
    if ($resp->is_success) {
	if (length $resp->content > 0) {
	    my $fn = $product->abs_file_path;
	    $fn =~ s#/[^/]*$##;
	    unless (-d $fn) {
		mkdir $fn or return (SC_FAIL, "Local dir create failed: $!");
	    }
	    my $fh = new IO::File($product->abs_file_path, 'w');
	    if (not defined $fh) {
		return (SC_FAIL, "Local file create failed: $!");
	    }
	    binmode $fh;
	    $fh->write($resp->content, length $resp->content);
	    $fh->close;	    
	    @ret = (SC_OK, '');
	} else {
	    @ret = (SC_FAIL, 'remote file not present');
	}
	# considered a success as far as server status is concerned because
	# we successfully communicated with the remote server
	$self->update_status(1);
    } else {
	# TODO handle can't connect; retry with IP address
	@ret = (SC_HTTP_FAIL, $resp->status_line);
	$self->update_status(0);
	# TODO log the exchange ?
	SC->log(0, "http failure:", $resp->status_line);
    }
    return @ret;
}

sub update_event_hwm {
    my ($self, $hwm) = @_;

    undef $SC::errstr;
    $self->event_hwm($hwm);
    eval {
        SC->dbh->do(qq/
            update server
               set event_hwm = ?
             where server_id = ?/, undef,  $hwm, $self->server_id);
	SC->dbh->commit;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub update_shakemap_hwm {
    my ($self, $hwm) = @_;

    undef $SC::errstr;
    $self->shakemap_hwm($hwm);
    eval {
        SC->dbh->do(qq/
            update server
               set shakemap_hwm = ?
             where server_id = ?/, undef,  $hwm, $self->server_id);
	SC->dbh->commit;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub update_product_hwm {
    my ($self, $hwm) = @_;

    undef $SC::errstr;
    $self->product_hwm($hwm);
    eval {
        SC->dbh->do(qq/
            update server
               set product_hwm = ?
             where server_id = ?/, undef,  $hwm, $self->server_id);
	SC->dbh->commit;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub update_status {
    my ($self, $ok) = @_;

    undef $SC::errstr;
    return 1 if not defined SC->dbh;
    eval {
	if ($ok) {
	    SC->dbh->do(qq/
		update server
		   set last_heard_from = $SC::to_date,
		       error_count = 0,
                       server_status = 'ALIVE'
		 where server_id = ?/, {}, SC->time_to_ts(), $self->server_id);
	} else {
	    SC->dbh->do(qq/
		update server
		   set error_count = error_count + 1,
                       server_status = 'UNKNOWN'
		 where server_id = ?/, {}, $self->server_id);
	}
	SC->dbh->commit;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub update_hwms {
    my ($self, $e_hwm, $s_hwm, $p_hwm) = @_;
    my $changed = 0;

    undef $SC::errstr;
    $self->event_hwm($e_hwm),    $changed++ if $self->event_hwm != $e_hwm;
    $self->shakemap_hwm($s_hwm), $changed++ if $self->shakemap_hwm != $s_hwm;
    $self->product_hwm($p_hwm),  $changed++ if $self->product_hwm != $p_hwm;
    return 1 unless $changed;
    eval {
	SC->log(2, "event_hwm: $e_hwm, shakemap_hwm: $s_hwm, product_hwm: $p_hwm");
	SC->dbh->do(qq/
	    update server
	       set event_hwm = ?,
	           shakemap_hwm = ?,
	           product_hwm = ?
	     where server_id = ?/, {},
	    $self->event_hwm,
	    $self->shakemap_hwm,
	    $self->product_hwm,
	    $self->server_id);
	SC->dbh->commit;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub poll_for_updates {
    my $self = shift;

    require SC::Event;
    require SC::Shakemap;
    require SC::Product;

    # Query for updates
    # If we have not received anything from this server then limit time
    # so that only current things are delivered (we still will get the hwm
    # for each type).
    my $oldest = '';
    if (not $self->event_hwm) {
	$oldest = SC->time_to_ts();
    }

    my $e_hwm = $self->event_hwm;
    my $s_hwm = $self->shakemap_hwm;
    my $p_hwm = $self->product_hwm;

    # Build the query
    my $q_xml = qq{
<query event_hwm='$e_hwm' shakemap_hwm='$s_hwm' product_hwm='$p_hwm' oldest='$oldest' />};

    # send the query
    my ($status, $message, $rv) = $self->send('poll', $q_xml);
    if ($status ne SC_OK) {
        $SC::errstr = $message;
        return 0;
    }
    
    eval {
	# Instantiate new items
	die 'did not find query_result element'
	    unless exists $rv->{'query_result'};
	my $response = $rv->{'query_result'};
	my @items;
	if (exists $response->{'event'}) {
	    if (ref $response->{'event'} eq 'HASH') {
		@items = ($response->{'event'});
	    } else {
		@items = @{ $response->{'event'} };
	    }
	    SC->log(2, "poll got", scalar @items, "events");
	    foreach my $xml (@items) {
		SC::Event->new(%$xml)->process_new_event;
	    }
	}
	if (exists $response->{'shakemap'}) {
	    if (ref $response->{'shakemap'} eq 'HASH') {
		@items = ($response->{'shakemap'});
	    } else {
		@items = @{ $response->{'shakemap'} };
	    }
	    SC->log(2, "poll got", scalar @items, "shakemaps");
	    foreach my $xml (@items) {
		SC::Shakemap->new(%$xml)->process_new_shakemap;
	    }
	}
	if (exists $response->{'product'}) {
	    if (ref $response->{'product'} eq 'HASH') {
		@items = ($response->{'product'});
	    } else {
		@items = @{ $response->{'product'} };
	    }
	    SC->log(2, "poll got", scalar @items, "products");
	    foreach my $xml (@items) {
		SC::Product->new(%$xml)->process_new_product($self);
	    }
	}

	# Store new HWMs
	$self->update_hwms(
	    $response->{'event_hwm'},
	    $response->{'shakemap_hwm'},
	    $response->{'product_hwm'}) or die $SC::errstr;
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub queue_request {
    my ($self, $request, @args) = @_;

    require Dispatch::Client;

    Dispatch::Client::set_logger($SC::logger);

    Dispatch::Client::dispatch(
	SC->config->{'Dispatcher'}->{'RequestPort'},
	$request, $self->server_id, @args);    
}

# returns a list of all servers that should be polled for new events, etc.
sub servers_to_rss {
    my $class = shift;
    my @servers;

    undef $SC::errstr;
    eval {
	my $sth = SC->dbh->prepare(qq/
	    select *
	      from server
	     where query_flag = 1/);
	$sth->execute;
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    push @servers, new SC::Server(%$p);
	}
    };
    $SC::errstr = $@, return () if $@;
    return @servers;
}


sub rss_for_updates {
    my $self = shift;

    require SC::RSS;
    require SC::Event;

    # Query for updates
    # If we have not received anything from this server then limit time
    # so that only current things are delivered (we still will get the hwm
    # for each type).
    my $oldest = '';
    if (not $self->event_hwm) {
	$oldest = SC->time_to_ts();
    }

    my $e_hwm = $self->event_hwm;
    my $s_hwm = $self->shakemap_hwm;
    my $p_hwm = $self->product_hwm;
	my (%evt_list, $rss_log);
	# default 7-day cutoff time, maximum 30 for feed
	my $rss_window = (SC->config->{'rss'}->{'TIME_WINDOW'}) ? 
		SC->config->{'rss'}->{'TIME_WINDOW'} : 7;
	my $min_time = time() - $rss_window*86400;
	my $rss_dat = SC->config->{'DataRoot'}.'/'.$self->server_id.'_sm_rss.dat';
	if( -e $rss_dat)
	{
		open(SHAKE, "< $rss_dat");
		while (my $line = <SHAKE>) {
			chomp($line);
			my ($evt, $pubDate) = split /:/, $line;
			next unless ($pubDate > $min_time);
			$evt_list{$evt} = $pubDate;
		}
		close(SHAKE);
		$rss_log = 1;
	} else {
		$rss_log = 0;
	}

    # send the query
    my ($status, $message, $rv) = $self->rss_send();
    #if ($status ne SC_OK) {
        $SC::errstr = $message;
    #    return 0;
    #}

    my %archive_sm;

    eval {
	my $sth = SC->dbh->prepare(qq/
	    SELECT *
		FROM event e inner join shakemap s 
			on e.event_id = s.event_id and 
			e.event_version = s.event_version
		WHERE adddate( e.event_timestamp, 7 ) > now( )
		AND e.event_type = "actual"
		AND e.event_id NOT
		IN (
			SELECT event_id
			FROM event
			WHERE event_status = "cancelled"
		)
		GROUP BY e.event_id/);
	$sth->execute;
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
	    $archive_sm{$p->{external_event_id}} = $p;
	}
    };

    eval {
		# Instantiate new items
		die 'did not find ShakeMap RSS feed element'
			unless exists $rv->{'channel'};
		my $response = $rv->{'channel'};
		my @items;
		my $latest_eq = 0;
		if (exists $response->{'item'}) {
			if (ref $response->{'item'} eq 'HASH') {
				@items = ($response->{'item'});
			} else {
				@items = @{ $response->{'item'} };
			}
			SC->log(2, "poll got", scalar @items, "events");
			foreach my $xml (@items) {
				# Parse Event ID
				my $link = $xml->{'link'};
				$link =~ s/(index.php|intensity.html)$//i;
				$link =~ s/\/$//;
				my ($evid) = $link =~ /shake\/(.+)/;
				delete $archive_sm{$evid} if defined $archive_sm{$evid};
			
				my $pubDate = SC->ts_to_time($xml->{'pubDate'});
				$evt_list{$evid} = $pubDate unless ($rss_log);
				
				next unless ($rss_log && $pubDate > $min_time);
				next if (defined $evt_list{$evid} && $pubDate <= $evt_list{$evid});
				$latest_eq = $pubDate if ($pubDate > $latest_eq);
				SC->log(2, "new rss", $xml->{'title'});
				SC::RSS->new($xml)->process_new_rss;
				$evt_list{$evid} = $pubDate;
				#SC::RSS->new($xml);
			}
		}

		# Build the cancellation message
	    SC->log(2, "rss determined", scalar keys %archive_sm, "missing event(s)");
		foreach my $m (keys %archive_sm) {
			my $evid = $archive_sm{$m}->{event_id};
			SC->log(2, "shakemap id: ", $evid);
			#my $cmd = SC->config->{'RootDir'}."/bin/shake_fetch.pl -network query -event $evid -status -verbose";
			#my	$result = `perl $cmd`;
	
			#if ($?) {
			#	$archive_sm{$m}->{event_version} = $archive_sm{$m}->{event_version} + 1;
			#	my $xml = qq{
			#		<event event_id="$archive_sm{$m}->{event_id}" 
			#		event_version="$archive_sm{$m}->{event_version}" 
			#		event_status="CANCELLED" 
			#		event_type="$archive_sm{$m}->{event_type}" 
			#		event_name="$archive_sm{$m}->{event_name}" 
			#		event_location_description="$archive_sm{$m}->{event_location_description}" 
			#		event_timestamp="$archive_sm{$m}->{event_timestamp}" 
			#		external_event_id="$archive_sm{$m}->{external_event_id}" 
			#		magnitude="$archive_sm{$m}->{magnitude}" 
			#		lat="$archive_sm{$m}->{lat}" 
			#		lon="$archive_sm{$m}->{lon}" />};
			#	my $rv = SC->xml_in($xml)->{event};
			#	SC::Event->new(%$rv)->process_new_event;
			#	SC->log(2, "event $m cancelled");
			#}
		}

		# Store new HWMs
		my $timestamp = ($s_hwm > $latest_eq) ? $s_hwm : $latest_eq;
		$self->update_hwms(
			$s_hwm,
			$timestamp,
			$timestamp) or die $SC::errstr;
			
		open(SHAKE, "> $rss_dat");
		foreach my $key (keys %evt_list) {
			print SHAKE $key,':',$evt_list{$key},"\n";
		}
		close(SHAKE);
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub eq_csv_for_updates {
    my $self = shift;

    require SC::RSS;
    require SC::Event;

    # Query for updates
    # If we have not received anything from this server then limit time
    # so that only current things are delivered (we still will get the hwm
    # for each type).
    my $oldest = '';
    if (not $self->event_hwm) {
	$oldest = SC->time_to_ts();
    }

    my $e_hwm = $self->event_hwm;
    my $s_hwm = $self->shakemap_hwm;
    my $p_hwm = $self->product_hwm;

	# default 7-day cutoff time, maximum 30 for feed
	my $rss_window = (SC->config->{'rss'}->{'TIME_WINDOW'}) ? 
		SC->config->{'rss'}->{'TIME_WINDOW'} : 7;
	my $min_time = time() - $rss_window*86400;
	my $mag_cutoff = (defined SC->config->{'MAG_CUTOFF'}) ? SC->config->{'MAG_CUTOFF'} : 4.0;

    # send the query
    my ($status, $message, $csv) = $self->fetch_eq_csv();
    #if ($status ne SC_OK) {
        $SC::errstr = $message;
    #    return 0;
    #}

    my %archive_sm;

    eval {
		my $sth = SC->dbh->prepare(qq/
			SELECT *
			FROM event
			WHERE adddate( event_timestamp, 7 ) > now( )
			AND event_type = "actual"
			GROUP BY event_id/);
		$sth->execute;
		while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
			$archive_sm{$p->{event_id}} = $p;
		}
    };

    eval {
		# Instantiate new items
		die 'did not find ShakeMap RSS feed element'
			unless defined $csv;

		SC->log(2, "poll got", scalar @$csv, "events");
		foreach my $item (@$csv) {
			# Parse Event ID
			my $netid = lc($item->{SRC});
			my $evid = $netid.$item->{EQID};
			my $mag = $item->{MAGNITUDE};
			next unless ($mag >= $mag_cutoff);
			
			if (defined $archive_sm{$evid}) {
				my $event_status = $archive_sm{$evid}->{event_status};
				if ($event_status =~ /cancelled/i) {
					eval {
						SC->dbh->do(qq/
							update event
							   set event_status="NORMAL"
							 where event_id = ?/, undef, $evid);
						SC->dbh->commit;
					};
				} else {
					delete $archive_sm{$evid};
					next;
				}
			} 

			my $pubDate = SC->ts_to_time($item->{DATETIME});
			next unless ($pubDate > $min_time);
			SC->log(2, "new eq csv", $item->{REGION});

			my $ts = SC->time_to_ts($pubDate);
			my $xml = qq{
				<event event_id="$evid" 
				event_version="1" 
				event_status="NORMAL" 
				event_type="ACTUAL" 
				event_name="" 
				event_location_description="$item->{'REGION'}" 
				event_timestamp="$ts" 
				external_event_id="$item->{'EQID'}" 
				magnitude="$item->{'MAGNITUDE'}" 
				lat="$item->{'LAT'}" 
				lon="$item->{'LON'}" 
				depth="$item->{'DEPTH'}" />};
			my $rv = SC->xml_in($xml)->{event};
			SC::Event->new(%$rv)->process_new_event;
			SC->log(2, "event $evid inserted");
		}

		# Build the cancellation message
	    #SC->log(2, "eq csv determined", scalar keys %archive_sm, "missing event(s)");
		foreach my $m (keys %archive_sm) {
			SC->log(2, $archive_sm{$m}->{event_id}, " is missing from the EQ CSV.");
			#eval {
			#	SC->dbh->do(qq/
			#		update event
			#		   set event_status="CANCELLED"
			#		 where event_id = ?/, undef, $archive_sm{$m}->{event_id});
			#	SC->dbh->commit;
			#};
			#my $xml = qq{
			#	<event event_id="$archive_sm{$m}->{event_id}" 
			#	event_version="$archive_sm{$m}->{event_version}" 
			#	event_status="CANCELLED" 
			#	event_type="$archive_sm{$m}->{event_type}" 
			#	event_name="$archive_sm{$m}->{event_name}" 
			#	event_location_description="$archive_sm{$m}->{event_location_description}" 
			#	event_timestamp="$archive_sm{$m}->{event_timestamp}" 
			#	external_event_id="$archive_sm{$m}->{external_event_id}" 
			#	magnitude="$archive_sm{$m}->{magnitude}" 
			#	lat="$archive_sm{$m}->{lat}" 
			#	lon="$archive_sm{$m}->{lon}"
			#	depth="$archive_sm{$m}->{depth}" />};
			#my $rv = SC->xml_in($xml)->{event};
			#SC::Event->new(%$rv)->process_new_event;
			#SC->log(2, "event $m cancelled");
		}

		# Store new HWMs
		my $proc_time = time();
		$self->update_hwms(
			$proc_time,
			$s_hwm,
			$p_hwm) or die $SC::errstr;
			
    };
    $SC::errstr = $@ if $@;
    return not defined $SC::errstr;
}

sub fetch_eq_csv {
    my ($self) = @_;
    my ($status, $message, $rv);

    # avoid sucking all this in for clients that don't need to send messages
    require LWP::UserAgent;
    #require HTTP::Request;
    #require MIME::Base64;

	my   $url = 'http://' . $self->dns_address . '/earthquakes/catalogs/eqs7day-M2.5.txt';
		
    SC->log(3, "server->send($url)");
    my $ua = new LWP::UserAgent();
    $ua->agent($USER_AGENT);
	$ua->proxy(['http'], SC->config->{'ProxyServer'})
		if (defined SC->config->{'ProxyServer'});
    #my $req = new HTTP::Request(POST => $url);
    #my $pwd = (defined $self->password ?
	#MIME::Base64::decode_base64($self->password) : '');
    #$req->authorization_basic(SC::Server->local_server_id(), $pwd);

    my $resp = $ua->get($url);
    SC->log(3, "response:", $resp->status_line);
    if ($resp->is_success) {
	my $p;
	SC->log(3, "content:", substr($resp->content, 0, 300));
	#SC->log(3, "content:", $resp->content);
	my @rows;
	eval {
		my @lines = split "\n", $resp->content;
		use Text::CSV_XS;

		my $csv = Text::CSV_XS->new ( { binary => 1 } )  # should set binary attribute.
					 or return "Cannot use CSV: ".Text::CSV->error_diag ();
		my $line = shift @lines;
		my $sub = process_header($csv, $line."\n");
		my $sub_ins_upd = eval $sub;
		while (my $row = shift @lines ) {
			next unless ($csv->parse($row."\n"));
			my @fields = $csv->fields();
			my $result = &$sub_ins_upd(\@fields);
			$result->{LAT} =~ m/\d+/ or next; # 3rd field should match
			$result->{SRC} !~ m/pt|at|dr/i or next; # 3rd field should match
			push @rows, $result;
		}
	};
	$rv = \@rows;
	
	# Reply should be an XML document whose root element is either
	# <shakecast_status> or <shakecast_response>.  The former is used
	# when there is no return other than status.  The latter includes
	# <shakecast_status> as one of its sub-elements, and <response_body>
	# as the other sub-element.
	if ($SC::errstr) {
	    # XML parse failed
	    $status = SC_BAD_XML;
	    $message = $SC::errstr;
	} elsif ($@) {
	    # XML parse failed
	    $status = SC_BAD_XML;
	    $message = "error parsing shakecast_response: $@";
	} elsif (exists $p->{'shakecast_response'}) {
	    # grab status sub-element
	    my $s = $p->{'shakecast_response'}->{'shakecast_status'};
	    $status = $s->{'status'};
	    $message = $s->{'content'};
	    $rv = $p->{'shakecast_response'}->{'response_body'} if $status eq SC_OK;
	} elsif (exists $p->{'shakecast_status'}) {
	    # just a status return with no payload
	    $status = $p->{'shakecast_status'}->{'status'};
	    $message = $p->{'shakecast_status'}->{'content'};
	} else {
	    $status = SC_UNKNOWN;
	    $message = 'No status returned';
	}
	$self->update_status(1);
	# TODO log the exchange
    } else {
	# TODO handle can't connect; retry with IP address
	$status = SC_HTTP_FAIL;
	$message = $resp->status_line;
	$self->update_status(0);
	# TODO log the exchange ?
	SC->log(2, "http failure: $message");
    }
    return ($status, $message, $rv);
}

# Read and process header, building data structures
# Returns 1 if header is ok, 0 for problems
sub process_header {
	my ($csv, $header) = @_;
    my $err_cnt = 0;
    my %columns;
	my $sub_ins_upd;

    return 1 unless $header;      # empty file not an error
    
    # parse header line
    #vvpr $header;
    unless ($csv->parse($header)) {
        #epr "CSV header parse error on field '", $csv->error_input, "'";
        return 0;
    }

    my $ix = 0;         # field index

    # uppercase and trim header field names
    my @fields = map { uc $_ } $csv->fields;
    # Field name is one of:
    #   METRIC:<metric-name>:<metric-level>
    #   GROUP:<group-name>
    #   <facility-column-name>
    foreach my $field (@fields) {
		#vvpr "$ix\: COLUMN: $field";
		# TODO check for unknown columns (either here or later on)
        $field =~ s/^\s+//;
        $field =~ s/\s+$//;
		$columns{$field} = $ix;
        $ix++;
    }

    # check for required fields
    #while (my ($req, $req_type) = each %required) {
        # relax required fields for update (only PK is mandatory)
        #next if $req_type == 2 and $mode == M_UPDATE;
        #unless (defined $columns{$req}) {
        #    epr "required field $req is missing";
        #    $err_cnt++;
        #}
    #}

    return 0 if $err_cnt;

    # build sql
    my @keys = sort keys %columns;
    
    
    # dynamically create a sub that takes the input array of fields and
    # returns a new list with just those fields that go into the facility
    # insert/update statement, in the proper order
    my $sub = "sub { return {" .
        join(',', (map { q{'}.$_.q{' => }. q{$_[0]->[} .$columns{$_}.q{]} } (@keys))) .
        '} }';
    #print "$sub\n";
    #vvpr $sub;
    #$sub_ins_upd = eval $sub;

    return $sub;
}


sub rss_send {
    my ($self) = @_;
    my ($status, $message, $rv);

    # avoid sucking all this in for clients that don't need to send messages
    require LWP::UserAgent;
    #require HTTP::Request;
    #require MIME::Base64;

	my   $url = 'http://' . $self->dns_address . '/eqcenter/shakemap/shakerss.php';
		
    SC->log(3, "server->send($url)");
    my $ua = new LWP::UserAgent();
    $ua->agent($USER_AGENT);
	$ua->proxy(['http'], SC->config->{'ProxyServer'})
		if (defined SC->config->{'ProxyServer'});
    #my $req = new HTTP::Request(POST => $url);
    #my $pwd = (defined $self->password ?
	#MIME::Base64::decode_base64($self->password) : '');
    #$req->authorization_basic(SC::Server->local_server_id(), $pwd);

    my $resp = $ua->get($url);
    SC->log(3, "response:", $resp->status_line);
    if ($resp->is_success) {
	my $p;
	SC->log(3, "content:", substr($resp->content, 0, 300));
	#SC->log(3, "content:", $resp->content);

	eval {$p = SC->xml_in($resp->content)};
	$rv = $p->{'rss'};
	
	# Reply should be an XML document whose root element is either
	# <shakecast_status> or <shakecast_response>.  The former is used
	# when there is no return other than status.  The latter includes
	# <shakecast_status> as one of its sub-elements, and <response_body>
	# as the other sub-element.
	if ($SC::errstr) {
	    # XML parse failed
	    $status = SC_BAD_XML;
	    $message = $SC::errstr;
	} elsif ($@) {
	    # XML parse failed
	    $status = SC_BAD_XML;
	    $message = "error parsing shakecast_response: $@";
	} elsif (exists $p->{'shakecast_response'}) {
	    # grab status sub-element
	    my $s = $p->{'shakecast_response'}->{'shakecast_status'};
	    $status = $s->{'status'};
	    $message = $s->{'content'};
	    $rv = $p->{'shakecast_response'}->{'response_body'} if $status eq SC_OK;
	} elsif (exists $p->{'shakecast_status'}) {
	    # just a status return with no payload
	    $status = $p->{'shakecast_status'}->{'status'};
	    $message = $p->{'shakecast_status'}->{'content'};
	} else {
	    $status = SC_UNKNOWN;
	    $message = 'No status returned';
	}
	$self->update_status(1);
	# TODO log the exchange
    } else {
	# TODO handle can't connect; retry with IP address
	$status = SC_HTTP_FAIL;
	$message = $resp->status_line;
	$self->update_status(0);
	# TODO log the exchange ?
	SC->log(2, "http failure: $message");
    }
    return ($status, $message, $rv);
}

1;



__END__

=head1 NAME

SC::Server - ShakeCast Server

=head1 DESCRIPTION

Instances of this package represent servers known to this ShakeCast
installation.  There is a C<SC::Server> for the local server as well as
for each known remote server.

The current implementation B<never> caches data about servers when creating
new instances; every request is satisfied by a database query.
However, it B<always> caches information for any existing C<SC::Server>
instance.  Once created, a server's attributes (ex: password, statistics)
are never updated from the database.  B<TODO: add a refresh method>.

=head2 Class Methods

=over 4

=item SC::Server->this_server

Returns the local server, or C<undef> for errors (either no server marked
with C<SELF_FLAG=1> or multiple servers claiming to be the local server).

=item SC::Server->local_server_id

Returns the C<server_id> of the local server, or C<undef> for errors.

=item SC::Server->from_id( $server_id )

Returns a new C<SC::Server> whose server_id matches the specfied
parameter value, or C<undef> if no such server exists.
C<undef> is also returned for database errors or if multiple server
records are found with the given server_id; C<$SC::errstr> is also set
for these errors.

=item SC::Server->upstream_servers

Returns a list containing all the upstream servers
(those whose C<UPSTREAM_FLAG> field is 1).
The list could be empty.
If there are any errors an empty list is returned.

=item SC::Server->downstream_servers

Returns a list containing all the downstream servers
(those whose C<DOWNSTREAM_FLAG> field is 1).
The list could be empty.
If there are any errors an empty list is returned.

=item SC::Server->servers_to_poll

Returns a list containing all the servers
that should be polled for new data.
Each of these servers is polled in turn by <b>polld</b>.
If there are any errors an empty list is returned.

=back

=head2 Instance Methods

=over 4

=item $server->permitted( $access )

Tests to see if C<$server> is permitted the specified access.
Access is one of:
  U   is $server upstream
  D   is $server downstream
  Q   can $server query me
  P   should I attempt to poll $server

Returns nonzero if allowed, zero if denied.

=item $server->send( $action, $content )

Sends a request to this server.
The return value is a three element list of C<status>, C<message>, and
C<return-value>.

=over 4

=item status

This is one of the standard Shakecast status values.

=item message

If the status indicates an error then the C<message> element will contain
the error message.  This message might be locally generated or could come
from the remote server, depending on where the error occurred.

=item return-value

If the remote reply includes data, not just a status, then this element
will contain a hashref that points to the interpreted response.  In all
other cases this element will be undefined.

=back

=item $server->queue_request ( $action, @args )

Queues a request for C<$action> to be performed by the remote server.
The specified arguments are passed to the remote server.
The request will be queued with the Dispatcher and executed asynchronously.
This method will only fail if the request could not be queued; a
successful return does not indicate that the action itself succeeded, or that
it has even been performed yet.

The C<$action> parameter can have one of the following values (see
C<bin/worker.pl> for implementation details):

=over 4

=item new_event ( event_id, event_version )

Send the event with the specified id and version to the remote server.

=item new_shakemap ( shakemap_id, shakemap_version )

Send the shakemap with the specified id and version to the remote server.

=item new_product ( product_id )

Send the product with the specified id to the remote server.

=item get_file_for_product ( product_id )

Retrieve the file associated with the given product_id.  If the file is a
grid file, decode it and load the grid into the database.  Then pass the
product metadata along to any downstream servers.  (We deferred this
action when we received our copy of the product metadata because we don't
want the downstream server to ask us for the product file until we have
fetched it from our upstream server.)

=back

=back

=cut
