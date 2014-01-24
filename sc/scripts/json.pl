#!/usr/local/bin/perl
use Mojolicious::Lite;

# Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
plugin 'PODRenderer';

get '/welcome' => sub {
  my $self = shift;
  $self->render('index');
};

  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
Welcome to Mojolicious!

@@ layouts/default.html.ep
<!doctype html><html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
