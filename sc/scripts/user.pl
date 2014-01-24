#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::User;
use API::APIUtil;

SC->initialize;

my ($username, $password);

 # Authenticate based on name parameter
 under   sub {
    my $self = shift;

    # Authenticated
    $username = $self->param('username') || '';
    $password = $self->param('password') || '';
    return 1 if API::User->validate($username, $password);

    # Not authenticated
    my $json = API::APIUtil::stringfy('');
    $self->render(json => $json);
    return;
  };

  # / (with authentication)
  get '/' => sub {
    my $self = shift;
    # Authenticated
	my $user_list = new API::User->user_group();
	my $json = API::APIUtil::stringfy($user_list);

    $self->render(json => $json);
  };
  
  # / (with authentication)
  get '/type/*type' => sub {
    my $self = shift;
	my $type = $self->param('type') ? $self->param('type')  : '';
	my $event = new API::User->user_type_list($type);
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  # / (with authentication)
  any [qw(GET POST PATCH)] => '/from_id/*id' => sub {
    my $self = shift;
	my $user_id = $self->param('id') ? $self->param('id')  : '';
	my $event = new API::User->from_id($user_id);
	$event->{user_id}=$user_id;
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
  app->start('cgi');
