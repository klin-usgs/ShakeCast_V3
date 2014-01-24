#!/usr/local/bin/perl

  use Mojolicious::Lite;

 app->secret('My very secret passphrase.');

 get '/test' => sub {
    my $self = shift;
    $self->render(text => 'Hello world!');
  };

  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
  app->start('cgi');
