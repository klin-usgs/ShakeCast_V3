#!/usr/bin/perl

##############################################################################
# 
# Terms and Conditions of Software Use
# ====================================
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Disclaimer of Earthquake Information
# ====================================
# 
# The data and maps provided through this system are preliminary data
# and are subject to revision. They are computer generated and may not
# have received human review or official approval. Inaccuracies in the
# data may be present because of instrument or computer
# malfunctions. Subsequent review may result in significant revisions to
# the data. All efforts have been made to provide accurate information,
# but reliance on, or interpretation of earthquake data from a single
# source is not advised. Data users are cautioned to consider carefully
# the provisional nature of the information before using it for
# decisions that concern personal or public safety or the conduct of
# business that involves substantial monetary or operational
# consequences.
# 
# Disclaimer of Software and its Capabilities
# ===========================================
# 
# This software is provided as an "as is" basis.  Attempts have been
# made to rid the program of software defects and bugs, however the
# U.S. Geological Survey (USGS) and Gatekeeper Systems have no
# obligations to provide maintenance, support, updates, enhancements or
# modifications. In no event shall USGS or Gatekeeper Systems be liable
# to any party for direct, indirect, special, incidental or consequential
# damages, including lost profits, arising out of the use of this
# software, its documentation, or data obtained though the use of this
# software, even if USGS or Gatekeeper Systems have been advised of the
# possibility of such damage. By downloading, installing or using this
# program, the user acknowledges and understands the purpose and
# limitations of this software.
# 
# Contact Information
# ===================
# 
# Coordination of this effort is under the auspices of the USGS Advanced
# National Seismic System (ANSS) coordinated in Golden, Colorado, which
# functions as the clearing house for development, distribution,
# documentation, and support. For questions, comments, or reports of
# potential bugs regarding this software please contact wald@usgs.gov or
# cbworden@usgs.gov.  ShakeCast Contractor: Gatekeeper Systems; 1010 E
# Union St; Pasadena, CA 91109; 626-449-3070; 800-424-3070;
# info@gatekeeper.com; www.gatekeeper.com.
#
#############################################################################

use warnings;

use strict;

use vars qw ($VERSION $RCSID $COPYRIGHT $RCSID);

$VERSION = 'admin 0.0.17 2004-08-15 16:23Z';

$RCSID = '@(#) $Id: admin.pl 152 2007-09-25 14:44:15Z klin $ ';

use Carp;

use CGI;

use SC;

use MIME::Base64 ();

my $TABLE_ATTRS = "border=1 cellpadding=1 cellspacing=0 noshade";


my $script = $ENV{SCRIPT_NAME};

my $TOP = <<__EOF__
<font size=-1>
<a href="$script">Admin Home</a> |
<a href="$script?type=users">User Admin</a> |
<a href="$script?type=templates">Template Admin</a> |
<a href="$script?type=facilities">Facility Admin</a> |
<a href="$script?type=servers">Server Admin</a> |
<a href="/scripts/c/tester.pl">Tester Home</a>
</font>
<p>
__EOF__
    ;

my $BOTTOM = <<__EOF__
<p>
<hr>
<center>
<font size=-1>
<a href="$script">Admin Home</a> |
<a href="$script?type=users">User Admin</a> |
<a href="$script?type=templates">Template Admin</a> |
<a href="$script?type=facilities">Facility Admin</a> |
<a href="$script?type=servers">Server Admin</a>
</font>
</center>
__EOF__
    ;

my $shakecast_user_layout = 
    ['ID' => 'SHAKECAST_USER',
     'User Name' => 'USERNAME','Full Name' => 'FULL_NAME',
     'Phone Number' => 'PHONE_NUMBER',
     'Email Address' => 'EMAIL_ADDRESS',
     'Type' => 'USER_TYPE/USER_TYPE,USER_TYPE,NAME'];

my $shakecast_user_form =
    ['User Name' => '+USERNAME','Full Name' => '+FULL_NAME',
     'Phone Number' => '+PHONE_NUMBER',
     'Email Address' => '+EMAIL_ADDRESS',
     'Type' => '+USER_TYPE/USER_TYPE,USER_TYPE,NAME,NAME,USER'];

my $user_delivery_method_layout =
    ['ID' => 'USER_DELIVERY_METHOD_ID',
     'Method' => 'DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME',
     'Address' => 'DELIVERY_ADDRESS'];

my $user_delivery_method_form =
    ['Method' => '+DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME,DELIVERY_METHOD,EMAIL_TEXT',
     'Address' => '+DELIVERY_ADDRESS'];

my $template_layout =
    [ID => 'MESSAGE_FORMAT',
     Name => 'NAME',
     Description => 'DESCRIPTION',
     'File Name' => 'FILE_NAME'];

my $template_form =
    [Name => '+NAME',
     Description => 'DESCRIPTION',
     'File Name' => '+FILE_NAME'];


my $facility_notification_layout = 
    [ID => 'f.FACILITY_ID', Name => 'FACILITY_NAME',
     'Short Name' => 'SHORT_NAME',
     Type => 'FACILITY_TYPE/FACILITY_TYPE,FACILITY_TYPE,NAME',
     Description => 'DESCRIPTION',
     'Lat Min' => 'LAT_MIN',
     'Lat Max' => 'LAT_MAX',
     'Lon Min' => 'LON_MIN',
     'Lon Max' => 'LON_MAX'];

my $facility_layout = 
    [ID => 'FACILITY_ID', Name => 'FACILITY_NAME',
     'Short Name' => 'SHORT_NAME',
     Type => 'FACILITY_TYPE/FACILITY_TYPE,FACILITY_TYPE,NAME',
     Description => 'DESCRIPTION',
     'Lat Min' => 'LAT_MIN',
     'Lat Max' => 'LAT_MAX',
     'Lon Min' => 'LON_MIN',
     'Lon Max' => 'LON_MAX'];

my $facility_form = 
    [Name => '+FACILITY_NAME',
     'Short Name' => 'SHORT_NAME',
     Type => '+FACILITY_TYPE/FACILITY_TYPE,FACILITY_TYPE,NAME,NAME,STRUCTURE',
     Description => 'DESCRIPTION',
     'Lat Min' => '+LAT_MIN',
     'Lat Max' => 'LAT_MAX',
     'Lon Min' => '+LON_MIN',
     'Lon Max' => 'LON_MAX'];

my $notification_request_layout =
    [ID => 'NOTIFICATION_REQUEST_ID',
     Type => 'NOTIFICATION_TYPE/NOTIFICATION_TYPE,NOTIFICATION_TYPE,NAME',
     'Event Type' => 'EVENT_TYPE/EVENT_TYPE,EVENT_TYPE,NAME',
     Delivery => 'DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME',
     Template => 'MESSAGE_FORMAT/MESSAGE_FORMAT,MESSAGE_FORMAT,NAME,NAME',
     'Limit Value' => 'LIMIT_VALUE',
     'Damage Level' => 'DAMAGE_LEVEL/DAMAGE_LEVEL,DAMAGE_LEVEL,NAME',
     Product => 'PRODUCT_TYPE/PRODUCT_TYPE,PRODUCT_TYPE,NAME',
     Metric => 'METRIC/METRIC,SHORT_NAME,NAME',
     Disable => 'DISABLED/*BOOL,,Yes',
     Aggregate => 'AGGREGATE/*BOOL,,Yes',
     'Aggregation Group' => 'AGGREGATION_GROUP'];

my $notification_request_form =
    [Type => '+NOTIFICATION_TYPE/NOTIFICATION_TYPE,NOTIFICATION_TYPE,NAME,NAME',
     'Event Type' => 'EVENT_TYPE/EVENT_TYPE,EVENT_TYPE,NAME,NAME',
     Delivery => '+DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME,DELIVERY_METHOD,EMAIL_TEXT',
     Template => 'MESSAGE_FORMAT/MESSAGE_FORMAT,MESSAGE_FORMAT,NAME,NAME',
     'Limit Value' => 'LIMIT_VALUE',
     'Damage Level' => 'DAMAGE_LEVEL/DAMAGE_LEVEL,DAMAGE_LEVEL,NAME,NAME',
     Product => 'PRODUCT_TYPE/PRODUCT_TYPE,PRODUCT_TYPE,NAME,NAME',
     Metric => 'METRIC/METRIC,SHORT_NAME,NAME,NAME',
     Disable => 'DISABLED/*BOOL',
     Aggregate => 'AGGREGATE/*BOOL',
     'Aggregation Group' => 'AGGREGATION_GROUP'];

my $notification_request_form_e =
    [Type => '+NOTIFICATION_TYPE/NOTIFICATION_TYPE,NOTIFICATION_TYPE,NAME,NAME,NEW_EVENT,NOTIFICATION_CLASS=\'EVENT\'',
     'Event Type' => 'EVENT_TYPE/EVENT_TYPE,EVENT_TYPE,NAME,NAME',
     Delivery => '+DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME,DELIVERY_METHOD,EMAIL_TEXT',
     Template => 'MESSAGE_FORMAT/MESSAGE_FORMAT,MESSAGE_FORMAT,NAME,NAME',
     'Limit Value' => 'LIMIT_VALUE',
     Disable => 'DISABLED/*BOOL',
     Aggregate => 'AGGREGATE/*BOOL',
     'Aggregation Group' => 'AGGREGATION_GROUP'];

my $notification_request_form_p =
    [Type => '+NOTIFICATION_TYPE/NOTIFICATION_TYPE,NOTIFICATION_TYPE,NAME,NAME,NEW_PROD,NOTIFICATION_CLASS=\'PRODUCT\'',
     'Event Type' => 'EVENT_TYPE/EVENT_TYPE,EVENT_TYPE,NAME,NAME',
     Delivery => '+DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME,DELIVERY_METHOD,EMAIL_TEXT',
      Template=> 'MESSAGE_FORMAT/MESSAGE_FORMAT,MESSAGE_FORMAT,NAME,NAME',
     'Limit Value' => 'LIMIT_VALUE',
     'Product Type' => 'PRODUCT_TYPE/PRODUCT_TYPE,PRODUCT_TYPE,NAME,NAME',
     Disable => 'DISABLED/*BOOL',
     Aggregate => 'AGGREGATE/*BOOL',
     'Aggregation Group' => 'AGGREGATION_GROUP'];

my $notification_request_form_s =
    [Type => '+NOTIFICATION_TYPE/NOTIFICATION_TYPE,NOTIFICATION_TYPE,NAME,NAME,SHAKING,NOTIFICATION_TYPE=\'SHAKING\'',
     'Event Type' => 'EVENT_TYPE/EVENT_TYPE,EVENT_TYPE,NAME,NAME',
     Delivery => '+DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME,DELIVERY_METHOD,EMAIL_TEXT',
     Template => 'MESSAGE_FORMAT/MESSAGE_FORMAT,MESSAGE_FORMAT,NAME,NAME',
     'Limit Value' => 'LIMIT_VALUE',
     Metric => 'METRIC/METRIC,SHORT_NAME,NAME,NAME',
     Disable => 'DISABLED/*BOOL',
     Aggregate => 'AGGREGATE/*BOOL',
     'Aggregation Group' => 'AGGREGATION_GROUP'];

my $notification_request_form_d =
    [Type => '+NOTIFICATION_TYPE/NOTIFICATION_TYPE,NOTIFICATION_TYPE,NAME,NAME,DAMAGE,NOTIFICATION_TYPE=\'DAMAGE\'',
     'Event Type' => 'EVENT_TYPE/EVENT_TYPE,EVENT_TYPE,NAME,NAME',
     Delivery => '+DELIVERY_METHOD/DELIVERY_METHOD,DELIVERY_METHOD,NAME,DELIVERY_METHOD,EMAIL_TEXT',
     Template => 'MESSAGE_FORMAT/MESSAGE_FORMAT,MESSAGE_FORMAT,NAME,NAME',
     'Damage Level' => '+DAMAGE_LEVEL/DAMAGE_LEVEL,DAMAGE_LEVEL,NAME,NAME',
     Disable => 'DISABLED/*BOOL',
     Aggregate => 'AGGREGATE/*BOOL',
     'Aggregation Group' => 'AGGREGATION_GROUP'];

my $facility_fragility_layout = 
    [ID => 'FACILITY_FRAGILITY_ID',
     'Damage Level' => 'DAMAGE_LEVEL/DAMAGE_LEVEL,DAMAGE_LEVEL,NAME',
     'Low Limit' => 'LOW_LIMIT', 'High Limit' => 'HIGH_LIMIT',
     'Metric' => 'METRIC/METRIC,SHORT_NAME,NAME,NAME'];

my $facility_fragility_form = 
    ['Damage_Level' => '+DAMAGE_LEVEL/DAMAGE_LEVEL,DAMAGE_LEVEL,NAME,NAME,RED',
     'Low Limit' => '+LOW_LIMIT', 'High Limit' => '+HIGH_LIMIT',
     'Metric' => '+METRIC/METRIC,SHORT_NAME,NAME,NAME'];

my $server_layout = 
    [ID => 'SERVER_ID', 'DNS Address' => 'DNS_ADDRESS',
     'Last Heard From' => 'LAST_HEARD_FROM',
     'Organization' => 'OWNER_ORGANIZATION',
     'Status' => 'SERVER_STATUS',
     'Error Count' => 'ERROR_COUNT',
     'Upstream' => 'UPSTREAM_FLAG',
     'Downstream' => 'DOWNSTREAM_FLAG',
     'Poll' => 'POLL_FLAG',
     'Query' => 'QUERY_FLAG',
     ];

my $server_form = 
    [ID => '+SERVER_ID',
     'DNS Address' => '+DNS_ADDRESS',
     'Organization' => 'OWNER_ORGANIZATION',
     'Upstream' => 'UPSTREAM_FLAG/*BOOL',
     'Downstream' => 'DOWNSTREAM_FLAG/*BOOL',
     'Poll' => 'POLL_FLAG/*BOOL',
     'Query' => 'QUERY_FLAG/*BOOL',
     ];

my $this_server_form = 
    [ID => '+SERVER_ID',
     'DNS Address' => '+DNS_ADDRESS',
     'Organization' => 'OWNER_ORGANIZATION ',
     'Lat' => 'LAT', 'Lon' => 'LON',
     ];


my $dbh;

my $type;

my ($page_started, $page_ended);

sub dbquit;
sub pr;
sub quit;


my $q = new CGI;

my $admin_user = $q->remote_user;

$admin_user ||= 'unknown';

unless (SC->initialize()) {
    quit "Can't initialize: ", SC->errstr;
}

my $config = SC->config;

my $HTPASSWD = $config->{Admin}->{HtPasswordPath};
my $SERVER_PWDFILE = $config->{Admin}->{ServerPwdFile};
my $USER_PWDFILE = $config->{Admin}->{UserPwdFile};

quit "Config Error: HtPasswordPath not defined" unless $HTPASSWD;
quit "Config Error: ServerPwdFile not defined" unless $SERVER_PWDFILE;
quit "Config Error: UserPwdFile not defined" unless $USER_PWDFILE;

$dbh = SC->dbh;
$dbh->{RaiseError} = 0;

if ($type = $q->param('type')) { process_by_type() }
else { gen_base_page() }

end_page();

exit;


#
### Main Processing Functions
#

sub gen_base_page {
    start_page('ShakeCast Administration');
    pr qq[<a href="$script?type=users">User Administration</a>];
    pr qq[<p><a href="$script?type=facilities">Facility Administration</a>];
    pr qq[<p><a href="$script?type=servers">Server Administration</a>];
    pr qq[<p><a href="$script?type=templates">Template Description
	  Administration</a>];
    pr qq[<p>[<font size=-1>Version: $VERSION :: $RCSID</font>]];
}


sub process_by_type {
    if ($type eq 'users') { process_users() }
    elsif ($type eq 'findusers') { process_find_users() }
    elsif ($type eq 'edituser') { process_edit_user() }
    elsif ($type eq 'deluser') { process_delete_user() }
    elsif ($type eq 'deluser2') { process_delete_user_2() }
    elsif ($type eq 'submituser') { process_submit_user() }
    elsif ($type eq 'userdeliv') { process_user_delivery() }
    elsif ($type eq 'editumethod') { process_edit_user_method() }
    elsif ($type eq 'submitumethod') { process_submit_user_method() }
    elsif ($type eq 'delumethod') { process_delete_user_method() }
    elsif ($type eq 'delumethod2') { process_delete_user_method_2() }
    elsif ($type eq 'templates') { process_templates() }
    elsif ($type eq 'findtemplates') { process_find_templates() }
    elsif ($type eq 'edittemplate') { process_edit_template() }
    elsif ($type eq 'submittemplate') { process_submit_template() }
    elsif ($type eq 'deltemplate') { process_delete_template() }
    elsif ($type eq 'deltemplate2') { process_delete_template_2() } 
    elsif ($type eq 'facilities') { process_facilities() }
    elsif ($type eq 'findfacs') { process_find_facilities() }
    elsif ($type eq 'editfac') { process_edit_facility() }
    elsif ($type eq 'submitfac') { process_submit_facility() }
    elsif ($type eq 'delfac') { process_delete_facility() }
    elsif ($type eq 'delfac2') { process_delete_facility_2() }
    elsif ($type eq 'notify') { process_notify() }
    elsif ($type eq 'facnotify') { process_notify_facility() }
    elsif ($type eq 'newnotify') { process_new_notify() }
    elsif ($type eq 'editnotify_e') { process_edit_notify_e() }
    elsif ($type eq 'submitnotify_e') { process_submit_notify_e() }
    elsif ($type eq 'editnotify_p') { process_edit_notify_p() }
    elsif ($type eq 'submitnotify_p') { process_submit_notify_p() }
    elsif ($type eq 'editnotify_s') { process_edit_notify_s() }
    elsif ($type eq 'submitnotify_s') { process_submit_notify_s() }
    elsif ($type eq 'editnotify_d') { process_edit_notify_d() }
    elsif ($type eq 'submitnotify_d') { process_submit_notify_d() }
    elsif ($type eq 'submitnotify_c') { process_submit_notify_c() }
    elsif ($type eq 'delnotify') { process_delete_notify() }
    elsif ($type eq 'delnotify2') { process_delete_notify_2() }
    elsif ($type eq 'facfrag') { process_facility_fragility() }
    elsif ($type eq 'editfacfrag') { process_edit_facility_fragility() }
    elsif ($type eq 'submitfacfrag') { process_submit_facility_fragility() }
    elsif ($type eq 'delfacfrag') { process_delete_facility_fragility() }
    elsif ($type eq 'delfacfrag2') { process_delete_facility_fragility_2() }
    elsif ($type eq 'servers') { process_servers() }
    elsif ($type eq 'findservers') { process_find_servers() }
    elsif ($type eq 'editserver') { process_edit_server() }
    elsif ($type eq 'delserver') { process_delete_server() }
    elsif ($type eq 'delserver2') { process_delete_server_2() }
    elsif ($type eq 'editserverpwd') { process_edit_server_pwd() }
    elsif ($type eq 'editserverpwd2') { process_edit_server_pwd_2() }
    elsif ($type eq 'submitserver') { process_submit_server() }
    elsif ($type eq 'thisserver') { process_this_server() }
    elsif ($type eq 'submitthisserver') { process_submit_this_server() }
    elsif ($type eq 'edituserpwd') { process_edit_user_pwd() }
    elsif ($type eq 'edituserpwd2') { process_edit_user_pwd_2() }
    elsif ($type eq 'selfacrequest') { process_sel_fac_req() }
    elsif ($type eq 'addfacrequest') { process_add_fac_req() }
    elsif ($type eq 'delfacrequest') { process_del_fac_req() }
    elsif ($type eq 'notifyaction') { process_notify_facility_action() }
    elsif ($type eq 'clonenotifyaction') { process_clone_notification_action() }
    else { quit "Invalid type request: [$type]" }
}


#
### Facilities
#

sub process_delete_facility {
    start_page("Delete Facility");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    my ($name, $shortname, $factype) = get_facility_info($key);
    print <<__EOF__;
Do you really want to delete facility <b>$name ($shortname)
[$factype]</b> and all
associated data?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=delfac2>
    <input type=hidden name=key value="$key">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>   
</form>
__EOF__
    ;    
}


sub process_delete_facility_2 {
    if ($q->param('del_no')) {
	start_page('Deletion Cancelled');
	pr "Deletion of user was cancelled.";
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM facility WHERE FACILITY_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_facility_2: del facility";
	$dbh->do("DELETE FROM notification_request WHERE FACILITY_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_user_2: del notification_request";
	$dbh->do("DELETE FROM facility_fragility WHERE FACILITY_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_user_3: del facility_fragility";
	start_page('Successful User Deletion');
	pr "The user was successfully deleted.";
    }
}


sub process_edit_facility {
    my $key = $q->param('key');
    my $comment = <<__EOF__;
Lat Max defaults to Lat Min and Lon Max defaults to Lon Min.
__EOF__
    ;
    edit_table_entry('submitfac', 'Facility', $comment, 'FACILITY',
		     'FACILITY_ID', $key, undef, undef,
		     $facility_form);
}


sub process_facilities {
    start_page('Facility Administration');
    print <<__EOF__;
<form method=post action="$script">
    <table $TABLE_ATTRS>
	<tr><td>Name Starts With<td><input type=text name=facname> or
	<tr><td>Short Name Starts With<td><input type=text name=shortname> or
	<tr><td>Description Starts With<td><input type=text name=descr>
    </table>
    <p>
    <input type=submit value=Find name=xfind>
    <input type=submit value=New  name=xnew>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=reset value="Clear Form">
    <input type=hidden name=type value=findfacs>    
</form>
__EOF__
    ;
}


sub process_find_facilities {
    my ($caption, $where);

	my $skip = $q->param('skip') || 0;  #kwl
	my $order = $q->param('order') || 'FACILITY_NAME';  #kwl

#     pr 'Where :',join(', ',$q->param), $q->self_url();
   if ($q->param('xnew')) { process_edit_facility() }
    elsif (! $where) {
	if (my $facname = $q->param('facname')) {
	    $caption = "Facilities with Name Starting with '$facname'";
	    $where = qq[WHERE FACILITY_NAME LIKE '$facname%'];
	}
	elsif (my $shortname = $q->param('shortname')) {
	    $caption = "Facilities with Short Name Starting with '$shortname'";
	    $where = qq[WHERE SHORT_NAME LIKE '$shortname%'];
	}
	elsif (my $descr = $q->param('descr')) {
	    $caption = "Facilities with Description Starting with '$descr'";
	    $where = qq[WHERE SHORT_NAME LIKE '$descr%'];
	}
	start_page('ShakeCast Facilities');
	pr qq[<h3>$caption</h3>] if $caption;
	show_table('FACILITY', $where, $order,
		   $facility_layout, $skip,  #kwl
		   ['fragility', 'facfrag', 'FACILITY_ID'],
		   ['edit', 'editfac', 'FACILITY_ID'],
		   ['delete', 'delfac', 'FACILITY_ID']);
	print <<__EOF__;
<form method=post action="$script">
    <p>
    <input type=submit value=New name=xnew>
    <input type=hidden name=type value=editfac>
</form>
__EOF__
    ;
    }
}


sub process_submit_facility {
    my @missing;

    my $key = $q->param('key');
    $q->param('TXT_LAT_MAX', $q->param('TXT_LAT_MIN')) unless
	$q->param('TXT_LAT_MAX');
    $q->param('TXT_LON_MAX', $q->param('TXT_LON_MIN')) unless
	$q->param('TXT_LON_MAX');
    if ($key) { 
	@missing = update_table_entry('FACILITY',
				      'FACILITY_ID', $key,
				      undef, undef,
				      $facility_form);
    }
    else {
	@missing = insert_table_entry('FACILITY',
				      $facility_form);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
	start_page('Success');
	pr qq[<b>Transaction successfully completed.</b>];
    }
}


#
### Facility Fragility
#

sub process_delete_facility_fragility {
    start_page("Delete Facility Fragility");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    print <<__EOF__;
Do you really want to delete the designated facility fragility?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=delfacfrag2>
    <input type=hidden name=key value="$key">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>   
</form>
__EOF__
    ;    
}


sub process_delete_facility_fragility_2 {
    if ($q->param('del_no')) {
	start_page('Deletion Cancelled');
	pr "Deletion of facility fragility was cancelled.";
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM facility_fragility WHERE FACILITY_FRAGILITY_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_facility_fragility_2: del facility_fragility";
	start_page('Successful Facility Fragility Deletion');
	pr "The facility fragility was successfully deleted.";
    }
}


sub process_edit_facility_fragility {
    my $facility_key = $q->param('fkey');
    my $key = $q->param('key');
    my ($name, $short_name, $factype) = get_facility_info($facility_key);
    edit_table_entry('submitfacfrag',
		     "Facility Fragility for $name ($short_name) [$factype]",
		     undef,
		     'FACILITY_FRAGILITY',
		     'FACILITY_FRAGILITY_ID', $key,
		     'FACILITY_ID', $facility_key,
		     $facility_fragility_form);
}


sub process_facility_fragility {
	my $skip = $q->param('skip') || 0;  #kwl
	my $order = $q->param('order') || 'LOW_LIMIT';  #kwl

    start_page('Fragility');
    my $key = $q->param('key');
    quit 'Key is required.' unless $key;
    my ($name, $short_name, $factype) = get_facility_info($key);
    pr "Facility Fragility for <b>$name ($short_name) [$factype]</b>:";
    pr "<p>";
    show_table("FACILITY_FRAGILITY", "WHERE FACILITY_ID = $key",
	       $order, $facility_fragility_layout, $skip,  #kwl
	       ['edit', 'editfacfrag', 'FACILITY_FRAGILITY_ID',
		"fkey=$key"],
	       ['delete', 'delfacfrag', 'FACILITY_FRAGILITY_ID']);
    print <<__EOF__;
<form methos=POST action="$script">
    <p>
	<input type=submit value=New name=xnew>
	<input type=hidden name=type value=editfacfrag>
	<input type=hidden name=fkey value=$key>
</form>
__EOF__
    ;	
}


sub process_submit_facility_fragility {
    my @missing;

    my $key = $q->param('key');
    my $key2 = $q->param('key2');
    if ($key) { 
	@missing = update_table_entry('FACILITY_FRAGILITY',
				      'FACILITY_FRAGILITY_ID', $key,
				      undef, undef,
				      $facility_fragility_form);
    }
    else {
	@missing = insert_table_entry('FACILITY_FRAGILITY',
				      $facility_fragility_form,
				      'FACILITY_ID', $key2);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
	start_page('Success');
	pr qq[<b>Transaction successfully completed.</b>];
    }
}


#
### Notification Requests
#

sub gen_notify_edit {
    my ($r, $ukey) = @_;
    my $type;

    my $key = $r->{NOTIFICATION_REQUEST_ID};
    my $ntype = $r->{NOTIFICATION_TYPE};
    my $nclass = get_notification_class($ntype);
    if ($nclass eq 'EVENT') { $type = 'editnotify_e' }
    elsif ($nclass eq 'PRODUCT') { $type = 'editnotify_p' }
    elsif ($nclass eq 'GRID') {
	if ($ntype eq 'SHAKING') { $type = 'editnotify_s' }
	elsif ($ntype eq 'DAMAGE') { $type = 'editnotify_d' }
	else { quit "Impossible notification type: [$ntype]" }
    }
    else { quit "Impossible notification class: [$nclass]" }
    my $parms = "key=$key;ukey=$ukey";
    my $s = qq[<td><a href="$script?type=$type;$parms">edit</a>];
    return $s;
}


sub gen_notify_facility {
    my ($r) = @_;

    my $key = $r->{NOTIFICATION_REQUEST_ID};
    my $sth = $dbh->prepare(qq{
        select count(*) from facility_notification_request
         where notification_request_id = ?}) or dbquit "prepare failed";
    $sth->execute($key) or dbquit "execute";
    my $n_facs = $sth->fetchrow_array;
    my $s = qq[<td><a href="$script?type=facnotify;key=$key">${n_facs}&nbsp;facilities</a>];
    return $s;
}


sub process_delete_notify {
    start_page("Delete Notification Request");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    my $ukey = $q->param('key2');
    print <<__EOF__;
Do you really want to delete the designated notification request?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=delnotify2>
    <input type=hidden name=key value="$key">
    <input type=hidden name=key2 value="$ukey">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>   
</form>
__EOF__
    ;    
}


sub process_delete_notify_2 {
    my $caption;

    if ($q->param('del_no')) {
#	start_page('Deletion Cancelled');
#	pr "Deletion of notification request was cancelled.";
	$caption = 'Notification Request deletion was cancelled!';
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM facility_notification_request WHERE NOTIFICATION_REQUEST_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_notify_2a";
	$dbh->do("DELETE FROM notification_request WHERE NOTIFICATION_REQUEST_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_notify_2b";
#	start_page('Successful Notification Request Deletion');
#	pr "The notification request was successfully deleted.";
	$caption = 'Notification Request deletion was successful!';
    }
    $q->param('key', $q->param('key2'));
    process_notify($caption);
}


sub process_edit_notify {
    my ($caption, $type, $form) = @_;
    my $user_key = $q->param('ukey');
    my $key = $q->param('key');
    my ($uname, $fullname) = get_user_info($user_key);
    edit_table_entry("$type;key2=$user_key",
		     "$caption Notification Request for $fullname ($uname)",
		     undef,
		     'NOTIFICATION_REQUEST',
		     'NOTIFICATION_REQUEST_ID', $key, 
		     'SHAKECAST_USER', $user_key,
		     $form);
}


sub process_edit_notify_e {
    process_edit_notify('Event', 'submitnotify_e',
			$notification_request_form_e);
}


sub process_edit_notify_p {
    process_edit_notify('Product', 'submitnotify_p',
			$notification_request_form_p);
}


sub process_edit_notify_s {
    process_edit_notify('Shaking', 'submitnotify_s',
			$notification_request_form_s);
}


sub process_edit_notify_d {
    process_edit_notify('Damage', 'submitnotify_d',
			$notification_request_form_d);
}


sub process_edit_notify_c {
    process_clone_notification_req();
}


sub process_new_notify {
    if ($q->param('xenew')) { process_edit_notify_e() }
    elsif ($q->param('xpnew')) { process_edit_notify_p() }
    elsif ($q->param('xsnew')) { process_edit_notify_s() }
    elsif ($q->param('xdnew')) { process_edit_notify_d() }
    elsif ($q->param('xcnew')) { process_edit_notify_c() }
    else { quit "Unknown notification request creation type" }
}


sub process_clone_notification_req {
    start_page("Copy Notifications");
    my @values;
    my %labels;
    my $user_key = $q->param('ukey');
    my ($uname, $fullname) = get_user_info($user_key);
    my $sth = $dbh->prepare(qq/
        select shakecast_user,
               full_name
          from shakecast_user
         where shakecast_user <> ?
         order by full_name/);
    $sth->execute($user_key);
    while (my $p = $sth->fetchrow_arrayref) {
        push @values, $p->[0];
        $labels{$p->[0]} = $p->[1];
    }

    pr "Choose a user to copy notification requests from.  ";
    pr "All notification requests for the selected user will be ";
    pr "added to those for $fullname ($uname).";
    pr "<br>";
    pr qq/<form method=POST action="$script">/;
    pr $q->scrolling_list(-name => 'source_user',
                          -values =>  \@values, 
                          -labels =>  \%labels, 
                          -size => 20);
    pr "<br>";
    pr  <<__EOF__;
    <p>
	<input type=submit value="Add" name=xcnadd>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Cancel" name=xfdone>
	    &nbsp;&nbsp;&nbsp;
	<input type=hidden name=type value=clonenotifyaction>
	<input type=hidden name=ukey value=$user_key>
</form>
__EOF__
}

sub process_clone_notification_action {
    my $user_key = $q->param('ukey');
    my $source_user = $q->param('source_user');
    quit 'user and source_user are required.' unless $user_key && $source_user;
    my $sth_n = $dbh->prepare(qq/
        select notification_request_id,
               damage_level,
               notification_type,
               event_type,
               delivery_method,
               message_format,
               limit_value,
               user_message,
               notification_priority,
               auxiliary_script,
               disabled,
               product_type,
               metric,
               aggregate,
               aggregation_group
          from notification_request
         where shakecast_user = ?/);
    my $sth_i = $dbh->prepare(qq/
        insert into notification_request (
               damage_level,
               notification_type,
               event_type,
               delivery_method,
               message_format,
               limit_value,
               user_message,
               notification_priority,
               auxiliary_script,
               disabled,
               product_type,
               metric,
               aggregate,
               aggregation_group,
               shakecast_user,
               update_username,
               update_timestamp)
        values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)/);
    $sth_n->execute($source_user);

    my %needed_methods; # remember needed delivery methods here
    while (my @v = $sth_n->fetchrow_array) {
        my $old_id = shift @v;
        $needed_methods{$v[3]} = $v[3];
        $sth_i->execute(@v, $user_key, $admin_user, ts()) or quit $DBI::errstr;
        # get the notification_request_id for the record just inserted
        my $new_id = $dbh->{mysql_insertid};
        quit 'insert id is null' unless $new_id;
        # copy all the facilities for one notification request
        $dbh->do(qq/
            insert into facility_notification_request (
                   notification_request_id, facility_id)
                   select $new_id, fnr.facility_id
                     from facility_notification_request fnr
                    where fnr.notification_request_id = ?/, undef, $old_id)
            or quit $DBI::errstr;
    }
    # create any missing delivery methods for the new user
    # find out what methods already exist for the new user
    my $existing_methods = $dbh->selectcol_arrayref(qq/
        select distinct delivery_method
          from user_delivery_method
         where shakecast_user = ?/, undef, $user_key)
            or quit $DBI::errstr;
    foreach my $m (@$existing_methods) {
        delete $needed_methods{$m};
    }
    # now %needed_methods only contains delivery_methods we must still create
    foreach my $m (keys %needed_methods) {
        $dbh->do(qq/
            insert into user_delivery_method (
                   delivery_method,
                   shakecast_user,
                   update_username,
                   update_timestamp)
            values (?, ?, ?, ?)/, undef, $m, $user_key, $admin_user, ts())
                or quit $DBI::errstr;
    }

    $q->param('key', $q->param('ukey'));
    # if we added any delivery methods then go to the maintenance page
    # for them so the addresses can be filled in (we did not copy those).
    if (%needed_methods) {
        #$q->param('key', $q->param('ukey'));
        #process_user_delivery();
        # changed my mind on this -- better to just let the user know
        process_notify('Notifications were copied successfully.  Please complete delivery methods.');
    } else {
        process_notify('Notifications were copied successfully');
    }
}


sub process_notify_facility {
    my $success = shift;

    start_page('Notification Request Facilities');
    my $key = $q->param('key');
    quit 'Key is required.' unless $key;
    if ($success) {
	pr "<font color=teal><b>$success</b></font><p>";
    }
    print <<__EOF__;
<form method=POST action="$script">
    <p>
	<input type=submit value="Add" name=xfadd>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Done" name=xfdone>
	    &nbsp;&nbsp;&nbsp;
	<input type=hidden name=type value=notifyaction>
	<input type=hidden name=key value=$key>
</form>
<p>
__EOF__
    pr "Facilities for Notification Request <b>$key</b>:";
    pr "<p>";
    show_table("facility_notification_request fn inner join facility f on fn.facility_id = f.facility_id",
                "WHERE fn.notification_request_id = $key",
	       "f.facility_name", $facility_notification_layout, 0,  #kwl
	       ['delete', 'delfacrequest',
                "key=$key",
		"key2=~FACILITY_ID"]);
    print <<__EOF__;
<form method=POST action="$script">
    <p>
	<input type=submit value="Add" name=xfadd>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Done" name=xfdone>
	    &nbsp;&nbsp;&nbsp;
	<input type=hidden name=type value=notifyaction>
	<input type=hidden name=key value=$key>
</form>
__EOF__
}


# key -> notification_request_id
sub process_notify_facility_action {
    my $p = $dbh->selectrow_arrayref(qq{
        select shakecast_user,
               damage_level
          from notification_request
         where notification_request_id = ?},
        undef,
        $q->param('key')) or dbquit "getting request data";
    if ($q->param('xfdone')) {
        $q->param('key', $p->[0]); # expects key -> shakecast_user
        process_notify();
    } elsif ($q->param('xfadd')) {
        # pass damage level
        construct_facility_filter(ns($p->[1]));
    } else {
        quit "Unrecognized or missing action";
    }
}


sub construct_facility_filter {
    my $damage = shift;
    my $key = $q->param('key');
    my $sth;
    my $attr_name = '';
    my @attr_values;

    start_page("Define Filter Criteria");
    pr qq[Facilities with fragility defined for $damage damage level<br>\n]
        if $damage;
    pr qq[<form name=f method=POST action="$script">];

    $sth = $dbh->prepare(qq{
        select facility_type,
               count(*)
          from facility
         group by facility_type}) or dbquit "prepare";
    $sth->execute or dbquit "execute";
    while (my $p = $sth->fetchrow_arrayref) {
        push @attr_values, [ $p->[0], ($p->[0] . ' (' . $p->[1] . ')') ];
    }
    pr make_one_filter_list('FACILITY_TYPE', \@attr_values);

    $sth = $dbh->prepare(qq{
        select attribute_name,
               attribute_value,
               count(*)
          from facility_attribute
         group by attribute_name, attribute_value}) or dbquit "prepare";
    $sth->execute or dbquit "execute";
    undef @attr_values;
    while (my $p = $sth->fetchrow_arrayref) {
        if ($p->[0] ne $attr_name) {
            if ($attr_name) {
                pr make_one_filter_list($attr_name, \@attr_values);
                undef @attr_values;
            }
            $attr_name = $p->[0];
        }
        push @attr_values, [ $p->[1], ($p->[1] . ' (' . $p->[2] . ')') ];
    }
    if ($attr_name) {
        pr make_one_filter_list($attr_name, \@attr_values);
    }
    print <<__EOF__;
    <p>
	<input type=submit value="Query" name=xadd>
	<input type=hidden name=type value=selfacrequest>
	<input type=hidden name=key value=$key>
	<input type=hidden name=damage value=$damage>
</form>
<script language="Javascript">document.f.reset();</script>
__EOF__
}

# Given a dimension name and a list of possible values, return a
# SELECT construct
sub make_one_filter_list {
    my ($attr_name, $attr_valp) = @_;
    if (scalar @$attr_valp == 0) {
        # no values
        return '';
    }
    my $block;
    my $label = $attr_name;
    $label =~ s/_/ /g;
    $label = join(' ', map { ucfirst lc $_ } split(' ', $label));
    $block  = '<p>';
    $block .= qq[
        <script language="JavaScript">
            function click$attr_name() { document.f.ATTR_$attr_name.disabled = ! document.f.CHK_$attr_name.checked }
        </script>];
    $block .= qq[<input name="CHK_$attr_name" type=checkbox value=1 onClick="click$attr_name();">];
    $block .= qq[&nbsp;$label\n<br>\n];
    $block .= qq[<select name="ATTR_$attr_name" multiple size=8 disabled=! document.f.CHK_$attr_name.checked>\n];
    $block .= join "\n",
            map { qq{<option value="} . $_->[0] . qq{">} . $_->[1] . qq{</option>} } @$attr_valp;
    $block .= qq[\n</select>\n];
    $block .= qq[<input type=hidden name=attr value="$attr_name">];
    return $block;
}

sub build_facility_where {
    my $damage = shift;
    my @attrs = $q->param('attr');
    my @tables;
    my @pred;
    my $errmsg;
    my $nr = 0;
    foreach my $attr (@attrs) {
        if ($q->param("CHK_$attr")) {
            # user enabled this term
            my @values = $q->param("ATTR_$attr");
            if (scalar @values == 0) {
                # XXX not sure if this is optimal behavior but it's just too
                # messy to handle an empty choice list.
                $errmsg .= "You must select at least one $attr<br>\n";
                next;
            }
            my $inlist = join ',', map { qq{'$_'} } @values;
            if ($attr eq 'FACILITY_TYPE') {
                # special case because this is stored directly in
                # the facility table
                push @pred, "facility_type IN ($inlist)";
            } else {
                my $alias = "fa$nr";
                $nr++;
                push @tables, "facility_attribute $alias";
                push @pred, "facility.facility_id = $alias.facility_id";
                push @pred, "$alias.attribute_value IN ($inlist)";
            }
        }
    }
    if ($damage) {
        push @tables, 'facility_fragility ff';
        push @pred, 'facility.facility_id = ff.facility_id';
        push @pred, qq{ff.damage_level = '$damage'};
    }
    return (\@tables, \@pred);
}

sub process_sel_fac_req {
    start_page('Add Facilities');
    my $key = $q->param('key');
    my $damage = $q->param('damage');
    quit 'Key is required.' unless $key;
    pr "Add Facilities to Notification Request <b>$key</b>:";
    pr '<p>';
    my ($tablep, $predp) = build_facility_where($damage);
    my $tables = join ',', ('facility', @$tablep);
    my $where  = (scalar @$predp) ? ('where ' . join(' and ', @$predp)) : '';
    my $pp = $dbh->selectall_arrayref(qq{
        select facility.facility_id, facility.facility_name
          from $tables
          $where
          order by facility.facility_name})
            or dbquit "Can't select";
    my $nrows = scalar @$pp;
    if ($nrows == 0) {
        quit "No facilities match your query";
    }
    pr qq[<form method=POST action="$script">];
    my $ssize = ($nrows > 20 ) ? 20 : $nrows;
    pr qq[<select name="TXT_FACILITY" multiple size=$ssize>];
    foreach my $r (@$pp) {
        my $s = qq[<option value="$r->[0]">];
        $s .= $r->[1];
        $s .= qq[</option>];
        pr $s;
    }
    pr qq[</select>\n];
    print <<__EOF__;
    <p>
	<input type=submit value="Add" name=xadd>
	    &nbsp;&nbsp;&nbsp;
	<input type=hidden name=type value=addfacrequest>
	<input type=hidden name=key value=$key>
</form>
__EOF__
}

sub process_add_fac_req {
    my $request_id = $q->param('key');
    my @facilities = $q->param('TXT_FACILITY');
    my $n_add = 0;
    my $n_had = 0;
    quit "Key is required" unless $request_id;
    if (scalar @facilities == 0) {
        process_notify_facility("No facilities were selected");
    } else {
        my $sth = $dbh->prepare(qq{
            insert into facility_notification_request (
                facility_id,
                notification_request_id) values (?,?)}) or dbquit "Can't prepare insert";
        foreach my $fac (@facilities) {
            if ($sth->execute($fac, $request_id)) {
                $n_add++;
            } else {
                dbquit("facility_notificatin_request")
                       unless ($sth->errstr =~ /duplicate entry/i);
                $n_had++;
            }
        }
        my $msg = "$n_add facilities were added";
        $msg .= " ($n_had already existed)" if ($n_had);
        process_notify_facility($msg);
    }
}

sub process_del_fac_req {
    #start_page('Remove Facilities from Notification Request');
    my $request_id = $q->param('key');
    my $facility_id = $q->param('key2');
    quit "Keys are required ($request_id, $facility_id)" unless $request_id and $facility_id;
    #pr "$key, $key2";
    my $nrows = $dbh->do(qq{
        delete from facility_notification_request
         where facility_id = ?
           and notification_request_id = ?},
        undef,
        $facility_id,
        $request_id) or dbquit("Can't remove facility from request");
    process_notify_facility($nrows ? "Removal was successful" : "record not found");
}


sub process_notify {
    my $success = shift;

    start_page('Notification Requests');
    my $key = $q->param('key');
    quit 'Key is required.' unless $key;
    my ($uname, $fullname) = get_user_info($key);
    if ($success) {
	pr "<font color=teal><b>$success</b></font><p>";
    }
    pr "Notification requests(s) for <b>$fullname ($uname)</b>:";
    pr "<p>";
    show_table("NOTIFICATION_REQUEST", "WHERE SHAKECAST_USER = $key",
	       "NOTIFICATION_TYPE", $notification_request_layout, 0,  #kwl
	       [\&gen_notify_facility],
	       [\&gen_notify_edit, $key],
	       ['delete', 'delnotify', 'NOTIFICATION_REQUEST_ID',
		"key2=$key"]);
    print <<__EOF__;
<form method=POST action="$script">
    <p>
	<b>Create New Notification Requests:<p>
    <p>
	<input type=submit value="Event" name=xenew>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Product" name=xpnew>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Shaking" name=xsnew>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Damage" name=xdnew>
	    &nbsp;&nbsp;&nbsp;
	<input type=submit value="Copy User" name=xcnew>
	    &nbsp;&nbsp;&nbsp;
	<input type=hidden name=type value=newnotify>
	<input type=hidden name=ukey value=$key>
</form>
__EOF__
    ;	
}


sub process_submit_notify {
    my $form = shift;
    my @missing;
    my $kind;

    my $key = $q->param('key');
    my $key2 = $q->param('key2');
    if ($key) { 
	$kind = "Update was successful!";
	@missing = update_table_entry('NOTIFICATION_REQUEST',
				      'NOTIFICATION_REQUEST_ID', $key,
				      undef, undef,
				      $form);
    }
    else {
	$kind = "Insert was successful!";
	@missing = insert_table_entry('NOTIFICATION_REQUEST',
				      $form,
				      'SHAKECAST_USER', $key2);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
#	start_page('Success');
#	pr qq[<b>Transaction successfully completed.</b>];
	$q->param('key', $key2);
	process_notify($kind);
    }
}


sub process_submit_notify_e {
    process_submit_notify($notification_request_form_e);
}


sub process_submit_notify_p {
    process_submit_notify($notification_request_form_p);
}


sub process_submit_notify_s {
    process_submit_notify($notification_request_form_s);
}


sub process_submit_notify_d {
    my %levels;

    my $damage = $q->param('TXT_DAMAGE_LEVEL');
    unless ($damage) {
	start_page('Missing Values');
	print <<__EOF__;
A <b>Damage Level</b> is required for this kind of
Notification Request.
<p>
Please go back and correct the request.
__EOF__
    ;
    }
    else {
        process_submit_notify($notification_request_form_d);
    }
}


#
### Users
#

sub process_delete_user {
    start_page("Delete User");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    my ($uname, $fullname) = get_user_info($key);
    my ($pfname) = ns($q->param('fname'));
    my ($puname) = ns($q->param('uname'));
    print <<__EOF__;
Do you really want to delete user <b>$fullname ($uname)</b> and all
associated data?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=deluser2>
    <input type=hidden name=key value="$key">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>  
    <input type=hidden name=fname value=$pfname>
    <input type=hidden name=uname value=$puname> 
</form>
__EOF__
    ;    
}


sub process_delete_user_2 {
    my $caption;
    if ($q->param('del_no')) {
#	start_page('Deletion Cancelled');
#	pr "Deletion of user was cancelled.";
	$caption = 'User deletion was cancelled!';
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM user_delivery_method WHERE SHAKECAST_USER = ?",
		 undef, $key) or
		     dbquit "process_delete_user_2: del user_delivery_method";
	$dbh->do("DELETE FROM notification_request WHERE SHAKECAST_USER = ?",
		 undef, $key) or
		     dbquit "process_delete_user_2: del notification_request";
	$dbh->do("DELETE FROM shakecast_user WHERE SHAKECAST_USER = ?",
		 undef, $key) or
		     dbquit "process_delete_user_2: del shakecast_user";
	$caption = 'User deletion was successful!';
#	start_page('Successful User Deletion');
#	pr "The user was successfully deleted.";
    }
    process_find_users($caption);
}


sub process_edit_user {
    if ($q->param('xfind')) { process_users() }
    else {
	my $key = $q->param('key');
	my $fname = ns($q->param('fname'));
	my $uname = ns($q->param('uname'));
	edit_table_entry("submituser;fname=$fname;uname=$uname",
			 'User', undef, 'SHAKECAST_USER',
			 'SHAKECAST_USER', $key, undef, undef,
			 $shakecast_user_form);
    }
}


sub process_find_users {
    my $success = shift;
    my ($caption, $where);
	my $skip = $q->param('skip') || 0;  #kwl
	my $order = $q->param('order') || 'USERNAME';  #kwl

    if ($q->param('xnew')) { process_edit_user() }
    else {
	my $fname = $q->param('fname');
	my $uname = $q->param('uname');
	if ($fname) {
	    $caption = "Users with Full Name starting with '$fname'";
	    $where = qq[WHERE FULL_NAME LIKE '$fname%'];
	}
	elsif ($uname) {
	    $caption = "Users with User Name starting with '$uname'";
	    $where = qq[WHERE USERNAME LIKE '$uname%'];
	}
	start_page('ShakeCast Users');
	if ($success) {
	    pr "<font color=teal><b>$success</b></font><p>";
	}
	pr qq[<h3>$caption</h3><p>] if $caption;
	show_table('SHAKECAST_USER',
		   $where, $order,
		   $shakecast_user_layout,  $skip,  # kwl
		   ['delivery', 'userdeliv', 'SHAKECAST_USER'],
		   ['notify', 'notify', 'SHAKECAST_USER'],
		   ['edit',
		    "edituser;fname=$fname;uname=$uname",
		    'SHAKECAST_USER'],
		   ['password',
		    "edituserpwd;fname=$fname;uname=$uname",
		    'SHAKECAST_USER'],
		   ['delete',
		    "deluser;fname=$fname;uname=$uname",
		    'SHAKECAST_USER']);
	print <<__EOF__;
<form method=post action="$script">
    <p>
    <input type=submit value=New  name=xnew>
    &nbsp;&nbsp;&nbsp;
    <input type=submit value="Go to Find"  name=xfind>
    <input type=hidden name=type value=edituser>
    <input type=hidden name=fname value=$fname>
    <input type=hidden name=uname value=$uname>
</form>
__EOF__
    ;
    }
}


sub process_users {
    start_page('User Administration');
    print <<__EOF__;
<form method=post action="$script">
    <table $TABLE_ATTRS>
	<tr><td>Full Name Starts With<td><input type=text name=fname> or
        <tr><td>User Name Starts With<td><input type=text name=uname>
    </table>
    <p>
    <input type=submit value=Find name=xfind>
    <input type=submit value=New  name=xnew>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=reset value="Clear Form">
    <input type=hidden name=type value=findusers>
</form>
__EOF__
    ;
}


sub process_submit_user {
    my @missing;
    my $kind;

    my $key = $q->param('key');
    if ($key) { 
	$kind = 'Update was successful!';
	@missing = update_table_entry('SHAKECAST_USER',
				      'SHAKECAST_USER', $key,
				      undef, undef,
				      $shakecast_user_form);
    }
    else {
	$kind = 'Insert was successful!';
	@missing = insert_table_entry('SHAKECAST_USER',
				      $shakecast_user_form);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
#	start_page('Success');
#	pr qq[<b>Transaction successfully completed.</b>];
	process_find_users($kind);
    }
}


#
### User Delivery Methods
#

sub process_delete_user_method {
    start_page("Delete User Method");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    print <<__EOF__;
Do you really want to delete the designated method?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=delumethod2>
    <input type=hidden name=key value="$key">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>   
</form>
__EOF__
    ;    
}


sub process_delete_user_method_2 {
    if ($q->param('del_no')) {
	start_page('Deletion Cancelled');
	pr "Deletion of user delivery method was cancelled.";
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM user_delivery_method WHERE USER_DELIVERY_METHOD_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_user_method_2: del user_delivery_method";
#	start_page('Successful User Delivery Method Deletion');
#	pr "The method was successfully deleted.";
	process_find_users('Delivery method deleted');
    }
}


sub process_edit_user_method {
    my $user_key = $q->param('ukey');
    my $key = $q->param('key');
    my ($uname, $fullname) = get_user_info($user_key);
    edit_table_entry('submitumethod',
		     "Delivery Method for $fullname ($uname)",
		     undef,
		     'USER_DELIVERY_METHOD',
		     'USER_DELIVERY_METHOD_ID', $key,
		     'SHAKECAST_USER', $user_key,
		     $user_delivery_method_form);
}


sub process_submit_user_method {
    my @missing;
    my $action;

    my $key = $q->param('key');
    my $key2 = $q->param('key2');
    if ($key) { 
        $action = 'updated';
	@missing = update_table_entry('USER_DELIVERY_METHOD',
				      'USER_DELIVERY_METHOD_ID', $key,
				      undef, undef,
				      $user_delivery_method_form);
    }
    else {
        $action = 'added';
	@missing = insert_table_entry('USER_DELIVERY_METHOD',
				      $user_delivery_method_form,
				      'SHAKECAST_USER', $key2);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
#	start_page('Success');
#	pr qq[<b>Transaction successfully completed.</b>];
	process_find_users("Delivery method $action");
    }
}


sub process_user_delivery {
    start_page('Delivery Methods');
    my $key = $q->param('key');
    quit 'Key is required.' unless $key;
    my ($uname, $fullname) = get_user_info($key);
    pr "Delivery method(s) for <b>$fullname ($uname)</b>:";
    pr "<p>";
    show_table("USER_DELIVERY_METHOD", "WHERE SHAKECAST_USER = $key",
	       "DELIVERY_METHOD", $user_delivery_method_layout, 0, # kwl
	       ['edit', 'editumethod', 'USER_DELIVERY_METHOD_ID',
		"ukey=$key"],
	       ['delete', 'delumethod', 'USER_DELIVERY_METHOD_ID']);
    print <<__EOF__;
<form methos=POST action="$script">
    <p>
	<input type=submit value=New name=xnew>
	<input type=hidden name=type value=editumethod>
	<input type=hidden name=ukey value=$key>
</form>
__EOF__
    ;	
}


#
### Templates
#

sub process_templates {
    start_page('Delivery Template Description Administration');
    print <<__EOF__;
<form method=post action="$script">
    <table $TABLE_ATTRS>
	<tr><td>Name Starts With<td><input type=text name=tname> or
        <tr><td>Description Starts With<td><input type=text name=desc>
    </table>
    <p>
    <input type=submit value=Find name=xfind>
    <input type=submit value=New  name=xnew>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=reset value="Clear Form">
    <input type=hidden name=type value=findtemplates>
</form>
__EOF__
    ;
}


sub process_find_templates {
    my $success = shift;
    my ($caption, $where);

    if ($q->param('xnew')) { process_edit_template() }
    else {
	my $tname = $q->param('tname');
	my $desc = $q->param('desc');
	if ($tname) {
	    $caption = "Delivery Templates with Name starting with '$tname'";
	    $where = qq[WHERE NAME LIKE '$tname%'];
	}
	elsif ($desc) {
	    $caption = "Delivery Templates with Description starting with '$desc'";
	    $where = qq[WHERE DESCRIPTION LIKE '$desc%'];
	}
	start_page('ShakeCast Delivery Template Descriptions');
	if ($success) {
	    pr "<font color=teal><b>$success</b></font><p>";
	}
	pr qq[<h3>$caption</h3><p>] if $caption;
	show_table('MESSAGE_FORMAT',
		   $where, 'NAME',
		   $template_layout, 0, # kwl
		   ['edit',
		    "edittemplate;tname=$tname;desc=$desc",
		    'MESSAGE_FORMAT'],
		   ['delete',
		    "deltemplate;tname=$tname;desc=$desc",
		    'MESSAGE_FORMAT']);
	print <<__EOF__;
<form method=post action="$script">
    <p>
    <input type=submit value=New  name=xnew>
    &nbsp;&nbsp;&nbsp;
    <input type=submit value="Go to Find"  name=xfind>
    <input type=hidden name=type value=edittemplate>
    <input type=hidden name=tname value=$tname>
    <input type=hidden name=desc value=$desc>
</form>
__EOF__
    ;
    }
}


sub process_edit_template {
    if ($q->param('xfind')) { process_templates() }
    else {
	my $key = $q->param('key');
	my $tname = ns($q->param('tname'));
	my $desc = ns($q->param('desc'));
	edit_table_entry("submittemplate;tname=$tname;desc=$desc",
			 'Template', undef, 'MESSAGE_FORMAT',
			 'MESSAGE_FORMAT', $key, undef, undef,
			 $template_form);
    }
}


sub process_submit_template {
    my @missing;
    my $kind;

    my $key = $q->param('key');
    if ($key) { 
	$kind = 'Update was successful!';
	@missing = update_table_entry('MESSAGE_FORMAT',
				      'MESSAGE_FORMAT', $key,
				      undef, undef,
				      $template_form);
    }
    else {
	$kind = 'Insert was successful!';
	@missing = insert_table_entry('MESSAGE_FORMAT',
				      $template_form);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
#	start_page('Success');
#	pr qq[<b>Transaction successfully completed.</b>];
	process_find_templates($kind);
    }
}


sub process_delete_template {
    start_page("Delete Delivery Template Description");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    print <<__EOF__;
Do you really want to delete the designated delivery template description?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=deltemplate2>
    <input type=hidden name=key value="$key">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>  
</form>
__EOF__
    ;    
}


sub process_delete_template_2 {
    if ($q->param('del_no')) {
	start_page('Deletion Cancelled');
	pr "Deletion of delivery template description was cancelled.";
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM message_format WHERE MESSAGE_FORMAT = ?",
		 undef, $key) or
		     dbquit "process_delete_template_2: del template";
	$dbh->do(<<__SQL__,undef, $key) or dbquit "process_delete_template_2: nullify refs";
UPDATE notification_request SET MESSAGE_FORMAT = NULL 
  WHERE MESSAGE_FORMAT = ?
__SQL__
;
	start_page('Successful Delivery Template Description Deletion');
	pr "The template description was successfully deleted.";
    }
}


#
### Servers
#

sub process_find_servers {
    my ($caption, $where);
    my $not_self = qq{(SELF_FLAG IS NULL OR SELF_FLAG = 0)};

    if ($q->param('snew')) { process_edit_server() }
    elsif ($q->param('thisserver')) { process_this_server() }
    else {
	if (my $serverid = ($q->param('serverid') || $q->param('key'))) {
	    $caption = "Server ID = '$serverid'";
	    $where = qq[WHERE SERVER_ID = $serverid AND $not_self];
	}
	elsif (my $hostname = $q->param('hostname')) {
	    $caption = "Servers with Hostname Starting with '$hostname'";
	    $where = qq[WHERE DNS_ADDRESS LIKE '$hostname%' AND $not_self];
	}
	else {
	    $where = qq[WHERE $not_self];
	}
	start_page('ShakeCast Servers');
	pr qq[<h3>$caption</h3>] if $caption;
	show_table('SERVER', $where, 'DNS_ADDRESS',
		   $server_layout, 0, # kwl
		   ['edit', 'editserver', 'SERVER_ID'],
		   ['delete', 'delserver', 'SERVER_ID'],
		   ['password', 'editserverpwd', 'SERVER_ID']);
	print <<__EOF__;
<form method=post action="$script">
    <p>
    <input type=submit value=New name=snew>
    <input type=hidden name=type value=editserver>
</form>
__EOF__
    ;
    }
}

sub process_edit_server {
    my $key = $q->param('key');
    my $comment = <<__EOF__;
__EOF__
    ;
    edit_table_entry('submitserver', 'Server', $comment, 'SERVER',
		     'SERVER_ID', $key, undef, undef,
		     $server_form);
}


sub process_submit_server {
    my @missing;
    my $caption;

    my $key = $q->param('key');
    if ($key) { 
	@missing = update_table_entry('SERVER',
				      'SERVER_ID', $key,
				      undef, undef,
				      $server_form);
    }
    else {
	@missing = insert_table_entry('SERVER',
				      $server_form);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
	$caption = 'Server update was successful!';
    }
    process_find_servers($caption);
}


sub process_this_server {
    my ($caption, $where);

    #start_page('ShakeCast Server Definition');
    my ($key) = $dbh->selectrow_array(qq{
	select server_id
	  from server
	 where self_flag=1});
    dbquit 'finding this server' if $dbh->errstr;

    edit_table_entry('submitthisserver', 'This Server', '', 'SERVER',
		     'SERVER_ID', $key, undef, undef,
		     $this_server_form);
}


sub process_submit_this_server {
    my @missing;

    my $key = $q->param('key');
    if ($key) { 
	@missing = update_table_entry('SERVER',
				      'SERVER_ID', $key,
				      undef, undef,
				      $this_server_form);
    }
    else {
	@missing = insert_table_entry('SERVER',
				      $this_server_form,
                                      'SELF_FLAG', 1);
    }
    if (@missing) {
	show_missing(@missing);
    }
    else {
	start_page('Success');
	pr qq[<b>Transaction successfully completed.</b>];
    }
}


sub process_servers {
    start_page('Server Administration');
    print <<__EOF__;
<form method=post action="$script">
    <table $TABLE_ATTRS>
	<tr><td>Server ID<td><input type=text name=serverid> or
	<tr><td>Hostname Starts With<td><input type=text name=hostname>
    </table>
    <p>
    <input type=submit value=Self name=thisserver>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=submit value=Find name=sfind>
    <input type=submit value=New  name=snew>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=reset value="Clear Form">
    <input type=hidden name=type value=findservers>    
</form>
__EOF__
    ;
}

sub process_delete_server {
    start_page("Delete Server");
    my $key = $q->param('key');
    quit "Key required." unless $key;
    my ($dns, $organization, $when) = get_server_info($key);
    my $last_heard_from;
    if (defined $when and $when) {
	$last_heard_from = "last heard from at $when";
    }
    else {
	$last_heard_from = "never heard from";
    }

    print <<__EOF__;
Do you really want to delete server ID: $key (hostname: $dns,
 $last_heard_from) and all
associated data?
<p>
<form method=POST action="$script">
    <input type=hidden name=type value=delserver2>
    <input type=hidden name=key value="$key">
    <input type=submit value=Yes name=del_yes>&nbsp;&nbsp;&nbsp; 
    <input type=submit value=No name=del_no>  
</form>
__EOF__
    ;    
}


sub process_delete_server_2 {
    my $caption;
    if ($q->param('del_no')) {
	$caption = 'Server deletion was cancelled!';
    }
    else {
	my $key = $q->param('key');
	$dbh->do("DELETE FROM server WHERE SERVER_ID = ?",
		 undef, $key) or
		     dbquit "process_delete_server_2: del server";
        delete_htpasswd($SERVER_PWDFILE, $key);
	$caption = 'Server deletion was successful!';
    }
    process_find_servers($caption);
}

sub process_edit_server_pwd {
    start_page('Edit Password for Remote Server');
    my $key = $q->param('key');
    quit "Key required." unless $key;
    my ($dns, $organization, $when) = get_server_info($key);
    print <<__EOF__;
Remote server <b>$dns</b> (ID = $key)
<p>
The <b>incoming password</b> is used by the remote Shakecast server
when connecting to this server.
The <b>outgoing password</b> is used by this server when making a connection
to the remote Shakecast server.
Your outgoing password to a particular server must match the incoming password
they have established for you, and vice-versa.
<form method=post action="$script">
    <table $TABLE_ATTRS>
	<tr><td>New Password<td><input type=password name=password1>
	<tr><td>Retype Password<td><input type=password name=password2>
    </table>
    <p>
    <input type=submit value="Update Incoming Password" name=xincoming>
    &nbsp;
    <input type=submit value="Update Outgoing Password" name=xoutgoing>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=reset value="Clear Form">
    <input type=hidden name=type value=editserverpwd2>    
    <input type=hidden name=key value="$key">
</form>
__EOF__
    ;
}


sub process_edit_server_pwd_2 {
    if ($q->param('xincoming')) {
	start_page("Edit Incoming Password for Remote Server");
    }
    elsif ($q->param('xoutgoing')) {
	start_page("Edit Outgoing Password for Remote Server");
    }
    else {
	quit 'neither incoming nor outgoing';
    }

    my $key = $q->param('key');
    quit "Key required." unless $key;
    my $password1 = $q->param('password1');
    my $password2 = $q->param('password2');
    quit "The two passwords must match" unless $password1 eq $password2;
    # XXX should we impose any password strength rules?
    if ($q->param('xincoming')) {
	update_incoming_password($key, $password1);
    }
    elsif ($q->param('xoutgoing')) {
	update_outgoing_password($key, $password1);
    }
    pr qq[<b>Transaction successfully completed.</b>];
}


sub process_edit_user_pwd {
    start_page('Edit Password for Local User');
    my $key = $q->param('key');
    quit "Key required." unless $key;
    my ($username, $full_name) = get_user_info($key);
    print <<__EOF__;
Local user $full_name ($username)
<form method=post action="$script">
    <table $TABLE_ATTRS>
	<tr><td>New Password<td><input type=password name=password1>
	<tr><td>Retype Password<td><input type=password name=password2>
    </table>
    <p>
    <input type=submit value="Update" name=xupdate>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    <input type=reset value="Clear Form">
    <input type=hidden name=type value=edituserpwd2>    
    <input type=hidden name=user value="$username">
</form>
__EOF__
    ;
}


sub process_edit_user_pwd_2 {
    if ($q->param('xupdate')) {
	start_page("Update Local User Password");
    }

    my $username = $q->param('user');
    quit "Username required." unless $username;
    my $password1 = $q->param('password1');
    my $password2 = $q->param('password2');
    quit "The two passwords must match" unless $password1 eq $password2;
    # XXX should we impose any password strength rules?
    update_user_password($username, $password1);
    pr qq[<b>Transaction successfully completed.</b>];
}


#
### Support Functions
#

sub dbquit {
    quit "Database Error: ", @_, ": ", $dbh->errstr;
}


sub delete_htpasswd {
    my ($passwordfile, $user) = @_;

    my $tempfile = "${passwordfile}~";
    open TEMP, "> $tempfile" or quit "Can't create $tempfile: $!";
    open PWD, "< $passwordfile" or quit "Can't open $passwordfile: $!";
    while (<PWD>) {
        next if /^$user:/o;
        print TEMP;
    }
    close PWD;
    close TEMP;
    chmod 0600, $tempfile;
    rename $passwordfile, "$passwordfile.bak"
        or quit "Can't rename $passwordfile: $!";
    rename $tempfile, $passwordfile or quit "Can't rename $tempfile: $!";
}


sub edit_table_entry {
    my ($type, $caption, $comment, $table, $key_name, $key_value,
	$key2_name, $key2_value, $layout) = @_;
    my (@names, @fields, @fvals, %fmap);
    my $r;
    my $numreq;
 
    $table = lc $table;
    my @list = @$layout;
    while (my $p = shift @list) {
	my $f = shift(@list);
	my ($fname, $rest) = split /\//, $f;
	my $nm = $p;
	if ($fname =~ s/^\+//) {	# drop 'required' flag if present
	    $nm .= ' <font color=red>*</font>';
	    $numreq++;
	}
	push @names, $nm;
	push @fields, $fname;
	$fmap{$fname} = $rest if $rest;
    }
    if ($key_value) {
	start_page("Edit $caption");
	my $sql = "SELECT " . join(',', @fields) . " FROM $table";
	$sql .= " WHERE $key_name = ?";
#	$sql .= " AND $key2_name = ?" if $key2_value;
	my $sth = $dbh->prepare($sql) or
	    dbquit "Can't prepare edit_table_entry (1)";
#	my @keys = ($key_value);
#	push @keys, $key2_value if $key2_value;
	$sth->execute($key_value) or
	    dbquit "Can't execute edit_table_entry (1): [$sql]";
	$r = $sth->fetchrow_arrayref;
	unless ($r) {
	    my $msg = "No entry in [$table] with [$key_name] = [$key_value]";
	    $msg .= " and [$key2_name] = [$key2_value]";
	    quit $msg;
	}
	@fvals = @$r;
    }
    else {
	start_page("New $caption");
    }
    if ($comment) {
	pr "$comment<p>";
    }
    pr qq[<form method=POST action="$script">];
    pr "<table $TABLE_ATTRS>";
    while (my $name = shift @names) {
	my $fname = shift @fields;
	my $val = ns(shift @fvals);
	if (exists $fmap{$fname}) {
	    my $p = make_combo_box($fname, $val, $fmap{$fname});
	    pr qq[<tr><td>$name<td>$p];
	}
	else {
	    pr qq[<tr><td>$name<td><input type=text name="TXT_$fname" value="$val">];
	}
    }
    pr "</table>";
    if ($numreq) {
	pr qq[(<font color=red>*</font> = required field)];
    }
    if ($key2_value) {
	pr qq[<input type=hidden name=key2 value="$key2_value">];
    }
    if ($key_value) {
	pr qq[<input type=hidden name=key value="$key_value">];
	pr qq[<p><input type=submit name=xupdate value="Update $caption">];
    }
    else {
	pr qq[<p><input type=submit name=xadd value="Add $caption">];
    }
    my ($t, @parms) = split /;/, $type;
    foreach my $p (@parms) {
	my ($nm, $val) = split /=/, $p;
	pr qq[<input type=hidden name=$nm value=$val>];
    }
    pr qq[<input type=hidden name=type value=$t>];
    pr "</form>";
}


sub end_page {
    if ($page_started and !$page_ended) {
	print $BOTTOM;
	my $footer = $config->{TemplateDir}.'/web/footer.htm';
	if (-e $footer) {
		open (TEMP, "< $footer") or quit "Can't open $footer: $!";
		print <TEMP>;
		close(TEMP);
	} else {
	print <<__EOF__;
</body>
</html>
__EOF__
    ;
	}
	$page_ended = 1;
    }
}


sub get_facility_info {
    my $key = shift;

    my $sth = $dbh->prepare(<<__SQL__);
SELECT FACILITY_NAME, SHORT_NAME, FACILITY_TYPE FROM facility
   WHERE FACILITY_ID = ?
__SQL__
    ;
    dbquit "get_facility_info prepare failed" unless $sth;
    $sth->execute($key) or dbquit "get_facility_info execute failed";
    my $r = $sth->fetchrow_arrayref or dbquit "get_facility_info fetch failed";
    return @$r;
}


sub get_notification_class {
    my $key = shift;

    my $sth = $dbh->prepare(<<__SQL__);
SELECT NOTIFICATION_CLASS FROM notification_type
   WHERE NOTIFICATION_TYPE = ?
__SQL__
    ;
    dbquit "get_notification_class prepare failed" unless $sth;
    $sth->execute($key) or dbquit "get_notification_class execute failed";
    my $r = $sth->fetchrow_arrayref or dbquit "get_notification_class fetch failed";
    return $r->[0];
}


sub get_user_info {
    my $key = shift;

    my $sth = $dbh->prepare(<<__SQL__);
SELECT USERNAME, FULL_NAME FROM shakecast_user WHERE SHAKECAST_USER = ?
__SQL__
    ;
    dbquit "get_user_info prepare failed" unless $sth;
    $sth->execute($key) or dbquit "get_user_info execute failed";
    my $r = $sth->fetchrow_arrayref or dbquit "get_user_info fetch failed";
    return @$r;
}


sub get_server_info {
    my $key = shift;

    my $sth = $dbh->prepare(<<__SQL__);
SELECT DNS_ADDRESS, OWNER_ORGANIZATION, LAST_HEARD_FROM
  FROM server WHERE SERVER_ID = ?
__SQL__
    ;
    dbquit "get_server_info prepare failed" unless $sth;
    $sth->execute($key) or dbquit "get_server_info execute failed";
    my $r = $sth->fetchrow_arrayref or dbquit "get_server_info fetch failed";
    return @$r;
}


sub insert_table_entry {
    my ($table, $layout, @extras) = @_;
    my (@fields, @values, @missing);

    $table = lc $table;
    my @list = @$layout;
    while (my $title = shift @list) {
	my $f = shift @list;
	my ($name, $rest) = split /\//, $f;
	my $req = $name =~ s/^\+//;
	push @fields, $name;
	my $v = $q->param("TXT_$name");
	if ($req and !$v) { push @missing, $title }
	else { push @values, (defined($v) and $v eq '') ? undef : $v }
    }
    unless (@missing) {
	while (my $name = shift @extras) {
	    push @fields, $name;
	    push @values, shift(@extras);
	}
	push @fields, 'UPDATE_USERNAME';
	push @values, $admin_user;
	push @fields, 'UPDATE_TIMESTAMP';
	push @values, ts();
	my $sql = "INSERT INTO $table (" . join(',', @fields) . ") ";
	$sql .= ' VALUES (' . join(',', ('?') x @fields) . ')';
	$dbh->do($sql, undef, @values) or dbquit "Can't insert";
    }
    return @missing;
}


sub make_combo_box {
    my ($fname, $val, $lookup) = @_;
    my $box;

    my ($table, $fval, $fshow, $order, $default, $where) = split /,/, $lookup;
    if ($table eq '*BOOL') {
	my $chk = $val ? ' checked' : '';
	$box = qq[<input name="TXT_$fname" type=checkbox value=1$chk>];
    }
    else {
	$fval ||= $table;
	$fshow ||= $fval;
	$order ||= $fshow;
        $table = lc $table;
	my $sql = "SELECT $fval, $fshow FROM $table";
	$sql .= " WHERE $where" if $where;
	$sql .= " ORDER BY $order";
	my $sth = $dbh->prepare($sql) or dbquit "Can't prepare make_combo_box";
	$sth->execute or dbquit "Can't execute make_combo_box";
	$box = qq[<select name="TXT_$fname">\n];
	unless ($val) { $val = $default if defined $default }
	$box .= qq[<option value=''></option>\n];
	while (my $r = $sth->fetchrow_arrayref) {
	    my $ss = ($val eq $r->[0]) ? ' selected' : '';
	    my $s = qq[<option value="$r->[0]"$ss>];
	    $s .= $r->[1];
	    $s .= qq[</option>\n];
	    $box .= $s;
	}
	$box .= qq[\n</select>];
    }
    return $box;
}


sub make_lookup_value {
    my ($val, $lookup) = @_;
    my $v;

    my ($table, $fval, $fshow) = split /,/, $lookup;
    if ($table eq '*BOOL') {
	if (nz($val)) { $v = $fshow }
	else { $v = $fval }
    }
    elsif ($val) {
        $table = lc $table;
	$fval ||= $table;
	$fshow ||= $fval;
	my $sql = qq[SELECT $fshow FROM $table WHERE $fval = ?];
	my $sth = $dbh->prepare($sql) or dbquit "Can't prepare make_lookup_value";
	$sth->execute($val) or dbquit "Can't execute make_lookup_value ($sql)(.$val.)";
	my $r = $sth->fetchrow_arrayref;
	$sth->finish;
	if ($r) { $v = $r->[0] }
    }
    return $v;
}


sub nbs_null {
    $_[0] ? $_[0] : '&nbsp;';
}


sub ns {
    $_[0] ? $_[0] : '';
}


sub nz {
    $_[0] ? $_[0] : 0;
}


sub pr {
    start_page() unless $page_started;
    print @_, "\n";
}


sub quit {
    start_page("ShakeCast Administration Error");
    pr "<font color=red size=+2><b>", @_, "</b></font>";
    pr "<p><hr>";
    end_page();
    exit;
}


sub show_missing {
    my @missing = @_;

    start_page('Missing Fields');
    pr "The following required fields were missing:<p>";
    pr "<blockquote>";
    foreach my $name (@missing) {
	pr "<font color=red><b>$name</b></font><br>";
    }
    pr "</blockquote>";
    pr "<p>Please go back and supply them.";
}


sub show_table {
    my ($table, $where, $order, $fp, $row_skip, @links) = @_;
    my (@names, @fields, %fmap);
	my $row_page = 20;

	$table = lc $table;
    my $nrows = 0;
    my @list = @$fp;
    while (my $p = shift @list) {
	push @names, $p;
	my $f = shift(@list);
	my ($fname, $rest) = split /\//, $f;
	push @fields, $fname;
	$fmap{$fname} = $rest if $rest;
    }
    my $sql = "SELECT " . join(',', @fields) . " FROM $table";
    $sql .= " $where" if $where;
    $sql .= " ORDER BY $order" if $order;

    my $sth = $dbh->prepare($sql) or dbquit("Can't prepare table selection");
#	$sth->mysql_use_result();
    $sth->execute or dbquit("Can't execute table selection");
	my $rows = $sth->rows;

	my $target_url = $q->self_url();
	$target_url =~ s/skip=(.*?)$//;
	$target_url =~ s/order=(.*?)$//;

    while (my $r = $sth->fetchrow_hashref) {
	unless ($nrows++) {
	    pr "<table $TABLE_ATTRS><tr>";
		if ($type =~ /find/i) {
		for my $ind (0 .. $#names) {
	      pr qq[<td><font size=-1><a href="$target_url;order=], $fields[$ind];
		  pr qq[">],$names[$ind], qq[</a></td>];
		  #my $s =  "<td><font size=-1>" . join('</td><td><font size=-1>', @names);  #kwl
		} 
		}else {
	      pr  qq[<td><font size=-1>], join('</td><td><font size=-1>', @names);
		}
	    pr "<td>&nbsp;</td>" x @links;  #kwl
	    pr '</tr>';  #kwl
	}
	  next unless ($nrows > $row_skip);
	  last if ($nrows > $row_page+$row_skip);
#	my $line = "<tr>";
	my $line = "<tr>";
	foreach my $fname (@fields) {
	    my $val = $r->{$fname};
	    if (exists $fmap{$fname}) {
		$line .= "<td><font size=-1>" . nbs_null(make_lookup_value($val,
							     $fmap{$fname})) . '</td>';
	    }
	    else {
		my $v = nbs_null($val);
		$line .= "<td><font size=-1>$v</td>";
	    }
	}
	foreach my $lp (@links) {
	    my ($text, $type, @keystrs) = @$lp;
	    if (ref($text) eq 'CODE') { $line .= &$text($r, $type, @keystrs) }
	    else {
		my $parms = '';
		foreach my $keystr (@keystrs) {
		    my ($keyname, $keyval) = split /=/, $keystr;
		    if ($keyval) {
			if ($keyval =~ s/^~//) { $keyval = $r->{$keyval} }
		    }
		    else {
			$keyval = $r->{$keyname};
			$keyname = 'key';
		    }
		    $parms .= ";$keyname=$keyval";
		}
		my $s = qq[<td><font size=-1><a href="$script?type=$type$parms">$text</a></td>];
		$line .= $s;
	    }
	}
	pr $line, '</tr>';
    }
    pr "</table>";
    pr "<p>";
    if ($nrows == 0) { pr "<b>There were no matching entries.</b>" }
    elsif ($nrows == 1) { pr "One matching entry." }
    else { 
	  pr "<font size=-2>$rows matching entries.<br><center>";
	    #kwl start
	  my $start_ind = int($row_skip / ($row_page*10)) * ($row_page*10);
	  my $jump_ind = $start_ind - ($row_page*10);
	  $target_url .= ";order=$order";

	  pr qq[<table border="0" cellpadding="0"><tr>];
	  my $fields;
	  foreach my $param ($q->param) {
	    next if ($param =~ /skip/i);
	    $fields .= qq[<input type=hidden value="].$q->param($param).qq[" name=$param>];
	  }
	  if ($row_skip-$row_page >= 0) {
  	    pr qq[<td align="right"><form method=get action="$script">$fields];
	    pr qq[<input type=hidden value="], $row_skip-$row_page, qq[" name=skip>],
		  qq[<input type=submit value="Previous Page"></td></form>];
	  }
	  if ($row_skip+$row_page <= $rows) {
  	    pr qq[<td align="left"><form method=get action="$script">$fields]; 
	    pr qq[<input type=hidden value="], $row_skip+$row_page, qq[" name=skip>],
		  qq[<input type=submit value="Next Page"></td></form>];
	  }
	  pr '</tr><tr align="center"><td colspan="2">';
	  if ($jump_ind >= 0) {
	    pr qq[<font size=-1>\[<a href="$target_url;skip=0">1</a>\] ... ];
	    pr qq[<font size=-1>\[<a href="$target_url;skip=$jump_ind"><<</a>\] | ];
	  }
	  for (my $ind = 1; $ind <= 10; $ind++) {
	    my $show_ind = $start_ind + ($ind-1)*$row_page;
		if ($show_ind < $rows) {
		  if ($show_ind != $row_skip) {
	        pr qq[<font size=-1><a href="$target_url;skip=$show_ind">], 
			$ind+$start_ind/$row_page, qq[</a> ];
		  } else {
	        pr qq[<font size=-1 color="#990000"><b>], $ind+$start_ind/$row_page, '</b></font>';
	      }
		}
	  }
	  $jump_ind = $start_ind + ($row_page*10);
	  if ($jump_ind < $rows) {
	    pr qq[ | \[<a href="$target_url;skip=$jump_ind">>></a>\] ];
		$rows -= $rows % $row_page;
	    pr qq[ ... \[<a href="$target_url;skip=$rows">], $rows/$row_page+1, qq[</a>\] ];
	  }
	    #kwl end
	  }
	  pr '</td></tr></table>';
}


sub start_page {
    my $title = shift;

    $title ||= 'ShakeCast Administration';
    unless ($page_started) {
	print "Content-Type: text/html\n\n";
	my $header = $config->{TemplateDir}.'/web/header.htm';
	if (-e $header) {
		open (TEMP, "< $header") or quit "Can't open $header: $!";
		print <TEMP>;
		close(TEMP);
	} else {
	print <<__EOF__;

<html>
<head>
<title>$title</title>
</head>
<body>
__EOF__
    ;
	}
	print "$TOP\n<h2>$title</h2>";
	$page_started = 1;
    }
}


sub ts {
    my $time = shift;
    my($sec, $min, $hr, $mday, $mon, $yr);

    $time = time unless defined $time;
    ($sec, $min, $hr, $mday, $mon, $yr) = localtime $time;
    sprintf ("%04d-%02d-%02d %02d:%02d:%02d",
	     $yr+1900, $mon+1, $mday,
	     $hr, $min, $sec);
}


sub update_user_password {
    my ($user, $new_password) = @_;

    my @args = qq("$HTPASSWD" -b $USER_PWDFILE $user $new_password);
    my $rc = system(@args);
    quit "htpasswd failed: $rc" if $rc;
}


sub update_incoming_password {
    my ($remote_server, $new_password) = @_;

    my @args = qq("$HTPASSWD" -b $SERVER_PWDFILE $remote_server $new_password);
    my $rc = system(@args);
    quit "htpasswd failed: $rc" if $rc;
}


sub update_outgoing_password {
    my ($remote_server, $new_password) = @_;
    my $encoded_password;

    if ($new_password eq '') {
        $encoded_password = undef;
    } else {
        $encoded_password = MIME::Base64::encode_base64($new_password);
    }

    $dbh->do(qq{
        UPDATE server
           SET password=?
         WHERE server_id=?}, undef, $encoded_password, $remote_server)
             or dbquit 'update remote server outgoing password';
}


sub update_table_entry {
    my ($table, $key_name, $key_value, $key2_name, $key2_value, $layout) = @_;
    my (@fields, @values, @missing);

    $table = lc $table;
    my @list = @$layout;
    while (my $title = shift @list) {
	my $f = shift @list;
	my ($name, $rest) = split /\//, $f;
	my $req = $name =~ s/^\+//;
	push @fields, $name;
	my $v = $q->param("TXT_$name");
	if ($req and !$v) { push @missing, $title }
	else { push @values, (defined($v) and $v eq '') ? undef : $v }
    }
    unless (@missing) {
	push @fields, 'UPDATE_USERNAME';
	push @values, $admin_user;
	push @fields, 'UPDATE_TIMESTAMP';
	push @values, ts();
	my $sql = "UPDATE $table SET " . join(',', map {"$_=?"} @fields);
	$sql .= " WHERE $key_name = ?";
	push @values, $key_value;
	if ($key2_value) {
	    $sql .= " AND $key2_name = ?";
	    push @values, $key2_value;
	}
	$dbh->do($sql, undef, @values) or dbquit "Can't update";
    }
    return @missing;
}


#####
