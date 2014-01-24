#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Damage;
use API::APIUtil;

SC->initialize;
my $default_options = API::APIUtil::config_options();

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
	my $damage = new API::Damage->damage_list($start);
	my $json = API::APIUtil::stringfy($damage);

    $self->render(json => $json);
  };
  
  get '/datatables/*shakemap' => sub {
    my $self = shift;
    my @facility;
    my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
    my $action = $self->param('action');
    my $start =  ($self->param('start')) ? ($self->param('start'))-1 : 0;
    my $length = ($self->param('length')) ? $self->param('length') : 
      (($default_options->{'topics_per_page'}) ? $default_options->{'topics_per_page'} : 200);
    my $type = ($self->param('type')) ? uc($self->param('type')) : 'ALL';

    my $count;

	push @facility, (split ',', $self->param('facility')) 
		if $self->param('facility');
	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version,
			'type' => $type,
			'action' => $action,
			'start' => $start,
			'length' => $length,
			'facility' => \@facility};
	my $damage = new API::Damage->from_id($options);
	$damage->{'type'} = $type;
	$damage->{"total"} = $damage->{'count'};    
	$damage->{"start"} = $start;
	$damage->{"length"} = scalar keys %{$damage->{'facility_damage'}};
	my $json = API::APIUtil::stringfy($damage);
	if ($action =~ /summary/i) {
		$json = {'count' => $json->{'count'},
				'damage_summary' => $json->{'damage_summary'}
				};
	}

    $self->render(json => $json);
  };

  get '/from_id/*shakemap' => sub {
    my $self = shift;
    # Authenticated
	my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
	my @facility;
	my $start = ($self->param('start')) ? ($self->param('start'))-1 : 0;
    my $type = $self->param('type');
    my $action = $self->param('action');
	push @facility, (split ',', $self->param('facility')) 
		if $self->param('facility');
	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version,
			'start' => $start,
			'type' => $type,
			'action' => $action,
			'facility' => \@facility};
	my $damage = new API::Damage->from_id($options);
	$damage->{'type'} = $type;
	my $json = API::APIUtil::stringfy($damage);
	if ($action =~ /summary/i) {
		$json = {'count' => $json->{'count'},
				'damage_summary' => $json->{'damage_summary'}
				};
	}

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

