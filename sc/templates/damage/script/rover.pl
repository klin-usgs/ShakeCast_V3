#!/usr/local/sc/sc.bin/perl

    require LWP::UserAgent;
    require HTTP::Request;
    require MIME::Base64;

    my $time = '%EVENT_TIMESTAMP%';
    my $damage = '%DAMAGE_LEVEL:RED;R;YELLOW;Y;GREEN;G%';
    my $content = '%EXTERNAL_FACILITY_ID%';
    
    my $url = 'http://127.0.0.1:8000/Rover/api/post_color?screener=admin&pw=rover&color='.$damage.'&when='.$time;
                
    my $ua = new LWP::UserAgent();
    $ua->agent($USER_AGENT);
    #$ua->proxy(['http'], SC->config->{'ProxyServer'})
    #            if (defined SC->config->{'ProxyServer'});
    my $req = new HTTP::Request(POST => $url ,undef, $content);
    #my $pwd = (defined $self->password ?
    #    MIME::Base64::decode_base64($self->password) : '');
    #$req->authorization_basic(SC::Server->local_server_id(), $pwd);

    my $resp = $ua->request($req);
    print $resp->status_line;
    #SC->log(3, "response:", $resp->status_line);
    #if ($resp->is_success) {

	
exit;