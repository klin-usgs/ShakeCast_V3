#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;

use Shake::EqInfo;
use SC::Event;

SC->initialize;

my $event = new SC::Event->current_event();
my $json_str = 'event:{'.(join ',', map {'"'.$_ .'"=>"'. $event->{$_}.'"' } keys %$event). '}';
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
  #get '/' => 'index';
  get '/' => sub {
    my $self = shift;
    $self->render_json(eval($json_str));
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
  
  
  app->start('cgi');
  
__DATA__

@@ counter.html.ep
Counter: <%= session 'counter' %>

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.

