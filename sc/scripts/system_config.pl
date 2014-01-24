#!/usr/local/bin/perl

use Mojolicious::Lite;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SC;
use API::Server;
use API::APIUtil;
use API::User;

SC->initialize;
my $config = SC->config;

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
  any [qw(GET POST PATCH)] => '/' => sub {
    my $self = shift;
    # Authenticated
	my $server_list = new API::Server->server_list();
	$config->{'server'} = $server_list;
	my $json = API::APIUtil::stringfy($config);
	
    $self->render(json => $json);
  };
  
  post '/server_update' => sub {
    my $self = shift;
    # Authenticated
    my $server_id = $self->param('server_id');
    my $dns_address = $self->param('dns_address');
    my $query_flag = $self->param('query_flag');
		my $event;
	my $server = new API::Server->from_id($server_id);
	my $result = $server->update_info($server_id, $dns_address, $query_flag);
	#$event->{'result'} = new API::Product->toggle_product_display($product_id, $save_flag);
	$event->{'query_flag'} = $query_flag;
	$event->{'dns_address'} = $dns_address;
	$server->{'update_result'} = $result;
	my $json = API::APIUtil::stringfy($server);
	

	use Config::General qw(SaveConfig);
	undef $config->{'server'};
	SaveConfig($config->{'RootDir'}.'/conf/sc.conf', $config);

    $self->render(json => $json);
  };
  
  post '/config_update' => sub {
    my $self = shift;
    # Authenticated
    my $param_groupid = $self->param('param_groupid');
    my $param_gnuplot = $self->param('param_gnuplot');
    my $param_wkhtmltopdf = $self->param('param_wkhtmltopdf');
    my $param_redundant_check = $self->param('param_redundant_check');
    my $param_perlbin = $self->param('param_perlbin');
    my $param_userid = $self->param('param_userid');
	$config->{'GroupID'} = $param_groupid;
	$config->{'UserID'} = $param_userid;
	$config->{'gnuplot'} = $param_gnuplot;
	$config->{'wkhtmltopdf'} = $param_wkhtmltopdf;
	$config->{'REDUNDANT_CHECK'} = $param_redundant_check;
	$config->{'perlbin'} = $param_perlbin;

    my $param_dataroot = $self->param('param_dataroot');
    my $param_logfile = $self->param('param_logfile');
    my $param_rootdir = $self->param('param_rootdir');
    my $param_templatedir = $self->param('param_templatedir');
    my $param_loglevel = $self->param('param_loglevel');
    my $param_logdir = $self->param('param_logdir');
	$config->{'DataRoot'} = $param_dataroot;
	$config->{'LogFile'} = $param_logfile;
	$config->{'RootDir'} = $param_rootdir;
	$config->{'TemplateDir'} = $param_templatedir;
	$config->{'LogLevel'} = $param_loglevel;
	$config->{'LogDir'} = $param_logdir;

    my $sm_time_window = $self->param('sm_time_window');
    my $sm_region = $self->param('sm_region');
	$config->{'rss'}->{'TIME_WINDOW'} = $sm_time_window;
	$config->{'rss'}->{'REGION'} = $sm_region;

    my $param_update_threshold = $self->param('param_update_threshold');
    my $param_mag_threshold = $self->param('param_mag_threshold');
	$config->{'Threshold'} = $param_update_threshold;
	$config->{'MAG_CUTOFF'} = $param_mag_threshold;

    my $email_smtpserver = $self->param('email_smtpserver');
    my $email_security = $self->param('email_security');
    my $email_port = $self->param('email_port');
    my $email_username = $self->param('email_username');
    my $email_password = $self->param('email_password');
    my $email_defaultemailtemplate = $self->param('email_defaultemailtemplate');
    my $email_defaultscripttemplate = $self->param('email_defaultscripttemplate');
    my $email_from = $self->param('email_from');
    my $email_envelopefrom = $self->param('email_envelopefrom');
	$config->{'Notification'}->{'SmtpServer'} = $email_smtpserver;
	$config->{'Notification'}->{'Security'} = $email_security;
	$config->{'Notification'}->{'Port'} = $email_port;
	$config->{'Notification'}->{'Username'} = $email_username;
	$config->{'Notification'}->{'Password'} = $email_password;
	$config->{'Notification'}->{'DefaultEmailTemplate'} = $email_defaultemailtemplate;
	$config->{'Notification'}->{'DefaultScriptTemplate'} = $email_defaultscripttemplate;
	$config->{'Notification'}->{'From'} = $email_from;
	$config->{'Notification'}->{'EnvelopeFrom'} = $email_envelopefrom;

    my $db_connection_string = $self->param('db_connection_string');
    my $db_type = $self->param('db_type');
    my $db_username = $self->param('db_username');
    my $db_password = $self->param('db_password');
	$config->{'DBConnection'}->{'ConnectString'} = $db_connection_string;
	$config->{'DBConnection'}->{'Type'} = $db_type;
	$config->{'DBConnection'}->{'Username'} = $db_username;
	$config->{'DBConnection'}->{'Password'} = $db_password;

	my $json = API::APIUtil::stringfy($config);
	
	use Config::General qw(SaveConfig);
	SaveConfig($config->{'RootDir'}.'/conf/sc.conf', $config);

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

