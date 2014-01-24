#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Shaking;
use API::APIUtil;

SC->initialize;

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
	my $start = ($self->param('start')) ? ($self->param('start'))-1 : 0;
	my $shaking = new API::Shaking->shaking_list($start);
	my $json = API::APIUtil::stringfy($shaking);

    $self->render(json => $json);
  };
  
  get '/from_id/*shakemap' => sub {
    my $self = shift;
    # Authenticated
	my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
	my @facility;
	my $start = ($self->param('start')) ? ($self->param('start'))-1 : 0;
	push @facility, (split ',', $self->param('facility')) 
		if $self->param('facility');
	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version,
			'start' => $start,
			'facility' => \@facility};
	my $shaking = new API::Shaking->from_id($options);
	my $json = API::APIUtil::stringfy($shaking);

    $self->render(json => $json);
  };
  
  get '/shaking_summary/*shakemap' => sub {
    my $self = shift;
    # Authenticated
	my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version};
	my $shaking = new API::Shaking->shaking_summary($options);
	my $json = API::APIUtil::stringfy($shaking);

    $self->render(json => $json);
  };
  
  get '/shaking_point/*shakemap' => sub {
    my $self = shift;
    # Authenticated
	my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
	my $longitude = $self->param('longitude');
	my $latitude = $self->param('latitude');
	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version,
			'latitude' => $latitude,
			'longitude' => $longitude
			};
			
	my $shaking = new API::Shaking->shaking_point($options);
	my $json = API::APIUtil::stringfy($shaking);

    $self->render(json => $json);
  };
  
  get '/counter' => sub {
    my $self = shift;
    $self->session->{counter}++;
  };

  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
#  app->start('cgi');
  app->start();
  
__DATA__

@@ counter.html.ep
Counter: <%= session 'counter' %>

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.

