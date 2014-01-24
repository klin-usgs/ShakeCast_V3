#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Station;
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
	my $station = new API::Station->station_list();
	my $json = API::APIUtil::stringfy($station);

    $self->render(json => $json);
  };
  
  get '/from_id' => sub {
    my $self = shift;
    # Authenticated
    my $station_id = $self->param('station_id') || '';
	my $station = new API::Station->from_id($station_id);
	my $json = API::APIUtil::stringfy($station);

    $self->render(json => $json);
  };
  
  get '/counter' => sub {
    my $self = shift;
    $self->session->{counter}++;
  };

  # / (with authentication)
  get '/type/*type' => sub {
    my $self = shift;
	my $type = $self->param('type') ? $self->param('type')  : '';
	my $event = new API::Station->station_type_list($type);
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
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

