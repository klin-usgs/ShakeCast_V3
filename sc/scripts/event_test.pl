#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use File::Basename;
use File::Copy;
use File::Path;

use SC;
use API::Event;
use API::APIUtil;
use SC::Event;
use SC::Shakemap;
use SC::Product;
use SC::Server;

SC->initialize;
my $test_dir = SC->config->{'RootDir'} . '/test_data';
my $data_dir = SC->config->{'DataRoot'};

#print $json_str;
 # Authenticate based on name parameter
# under   sub {
#   sub {
#    my $self = shift;

    # Authenticated
#    my $name = $self->param('name') || '';
#    return 1 if $name eq 'Bender';

    # Not authenticated
#    $self->render('denied');
#    return;
#  };

  # / (with authentication)
  get '/' => sub {
    my $self = shift;
	my $event = new API::Event->current_event();
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/current_event' => sub {
    my $self = shift;
	my $event = new API::Event->current_event();
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/current_version' => sub {
    my $self = shift;
    my $event_id = $self->param('event_id') || '';
	my $event = new API::Event->current_version($event_id);
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/from_id' => sub {
    my $self = shift;
    # Authenticated
    my $event_id = $self->param('event_id') || '';
	my $event = new API::Event->from_id($event_id);
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/newer_than' => sub {
    my $self = shift;
    # Authenticated
    my $oldest = $self->param('oldest') || '';
	my $events = new API::Event->newer_than('', $oldest);
	my $json = API::APIUtil::stringfy($events);

    $self->render(json => $json);
  };
  
  get '/event_list' => sub {
    my $self = shift;
	my $start = ($self->param('start')) ? ($self->param('start'))-1 : 0;
	my $type = ($self->param('type')) ? ($self->param('type')) : '';
    my $age = $self->param('age') || 'week';
	my $events;
	if ($type =~ /scenario|major/i) {
		$events = new API::Event->event_list($type);
	} elsif ($type =~ /test/i) {
		$events = get_test_events();
	} elsif ($age) {
		my $timestamp = age_trans($age);
		$events = new API::Event->newer_than('', $timestamp);
	}
	my $json = API::APIUtil::stringfy($events);

    $self->render(json => $json);
  };

  get '/erase' => sub {
    my $self = shift;
    # Authenticated
    my @event_list = split ',', $self->param('event_id');
	my $event_results;
	foreach my $event_id (@event_list) {
		my $event = new API::Event->erase_event($event_id);
		$event_results->{$event_id} = $event;
	}
	my $json = API::APIUtil::stringfy($event_results);
 
   $self->render(json => $json);
  };
  
  get '/toggle' => sub {
    my $self = shift;
    # Authenticated
    my @event_list = split ',', $self->param('event_id');
	my $event_results;
	foreach my $event_id (@event_list) {
		my $event = new API::Event->toggle_major_event($event_id);
		$event_results->{$event_id} = $event;
	}
	my $json = API::APIUtil::stringfy($event_results);
    $self->render(json => $json);
  };
  
  get '/inject_test' => sub {
    my $self = shift;
    # Authenticated
    my @event_list = split ',', $self->param('event_id');
	my $event_results;
    my $xml;
    my $event_version = 1;
    my $event;
    my $product_dir;
	
	foreach my $event_id (@event_list) {
		# see if this event already exists in the database
		$event = SC::Event->current_version($event_id);
		if ($event) {
			# must delete any existing events and related data
			API::Event->erase_test_event($event_id) or quit $SC::errstr;
		}
	
		$xml = read_xml($event_id, 'event') or exit;
		$xml =~ s/\?event_version/$event_version/g;
		$event = SC::Event->from_xml($xml) or exit;
		$event->event_type("TEST"); # make sure it is a TEST!
		$event->process_new_event;
		$xml = read_xml($event_id, 'shakemap') or exit;
		$xml =~ s/\?event_version/$event_version/g;
		SC::Shakemap->from_xml($xml)->process_new_shakemap;
		$xml = read_xml($event_id, 'product') or exit;
		my @product_types = product_types();
		$event->{'product'} = \@product_types;
		foreach my $product_type (@product_types) {
			#next;   # temporarily skip products
			my $xml2 = $xml;
			my $product;
			$xml2 =~ s/\?event_version/$event_version/g;
			$xml2 =~ s/\?product_type/$product_type/g;
			SC->log(4, $xml2);
			$product = SC::Product->from_xml($xml2);
			unless ($product_dir) {
				$product_dir = $product->dir_name;
				SC->log(4, "product dir: $product_dir");
				unless (-d $product_dir) {
					eval { mkpath($product_dir) };
					SC->log(4, "mkpath product dir: $product_dir");
					#exit if $@;
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
				;
		}
		my @local_products = local_products();
		$event->{'local_products'} = \@local_products;
		foreach my $local_product (@local_products) {
			copy $test_dir .'/' . $event_id . '/' . $local_product, $product_dir;
		}
	}
	my $json = API::APIUtil::stringfy($event);
    $self->render(json => $json);
  };

  get '/create_test' => sub {
    my $self = shift;
    # Authenticated
    my @event_list = split ',', $self->param('event_id');
	my $event_results;
    my $xml;
    my $event_version = 1;
    my $event;
    my $product_dir;
	
	foreach my $event_id (@event_list) {
		create_test($event_id);
	}
	my $json = API::APIUtil::stringfy($event);
    $self->render(json => $json);
  };
  
  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
  
  app->secret('scv3');
  app->start('cgi');
#  app->start();
  
sub age_trans {
    my $age = (@_ ? shift : 'day');
	my $span;
	if ($age =~ /day/i) {
		$span = 1;
	} elsif ($age =~ /week/i) {
		$span = 7;
	} elsif ($age =~ /month/i) {
		$span = 30;
	} elsif ($age =~ /year/i) {
		$span = 365;
	} elsif ($age =~ /all/i) {
		$span = time/86400;
	}
    my $time = time - $span*86400;
    my ($sec, $min, $hr, $mday, $mon, $yr);
		($sec, $min, $hr, $mday, $mon, $yr) = gmtime $time;

    sprintf ("%04d-%02d-%02d",
	     $yr+1900, $mon+1, $mday);


}

sub check_test_dir {
    unless (-d $test_dir) {
        mkdir $test_dir or exit;
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
            my $event = API::Event->from_xml($xml)
                or exit;
			$event->{shakemap_id}=$event->{event_id};
			$event->{shakemap_version} = 1;
            push @test_events, $event;
			$event->{product} = copy_test($event->{event_id});
        };
        return if $@;
    }
    return \@test_events;
}
    
sub read_xml {
    my ($event_id, $type) = @_;

    my $fname = "$test_dir/$event_id/${type}_template.xml";
    open XML, "< $fname" or exit;
    my @lines = <XML>;
    close XML;
    chomp @lines;
    return join(' ', @lines);
}

sub copy_test {
    my ($event_id) = @_;
    my $xml;
    my $event;
    my $source_dir = "$test_dir/$event_id";
    my $dest_dir = "$data_dir/$event_id"."-1";

	return if (-d $dest_dir);
	eval {mkpath($dest_dir);};
	SC->log(4, "mkpath product dir: $dest_dir");
	return if $@;
	
    opendir TESTDIR, $source_dir or quit("Can't open $source_dir\: $!");
    # exclude .* files
    my @files = grep !/^\./, readdir TESTDIR;
    # exclude non-files
	#print @files,"\n";
    my @products = grep -f, map "$source_dir/$_", @files;
    foreach my $product (@products) {
        copy $product, $dest_dir;
    }
    return \@products;
}

# returns a list of all products that should be polled for new events, etc.
sub product_types {
	my @products;
	
    undef $SC::errstr;
    eval {
		my $sth = SC->dbh->prepare(qq/
			select product_type
			  from product_type/);
		$sth->execute;
		while (my @p = $sth->fetchrow_array()) {
			push @products, @p;
		}
    };
    return @products;
}

sub local_products {
	my $temp_dir = SC->config->{'TemplateDir'} . '/xml';
	my @local_products;
	if (-d $temp_dir) {
		if (opendir TEMPDIR, $temp_dir) {
			# exclude .* files
			my @files = grep !/^\./, readdir TEMPDIR;
			# exclude non-directories
			closedir(TEMPDIR);
		
			foreach my $file (@files) {
				if ($file =~ m#([^/\\]+)\.tt$#) {     # last component only
					my $temp_file = $1.".tt";
					my $output_file = $1;
					$output_file =~ s/_/\./;
					push @local_products, $output_file;
				}
			}
		}
	}
    return \@local_products;
}

sub create_test {
    my ($event_id) = @_;
	
    check_test_dir();
    my $template_dir = "$test_dir/${event_id}_scte";
    exit if (-d $template_dir);
    mkdir $template_dir or exit;
    my $event = SC::Event->current_version($event_id);
    exit unless $event;
    my $xml = make_test_xml($event->to_xml);
    open OUT, "> $template_dir/event_template.xml" or exit;
    print OUT "$xml\n";
    close OUT;
    my $shakemap = SC::Shakemap->current_version($event_id);
    return "No shakemap with ID $event_id" unless $shakemap;
    $xml = make_test_xml($shakemap->to_xml);
    open OUT, "> $template_dir/shakemap_template.xml" or exit;
    print OUT "$xml\n";
    close OUT;
    my @products = SC::Product->current_version($event_id);
    exit if $SC::errstr;
    exit unless @products > 0;
    $xml = make_test_xml($products[0]->to_xml);
    open OUT, "> $template_dir/product_template.xml" or exit;
    print OUT "$xml\n";
    close OUT;
    foreach my $product (@products) {
        copy $product->abs_file_path, $template_dir;
    }
		my @local_products = local_products();
    foreach my $local_product (@local_products) {
        copy $shakemap->product_dir .'/' . $local_product, $template_dir;
    }
	return;
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



__DATA__

@@ counter.html.ep
Counter: <%= session 'counter' %>

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.

