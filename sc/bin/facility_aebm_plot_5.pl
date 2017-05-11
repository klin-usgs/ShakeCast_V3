#!/usr/local/bin/perl

my $start = time;

use FindBin;
use lib "$FindBin::Bin/../lib";
use File::Path;
use SC;
use Data::Dumper;
use JSON;
#use JSON::XS;

SC->initialize();
my $config = SC->config;

my $sc_dir = $config->{'DataRoot'};
my $db_dir = $config->{'RootDir'} . '/db';

my $evid = $ARGV[0];
my $version = $ARGV[1];
my $facility_id = $ARGV[2];
my $gnuplot  = $config->{'gnuplot'};
my $event = "$evid-$version";
my $aebm_file = "$sc_dir/$event/facility_aebm.json";
exit 0 unless (-e $aebm_file);

my $dir_path = "$sc_dir/$event/fragility";
mkdir($dir_path) unless (-d $dir_path);

# map array index to damage level
my @damage_levels = (
    'None',
    'Slight',
    'Moderate',
    'Extensive',
    'Complete'
);

open (FH, "< $aebm_file") or exit 0;
my @contents = <FH>;
close (FH);
my $content = join '', @contents;
#my $content = $resp->content;

open (GNUPLOT, "| $gnuplot");

#eval{
my $json = new JSON;

# these are some nice json options to relax restrictions a bit:
my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);

#$json_text = $json_text->{properties} if (@ARGV);
$json_text = $json_text->{'aebm'};

foreach my $facility (keys %{$json_text}) {
	my $output_png;
	my $ds_data = '$ds << DS'."\n";
	my $cmd;
	my $max_value;
	
	$output_png = "$dir_path/$facility.png";
    my @fac_frag_prob = map {$_ * 100} @{$json_text->{$facility}->{'damage_state'}->{'pdf'}->{'median'}};
    my @fac_frag_high = map {$_ * 100} @{$json_text->{$facility}->{'damage_state'}->{'err'}->{'max'}};
    my @fac_frag_low = map {$_ * 100} @{$json_text->{$facility}->{'damage_state'}->{'err'}->{'min'}};
    my $capacity = $json_text->{$facility}->{'capacity'};
    my $demand = $json_text->{$facility}->{'demand_spectrum'};
    my $permformance = $json_text->{$facility}->{'performance'};
    my $response_spectrum = $json_text->{$facility}->{'response_spectrum'};

    my $spect_data = '$spect << SPECT'."\n";
    foreach my $ind (0 .. scalar @{$response_spectrum->{'sa'}} - 1) {
      my $spect_sa = $response_spectrum->{'sa'}->[$ind];
      my $spect_sd = $response_spectrum->{'sd'}->[$ind];
      my $spect_fact = $response_spectrum->{'smooth_factor'}->[$ind];
      my $dem_sa = $demand->{'sa'}->[$ind];
      my $dem_sd = $demand->{'sd'}->[$ind];
      $spect_data .= "$ind $spect_sd $spect_sa ".$spect_sa/$spect_fact." $dem_sd, $dem_sa\n";
    }
    $spect_data .= "SPECT\n";

    my $perm_data = join ' ', (
                'set arrow from ', $permformance->{'median'}->{'sd'} + .5, ',', $permformance->{'median'}->{'sa'} - .05, 'to', $permformance->{'median'}->{'sd'}+.1, ',', $permformance->{'median'}->{'sa'},"\n",
                'set label "[', sprintf("%.2f", $permformance->{'median'}->{'sd'}), '(in) ,', sprintf("%.2f", $permformance->{'median'}->{'sa'}),
                '(g)]" at ', $permformance->{'median'}->{'sd'} + .6, ',', $permformance->{'median'}->{'sa'} - .05, "\n",
                '$perm_point << PERM_POINT'."\n",
                    $permformance->{'median'}->{'sd'}, $permformance->{'median'}->{'sa'},
    "\nPERM_POINT\n", '$perm << PERM'."\n");

	my @damage_states;
	my $metric_key;
	
	#my $obj_cmd = "set object rect from graph 0.6, 0.05 to  graph 0.95, 0.4 front fc rgb '#FFD700' fillstyle solid 0.15\n" ;
	my $x_inc = 0.10;
	my $x_ind = 0.87 - scalar @damage_states * $x_inc;
	my $obj_cmd = "set object rect from graph ".($x_ind-0.01).", 0.05 to  graph ".($x_ind+$x_inc*(scalar @fac_frag_prob+1)+0.01).",0.47 front fc rgb '#FFD700' fillstyle solid 0.15\n" ;
	my $label.= "set label \"Distribution of Probability\" at graph ".($x_ind+$x_inc*(scalar @fac_frag_prob+1)/2).", 0.50 front center font \"Arial,11\"\n";
	my %color_spec = ("GRAY" => 'gray', "GREEN" => 'green', "YELLOW" => 'yellow', "ORANGE" => 'orange', "RED" => 'red');
	my @color_spec = ('gray', 'green', 'yellow', 'orange', 'red');
	foreach my $ind (0 .. scalar @fac_frag_prob - 1) {
		my $prob = int($fac_frag_prob[$ind] + 0.5);
        my $upper = $fac_frag_high[$ind];
        my $lower = $fac_frag_low[$ind];
		my $color = $color_spec[$ind];
        my $ltind = $ind+51;
        my $ds = $damage_levels[$ind];
	    $ds_data .= "$ind $prob $lower $upper $ltind $ds\n";
		$obj_cmd .= "set object rect from graph $x_ind, 0.06 to  graph ".($x_ind+$x_inc).", ".($prob *0.4+0.06)." front fc rgb '".$color."' fillstyle solid 0.55 noborder\n" ;
		$label .= "set label \"".(int($prob*100+0.5))."%\" at graph ".($x_ind+$x_inc/2).", 0.08 front center font \"Arial,11\"\n";
		$x_ind += $x_inc;
	}
	$cmd = 'plot $ds using 1:2:3:4:5:xticlabels(6) with boxerrorbars lc variable, $ds using 1:2:2 with labels';
	$ds_data .= "DS\n";
	$output_png = "$dir_path/$facility"."_ds.png";
	send_data_to_gnuplot($event, $facility, $output_png, $label, $max_value, $obj_cmd, $cmd, $ds_data);

  my $Bc = $json_text->{$facility}->{'mbt'}->{'Bc'};
  my $Bd = $json_text->{$facility}->{'mbt'}->{'Bd'};
  foreach my $ind (0 .. scalar @{$capacity->{'sa'}} - 1) {
		my $cap_sa = $capacity->{'sa'}->[$ind];
		my $cap_sd = $capacity->{'sd'}->[$ind];
		my $dem_sa = $demand->{'sa'}->[$ind];
		my $dem_sd = $demand->{'sd'}->[$ind];
    my $cap_sa_upper = $cap_sa * exp($Bc);
    my $cap_sd_upper = $cap_sd * exp($Bc);
    my $cap_sa_lower = $cap_sa / exp($Bc);
    my $cap_sd_lower = $cap_sd / exp($Bc);
    my $dem_sa_upper = $dem_sa * exp($Bd);
    my $dem_sd_upper = $dem_sd * exp($Bd);
    my $dem_sa_lower = $dem_sa / exp($Bd);
    my $dem_sd_lower = $dem_sd / exp($Bd);
	  $perm_data .= "$ind $cap_sd $cap_sa $dem_sd $dem_sa $cap_sd_lower $cap_sa_lower $cap_sd_upper $cap_sa_upper $dem_sd_lower $dem_sa_lower $dem_sd_upper $dem_sa_upper\n";
	}
	$cmd = 'plot $perm using 6:7 title "Capacity Lower/Upper Bound" with lines lt 53, $perm using 8:9 notitle with lines lt 53, $perm using 10:11 title "Demand Lower/Upper Bound" with lines lt 54, $perm using 12:13 notitle with lines lt 54, $perm using 2:3 title "Capacity" with linespoints lt 51, $perm using 4:5 title "Demand" with linespoints lt 52, $perm_point title "Performance Point" with points pt 3 lw 3 lc "green"';
	$perm_data .= "PERM\n";
  
	$output_png = "$dir_path/$facility"."_perm.png";
	send_data_to_perm_plot($event, $facility, $output_png, $label, $max_value, $obj_cmd, $cmd, $perm_data);

	$cmd = 'plot $spect using 2:4 title "Raw 5%-Damped 3-Domain Spectrum" with lines lt 53, $spect using 2:3 title "Smoothed Spectrum" with linespoints lt 51, $spect using 5:6 title "Demand Spectrum" with linespoints lt 52';
  $output_png = "$dir_path/$facility"."_spect.png";
	send_data_to_spect_plot($event, $facility, $output_png, $label, $max_value, $obj_cmd, $cmd, $spect_data);

}

#};

close (GNUPLOT);
my $end = time;

print "The total time is ", $end-$start;
exit;

sub send_data_to_spect_plot
{
	my ($event, $fac_id, $output_png, $label, $max_value, $obj_cmd, $cmd, $perm_data) = @_;
	$event =~ s/_/ /g;
    #print "$gnuplot_data\n";
    print GNUPLOT <<gnuplot_Commands_Done;
    set terminal png transparent nocrop enhanced size 600,400
    set output "$output_png"
    set encoding utf8
	set timestamp "Generated at %m/%d/%Y %H:%M" font "Arial,08"
	
set termoption dash
set grid xtics mxtics ytics nomytics nox2tics nomx2tics noy2tics nomy2tics nocbtics nomcbtics
set grid front   lt 0 linewidth 0.500,  lt 0 linewidth 0.500
set border lw 2
set xrange [ 0.1 :  ]
#set yrange [ 0 : 2 ]
set logscale x 10
set key right box 
set xlabel "Damped Response Spectral Displacement (in)"
set ylabel "Damped Response Spectral Acceleration (g)"
set linetype 51 lw 2 lc rgb "purple"
set linetype 52 lw 2 lc rgb "red"
set linetype 53 lw 2 lc rgb "dark-cyan" dt 3 

$perm_data
$cmd

unset xrange
reset
gnuplot_Commands_Done

}
#set title "Damage Probabilities for Facility $fac_id\\nEvent: $event" font \"Times,15\"

sub send_data_to_perm_plot
{
	my ($event, $fac_id, $output_png, $label, $max_value, $obj_cmd, $cmd, $perm_data) = @_;
	$event =~ s/_/ /g;
    #print "$gnuplot_data\n";
    print GNUPLOT <<gnuplot_Commands_Done;
    set terminal png transparent nocrop enhanced size 600,400
    set output "$output_png"
    set encoding utf8
	set timestamp "Generated at %m/%d/%Y %H:%M" font "Arial,08"
	
set border lw 2
set xrange [ 0 : 10 ]
#set yrange [ 0 : 2 ]
set grid xtics mxtics ytics nomytics nox2tics nomx2tics noy2tics nomy2tics nocbtics nomcbtics
set grid front   lt 0 linewidth 0.500,  lt 0 linewidth 0.500
set key right box 
set xlabel "β_{eff}%-Damped Spectral Displacement (in)"
set ylabel "β_{eff}%-Damped Spectral Acceleration (g)"
set linetype 51 lw 2 lc rgb "blue"
set linetype 52 lw 2 lc rgb "red"
set linetype 53 lc rgb "light-blue" dt 3 
set linetype 54 dt ".. " lc rgb "pink"


$perm_data
$cmd

unset xrange
reset
gnuplot_Commands_Done

}
#set title "Damage Probabilities for Facility $fac_id\\nEvent: $event" font \"Times,15\"
#set object 1 rect from graph 0, 0, 0 to graph 1, 1, 0 behind lw 1.0 fc  rgb "gray"  fillstyle   solid 0.15 border -1
#$obj_cmd

#set title "Fragility Curves for Facility $fac_id\\nEvent: $event" font \"Times,15\"
#$label

sub send_data_to_gnuplot
{
	my ($event, $fac_id, $output_png, $label, $max_value, $obj_cmd, $cmd, $ds_data) = @_;
	$event =~ s/_/ /g;
    #print "$gnuplot_data\n";
    print GNUPLOT <<gnuplot_Commands_Done;
    set terminal png transparent nocrop enhanced size 600,400
    set output "$output_png"
	set timestamp "Generated at %m/%d/%Y %H:%M" font "Arial,08"
	
set border lw 2
set grid ytics nomytics nox2tics nomx2tics noy2tics nomy2tics nocbtics nomcbtics
set grid front   lt 0 linewidth 0.500,  lt 0 linewidth 0.500
set xrange [ -0.5 : 4.5 ]
set yrange [ 0 : 100 ]
set xlabel "Structural Damage State"
set ylabel "Probability of Structural Damage State (%)"
set style fill solid 0.6 
set style line 1 lt 2 lc rgb "dark-red" lw 2
set boxwidth -2

set key off

set linetype 51 lc rgb "gray"
set linetype 52 lc rgb "green"
set linetype 53 lc rgb "yellow"
set linetype 54 lc rgb "orange"
set linetype 55 lc rgb "red"

set object 1 rectangle from graph 0,0 to graph 1,1 fc rgb "gray70" behind

$ds_data
$cmd

unset xrange
reset
gnuplot_Commands_Done

}
#set title "Damage Probabilities for Facility $fac_id\\nEvent: $event" font \"Times,15\"
#set object 1 rect from graph 0, 0, 0 to graph 1, 1, 0 behind lw 1.0 fc  rgb "gray"  fillstyle   solid 0.15 border -1
#$obj_cmd

#set title "Fragility Curves for Facility $fac_id\\nEvent: $event" font \"Times,15\"
#$label

sub parse_facility_exposure {
  my ($evid, $version) = @_;
  my $file = "$sc_dir/$evid-$version/exposure.csv";
  return unless (-e $file);
 

  use Text::CSV_XS;

  my @rows;
  my $csv = Text::CSV_XS->new ( { binary => 1 } )  # should set binary attribute.
                 or return "Cannot use CSV: ".Text::CSV->error_diag ();
 
  open my $fh, "<:encoding(utf8)", $file or return"$file: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    $row->[3] =~ m/\d+/ or next; # 3rd field should match
    push @rows, $row;
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  return \@rows;
}

sub parse_event_catalog {
  my ($file) = @_;
  return unless (-e $file);
 

  use Text::CSV_XS;

  my @rows;
  my $csv = Text::CSV_XS->new ( { binary => 1 } )  # should set binary attribute.
                 or return "Cannot use CSV: ".Text::CSV->error_diag ();
 
  open my $fh, "<:encoding(utf8)", $file or return"$file: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    $row->[5] =~ m/\d+/ or next; # 3rd field should match
    push @rows, $row;
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  return \@rows;
}

sub parse_event {
  my ($file) = @_;
  return unless (-e $file);
 

  use XML::LibXML::Simple;

  my $event = XMLin($file);

  return $event;
}


sub parse_station {
  my ($file) = @_;
  return unless (-e $file);
 

  use XML::LibXML::Simple;

  my $event = XMLin($file);

  return $event->{stationlist};
}


### SAVE ROOM AT THE TOP ###
sub parse_facility {
  my ($evid, $version) = @_;
  my $file = "$sc_dir/$evid-$version/exposure.csv";
  return unless (-e $file);
 

  use Text::CSV_XS;

  my @rows;
  my $csv = Text::CSV_XS->new ( { binary => 1 } )  # should set binary attribute.
                 or return "Cannot use CSV: ".Text::CSV->error_diag ();
 
  open my $fh, "<:encoding(utf8)", $file or return"$file: $!";
  while ( my $row = $csv->getline( $fh ) ) {
    $row->[0] =~ m/\w+/ or next; # 3rd field should match
    $row->[0] !~ m/^facility_type/i or next; # skip header
    push @rows, $row;
  }
  $csv->eof or $csv->error_diag();
  close $fh;

  return \@rows;
}

# returns a list of all metrics that should be polled for new events, etc.
sub metric_list {
	my @metrics;
	
    undef $SC::errstr;
    eval {
		my $sth = SC->dbh->prepare(qq/
			select short_name, metric_id
			  from metric/);
		$sth->execute;
		while (my @p = $sth->fetchrow_array()) {
			push @metrics, @p;
		}
    };
    return @metrics;
}

sub _min {
    (defined $_[0] && (!defined $_[1] || $_[0] <= $_[1])) ? $_[0] : $_[1];
}

sub _max {
    (defined $_[0] && (!defined $_[1] || $_[0] >= $_[1])) ? $_[0] : $_[1];
}

