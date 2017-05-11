#!/usr/local/bin/perl

my $start = time;

use FindBin;
use lib "$FindBin::Bin/../lib";
use File::Path;
use SC;
use Shake::Distance;
use Data::Dumper;
use JSON::XS;
use API::APIUtil;

SC->initialize();
my $config = SC->config;

my $sc_dir = $config->{'DataRoot'};
my $db_dir = $config->{'RootDir'} . '/db';

my $evid = $ARGV[0];
my $version = $ARGV[1];
my $event = "$evid-$version";
my $dir_path = "$sc_dir/$event";
mkdir($dir_path) unless (-d $dir_path);

sub epr;
my $sth_lookup_grid;

$sth_lookup_grid = SC->dbh->prepare(qq{
    select grid_id
      from grid
     where shakemap_id = ?
       and shakemap_version = ?});

# some data to layout
#my $facility_data = parse_facility_exposure($evid, $version);

my %metric_column_map = metric_list();
my $event = event_info($evid);
my $grid_id = lookup_grid($evid, $version);
my $fac_list = SC->dbh->selectall_arrayref(qq{
	SELECT fs.facility_id, f.external_facility_id, f.facility_name,
		group_concat(fa.attribute_name) as attribute,
		group_concat(fa.attribute_value) as value
	FROM facility_shaking fs inner join grid g on
		fs.grid_id = g.grid_id 
	INNER JOIN facility f on f.facility_id = fs.facility_id
	LEFT JOIN facility_attribute fa on
		fs.facility_id = fa.facility_id
	WHERE g.shakemap_id = ? and g.shakemap_version = ?
	GROUP BY fs.facility_id
	}, undef, $evid, $version);

my @periods = (0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0);
my $nrec=0;
my $json = {
	    'event' => $event,
	    'facility_list' => $fac_list,
	    'periods' => \@periods
	    };
foreach my $facility (@$fac_list) {
	my $output_png;
	my $gnuplot_data;
	my $cmd;
	my $max_value;
	my ($fac_id, $ext_fac_id, $fac_name, $class, $component) = @$facility;
	#next unless ($class =~ /AEBM/i);
	
	my %reg_rv;
	my $mbt = mbt($fac_id);
	my $mbt_fragility = mbt_fragility($fac_id, $mbt);
	my $capacity = capacity($mbt);
	my ($sm_input, $domain_periods, $smooth_sa, $smooth_sd, $smooth_factor) = response_spectra($fac_id);
	my $damped_scaling = damped_scaling($fac_id, $mbt, $capacity);
	my $demand_sa = demand($smooth_sa, $damped_scaling);
	my $demand_sd = demand($smooth_sd, $damped_scaling);
	my $performance = performance_point($capacity, $demand_sa, $demand_sd, $mbt_fragility);
	my ($ds, $beta) = compute_ds($performance, $mbt_fragility);
	my $loss = compute_loss($ds);

	$reg_rv{'mbt'} = $mbt;
	$reg_rv{'mbt_fragility'} = $mbt_fragility;
	$reg_rv{'capacity'} = $capacity;
	$reg_rv{'sm_input'} = $sm_input;
	$reg_rv{'response_spectrum'}->{'domain_periods'} = $domain_periods;
	$reg_rv{'response_spectrum'}->{'smooth_factor'} = $smooth_factor;
	$reg_rv{'response_spectrum'}->{'sa'} = $smooth_sa;
	$reg_rv{'response_spectrum'}->{'sd'} = $smooth_sd;
	$reg_rv{'demand_spectrum'}->{'scaling'} = $damped_scaling;
	$reg_rv{'demand_spectrum'}->{'sa'} = $demand_sa;
	$reg_rv{'demand_spectrum'}->{'sd'} = $demand_sd;
	$reg_rv{'performance'} = $performance;
	$reg_rv{'damage_state'} = $ds;
	$reg_rv{'mbt_fragility'}{'beta'} = $beta;
	$reg_rv{'loss'} = $loss;

	$json->{'aebm'}->{$fac_id} = \%reg_rv;	
	
}

open(FH, "> $dir_path/facility_aebm.json") or exit;
print FH JSON::XS->new->utf8->encode(API::APIUtil::stringfy($json));
close(FH);

my $end = time;

print "The total time is ", $end-$start, "\n";
print "process product STATUS=SUCCESS\n";
exit;

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

# returns a list of all metrics that should be polled for new events, etc.
sub event_info {
	my ($event_id) = @_;
	my $event;
	
    undef $SC::errstr;
    eval {
		my $sth = SC->dbh->prepare(qq{
			select *
			from event
			where event_id = ?
			order by seq desc
			limit 1});
		$sth->execute($event_id);
		$event = $sth->fetchrow_hashref("NAME_lc");
    };
    return $event;
}

# Return facility_id given external_facility_id and facility_type
sub lookup_grid {
    my ($shakemap_id, $shakemap_version) = @_;
    my $idp = SC->dbh->selectcol_arrayref($sth_lookup_grid, undef,
        $shakemap_id, $shakemap_version);
    if (scalar @$idp > 1) {
        epr "multiple matching facilities for $shakemap_id, $shakemap_version";
        return -1;      # valid IDs are all greater than 0
    } elsif (scalar @$idp == 1) {
        return $$idp[0];
    } else {
        return 0;       # not found
    }
}


sub epr {
    print STDERR @_, "\n";
}

# send product to a remote server
sub kappa {
    my ($fac_id) = @_;
	
	#return 0 unless ($event->{'magnitude'} >= 6.0);
	
	my ($M_ind, $R_ind);
	my $idp = SC->dbh->selectcol_arrayref(qq{
		SELECT dist
		FROM facility_shaking
		WHERE facility_id = ?
		AND grid_id = ?}, undef, $fac_id, $grid_id);
	
	return -1 unless (scalar @$idp >= 1);
	my $dist = $$idp[0];
	
	my @kappa_table = (0.6, 0.6, 0.5, 0.5, 0.4, 0.3, 0.3, 0.2, 0.2);

	my @kappa_index_factor = ([0,1,1,2],[4,1,1,2],[5,1,2,3],[7,2,3,4],[10,3,4,5],[13,4,5,6],[16,5,6,7],[20,6,7,8],[35,7,8,9],[50,8,9,9],[1000,8,9,9]);

	if ($event->{'magnitude'} <= 6.5) {
		$M_ind = 1;
	} elsif ($event->{'magnitude'} > 7) {
		$M_ind = 3;
	} else {
		$M_ind = 2;
	}

	my $R_ind;
	for ($R_ind = 1; $R_ind < scalar (@kappa_index_factor); $R_ind++) {
		last if ($dist <= $kappa_index_factor[$R_ind]->[0]);
	}
	$R_ind = $R_ind - 1;
    
	$kappa = $kappa_table[$kappa_index_factor[$R_ind]->[$M_ind]-1];
	return $kappa;
}

# send product to a remote server
sub capacity {
    my ($mbt) = @_;
	
	#return 0 unless ($event->{'magnitude'} >= 6.0);
	
	my ($M_ind, $R_ind);
	my @output_periods;
	for (my $ind=0; $ind< $#periods; $ind++) {
		if ($mbt->{'Te'} < $periods[$ind+1]) {
			if ($mbt->{'Te'} > $periods[$ind]) {
				$output_periods[$ind] = $mbt->{'Te'};
			} else {
				$output_periods[$ind] = $periods[$ind];
			}
		} else {
			$output_periods[$ind] = 0;
		}
	}
	push @output_periods, $periods[$#periods];
	
	my $capacity = {};
	my (@sa, @sd);
	for (my $ind=0; $ind <= $#output_periods; $ind++) {
		my ($sa, $sd);
		if ($output_periods[$ind] >= 0.32*sqrt($mbt->{'Du'} / $mbt->{'Au'})) {
			$sa = $mbt->{'Au'};
		} elsif ($output_periods[$ind] > $mbt->{'Te'}) {
			$sa = sqrt($mbt->{'Ay'} / $mbt->{'Au'});
		} elsif ($output_periods[$ind] <= 0) {
			$sa = 0;
		} else {
			$sa = $mbt->{'Ay'};
		}
		$sa = 0.474 if ($ind == 11);
		$sa = 0.598 if ($ind == 12);
		$sa = 0.647 if ($ind == 13);
		
		$sd = 9.8 * $sa * $output_periods[$ind]**2;
		push @sa, $sa;
		push @sd, $sd;
	}

	$capacity->{'periods'} = \@output_periods;
	$capacity->{'sd'} = \@sd;
	$capacity->{'sa'} = \@sa;
	
	return $capacity;
}

# send product to a remote server
sub mbt {
    my ($fac_id) = @_;
	
	#return 0 unless ($event->{'magnitude'} >= 6.0);
	
	my $mbt = { 'MBT' => 'W2',
		   'Year' => 1965,
		   'Height' => 34,
		   'SDL' => 'M',
		   'Be' => 10,
		   'kappa' => kappa($fac_id),
		   'Cs' => 0.154,
		   'gamma' => 2.25,
		   'lamda' => 1.50,
		   'mu' => 4.94,
		   'alpha1' => 0.8,
		   'alpha2' => 0.75,
		   'alpha3' => 2.73,
		  };

	$mbt->{'Te'} = compute_te($mbt);
	$mbt->{'Ay'} = $mbt->{'Cs'} * $mbt->{'gamma'} / $mbt->{'alpha1'};
	$mbt->{'Dy'} = 9.8 * $mbt->{'Ay'} * ($mbt->{'Te'}**2);
	$mbt->{'Au'} = $mbt->{'Ay'} * $mbt->{'lamda'};
	$mbt->{'Du'} = $mbt->{'Dy'} * $mbt->{'lamda'} * $mbt->{'mu'};
	$mbt->{'k'} = ($mbt->{'Au'}**2 - $mbt->{'Ay'}**2 + $mbt->{'Ay'}**2 * ($mbt->{'Dy'} -$mbt->{'Du'})/ $mbt->{'Dy'} )
			/ ( 2 * ($mbt->{'Au'} - $mbt->{'Ay'}) + ($mbt->{'Ay'} / $mbt->{'Dy'}) * ($mbt->{'Dy'} - $mbt->{'Du'}));
	$mbt->{'b'} = $mbt->{'Au'} - $mbt->{'k'};
	$mbt->{'a'} = sqrt(($mbt->{'Dy'}/$mbt->{'Ay'}) * $mbt->{'b'}**2 * ($mbt->{'Du'}-$mbt->{'Dy'}) / ($mbt->{'Ay'} - $mbt->{'k'}));
	
	return $mbt;
}

# send product to a remote server
sub mbt_fragility {
    my ($fac_id, $mbt) = @_;
	
	#return 0 unless ($event->{'magnitude'} >= 6.0);
	
	my $mbt_fragility = { 'MBT' => 'W2',
		   'Year' => 1965,
		   'Height' => 34,
		   'Bc' => 0.3,
		   'Bd' => 0.4,
		   'deltaS' => 0.004,
		   'deltaM' => 0.01,
		   'deltaE' => 0.025,
		   'deltaC' => 0.06,
		   'betaTS' => 0.4,
		   'betaTM' => 0.4,
		   'betaTE' => 0.4,
		   'betaTC' => 0.4,
		  };

	$mbt_fragility->{'SS'} = 12 * $mbt_fragility->{'Height'} * $mbt_fragility->{'deltaS'} * ($mbt->{'alpha2'}/$mbt->{'alpha3'});
	$mbt_fragility->{'SM'} = 12 * $mbt_fragility->{'Height'} * $mbt_fragility->{'deltaM'} * ($mbt->{'alpha2'}/$mbt->{'alpha3'});
	$mbt_fragility->{'SE'} = 12 * $mbt_fragility->{'Height'} * $mbt_fragility->{'deltaE'} * ($mbt->{'alpha2'}/$mbt->{'alpha3'});
	$mbt_fragility->{'SC'} = 12 * $mbt_fragility->{'Height'} * $mbt_fragility->{'deltaC'} * ($mbt->{'alpha2'}/$mbt->{'alpha3'});
	
	return $mbt_fragility;
}

# send product to a remote server
sub compute_te {
    my ($mbt) = @_;
	
	my ($a1, $a2, $a3);
	if ($mbt->{'SDL'} eq 'VH') {
		$a1 = 1.4;
	} elsif ($mbt->{'SDL'} eq 'H') {
		$a1 = 1.4;
	} elsif ($mbt->{'SDL'} eq 'MH') {
		$a1 = 1.5;
	} elsif ($mbt->{'SDL'} eq 'L') {
		$a1 = 1.6;
	} else {
		$a1 = 1.7;
	}
	
	if ($mbt->{'MBT'} eq 'S1') {
		$a2 = 0.028;
		$a3 = 0.8;
	} elsif ($mbt->{'MBT'} eq 'C1') {
		$a2 = 0.016;
		$a3 = 0.9;
	} else {
		$a2 = 0.02;
		$a3 = 0.75;
	}
	
	return $a1 * $a2 * $mbt->{'Height'}**$a3;
}


# send product to a remote server
sub response_spectra {
    my ($fac_id) = @_;
	
	my $col = 'dist, value_'.$metric_column_map{'PGA'}.', value_'.$metric_column_map{'PSA03'}.', value_'.$metric_column_map{'PSA10'}.', value_'.$metric_column_map{'PSA30'};
	my $idp = SC->dbh->selectall_arrayref(qq{
		SELECT $col
		FROM facility_shaking
		WHERE facility_id = ?
		AND grid_id = ?}, undef, $fac_id, $grid_id);
		
	return join -1 unless (scalar @$idp >= 1);
	my ($dist, $pga, $psa03, $psa10, $psa30) = map { $_ / 100} @{$idp->[0]};
	my $sm_input = {
		'dist' => $dist*100,
		'pga' => $pga,
		'psa03' => $psa03,
		'psa10' => $psa10,
		'psa30' => $psa30,
	};
	return 0 if ($psa03 <=0 || $psa10 <=0);
	my $tolerate = 0.0001;
	my @M = (5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.01);
	my @Tl = (1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 8);

	my $ind;
	for ($ind = 0; $ind <= $#M; $ind++) {
		last if ($M[$ind] >= $event->{'magnitude'});
	}
	
	my $domain_periods = {};
	if ($event->{'magnitude'} > $M[$ind] || $event->{'magnitude'} < $M[0]) {
		$domain_periods->{'Tl'} = $Tl[$ind];
	} else {
		$domain_periods->{'Tl'} = $Tl[$ind-1];
	}
	
	$domain_periods->{'Ts'} = (_max($psa10, 3*$psa30)/$psa03 > 0) ? _max($psa10, 3*$psa30)/$psa03 : $tolerate;
	
	$domain_periods->{'T0'} = $domain_periods->{'Ts'}/5;
	
	my @smooth_factor;
	for ($ind = 0; $ind <= $#periods; $ind++) {
		$smooth_factor[$ind] = 1-0.2*(($domain_periods->{'Ts'}-0.2)/$domain_periods->{'Ts'})
			* _min($periods[$ind] / $domain_periods->{'Ts'}, $domain_periods->{'Ts'} / $periods[$ind])**4;
	}
	
	my (@sa, @sd);
	my $sa_smooth = [];
	my $sd_smooth = [];
	$sa[0] = $pga;
	for ($ind = 1; $ind <= $#periods; $ind++) {
		my $T = $periods[$ind];
		if ($T < $domain_periods->{'T0'}) {
			$sa[$ind] = ($psa03 - $pga) * (($T - 0.02) / ($domain_periods->{'T0'} - 0.02)) + $pga;
		} elsif ($T < $domain_periods->{'Tl'}) {
			$sa[$ind] = _min(_max($psa10, 3*$psa30)*(1.0/$T), $psa03);
		} else {
			$sa[$ind] = _max($psa10, 3*$psa30)*($domain_periods->{'Tl'}/$T**2);
		}
	}
	for ($ind = 0; $ind <= $#periods; $ind++) {
		my $T = $periods[$ind];
		$sd[$ind] = 9.8 * $sa[$ind] * $T**2;
		$sa_smooth->[$ind] = $smooth_factor[$ind] * $sa[$ind];
		$sd_smooth->[$ind] = 9.8 * $sa_smooth->[$ind] * $T**2;
	}
	
	return $sm_input, $domain_periods, $sa_smooth, $sd_smooth, \@smooth_factor;
}

sub _sum {
	my $sum=0;
	for (my $ind=0; $ind <= $#_; $ind++) {$sum+=$_[$ind];}
	return $sum;
}

sub _min {
    (defined $_[0] && (!defined $_[1] || $_[0] <= $_[1])) ? $_[0] : $_[1];
}

sub _max {
    (defined $_[0] && (!defined $_[1] || $_[0] >= $_[1])) ? $_[0] : $_[1];
}

# send product to a remote server
sub damped_scaling {
    my ($fac_id, $mbt, $capacity) = @_;
	
	my @periods = @{$capacity->{'periods'}};
	my @sa = @{$capacity->{'sa'}};
	my @sd = @{$capacity->{'sd'}};
	my $kappa = $mbt->{'kappa'};
	my $Dy = $mbt->{'Dy'};
	my $Ay = $mbt->{'Ay'};
	my $pi = 3.14159;
	my ($ind, @Be, @Bh);
	$Bh[0] = 0;
	$Be[0] = $mbt->{'Be'};
	for ($ind=1; $ind < scalar @periods; $ind++) {
		my $T = $periods[$ind];
		my ($sa_1, $sd_1) = ($sa[$ind-1], $sd[$ind-1]);
		my ($sa, $sd) = ($sa[$ind], $sd[$ind]);
		if ($T <= 0) {
			$Bh[$ind] = 0;
		} else {
			$bh[$ind] = 100*($kappa*(2*($sa+$sa_1)*($sd-($sd_1+($Dy/$Ay)*($sa-$sa_1)))+((($Bh[$ind-1]/100)/$kappa))*2*$pi*$sd_1*$sa_1)/(2*$pi*$sd*$sa));
		}
		
		if ($Bh[$ind] > $Be[$ind]) {
			$Be[$ind] = $Bh[$ind];
		} else {
			$Be[$ind] = $Be[0];
		}
	}
	
	my $dsf = dsf($fac_id, \@Be);
	return $dsf;
}

# send product to a remote server
sub demand {
    my ($spectra, $damping) = @_;
	
	my ($ind, @demand);
	for ($ind=0; $ind < scalar @$spectra; $ind++) {
		$demand[$ind] = $spectra->[$ind] * $damping->[$ind];
	}
	
	return \@demand;
}

# send product to a remote server
sub dsf {
    my ($fac_id, $Be) = @_;
	
	my $M = $event->{'magnitude'};
	my $idp = SC->dbh->selectall_arrayref(qq{
		SELECT lon_min, lat_min
		FROM facility
		WHERE facility_id = ?
		}, undef, $fac_id);
		
	return join -1 unless (scalar @$idp >= 1);
	my ($fac_lon, $fac_lat) = @{$idp->[0]};
	my $R = dist($fac_lat, $fac_lon, $event->{'lat'}, $event->{'lon'});
	
	my @T = (0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 7.5, 10);
	
	my @dsf_coef = (
	    [0.00173, -0.000207, -0.000629, 0.00000108, -0.0000824, 0.0000736, -0.00107, 0.000908, -0.000202, -0.0037, 0.00023, 0.000188],
	    [0.0553, -0.0377, 0.00215, -0.0043, 0.00321, -0.000332, -0.00475, 0.00252, 0.000229, -0.0219, 0.00211, 0.000499],
	    [0.122, -0.0702, -0.00228, -0.00321, 0.0000691, 0.000982, -0.013, 0.00782, 0.000227, -0.0521, 0.0046, 0.00104],
	    [0.239, -0.106, -0.0263, -0.000857, -0.00743, 0.00487, -0.0169, 0.00808, 0.00171, -0.0957, 0.00131, 0.0047],
	    [0.305, -0.0732, -0.0729, 0.000202, -0.0164, 0.0103, -0.000926, -0.0064, 0.00442, -0.121, -0.00579, 0.0046],
	    [0.269, 0.00418, -0.107, 0.0058, -0.0249, 0.0134, 0.0235, -0.0237, 0.00584, -0.124, -0.0108, 0.0038],
	    [0.141, 0.1, -0.118, 0.0301, -0.0409, 0.0141, 0.0316, -0.0247, 0.00315, -0.115, -0.0114, 0.00397],
	    [0.0501, 0.145, -0.111, 0.0469, -0.0477, 0.0118, 0.031, -0.0229, 0.00241, -0.108, -0.00885, 0.00464],
	    [0.0228, 0.143, -0.0973, 0.052, -0.047, 0.00947, 0.0271, -0.0202, 0.00131, -0.104, -0.00735, 0.00466],
	    [-0.0158, 0.148, -0.0883, 0.0521, -0.0436, 0.00733, 0.0387, -0.0266, 0.00176, -0.101, -0.0069, 0.00531],
	    [0.0224, 0.103, -0.0741, 0.0463, -0.0358, 0.00465, 0.0363, -0.0245, 0.00118, -0.102, -0.00671, 0.00621],
	    [0.0319, 0.0704, -0.0557, 0.0425, -0.0294, 0.00188, 0.0387, -0.0247, 0.000313, -0.101, -0.00622, 0.00713],
	    [0.0104, 0.0533, -0.0372, 0.0447, -0.024, -0.0024, 0.0347, -0.0259, 0.0029, -0.101, -0.00586, 0.00685],
	    [-0.0884, 0.0892, -0.0214, 0.0498, -0.0236, -0.0047, 0.0502, -0.0343, 0.00232, -0.102, -0.00731, 0.00666],
	    [-0.157, 0.0933, 0.00328, 0.0585, -0.0236, -0.00802, 0.0481, -0.033, 0.0021, -0.102, -0.00875, 0.00666],
	    [-0.296, 0.15, 0.0209, 0.073, -0.0296, -0.00995, 0.0524, -0.0332, 0.000686, -0.103, -0.00922, 0.00604],
	    [-0.407, 0.197, 0.0328, 0.0835, -0.0354, -0.0101, 0.0557, -0.0291, -0.00317, -0.0963, -0.0107, 0.00603],
	    [-0.449, 0.207, 0.0442, 0.0875, -0.0359, -0.0114, 0.0507, -0.0243, -0.00467, -0.0983, -0.0137, 0.00337],
	    [-0.498, 0.217, 0.0536, 0.0903, -0.0348, -0.0129, 0.0519, -0.023, -0.00568, -0.0942, -0.0153, 0.00299],
	    [-0.525, 0.206, 0.0779, 0.0988, -0.0376, -0.0151, 0.0291, -0.00493, -0.00902, -0.0895, -0.0163, 0.00259],
	    [-0.389, 0.143, 0.0612, 0.0714, -0.0236, -0.013, 0.0233, -0.00546, -0.00592, -0.0689, -0.0143, 0.00194]
	    );
	
	my (@dsf_est, @dsf_dev);
	for (my $ind=0; $ind <= $#T; $ind++) {
		my $const = $dsf_coef[$ind][0]+$dsf_coef[$ind][1]*log($Be->[$ind])+$dsf_coef[$ind][2]*(log($Be->[$ind])**2);
		my $m_term = ($dsf_coef[$ind][3]+$dsf_coef[$ind][4]*log($Be->[$ind])+$dsf_coef[$ind][5]*(log($Be->[$ind])**2))*$M;
		my $r_term = ($dsf_coef[$ind][6]+$dsf_coef[$ind][7]*log($Be->[$ind])+$dsf_coef[$ind][8]*(log($Be->[$ind])**2))*log($R+1);


		$dsf_est[$ind] = exp($const + $m_term + $r_term);
		#$dsf_dev[$ind] = sign(5 - be') .* (log(be' / 5) .* dsf_coef(:,10) + (log(be'/5).^2) .* dsf_coef(:,11));
	}
	
	return \@dsf_est;
}

# send product to a remote server
sub performance_point {
    my ($capacity, $demand_sa, $demand_sd, $mbt_fragility) = @_;
	
	my @periods = @{$capacity->{'periods'}};
	my @sa = @{$capacity->{'sa'}};
	my @sd = @{$capacity->{'sd'}};
	my $Bc = exp($mbt_fragility->{'Bc'});
	my $Bd = exp($mbt_fragility->{'Bd'});
	#use Math::Matrix;
	my $ind;
	my $performance = {};
	#my @intersect_test;
	my @sa_upper = map {$_ * $Bc} @sa;
	my @sd_upper = map {$_ * $Bc} @sd;
	my @sa_lower = map {$_ / $Bc} @sa;
	my @sd_lower = map {$_ / $Bc} @sd;
	my @dem_sa_upper = map {$_ * $Bd} @$demand_sa;
	my @dem_sd_upper = map {$_ * $Bd} @$demand_sd;
	my @dem_sa_lower = map {$_ / $Bd} @$demand_sa;
	my @dem_sd_lower = map {$_ / $Bd} @$demand_sd;
	
	$performance->{'median'} = intersection($capacity->{'sa'}, $capacity->{'sd'}, $demand_sa, $demand_sd);	
	$performance->{'capacity_upper'} = intersection(\@sa_upper, \@sd_upper, $demand_sa, $demand_sd);	
	$performance->{'capacity_lower'} = intersection(\@sa_lower, \@sd_lower, $demand_sa, $demand_sd);	
	$performance->{'demand_lower'} = intersection($capacity->{'sa'}, $capacity->{'sd'}, \@dem_sa_lower, \@dem_sd_lower);	
	$performance->{'demand_upper'} = intersection($capacity->{'sa'}, $capacity->{'sd'}, \@dem_sa_upper, \@dem_sd_upper);	
	return $performance;
}

# send product to a remote server
sub intersection {
    my ($capacity_sa, $capacity_sd, $demand_sa, $demand_sd) = @_;
	
	#use Math::Matrix;
	my $ind;
	my $performance = {};
	#my @intersect_test;
	for ($ind=1; $ind < scalar @$demand_sa; $ind++) {
		my ($cap_sa1, $cap_sd1) =  ($capacity_sa->[$ind-1], $capacity_sd->[$ind-1]);
		my ($cap_sa2, $cap_sd2) =  ($capacity_sa->[$ind], $capacity_sd->[$ind]);
		my ($dem_sa1, $dem_sa2, $dem_sd1, $dem_sd2) = ($demand_sa->[$ind-1], $demand_sa->[$ind],
							       $demand_sd->[$ind-1], $demand_sd->[$ind]);
		#my $intersect = new Math::Matrix ([$cap_sd2 - $cap_sd1, 0, -1, 0, -$cap_sd1],
		#				  [0, $dem_sd2 - $dem_sd1, -1, 0, -$dem_sd1],
		#				  [$cap_sa2 - $cap_sa1, 0, 0, -1, -$cap_sa1],
		#				  [0, $dem_sa2 - $dem_sa1, 0, -1, -$dem_sa1]) ->solve;
		#my ($t1, $t2, $sa, $sd) = ($intersect->[0]->[0], $intersect->[1]->[0],
		#			   $intersect->[2]->[0], $intersect->[3]->[0]);
		my ($a1, $b1, $c1, $a2, $b2, $c2) = (
			$cap_sd2-$cap_sd1, $dem_sd1-$dem_sd2, $dem_sd1-$cap_sd1,
			$cap_sa2-$cap_sa1, $dem_sa1-$dem_sa2, $dem_sa1-$cap_sa1,
		);
		my $div = $a1*$b2 - $b1*$a2;
		next if ($div == 0);
		my $px = ($c1*$b2 - $b1*$c2) / $div;
		my $py = ($a1*$c2 - $c1*$a2) / $div;
		
		if ($px>=0 && $px<=1 && $py<=1 && $py>=0) {
			$performance->{'sa'} = $py;
			$performance->{'sd'} = $px;
			last;
		}
		
	}
	
	return $performance;
}

# send product to a remote server
sub compute_ds {
    my ($performance, $mbt_fragility, $fragility_beta) = @_;
	
	my @alpha = ($mbt_fragility->{'SS'}, $mbt_fragility->{'SM'}, $mbt_fragility->{'SE'}, $mbt_fragility->{'SC'});
	my $beta = fragility_beta($performance, $mbt_fragility);
	my @beta = ($beta->{'BdS'}, $beta->{'BdM'}, $beta->{'BdE'}, $beta->{'BdC'});
	
	use Math::CDF qw(pnorm);
	my $cdf = {};
	my $pdf = {};
	my $err = {};
	foreach my $frag ('median', 'capacity_upper', 'capacity_lower', 'demand_upper', 'demand_lower') {
		my (@cdf, @pdf, @err_max, @err_min);
		for (my $ind=0; $ind <= $#alpha; $ind++) {
			next unless ($performance->{$frag}->{'sd'} > 0);
			push @cdf, pnorm((log($performance->{$frag}->{'sd'} / $alpha[$ind])) / $beta[$ind]);
		}
		$cdf->{$frag} = \@cdf;
		my @temp = (1, @cdf);
		@pdf = map {$temp[$_] - $cdf[$_]} (0..3);
		push @pdf, $cdf[3];
		$pdf->{$frag} = \@pdf;
		@err_max = map{&{_max}($pdf[$_], $err->{'max'}->[$_])} (0..4);
		$err->{'max'} = \@err_max;
		@err_min = map{&{_min}($pdf[$_], $err->{'min'}->[$_])} (0..4);
		$err->{'min'} = \@err_min;
	}
	
	my $ds = {
		'cdf' => $cdf,
		'pdf' => $pdf,
		'err' => $err,		
	};
	 
	#print join ' ', @cdf,"\n";
	return $ds, $beta;
}

# send product to a remote server
sub fragility_beta {
    my ($performance, $mbt_fragility) = @_;
	
	my $dem_upper_d = $performance->{'demand_upper'}->{'sd'};
	my $dem_lower_d = $performance->{'demand_lower'}->{'sd'};
	my $cap_upper_d = $performance->{'capacity_upper'}->{'sd'};
	my $cap_lower_d = $performance->{'capacity_lower'}->{'sd'};
	my $sc = $mbt_fragility->{'SC'};
	return 0 unless ($dem_lower_d && $dem_upper_d && $cap_upper_d && $cap_lower_d);
	my ($Du, $Dl, $Bd, $Bc, $Bcd);
	
	$Du = ($dem_upper_d < 1.2*$sc) ? $dem_upper_d : 1.2*$sc;
	$Dl = ($dem_lower_d < 1.2*$sc) ? $dem_lower_d : 1.2*$sc;
	$Bd = (log($Du/$Dl) > $mbt_fragility->{'Bd'}) ? log($Du/$Dl)/2 : $mbt_fragility->{'Bd'}/2;
	
	$Du = ($cap_upper_d < 1.2*$sc) ? $cap_upper_d : 1.2*$sc;
	$Dl = ($cap_lower_d < 1.2*$sc) ? $cap_lower_d : 1.2*$sc;
	$Bc = (log($Du/$Dl) > $mbt_fragility->{'Bc'}) ? log($Du/$Dl)/2 : $mbt_fragility->{'Bc'}/2;
	
	$Bcd = sqrt($Bc**2 + $Bd**2);
	my $fragility_beta = {
		'Bc' => $Bc,
		'Bd' => $Bd,
		'Bcd' => $Bcd,
		'BdS' => sqrt($Bcd**2 + $mbt_fragility->{'betaTS'}**2),
		'BdM' => sqrt($Bcd**2 + $mbt_fragility->{'betaTM'}**2),
		'BdE' => sqrt($Bcd**2 + $mbt_fragility->{'betaTE'}**2),
		'BdC' => sqrt($Bcd**2 + $mbt_fragility->{'betaTC'}**2),
	};
	
	return $fragility_beta;
}

sub compute_loss {
    my ($ds) = @_;
	
	my @lr = (0.02, 0.1, 0.5, 1);	
	my $pdf = $ds->{'pdf'};
	my $loss = {};
	foreach my $frag ('median', 'capacity_upper', 'capacity_lower', 'demand_upper', 'demand_lower') {
		my (@loss);
		my @pdf_frag = @{$pdf->{$frag}};
		my @temp = map {$lr[$_] * $pdf_frag[$_+1]} (0..3);
		my $sum = _sum(@temp);
		@loss = (1-$pdf_frag[1], @temp, $sum);
		$loss->{$frag} = \@loss;
	}
	#print join ' ', @cdf,"\n";
	return $loss;
}

