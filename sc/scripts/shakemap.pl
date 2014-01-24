#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::APIUtil;
use API::Shakemap;
use SC::Shakemap;

SC->initialize;
my $test_dir = SC->config->{'RootDir'} . '/test_data';
my $data_dir = SC->config->{'DataRoot'};
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
	my $shakemap = new API::Shakemap->current_shakemap();

	my $json = API::APIUtil::stringfy($shakemap);
	
    $self->render(json => $json);
  };
  
  # / (with authentication)
  get '/current_shakemap' => sub {
    my $self = shift;
	my $shakemap = new API::Shakemap->current_shakemap();

	my $json = API::APIUtil::stringfy($shakemap);
	
    $self->render(json => $json);
  };
  
  get '/current_version' => sub {
    my $self = shift;
    my $event_id = $self->param('event_id') || '';
	my $shakemap = new API::Shakemap->current_version($event_id);
	my $json = API::APIUtil::stringfy($shakemap);

    $self->render(json => $json);
  };
  
  get '/from_id/*shakemap' => sub {
    my $self = shift;
    # Authenticated
	my ($shakemap_id, $shakemap_version) = split '-', $self->param('shakemap');
    #my $shakemap_version = $self->param('shakemap_version') || 1;
	my $shakemap = new API::Shakemap->from_id($shakemap_id, $shakemap_version);
	if ($shakemap_id =~ /_scte$/) {
		my $xml = read_xml($shakemap_id, 'event') or exit;
		$xml =~ s/\?event_version/1/g;
		my $xml_hash = SC->xml_in($xml);
		$xml = read_xml($shakemap_id, 'shakemap');
		$xml =~ s/\?event_version/1/g;
		my $xml_hash2 = SC->xml_in($xml);
		$shakemap = $xml_hash2->{'shakemap'};
		foreach my $key (keys %{$xml_hash->{'event'}}) 
			{$shakemap->{$key} = $xml_hash->{'event'}->{$key};}
	}
	my $json = API::APIUtil::stringfy($shakemap);

    $self->render(json => $json);
  };
  
  get '/newer_than' => sub {
    my $self = shift;
    # Authenticated
    my $hwm = $self->param('hwm') || '';
    my $oldest = $self->param('oldest') || '';
	my $shakemap = new API::Shakemap->newer_than($hwm, $oldest);
	
	my $json = API::APIUtil::stringfy($shakemap);

    $self->render(json => $json);
  };
  
  get '/*' => sub {
    my $self = shift;
    # Authenticated
    $self->render(json => []);
  };
  
  
  app->start('cgi');
#  app->start();
  
sub read_xml {
    my ($event_id, $type) = @_;

    my $fname = "$test_dir/$event_id/${type}_template.xml";
    open XML, "< $fname" or exit;
    my @lines = <XML>;
    close XML;
    chomp @lines;
    return join(' ', @lines);
}


__DATA__

@@ counter.html.ep
Counter: <%= session 'counter' %>

@@ denied.html.ep
You are not Bender, permission denied.

@@ index.html.ep
Hi Bender.

