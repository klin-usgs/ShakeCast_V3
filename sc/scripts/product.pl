#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Product;
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
    # Authenticated
	my $product_list = new API::Product->product_source_list();
	my $json = API::APIUtil::stringfy($product_list);

    $self->render(json => $json);
  };
  
  # / (with authentication)
  get '/type/*type' => sub {
    my $self = shift;
	my $type = $self->param('type') ? $self->param('type')  : '';
	my $event = new API::Product->product_type_list($type);
	my $json = API::APIUtil::stringfy($event);

    $self->render(json => $json);
  };
  
  # / (with authentication)
  get '/from_id/*shakemap' => sub {
    my $self = shift;
    # Authenticated
	my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
    #my $shakemap_version = $self->param('shakemap_version') || 1;
	my $shakemap = new API::Product->from_id($shakemap_id, $shakemap_version);
	my $json = API::APIUtil::stringfy($shakemap);

    $self->render(json => $json);
  };
  
  get '/toggle' => sub {
    my $self = shift;
    # Authenticated
    my $product_id = $self->param('product_id');
    my $save_flag = $self->param('save');
		my $event;
	$event->{'result'} = new API::Product->toggle_product_display($product_id, $save_flag);
		$event->{'flag'} = $save_flag;
	my $json = API::APIUtil::stringfy($event);
    $self->render(json => $json);
  };
  
  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
  app->start('cgi');
#  app->start();
  
__DATA__

@@ counter.html.ep
Counter: <%= session 'counter' %>

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.

