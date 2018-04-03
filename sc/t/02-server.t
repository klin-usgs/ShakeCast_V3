#!perl 



use strict;

use FindBin;

use lib "$FindBin::Bin/../lib";

use Test;

use Data::Dumper;



BEGIN { plan tests => 28 }





use SC;

use SC::Server;

use SC::Product;



{

    my $server;

    my @servers;



    print "Server tests as localhost ...\n";

    SC->initialize('sc_test.conf');

    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";



    # create for self

    $server = SC::Server->this_server;

    ok defined $server;

    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";



    # test accessors

    ok $server->server_id eq 1000;

    ok $server->dns_address eq 'localhost';

    ok $server->as_string =~ /localhost/ or print STDERR $server->as_string, "\n";



    # create given a server ID

    $server = SC::Server->from_id(1);

    ok defined $server;

    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";

    ok $server->server_id == 1;



    # test status update

    my ($ts1, $ts2, $errs);

    $server->update_status(1);

    ok $SC::errstr, undef;

    # verify DB record

    eval {

	($ts1, $errs) = SC->dbh->selectrow_array(qq/

	    select last_heard_from, error_count from server

	     where server_id=?/, {}, $server->server_id);

    };

    ok $@, '', "selectrow_array failed: $@";

    ok $ts1, '/^20/';

    ok $errs, 0;



    sleep (2);	# to keep timestamps from matching

    $server->update_status(0);

    ok $SC::errstr, undef;

    # verify DB record

    eval {

	($ts2, $errs) = SC->dbh->selectrow_array(qq/

	    select last_heard_from, error_count from server

	     where server_id=?/, {}, $server->server_id);

    };

    ok $@, '', "selectrow_array failed: $@";

    ok $ts2, $ts1;

    ok $errs, 1;



    # test downstream servers (should be empty list)

    @servers = SC::Server->downstream_servers;

    ok scalar @servers, 0;

    

    # test servers to poll

    @servers = SC::Server->servers_to_query;

    ok scalar @servers, 1;

    ok $servers[0]->dns_address, 'earthquake.usgs.gov';

    

    # error case -- create based on nonexistent server ID

    $server = SC::Server->from_id(666);

    ok not defined $server;

    ok $SC::errstr =~ /No server/;



    ok(SC::Server->local_server_id(), 1000);

}



{

    print "Authentication tests...\n";

    #my $upstream = SC->authenticate(2, 'U');

    my $upstream = SC::Server->from_id(1302);

    ok defined $upstream;

    ok $upstream->permitted('U');

    ok not $upstream->permitted('D');

    ok not $upstream->permitted('P');

    ok  $upstream->permitted('Q');

}



# vim:syntax=perl

