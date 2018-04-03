#!perl 



use strict;

use FindBin;

use lib "$FindBin::Bin/../lib";

use Test;

use Data::Dumper;



BEGIN { plan tests => 10 }





use SC;

use SC::Server;

use SC::Product;



use MIME::Lite;

use Net::SMTPS;



my $config;

{

    my $server;



    print "Server tests as localhost ...\n";

    SC->initialize('sc_test.conf');

    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";

    $config = SC->config;

    ok defined $config;

}



my ($email_address, $username);

{

    eval {

	($email_address, $username) = SC->dbh->selectrow_array(qq/

	    select email_address, username from shakecast_user

	     where user_type='admin'/, {});

    };

    ok $@, '', "selectrow_array failed: $@";

    ok $username eq 'scadmin';

    SC->log(0, "Admin User: $username, $email_address");

}



{

    my $msg = MIME::Lite->new (

            From => 'shakecast@usgs.gov',

            To => $email_address,

            BCC => $email_address,

            Subject => 'SC Test Suite',

            Type => 'text/html',

            Data => 'Test message'

        );

    ok defined $msg;

    my $image = SC->config->{'RootDir'}.'/images/header.jpg';

    ok (-e $image);

    ok $msg->attach (

			   Type => 'AUTO',

			   Path => $image,

			   Id => 'header.jpg',

			   Filename => 'header.jpg',

			   Disposition => 'inline'

			);



    ok defined $config->{Notification}->{SmtpServer};

    my $smtp_server = $config->{Notification}->{SmtpServer};

    my $smtp = Net::SMTPS->new($smtp_server,

				Debug=>1, Port => 587, doSSL => 'starttls');

    ok defined $smtp;

    SC->log(0, $@);



    my $username = $config->{Notification}->{Username};

    my $password = $config->{Notification}->{Password};

    $smtp->auth($username, $password);

    ok $smtp->ok;

}

# vim:syntax=perl

