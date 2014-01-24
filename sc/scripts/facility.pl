#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Facility;
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
	my $event = new API::Facility->facility_list();
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/current_event' => sub {
    my $self = shift;
	my $event = new API::Facility->current_event();
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/current_version' => sub {
    my $self = shift;
    my $event_id = $self->param('event_id') || '';
	my $event = new API::Facility->current_version($event_id);
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/from_id/(:facility_id)' => sub {
    my $self = shift;
    # Authenticated
    my $facility_id = $self->param('facility_id') || '';
	my $facility = new API::Facility->from_id($facility_id);
	my $json = API::APIUtil::stringfy($facility);

    $self->render(json => $json);
  };
  
  get '/newer_than' => sub {
    my $self = shift;
    # Authenticated
    my $hwm = $self->param('hwm') || '';
    my $oldest = $self->param('oldest') || '';
	my $events = new API::Facility->newer_than($hwm, $oldest);
	
	my $json = API::APIUtil::stringfy($events);

    $self->render(json => $json);
  };
  
  get '/counter' => sub {
    my $self = shift;
    $self->session->{counter}++;
  };

  # / (with authentication)
  get '/type/*type' => sub {
    my $self = shift;
	my $type = $self->param('type');
	my $event = new API::Facility->facility_type_list($type);
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

