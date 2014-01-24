#!c:/perl/bin/perl.exe


use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Damage;
use API::APIUtil;

use Data::Dumper;

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

    # Authenticated
	my ($shakemap_id, $shakemap_version) = @ARGV;
	my @facility;
	my $options = { 'shakemap_id' => $shakemap_id,
			'shakemap_version' => $shakemap_version,
		};
	my $damage = new API::Damage->from_id($options);
	$damage->{'type'} = $type;
	my $json = API::APIUtil::stringfy($damage);
	print Dumper($damage);