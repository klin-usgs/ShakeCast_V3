#!/usr/local/bin/perl

use Mojolicious::Lite;
use File::Path qw(make_path remove_tree);
use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::GoogleMap;


SC->initialize() or quit $SC::errstr;
my $data_dir = SC->config->{'RootDir'}.'/html';

  # / (with authentication)
  get '/' => sub {
    my $self = shift;
	#my $event = new API::Event->current_event();
	#my $json = API::APIUtil::stringfy($event);

    #$self->render(json => $json);
  };
  
  get '/current_event' => sub {
    my $self = shift;
	#my $event = new API::Event->current_event();
	#my $json = API::APIUtil::stringfy($event);

    #$self->render(json => $json);
  };
  
  get '/current_version' => sub {
    my $self = shift;
    my $event_id = $self->param('event_id') || '';
	##my $event = new API::Event->current_version($event_id);
	#my $json = API::APIUtil::stringfy($event);

    #$self->render(json => $json);
  };
  
  get '/from_id' => sub {
    my $self = shift;
    # Authenticated
    my $event_id = $self->param('event_id') || '';
	#my $event = new API::Event->from_id($event_id);
	#my $json = API::APIUtil::stringfy($event);

    #$self->render(json => $json);
  };
  
  get '/newer_than' => sub {
    my $self = shift;
    # Authenticated
    my $hwm = $self->param('hwm') || '';
    my $oldest = $self->param('oldest') || '';
	#my $events = new API::Event->newer_than($hwm, $oldest);
	
	#my $json = API::APIUtil::stringfy($events);

    #$self->render(json => $json);
  };
  
  get '/event/(:x),(:y),(:zoom)/' => sub {
    my $self = shift;
    my $x = $self->param('x') || 0;
    my $y = $self->param('y') || 0;
    my $zoom = $self->param('zoom') || 5;
	#my $events = new API::Event->event_list($start);

	$data_dir .= "/tiles/event/$zoom/$x/";
	make_path($data_dir) unless (-d $data_dir);
	my $path = $data_dir."/${y}.png";
	if (-f $path) {
		open(FH, "<$path");
		binmode FH;
		local $/;
		my $png = <FH>;
		close(FH);
		$self->res->headers->content_type('image/png');
		$self->render(data => $png);
	} else {

	use GD;
	use GD::Polygon;
	my $im = new GD::Image(256,256);
	$im->trueColor(1);
	# allocate some colors
	my $white = $im->colorAllocate(255,255,255);
	my $lightgrey = $im->colorAllocate(192,192,192);
	my $grey = $im->colorAllocate(127,127,127);
	my $darkgrey = $im->colorAllocate(96,96,96);
	my $black = $im->colorAllocate(0,0,0);       
	my $red = $im->colorAllocate(255,0,0);      
	my $blue = $im->colorAllocate(0,0,255);
	my $lightblue = $im->colorAllocate(127,127,255);
	my $lightpink = $im->colorAllocate(255,153,244);
	my $pink = $im->colorAllocate(255,93,232);
	my $green = $im->colorAllocate(0,255,0);
	my $lightgreen = $im->colorAllocate(127,255,127);

	# make the background transparent and interlaced
	$im->interlaced('true');
	$im->transparent($white);

	my $rect = API::GoogleMap::getTileRect($x, $y, $zoom);
	
    undef $SC::errstr;
    my @list;
	
	my $tilesAtThisZoom = 1 << $zoom;
	$x = $x % $tilesAtThisZoom;
	
	#my $icon = new GD::Image("c:/shakecast/sc/docs/images/va_hosp.png", 1);
	#$icon->transparent($white);
	#$icon->interlaced('true');
	#my ($iconwidth, $iconheight) = $icon->getBounds();
	
	my $extend = 360.0 / $tilesAtThisZoom / 256 ; 
	#$extend = 0; 
	my $swlat=$rect->{'y'} - $extend;
	my $swlng=$rect->{'x'} - $extend;
	my $nelat=$swlat+$rect->{'height'} + 2*$extend;
	my $nelng=$swlng+$rect->{'width'} + 2*$extend;
	
	my %rect = ('x' => $self->param('x'), 'off' => $self->param('x') % $tilesAtThisZoom, 'zoom' => $tilesAtThisZoom, 'swlat' => $swlat, 'swlng' => $swlng, 'nelat' => $nelat, 'nelng' => $nelng);
	push @list, \%rect;
	my $time_window = (SC->config->{'rss'}->{'TIME_WINDOW'}) ? 
		SC->config->{'rss'}->{'TIME_WINDOW'} : 30;

   my $sql =  qq/
		SELECT
                lat,lon,magnitude,datediff(now(),event_timestamp) as opacity
        FROM
                event
        WHERE
                (lon > $swlng AND lon <= $nelng)
        AND (lat <= $nelat AND lat > $swlat)
        AND datediff(now(),event_timestamp) < $time_window	
	/;

    eval {
	my $sth = SC->dbh->prepare($sql);
	$sth->execute();
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
		my $point = API::GoogleMap::getPixelOffsetInTile($p->{'lat'}, $p->{'lon'}, $zoom);
	    #push @list, $p;
	    push @list, $point;
		if (($p->{'lon'}+$extend) > $nelng) {
			$point->{'x'} += 256;
		} elsif (($p->{'lon'}-$extend) <= $swlng) {
			$point->{'x'} -= 256;
		}
		if (($p->{'lat'}+$extend) > $nelat) {
			$point->{'y'} += 256;
		} elsif (($p->{'lat'}-$extend) <= $swlat) {
			$point->{'y'} -= 256;
		}
		$im->filledEllipse($point->{'x'}, $point->{'y'}, 8, 8, $lightpink );
		$im->ellipse($point->{'x'}, $point->{'y'}, 8, 8, $pink );
		#$im->copyResized($icon,$point->{'x'}-$iconwidth/3, $point->{'y'}-$iconheight/3,0,0,
		#	$iconwidth/1.5,$iconheight/1.5,$iconwidth,$iconheight);
	}
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    #return \@list;
	#print "$sql\n";
	my $json = API::APIUtil::stringfy(\@list);

    # Convert the image to PNG and print it on standard output
	open (FH, "> $path");
	binmode FH;
    print FH $im->png;
	close(FH);
    #$self->render(json => $json);
	$self->res->headers->content_type('image/png');
    $self->render(data => $im->png);
	}
  };

  get '/facility/(:x),(:y),(:zoom)/' => sub {
    my $self = shift;
    my $x = $self->param('x') || 0;
    my $y = $self->param('y') || 0;
    my $zoom = $self->param('zoom') || 5;
	#my $events = new API::Event->event_list($start);
	
	$data_dir .= "/tiles/facility/$zoom/$x/";
	make_path($data_dir) unless (-d $data_dir);
	my $path = $data_dir."/${y}.png";
	if (-f $path) {
		open(FH, "<$path");
		binmode FH;
		local $/;
		my $png = <FH>;
		close(FH);
		$self->res->headers->content_type('image/png');
		$self->render(data => $png);
	} else {
	

	use GD;
	use GD::Polygon;
	my $im = new GD::Image(256,256);
	$im->trueColor(1);
	# allocate some colors
	my $white = $im->colorAllocate(255,255,255);
	my $lightgrey = $im->colorAllocate(192,192,192);
	my $grey = $im->colorAllocate(127,127,127);
	my $darkgrey = $im->colorAllocate(96,96,96);
	my $black = $im->colorAllocate(0,0,0);       
	my $red = $im->colorAllocate(255,0,0);      
	my $blue = $im->colorAllocate(0,0,255);
	my $lightblue = $im->colorAllocate(127,127,255);
	my $lightpink = $im->colorAllocate(255,153,244);
	my $pink = $im->colorAllocate(255,93,232);
	my $green = $im->colorAllocate(0,255,0);
	my $lightgreen = $im->colorAllocate(127,255,127);

	# make the background transparent and interlaced
	$im->interlaced('true');
	$im->transparent($white);
	
	my $rect = API::GoogleMap::getTileRect($x, $y, $zoom);
	
    undef $SC::errstr;
    my @list;
	
	my $tilesAtThisZoom = 1 << $zoom;
	#$x = $x % $tilesAtThisZoom;
	
	my $extend = 360.0 / $tilesAtThisZoom / 256; 
	$extend = 0; 
	my $swlat=$rect->{'y'} - $extend;
	my $swlng=$rect->{'x'} - $extend;
	my $nelat=$swlat+$rect->{'height'} + 2*$extend;
	my $nelng=$swlng+$rect->{'width'} + 2*$extend;
	
	#my %rect = ('x' => $self->param('x'), 'off' => $self->param('x') % $tilesAtThisZoom, 'zoom' => $tilesAtThisZoom, 'swlat' => $swlat, 'swlng' => $swlng, 'nelat' => $nelat, 'nelng' => $nelng);
	#push @list, \%rect;
	my $time_window = (SC->config->{'rss'}->{'TIME_WINDOW'}) ? 
		SC->config->{'rss'}->{'TIME_WINDOW'} : 30;

   my $sql =  qq/
		SELECT
                lat_min, lat_max,lon_min, lon_max, facility_type
        FROM
                facility
        WHERE
                (lon_max > $swlng AND lon_min <= $nelng)
        AND (lat_min <= $nelat AND lat_max > $swlat)
	/;

    eval {
	my $sth = SC->dbh->prepare($sql);
	$sth->execute();
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
		my $lon = ($p->{'lon_min'} + $p->{'lon_max'}) / 2;
		my $lat = ($p->{'lat_min'} + $p->{'lat_max'}) / 2;
		my $point = API::GoogleMap::getPixelOffsetInTile($lat, $lon, $zoom);
	    #push @list, $p;
	    push @list, $point;
		if (($lon+$extend) > $nelng) {
			$point->{'x'} += 256;
		} elsif (($lon-$extend) <= $swlng) {
			$point->{'x'} -= 256;
		}
		if (($lat+$extend) > $nelat) {
			$point->{'y'} += 256;
		} elsif (($lat-$extend) <= $swlat) {
			$point->{'y'} -= 256;
		}
		$im->filledEllipse($point->{'x'}, $point->{'y'}, 8, 8, $lightblue );
		$im->ellipse($point->{'x'}, $point->{'y'}, 8, 8, $blue );
	
		my $icon = new GD::Image("c:/shakecast/sc/docs/images/".$p->{'facility_type'}.".png");
		#$icon->transparent($white);
		#$icon->interlaced('true');
		my ($iconwidth, $iconheight) = $icon->getBounds();
		$im->copyResized($icon,$point->{'x'}-$iconwidth/4, $point->{'y'}-$iconheight/4,0,0,
			$iconwidth/2,$iconheight/2,$iconwidth,$iconheight);
	}
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    #return \@list;
	#print "$sql\n";
	my $json = API::APIUtil::stringfy(\@list);

    # Convert the image to PNG and print it on standard output
	open (FH, "> $path");
	binmode FH;
    print FH $im->png;
	close(FH);
    #$self->render(json => $json);
	$self->res->headers->content_type('image/png');
    $self->render(data => $im->png);
	}
  };

  get '/station/(:x),(:y),(:zoom)/' => sub {
    my $self = shift;
    my $x = $self->param('x') || 0;
    my $y = $self->param('y') || 0;
    my $zoom = $self->param('zoom') || 5;
	#my $events = new API::Event->event_list($start);

	$data_dir .= "/tiles/station/$zoom/$x/";
	make_path($data_dir) unless (-d $data_dir);
	my $path = $data_dir."/${y}.png";
	if (-f $path) {
		open(FH, "<$path");
		binmode FH;
		local $/;
		my $png = <FH>;
		close(FH);
		$self->res->headers->content_type('image/png');
		$self->render(data => $png);
	} else {

	use GD;
	use GD::Polygon;
	my $im = new GD::Image(256,256);
	$im->trueColor(1);
	# allocate some colors
	my $white = $im->colorAllocate(255,255,255);
	my $lightgrey = $im->colorAllocate(192,192,192);
	my $grey = $im->colorAllocate(127,127,127);
	my $darkgrey = $im->colorAllocate(96,96,96);
	my $black = $im->colorAllocate(0,0,0);       
	my $red = $im->colorAllocate(255,0,0);      
	my $blue = $im->colorAllocate(0,0,255);
	my $lightblue = $im->colorAllocate(127,127,255);
	my $lightpink = $im->colorAllocate(255,153,244);
	my $pink = $im->colorAllocate(255,93,232);
	my $green = $im->colorAllocate(0,255,0);
	my $lightgreen = $im->colorAllocate(127,255,127);

	# make the background transparent and interlaced
	$im->interlaced('true');
	$im->transparent($white);

	my $rect = API::GoogleMap::getTileRect($x, $y, $zoom);
	
    undef $SC::errstr;
    my @list;
	my $size = 8;
	
	my $tilesAtThisZoom = 1 << $zoom;
	#$x = $x % $tilesAtThisZoom;
	
	my $extend = 360.0 / $tilesAtThisZoom / 256; 
	$extend = 0; 
	my $swlat=$rect->{'y'} - $extend;
	my $swlng=$rect->{'x'} - $extend;
	my $nelat=$swlat+$rect->{'height'} + 2*$extend;
	my $nelng=$swlng+$rect->{'width'} + 2*$extend;
	
	#my %rect = ('x' => $self->param('x'), 'off' => $self->param('x') % $tilesAtThisZoom, 'zoom' => $tilesAtThisZoom, 'swlat' => $swlat, 'swlng' => $swlng, 'nelat' => $nelat, 'nelng' => $nelng);
	#push @list, \%rect;
	my $time_window = (SC->config->{'rss'}->{'TIME_WINDOW'}) ? 
		SC->config->{'rss'}->{'TIME_WINDOW'} : 30;

   my $sql =  qq/
		SELECT
                latitude,longitude
        FROM
                station
        WHERE
            (longitude > $swlng AND longitude <= $nelng)
        AND (latitude <= $nelat AND latitude > $swlat)
        AND station_network != 'DYFI'
	/;

    #eval {
	my $sth = SC->dbh->prepare($sql);
	$sth->execute();
	while (my $p = $sth->fetchrow_hashref('NAME_lc')) {
		my $lon = $p->{'longitude'};
		my $lat = $p->{'latitude'};
		my $point = API::GoogleMap::getPixelOffsetInTile($lat, $lon, $zoom);
	    #push @list, $p;
	    push @list, $point;
		if (($lon+$extend) > $nelng) {
			$point->{'x'} += 256;
		} elsif (($lon-$extend) <= $swlng) {
			$point->{'x'} -= 256;
		}
		if (($lat+$extend) > $nelat) {
			$point->{'y'} += 256;
		} elsif (($lat-$extend) <= $swlat) {
			$point->{'y'} -= 256;
		}

		my $poly = new GD::Polygon;
		$poly->addPt($point->{'x'}, $point->{'y'} - $size * 0.5);
		$poly->addPt($point->{'x'} - $size * 0.5, $point->{'y'} + $size * 0.2);
		$poly->addPt($point->{'x'} + $size * 0.5, $point->{'y'} + $size * 0.2);
		$im->filledPolygon($poly, $lightgreen );
		$im->openPolygon($poly, $green );
	
		#my $icon = new GD::Image("c:/shakecast/sc/docs/images/".$p->{'facility_type'}.".png");
		#$icon->transparent($white);
		#$icon->interlaced('true');
		#my ($iconwidth, $iconheight) = $icon->getBounds();
		#$im->copyResized($icon,$point->{'x'}-$iconwidth/3, $point->{'y'}-$iconheight/3,0,0,
		#	$iconwidth/1.5,$iconheight/1.5,$iconwidth,$iconheight);
	}
	$sth->finish;
    #};
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    #return \@list;
	#print "$sql\n";
	my $json = API::APIUtil::stringfy(\@list);

    # Convert the image to PNG and print it on standard output
	open (FH, "> $path");
	binmode FH;
    print FH $im->png;
	close(FH);
    #$self->render(json => $json);
	$self->res->headers->content_type('image/png');
    $self->render(data => $im->png);
	}
  };

  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
  app->start('fastcgi');
#  app->start();
  
__DATA__

@@ counter.html.ep
Counter: <%= session 'counter' %>

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.

