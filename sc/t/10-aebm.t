#!perl 

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test;
use Data::Dumper;

BEGIN { plan tests => 123 }

use SC;
use SC::AEBM;

my $sm_input = {
    'magnitude' => 6.9,
    'dist' => 10,
    # %g
    'pga' => 0.60,
    'psa03' => 1.500,
    'psa10' => 0.600,
    'psa30' => 0.200,
};

{
    print "Initialization tests...\n";
    ok not defined $SC::errstr;
    SC->initialize('sc_test.conf');
    ok not defined $SC::errstr or print STDERR "$SC::errstr\n";
    SC->log(1, "test message for AEBM.pm");
    ok not defined $SC::errstr;
    my $aebm = SC::AEBM->new() or print "$SC::errstr\n";
    ok $aebm;
    my $str_delta;

    # W1 test
    $aebm->set_mbt_v2('W1M');
    ok 'W1M', $aebm->{'MBT_v2'};
    ok 'M', $aebm->{'code_era'};
    ok 14, $aebm->{'MBT_height'}->{'Avg_1'};
    ok 'W1', $aebm->{'MBT'};
    ok 0.025, $aebm->{'Te_param'}->{'Cr'};
    ok 0.27, sprintf("%.2f", $aebm->{'Te'});
    ok 0.18, sprintf("%.2f", $aebm->{'T'});
    ok "0.10", sprintf("%.2f", $aebm->{'Cs'});
    ok 0.8, $aebm->{'alpha1'};
    ok "0.75", $aebm->{'alpha2'};
    ok "1.00", sprintf("%.2f", $aebm->{'alpha3'});
    ok "2.70", sprintf("%.2f", $aebm->{'gamma'});
    ok "2.00", sprintf("%.2f", $aebm->{'lamda'});
    ok "6.00", sprintf("%.2f", $aebm->{'mu'});
    ok "10.00", sprintf("%.2f", $aebm->{'Be'});
    ok "0.34", sprintf("%.2f", $aebm->{'Ay'});
    ok "0.24", sprintf("%.2f", $aebm->{'Dy'});
    ok "0.68", sprintf("%.2f", $aebm->{'Au'});
    ok "2.92", sprintf("%.2f", $aebm->{'Du'});
    ok "0.4", sprintf("%.1f", $aebm->{'Bc'});
    ok "0.6", sprintf("%.1f", $aebm->{'betaTds'});
    $str_delta = $aebm->{'str_delta'};
    ok "0.004", sprintf("%.3f", $str_delta->{'deltaS'});
    ok "0.010", sprintf("%.3f", $str_delta->{'deltaM'});
    ok "0.031", sprintf("%.3f", $str_delta->{'deltaE'});
    ok "0.075", sprintf("%.3f", $str_delta->{'deltaC'});
    ok "0.50", sprintf("%.2f", $aebm->{'STR_SS'});
    ok "1.26", sprintf("%.2f", $aebm->{'STR_SM'});
    ok "3.91", sprintf("%.2f", $aebm->{'STR_SE'});
    ok "9.45", sprintf("%.2f", $aebm->{'STR_SC'});
    $aebm->capacity_curve();
    ok "0.00", sprintf("%.2f", $aebm->{'capacity'}->{'periods'}->[0]);
    ok "0.00", sprintf("%.2f", $aebm->{'capacity'}->{'sa'}->[0]);
    ok "0.00", sprintf("%.2f", $aebm->{'capacity'}->{'sd'}->[0]);
    ok "0.27", sprintf("%.2f", $aebm->{'capacity'}->{'periods'}->[8]);
    ok "0.34", sprintf("%.2f", $aebm->{'capacity'}->{'sa'}->[8]);
    ok "0.24", sprintf("%.2f", $aebm->{'capacity'}->{'sd'}->[8]);
    ok "10.00", sprintf("%.2f", $aebm->{'capacity'}->{'periods'}->[20]);
    ok "0.68", sprintf("%.2f", $aebm->{'capacity'}->{'sa'}->[20]);
    ok "661.50", sprintf("%.2f", $aebm->{'capacity'}->{'sd'}->[20]);

    $aebm->compute_kappa($sm_input);
    ok "0.50", sprintf("%.2f", $aebm->{'kappa'});

    $aebm->response_spectra($sm_input);
    ok "0.08", sprintf("%.2f", $aebm->{'domain_periods'}->{'T0'});
    ok "0.40", sprintf("%.2f", $aebm->{'domain_periods'}->{'Ts'});
    ok "3.50", sprintf("%.2f", $aebm->{'domain_periods'}->{'Tl'});
    ok "1.00", sprintf("%.2f", $aebm->{'smooth_factor'}->[0]);
    ok "0.60", sprintf("%.2f", $aebm->{'sa_smooth'}->[0]);

    $aebm->compute_Be();
    ok "10.00", sprintf("%.2f", $aebm->{'Be'}->[0]);
    $aebm->compute_dsf($sm_input);
    ok "1.00", sprintf("%.2f", $aebm->{'dsf'}->[0]);
    $aebm->{'demand_sa'} = $aebm->demand('demand_sa');
    ok "1.27", sprintf("%.2f", $aebm->{'demand_sa'}->[4]);
    $aebm->{'demand_sd'} = $aebm->demand('demand_sd');
    $aebm->performance_point();
    ok "0.57", sprintf("%.2f", $aebm->{'performance'}->{'median'}->{'sa'});
    ok "1.98", sprintf("%.2f", $aebm->{'performance'}->{'median'}->{'sd'});
    ok "0.66", sprintf("%.2f", $aebm->{'performance'}->{'demand_upper'}->{'sa'});
    ok "3.50", sprintf("%.2f", $aebm->{'performance'}->{'demand_upper'}->{'sd'});
    $aebm->compute_ds();
    ok "0.94", sprintf("%.2f", $aebm->{'DS'}->{'cdf'}->{'median'}->[0]);
    ok "0.06", sprintf("%.2f", $aebm->{'DS'}->{'pdf'}->{'median'}->[0]);
    ok "0.01", sprintf("%.2f", $aebm->{'DS'}->{'err'}->{'min'}->[0]);
    ok "0.87", sprintf("%.2f", $aebm->{'DS'}->{'beta'}->{'BdS'});

    # C2 Test
    $aebm->set_mbt_v2('C2MP');
    ok 'C2MP', $aebm->{'MBT_v2'};
    ok 'P', $aebm->{'code_era'};
    ok 12, $aebm->{'MBT_height'}->{'Avg_1'};
    ok 'C2', $aebm->{'MBT'};
    ok 0.0215, $aebm->{'Te_param'}->{'Cr'};
    ok 0.69, sprintf("%.2f", $aebm->{'Te'});
    ok "0.40", sprintf("%.2f", $aebm->{'T'});
    ok "0.05", sprintf("%.2f", $aebm->{'Cs'});
    ok "0.8", $aebm->{'alpha1'};
    ok "0.75", $aebm->{'alpha2'};
    ok "1.54", sprintf("%.2f", $aebm->{'alpha3'});
    ok "1.88", sprintf("%.2f", $aebm->{'gamma'});
    ok "2.00", sprintf("%.2f", $aebm->{'lamda'});
    ok "4.07", sprintf("%.2f", $aebm->{'mu'});
    ok "7.00", sprintf("%.2f", $aebm->{'Be'});
    ok "0.12", sprintf("%.2f", $aebm->{'Ay'});
    ok "0.54", sprintf("%.2f", $aebm->{'Dy'});
    ok "0.24", sprintf("%.2f", $aebm->{'Au'});
    ok "4.42", sprintf("%.2f", $aebm->{'Du'});
    $str_delta = $aebm->{'str_delta'};
    ok "0.003", sprintf("%.3f", $str_delta->{'deltaS'});
    ok "0.006", sprintf("%.3f", $str_delta->{'deltaM'});
    ok "0.016", sprintf("%.3f", $str_delta->{'deltaE'});
    ok "0.040", sprintf("%.3f", $str_delta->{'deltaC'});
    ok "0.4", sprintf("%.1f", $aebm->{'Bc'});
    ok "0.6", sprintf("%.1f", $aebm->{'betaTds'});
    ok "0.88", sprintf("%.2f", $aebm->{'STR_SS'});
    ok "1.75", sprintf("%.2f", $aebm->{'STR_SM'});
    ok "4.68", sprintf("%.2f", $aebm->{'STR_SE'});
    ok "11.69", sprintf("%.2f", $aebm->{'STR_SC'});

    $aebm->capacity_curve();
    $aebm->compute_kappa($sm_input);

    $aebm->response_spectra($sm_input);
    ok "0.08", sprintf("%.2f", $aebm->{'domain_periods'}->{'T0'});
    ok "0.40", sprintf("%.2f", $aebm->{'domain_periods'}->{'Ts'});
    ok "3.50", sprintf("%.2f", $aebm->{'domain_periods'}->{'Tl'});

    $aebm->compute_Be();
    $aebm->compute_dsf($sm_input);

    # PC1 Test
    $aebm->set_mbt_v2('PC1M');
    ok 'PC1M', $aebm->{'MBT_v2'};
    ok 'M', $aebm->{'code_era'};
    ok 15, $aebm->{'MBT_height'}->{'Avg_1'};
    ok 'PC1', $aebm->{'MBT'};
    ok 0.025, $aebm->{'Te_param'}->{'Cr'};
    ok 0.29, sprintf("%.2f", $aebm->{'Te'});
    ok 0.19, sprintf("%.2f", $aebm->{'T'});
    ok 0.07, sprintf("%.2f", $aebm->{'Cs'});
    ok 0.75, $aebm->{'alpha1'};
    ok "0.75", $aebm->{'alpha2'};
    ok "1.00", sprintf("%.2f", $aebm->{'alpha3'});
    ok "2.70", sprintf("%.2f", $aebm->{'gamma'});
    ok "1.33", sprintf("%.2f", $aebm->{'lamda'});
    ok "6.00", sprintf("%.2f", $aebm->{'mu'});
    ok "7.00", sprintf("%.2f", $aebm->{'Be'});
    ok "0.24", sprintf("%.2f", $aebm->{'Ay'});
    ok "0.19", sprintf("%.2f", $aebm->{'Dy'});
    ok "0.32", sprintf("%.2f", $aebm->{'Au'});
    ok "1.53", sprintf("%.2f", $aebm->{'Du'});
    $str_delta = $aebm->{'str_delta'};
    ok "0.004", sprintf("%.3f", $str_delta->{'deltaS'});
    ok "0.007", sprintf("%.3f", $str_delta->{'deltaM'});
    ok "0.019", sprintf("%.3f", $str_delta->{'deltaE'});
    ok "0.053", sprintf("%.3f", $str_delta->{'deltaC'});
    ok "0.4", sprintf("%.1f", $aebm->{'Bc'});
    ok "0.6", sprintf("%.1f", $aebm->{'betaTds'});
    ok "0.54", sprintf("%.2f", $aebm->{'STR_SS'});
    ok "0.95", sprintf("%.2f", $aebm->{'STR_SM'});
    ok "2.56", sprintf("%.2f", $aebm->{'STR_SE'});
    ok "7.15", sprintf("%.2f", $aebm->{'STR_SC'});

    $aebm->capacity_curve();
    $aebm->compute_kappa($sm_input);

    $aebm->response_spectra($sm_input);
    ok "0.08", sprintf("%.2f", $aebm->{'domain_periods'}->{'T0'});
    ok "0.40", sprintf("%.2f", $aebm->{'domain_periods'}->{'Ts'});
    ok "3.50", sprintf("%.2f", $aebm->{'domain_periods'}->{'Tl'});

    $aebm->compute_Be();
    $aebm->compute_dsf($sm_input);

#    ok (0.18, ($aebm->{'Cs'}));
    #my $ts = SC->time_to_ts(0);
    #ok $ts eq '1970-01-01 00:00:00.00Z' or print STDERR "$ts\n";
    #ok $ts, '1970-01-01 00:00:00';
    #SC->error("this", "is", "an", "error");
    #SC->warn("this is a warning");
    #my $h = SC->xml_in(qq{<elem one="1" two="2" />});
    #ok $SC::errstr, undef, $SC::errstr;
    #ok exists $h->{'elem'};
    #$h = $h->{'elem'};
    #ok exists $h->{'one'};
    #ok $h->{'two'}, 2;
    #ok (SC->to_xml_attrs({'one'=>1}, 'foo', [qw(one)], 1,
	#'<foo one="1"/>'));
    #ok (SC->to_xml_attrs({'one'=>1, 'two'=>2}, 'foo', [qw(two)], 0,
	#'<foo two="2">'));
    
}

# vim:syntax=perl
