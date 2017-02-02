# $Id: AEBM.pm 72 2016-11-02 15:17:00Z klin $

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
# U.S. Geological Survey (USGS) have no obligations to provide maintenance, 
# support, updates, enhancements or modifications. In no event shall USGS 
# be liable to any party for direct, indirect, special, incidental or 
# consequential damages, including lost profits, arising out of the use 
# of this software, its documentation, or data obtained though the use 
# of this software, even if USGS or have been advised of the
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
# klin@usgs.gov.  
#
#############################################################################

use strict;
use warnings;

package SC::AEBM;

use vars qw( %CONSTANTS );

use SC;

# HAZUS Facility Model defined in V2/V3
$CONSTANTS{PERIODS} = 
  [
    0.01, 0.02, 0.03, 0.05, 0.075, 0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0
  ];

# HAZUS Facility Model defined in V2/V3
$CONSTANTS{CODE_ERA} = 
  {'VH' => 'Special High Code', 
    'H' => 'High Code', 
    'M' => 'Moderate Code', 
    'L' => 'Low Code', 
    'P' => 'Pre Code', 
  };

# HAZUS Facility Model defined in V2/V3
$CONSTANTS{MBT_V2} = 
  {'C1HH' => 'C1H High Code', 
    'C1HM' => 'C1H Moderate Code', 
    'C1HL' => 'C1H Low Code', 
    'C1HP' => 'C1H Pre Code', 
    'C1MH' => 'C1M High Code', 
    'C1MM' => 'C1M Moderate Code', 
    'C1ML' => 'C1M Low Code', 
    'C1MP' => 'C1M Pre Code', 
    'C1LH' => 'C1L High Code', 
    'C1LM' => 'C1L Moderate Code', 
    'C1LL' => 'C1L Low Code', 
    'C1LP' => 'C1L Pre Code', 
    'C2HH' => 'C2H High Code', 
    'C2HM' => 'C2H Moderate Code', 
    'C2HL' => 'C2H Low Code', 
    'C2HP' => 'C2H Pre Code', 
    'C2MH' => 'C2M High Code', 
    'C2MM' => 'C2M Moderate Code', 
    'C2ML' => 'C2M Low Code', 
    'C2MP' => 'C2M Pre Code', 
    'C2LH' => 'C2L High Code', 
    'C2LM' => 'C2L Moderate Code', 
    'C2LL' => 'C2L Low Code', 
    'C2LP' => 'C2L Pre Code', 
    'C3HL' => 'C3H Low Code', 
    'C3HP' => 'C3H Pre Code', 
    'C3LL' => 'C3L Low Code', 
    'C3LP' => 'C3L Pre Code', 
    'C3ML' => 'C3M Low Code', 
    'C3MP' => 'C3M Pre Code', 
    'MHH' => 'MH High Code', 
    'MHM' => 'MH Moderate Code', 
    'MHL' => 'MH Low Code', 
    'MHP' => 'MH Pre Code', 
    'PC1H' => 'PC1 High Code', 
    'PC1M' => 'PC1 Moderate Code', 
    'PC1L' => 'PC1 Low Code', 
    'PC1P' => 'PC1 Pre Code', 
    'PC2HH' => 'PC2H High Code', 
    'PC2HM' => 'PC2H Moderate Code', 
    'PC2HL' => 'PC2H Low Code', 
    'PC2HP' => 'PC2H Pre Code', 
    'PC2MH' => 'PC2M High Code', 
    'PC2MM' => 'PC2M Moderate Code', 
    'PC2ML' => 'PC2M Low Code', 
    'PC2MP' => 'PC2M Pre Code', 
    'PC2LH' => 'PC2L High Code', 
    'PC2LM' => 'PC2L Moderate Code', 
    'PC2LL' => 'PC2L Low Code', 
    'PC2LP' => 'PC2L Pre Code', 
    'RM1MH' => 'RM1M High Code', 
    'RM1MM' => 'RM1M Moderate Code', 
    'RM1ML' => 'RM1M Low Code', 
    'RM1MP' => 'RM1M Pre Code', 
    'RM1LH' => 'RM1L High Code', 
    'RM1LM' => 'RM1L Moderate Code', 
    'RM1LL' => 'RM1L Low Code', 
    'RM1LP' => 'RM1L Pre Code', 
    'RM2HH' => 'RM2H High Code', 
    'RM2HM' => 'RM2H Moderate Code', 
    'RM2HL' => 'RM2H Low Code', 
    'RM2HP' => 'RM2H Pre Code', 
    'RM2MH' => 'RM2M High Code', 
    'RM2MM' => 'RM2M Moderate Code', 
    'RM2ML' => 'RM2M Low Code', 
    'RM2MP' => 'RM2M Pre Code', 
    'RM2LH' => 'RM2L High Code', 
    'RM2LM' => 'RM2L Moderate Code', 
    'RM2LL' => 'RM2L Low Code', 
    'RM2LP' => 'RM2L Pre Code', 
    'S1HH' => 'S1H High Code', 
    'S1HM' => 'S1H Moderate Code', 
    'S1HL' => 'S1H Low Code', 
    'S1HP' => 'S1H Pre Code', 
    'S1MH' => 'S1M High Code', 
    'S1MM' => 'S1M Moderate Code', 
    'S1ML' => 'S1M Low Code', 
    'S1MP' => 'S1M Pre Code', 
    'S1LH' => 'S1L High Code', 
    'S1LM' => 'S1L Moderate Code', 
    'S1LL' => 'S1L Low Code', 
    'S1LP' => 'S1L Pre Code', 
    'S2HH' => 'S2H High Code', 
    'S2HM' => 'S2H Moderate Code', 
    'S2HL' => 'S2H Low Code', 
    'S2HP' => 'S2H Pre Code', 
    'S2MH' => 'S2M High Code', 
    'S2MM' => 'S2M Moderate Code', 
    'S2ML' => 'S2M Low Code', 
    'S2MP' => 'S2M Pre Code', 
    'S2LH' => 'S2L High Code', 
    'S2LM' => 'S2L Moderate Code', 
    'S2LL' => 'S2L Low Code', 
    'S2LP' => 'S2L Pre Code', 
    'S3H' => 'S3 High Code', 
    'S3M' => 'S3 Moderate Code', 
    'S3L' => 'S3 Low Code', 
    'S3P' => 'S3 Pre Code', 
    'S4HH' => 'S4H High Code', 
    'S4HM' => 'S4H Moderate Code', 
    'S4HL' => 'S4H Low Code', 
    'S4HP' => 'S4H Pre Code', 
    'S4MH' => 'S4M High Code', 
    'S4MM' => 'S4M Moderate Code', 
    'S4ML' => 'S4M Low Code', 
    'S4MP' => 'S4M Pre Code', 
    'S4LH' => 'S4L High Code', 
    'S4LM' => 'S4L Moderate Code', 
    'S4LL' => 'S4L Low Code', 
    'S4LP' => 'S4L Pre Code', 
    'S5HL' => 'S5H Low Code', 
    'S5HP' => 'S5H Pre Code', 
    'S5LL' => 'S5L Low Code', 
    'S5LP' => 'S5L Pre Code', 
    'S5ML' => 'S5M Low Code', 
    'S5MP' => 'S5M Pre Code', 
    'URMLL' => 'URML Low Code', 
    'URMLP' => 'URML Pre Code', 
    'URMML' => 'URMM Low Code', 
    'URMMP' => 'URMM Pre Code', 
    'W1H' => 'W1 High Code', 
    'W1M' => 'W1 Moderate Code', 
    'W1L' => 'W1 Low Code', 
    'W1P' => 'W1 Pre Code', 
    'W2H' => 'W2 High Code', 
    'W2M' => 'W2 Moderate Code', 
    'W2L' => 'W2 Low Code', 
    'W2P' => 'W2 Pre Code', 
};

# Model Building Types Typical Height from HAZUS-MH Table 3.1
$CONSTANTS{MBT_HEIGHT} = 
  {'W1'   => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 1, 'Height' => 14},
    'W1A'   => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 1, 'Height' => 14},
    'W2' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 2, 'Height' => 24},
    'S1L' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 2, 'Height' => 24},
    'S1M' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 5, 'Height' => 60},
    'S1H' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 13, 'Height' => 156},
    'S2L' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 2, 'Height' => 24},
    'S2M' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 5, 'Height' => 60},
    'S2H' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 13, 'Height' => 156},
    'S3' => {'Avg_1' => 15, 'Avg_n' => 12, 'Typical' => 1, 'Height' => 15},
    'S4L' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 2, 'Height' => 24},
    'S4M' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 5, 'Height' => 60},
    'S4H' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 13, 'Height' => 156},
    'S5L' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 2, 'Height' => 24},
    'S5M' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 5, 'Height' => 60},
    'S5H' => {'Avg_1' => 14, 'Avg_n' => 12, 'Typical' => 13, 'Height' => 156},
    'C1L' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 2, 'Height' => 20},
    'C1M' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 5, 'Height' => 50},
    'C1H' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 12, 'Height' => 120},
    'C2L' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 2, 'Height' => 20},
    'C2M' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 5, 'Height' => 50},
    'C2H' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 12, 'Height' => 120},
    'C3L' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 2, 'Height' => 20},
    'C3M' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 5, 'Height' => 50},
    'C3H' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 12, 'Height' => 120},
    'PC1' => {'Avg_1' => 15, 'Avg_n' => 12, 'Typical' => 1, 'Height' => 15},
    'PC2L' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 2, 'Height' => 20},
    'PC2M' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 5, 'Height' => 50},
    'PC2H' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 12, 'Height' => 120},
    'RM1L' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 2, 'Height' => 20},
    'RM1M' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 5, 'Height' => 50},
    'RM2L' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 2, 'Height' => 20},
    'RM2M' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 5, 'Height' => 50},
    'RM2H' => {'Avg_1' => 12, 'Avg_n' => 10, 'Typical' => 12, 'Height' => 120},
    'URML' => {'Avg_1' => 15, 'Avg_n' => 12, 'Typical' => 1, 'Height' => 15},
    'URMM' => {'Avg_1' => 15, 'Avg_n' => 12, 'Typical' => 3, 'Height' => 35},
    'MH' => {'Avg_1' => 10, 'Typical' => 1, 'Height' => 10},
  };
  
# Model Building Types Design Strength from HAZUS-MH Table 5.4
$CONSTANTS{Cs} = 
  {'W1'   => {'H' => 0.2, 'M' => 0.15, 'L' => 0.1, 'P' => 0.1},
    'W2' => {'H' => 0.2, 'M' => 0.10, 'L' => 0.05, 'P' => 0.05},
    'S1L' => {'H' => 0.133, 'M' => 0.067, 'L' => 0.033, 'P' => 0.033},
    'S1M' => {'H' => 0.1, 'M' => 0.05, 'L' => 0.025, 'P' => 0.025},
    'S1H' => {'H' => 0.067, 'M' => 0.033, 'L' => 0.017, 'P' => 0.017},
    'S2L' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'S2M' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'S2H' => {'H' => 0.15, 'M' => 0.075, 'L' => 0.038, 'P' => 0.038},
    'S3' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'S4L' => {'H' => 0.16, 'M' => 0.08, 'L' => 0.04, 'P' => 0.04},
    'S4M' => {'H' => 0.16, 'M' => 0.08, 'L' => 0.04, 'P' => 0.04},
    'S4H' => {'H' => 0.12, 'M' => 0.06, 'L' => 0.03, 'P' => 0.03},
    'S5L' => {'L' => 0.05, 'P' => 0.05},
    'S5M' => {'L' => 0.05, 'P' => 0.05},
    'S5H' => {'L' => 0.038, 'P' => 0.038},
    'C1L' => {'H' => 0.133, 'M' => 0.067, 'L' => 0.033, 'P' => 0.033},
    'C1M' => {'H' => 0.133, 'M' => 0.067, 'L' => 0.033, 'P' => 0.033},
    'C1H' => {'H' => 0.067, 'M' => 0.033, 'L' => 0.017, 'P' => 0.017},
    'C2L' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'C2M' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'C2H' => {'H' => 0.067, 'M' => 0.033, 'L' => 0.017, 'P' => 0.017},
    'C3L' => {'L' => 0.05, 'P' => 0.05},
    'C3M' => {'L' => 0.05, 'P' => 0.05},
    'C3H' => {'L' => 0.038, 'P' => 0.038},
    'PC1' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'PC2L' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'PC2M' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'PC2H' => {'H' => 0.15, 'M' => 0.075, 'L' => 0.038, 'P' => 0.038},
    'RM1L' => {'H' => 0.267, 'M' => 0.133, 'L' => 0.067, 'P' => 0.067},
    'RM1M' => {'H' => 0.267, 'M' => 0.133, 'L' => 0.067, 'P' => 0.067},
    'RM2L' => {'H' => 0.267, 'M' => 0.133, 'L' => 0.067, 'P' => 0.067},
    'RM2M' => {'H' => 0.267, 'M' => 0.133, 'L' => 0.067, 'P' => 0.067},
    'RM2H' => {'H' => 0.2, 'M' => 0.1, 'L' => 0.05, 'P' => 0.05},
    'URML' => {'L' => 0.067, 'P' => 0.067},
    'URMM' => {'L' => 0.067, 'P' => 0.067},
    'MH' => {'H' => 0.1, 'M' => 0.1, 'L' => 0.1, 'P' => 0.1},
  };
  
# Model Building Types Capacity Parameters from HAZUS-MH Table 5.5
$CONSTANTS{CAPACITY} = 
  {'W1'   => {'Height' => 14, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 3.0},
    'W2' => {'Height' => 24, 'Te' => 0.40, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.5},
    'S1L' => {'Height' => 24, 'Te' => 0.50, 'alpha1' => 0.80, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 3.0},
    'S1M' => {'Height' => 60, 'Te' => 1.08, 'alpha1' => 0.80, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 3.0},
    'S1H' => {'Height' => 156, 'Te' => 2.21, 'alpha1' => 0.75, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 3.0},
    'S2L' => {'Height' => 24, 'Te' => 0.40, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.0},
    'S2M' => {'Height' => 60, 'Te' => 0.86, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.0},
    'S2H' => {'Height' => 156, 'Te' => 1.77, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.0},
    'S3' => {'Height' => 15, 'Te' => 0.40, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.0},
    'S4L' => {'Height' => 24, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.25},
    'S4M' => {'Height' => 60, 'Te' => 0.65, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.25},
    'S4H' => {'Height' => 156, 'Te' => 1.32, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.25},
    'S5L' => {'Height' => 24, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.00},
    'S5M' => {'Height' => 60, 'Te' => 0.65, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.00},
    'S5H' => {'Height' => 156, 'Te' => 1.32, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.00},
    'C1L' => {'Height' => 20, 'Te' => 0.40, 'alpha1' => 0.80, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 3.00},
    'C1M' => {'Height' => 50, 'Te' => 0.75, 'alpha1' => 0.80, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 3.00},
    'C1H' => {'Height' => 120, 'Te' => 1.45, 'alpha1' => 0.75, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 3.00},
    'C2L' => {'Height' => 20, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.50},
    'C2M' => {'Height' => 50, 'Te' => 0.56, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.50},
    'C2H' => {'Height' => 120, 'Te' => 1.09, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.50},
    'C3L' => {'Height' => 20, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.25},
    'C3M' => {'Height' => 50, 'Te' => 0.56, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.25},
    'C3H' => {'Height' => 120, 'Te' => 1.09, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.25},
    'PC1' => {'Height' => 15, 'Te' => 0.35, 'alpha1' => 0.50, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.00},
    'PC2L' => {'Height' => 20, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.00},
    'PC2M' => {'Height' => 50, 'Te' => 0.56, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.00},
    'PC2H' => {'Height' => 120, 'Te' => 1.09, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.00},
    'RM1L' => {'Height' => 20, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.00},
    'RM1M' => {'Height' => 50, 'Te' => 0.56, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.00},
    'RM2L' => {'Height' => 20, 'Te' => 0.35, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.00},
    'RM2M' => {'Height' => 50, 'Te' => 0.56, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.00},
    'RM2H' => {'Height' => 120, 'Te' => 1.09, 'alpha1' => 0.65, 'alpha2' => 0.60, 'gamma' => 1.10, 'lamda' => 2.00},
    'URML' => {'Height' => 15, 'Te' => 0.35, 'alpha1' => 0.50, 'alpha2' => 0.75, 'gamma' => 1.5, 'lamda' => 2.00},
    'URMM' => {'Height' => 35, 'Te' => 0.50, 'alpha1' => 0.75, 'alpha2' => 0.75, 'gamma' => 1.25, 'lamda' => 2.00},
    'MH' => {'Height' => 10, 'Te' => 0.35, 'alpha1' => 1.00, 'alpha2' => 1.00, 'gamma' => 1.50, 'lamda' => 2.00},
  };
  
# Ealstic Period Coefficients
$CONSTANTS{Te} = 
  {'C1'   => {'Cr' => 0.016, 'x' => 0.90, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'C2'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'C3'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'MH'   => {'Cr' => 0.025, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'PC1'   => {'Cr' => 0.025, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'PC2'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'RM1'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'RM2'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'S1'   => {'Cr' => 0.028, 'x' => 0.80, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'S2'   => {'Cr' => 0.0285, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'S3'   => {'Cr' => 0.025, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'S4'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'S5'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'URM'   => {'Cr' => 0.0215, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'W1'   => {'Cr' => 0.025, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'W1A'   => {'Cr' => 0.025, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
    'W2'   => {'Cr' => 0.025, 'x' => 0.75, 'Cu_H' => 1.4, 'Cu_M' => 1.5, 'Cu_L' => 1.6, 'Cu_P' => 1.7},
  };

# Ealstic Period Coefficients
$CONSTANTS{STR_DELTA} = 
  {'C1'   => {'VH' => {'deltaS' => 0.006, 'deltaM' => 0.013, 'deltaE' => 0.038, 'deltaC' => 0.100}, 
            'H' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.080}, 
            'M' => {'deltaS' => 0.005, 'deltaM' => 0.009, 'deltaE' => 0.023, 'deltaC' => 0.060}, 
            'L' => {'deltaS' => 0.005, 'deltaM' => 0.008, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            'P' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.040}, 
            },
    'C2'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.013, 'deltaE' => 0.038, 'deltaC' => 0.100}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.080}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.023, 'deltaC' => 0.060}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.040}, 
            },
    'C3'   => {'VH' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'H' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'M' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'L' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'P' => {'deltaS' => 0.002, 'deltaM' => 0.005, 'deltaE' => 0.012, 'deltaC' => 0.028}, 
            },
    'MH'   => {'VH' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'P' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            },
    'PC1'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.088}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.024, 'deltaC' => 0.070}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.007, 'deltaE' => 0.019, 'deltaC' => 0.053}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.044}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.005, 'deltaE' => 0.013, 'deltaC' => 0.035}, 
            },
    'PC2'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.088}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.024, 'deltaC' => 0.070}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.007, 'deltaE' => 0.019, 'deltaC' => 0.053}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.044}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.005, 'deltaE' => 0.013, 'deltaC' => 0.035}, 
            },
    'RM1'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.088}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.024, 'deltaC' => 0.070}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.007, 'deltaE' => 0.019, 'deltaC' => 0.053}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.044}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.005, 'deltaE' => 0.013, 'deltaC' => 0.035}, 
            },
    'RM2'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.088}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.024, 'deltaC' => 0.070}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.007, 'deltaE' => 0.019, 'deltaC' => 0.053}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.044}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.005, 'deltaE' => 0.013, 'deltaC' => 0.035}, 
            },
    'S1'   => {'VH' => {'deltaS' => 0.008, 'deltaM' => 0.015, 'deltaE' => 0.038, 'deltaC' => 0.100}, 
            'H' => {'deltaS' => 0.006, 'deltaM' => 0.012, 'deltaE' => 0.030, 'deltaC' => 0.080}, 
            'M' => {'deltaS' => 0.006, 'deltaM' => 0.010, 'deltaE' => 0.024, 'deltaC' => 0.060}, 
            'L' => {'deltaS' => 0.006, 'deltaM' => 0.010, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            'P' => {'deltaS' => 0.005, 'deltaM' => 0.008, 'deltaE' => 0.016, 'deltaC' => 0.040}, 
            },
    'S2'   => {'VH' => {'deltaS' => 0.006, 'deltaM' => 0.013, 'deltaE' => 0.038, 'deltaC' => 0.100}, 
            'H' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.080}, 
            'M' => {'deltaS' => 0.005, 'deltaM' => 0.009, 'deltaE' => 0.023, 'deltaC' => 0.060}, 
            'L' => {'deltaS' => 0.005, 'deltaM' => 0.008, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            'P' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.040}, 
            },
    'S3'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.088}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.024, 'deltaC' => 0.070}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.007, 'deltaE' => 0.019, 'deltaC' => 0.053}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.044}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.005, 'deltaE' => 0.013, 'deltaC' => 0.035}, 
            },
    'S4'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.010, 'deltaE' => 0.030, 'deltaC' => 0.088}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.008, 'deltaE' => 0.024, 'deltaC' => 0.070}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.007, 'deltaE' => 0.019, 'deltaC' => 0.053}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.006, 'deltaE' => 0.016, 'deltaC' => 0.044}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.005, 'deltaE' => 0.013, 'deltaC' => 0.035}, 
            },
    'S5'   => {'VH' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'H' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'M' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'L' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'P' => {'deltaS' => 0.002, 'deltaM' => 0.005, 'deltaE' => 0.012, 'deltaC' => 0.028}, 
            },
    'URM'   => {'VH' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'H' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'M' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'L' => {'deltaS' => 0.003, 'deltaM' => 0.006, 'deltaE' => 0.015, 'deltaC' => 0.035}, 
            'P' => {'deltaS' => 0.002, 'deltaM' => 0.005, 'deltaE' => 0.012, 'deltaC' => 0.028}, 
            },
    'W1'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.015, 'deltaE' => 0.050, 'deltaC' => 0.125}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.031, 'deltaC' => 0.075}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.025, 'deltaC' => 0.060}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.008, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            },
    'W1A'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.015, 'deltaE' => 0.050, 'deltaC' => 0.125}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.031, 'deltaC' => 0.075}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.025, 'deltaC' => 0.060}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.008, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            },
    'W2'   => {'VH' => {'deltaS' => 0.005, 'deltaM' => 0.015, 'deltaE' => 0.050, 'deltaC' => 0.125}, 
            'H' => {'deltaS' => 0.004, 'deltaM' => 0.012, 'deltaE' => 0.040, 'deltaC' => 0.100}, 
            'M' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.031, 'deltaC' => 0.075}, 
            'L' => {'deltaS' => 0.004, 'deltaM' => 0.010, 'deltaE' => 0.025, 'deltaC' => 0.060}, 
            'P' => {'deltaS' => 0.003, 'deltaM' => 0.008, 'deltaE' => 0.020, 'deltaC' => 0.050}, 
            },
  };

sub BEGIN {
    no strict 'refs';
    for my $method (qw(
            receive_timestamp
  			MBT_v2 code_era MBT_height
			Te T MBT Cs
			alpha1 alpha2 alpha3
			gamma lamda mu Be Ay Dy Au Du
			Bc betaTds
			initial_version 
			seq mag_type shakemap_id shakemap_version grid_id
			)) {
	*$method = sub {
	    my $self = shift;
	    @_ ? ($self->{$method} = shift, return $self)
	       : return $self->{$method};
	}
    }
}

# send product to a remote server
sub compute_ds {
    my ($self) = @_;
	
	#print Dumper($performance);
	my @alpha = ($self->{'STR_SS'}, $self->{'STR_SM'}, $self->{'STR_SE'}, $self->{'STR_SC'});
	my $beta = $self->fragility_beta();
	#print Dumper($beta);
	my @beta = ($beta->{'BdS'}, $beta->{'BdM'}, $beta->{'BdE'}, $beta->{'BdC'});
	
	use Math::CDF qw(pnorm);
	my $cdf = {};
	my $pdf = {};
	my $err = {};
	foreach my $frag ('median', 'capacity_upper', 'capacity_lower', 'demand_upper', 'demand_lower') {
		my (@cdf, @pdf, @err_max, @err_min);
		for (my $ind=0; $ind <= $#alpha; $ind++) {
			next unless ($self->{'performance'}->{$frag}->{'sd'} > 0 && $beta[$ind] > 0);
			#print "(log($performance->{$frag}->{'sd'} / $alpha[$ind])) / $beta[$ind])\n";
			push @cdf, pnorm((log($self->{'performance'}->{$frag}->{'sd'} / $alpha[$ind])) / $beta[$ind]);
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
        'beta' => $beta,
	};
	 
	#print join ' ', @cdf,"\n";
    $self->{'DS'} = $ds;

	return $ds, $beta;
}

# send product to a remote server
sub fragility_beta {
    my ($self) = @_;
	
    my $performance = $self->{'performance'};

	my $dem_upper_d = $performance->{'demand_upper'}->{'sd'};
	my $dem_lower_d = $performance->{'demand_lower'}->{'sd'};
	my $cap_upper_d = $performance->{'capacity_upper'}->{'sd'};
	my $cap_lower_d = $performance->{'capacity_lower'}->{'sd'};
	my $sc = $self->{'STR_SC'};
	#return 0 unless ($dem_lower_d && $dem_upper_d && $cap_upper_d && $cap_lower_d);
	my ($Du, $Dl, $Bd, $Bc, $Bcd);
	
	$Du = ($dem_upper_d < 1.2*$sc) ? $dem_upper_d : 1.2*$sc;
	$Dl = ($dem_lower_d < 1.2*$sc) ? $dem_lower_d : 1.2*$sc;
	if ($Dl <= 0 || $Du <= 0) {
	    $Bd = $self->{'Bd'}/2;
	} else {
	    $Bd = (log($Du/$Dl) > $self->{'Bd'}) ? log($Du/$Dl)/2 : $self->{'Bd'}/2;
	}
	
	$Du = ($cap_upper_d < 1.2*$sc) ? $cap_upper_d : 1.2*$sc;
	$Dl = ($cap_lower_d < 1.2*$sc) ? $cap_lower_d : 1.2*$sc;
	if ($Dl <= 0 || $Du <= 0) {
	    $Bc = $self->{'Bc'}/2;
	} else {
	    $Bc = (log($Du/$Dl) > $self->{'Bc'}) ? log($Du/$Dl)/2 : $self->{'Bc'}/2;
	}
	
	$Bcd = sqrt($Bc**2 + $Bd**2);
	my $fragility_beta = {
		'Bc' => $Bc,
		'Bd' => $Bd,
		'Bcd' => $Bcd,
		'BdS' => sqrt($Bcd**2 + $self->{'betaTS'}**2),
		'BdM' => sqrt($Bcd**2 + $self->{'betaTM'}**2),
		'BdE' => sqrt($Bcd**2 + $self->{'betaTE'}**2),
		'BdC' => sqrt($Bcd**2 + $self->{'betaTC'}**2),
	};
	
    $self->{'fragility_beta'} = $fragility_beta;

	return $fragility_beta;
}

# send product to a remote server
sub performance_point {
    my ($self) = @_;
	
	my $periods = $self->{'capacity'}->{'periods'};
	my $sa = $self->{'capacity'}->{'sa'};
	my $sd = $self->{'capacity'}->{'sd'};
	my $Bc = exp($self->{'Bc'});
	my $Bd = exp($self->{'Bd'});
    my $demand_sa = $self->{'demand_sa'};
    my $demand_sd = $self->{'demand_sd'};
	#use Math::Matrix;
	my $ind;
	my $performance = {};
	#my @intersect_test;
	my @sa_upper = map {$_ * $Bc} @$sa;
	my @sd_upper = map {$_ * $Bc} @$sd;
	my @sa_lower = map {$_ / $Bc} @$sa;
	my @sd_lower = map {$_ / $Bc} @$sd;
	my @dem_sa_upper = map {$_ * $Bd} @$demand_sa;
	my @dem_sd_upper = map {$_ * $Bd} @$demand_sd;
	my @dem_sa_lower = map {$_ / $Bd} @$demand_sa;
	my @dem_sd_lower = map {$_ / $Bd} @$demand_sd;

	$performance->{'median'} = intersection($sa, $sd, $demand_sa, $demand_sd);	
	$performance->{'capacity_upper'} = intersection(\@sa_upper, \@sd_upper, $demand_sa, $demand_sd);	
	$performance->{'capacity_lower'} = intersection(\@sa_lower, \@sd_lower, $demand_sa, $demand_sd);	
	$performance->{'demand_lower'} = intersection($sa, $sd, \@dem_sa_lower, \@dem_sd_lower);	
	$performance->{'demand_upper'} = intersection($sa, $sd, \@dem_sa_upper, \@dem_sd_upper);	

    $self->{'performance'} = $performance;

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

		my ($a1, $b1, $c1, $a2, $b2, $c2) = (
			$cap_sd2-$cap_sd1, $dem_sd1-$dem_sd2, $dem_sd1-$cap_sd1,
			$cap_sa2-$cap_sa1, $dem_sa1-$dem_sa2, $dem_sa1-$cap_sa1,
		);
		my $div = $a1*$b2 - $b1*$a2;
		next if ($div == 0);
		my $px = ($c1*$b2 - $b1*$c2) / $div;
		my $py = ($a1*$c2 - $c1*$a2) / $div;
		
		if (($px>=0 && $px<=1) || ($py<=1 && $py>=0)) {
			$performance->{'sa'} = $dem_sa1 - $py*$b2;
			$performance->{'sd'} = $dem_sd1 - $py*$b1;
			last;
		}

		
	}
	
	return $performance;
}

# send product to a remote server
sub demand {
    my ($self, $metric) = @_;
	
	my ($ind, @demand, $spectra, $damping);
	if ($metric eq 'demand_sa') {
	    $spectra = $self->{'sa_smooth'};
	} elsif ($metric eq 'demand_sd') {
	    $spectra = $self->{'sd_smooth'};
	} else {
	    return 0;
	}
	$damping = $self->{'dsf'};
	
	for ($ind=0; $ind < scalar @$spectra; $ind++) {
		$demand[$ind] = $spectra->[$ind] * $damping->[$ind];
	}
	
	$self->{$metric} = \@demand;
	
	return \@demand;
}

# Compute damped scaling factor
sub compute_Be {
    my ($self) = @_;
	
    undef $SC::errstr;

    my $capacity = $self->{'capacity'};
	my @periods = @{$capacity->{'periods'}};
	my @sa = @{$capacity->{'sa'}};
	my @sd = @{$capacity->{'sd'}};
	#print Dumper($mbt);
	my $kappa = $self->{'kappa'};
	my $Dy = $self->{'Dy'};
	my $Ay = $self->{'Ay'};
	my $pi = 3.14159;
	my ($ind, @Be, @Bh);
	$Bh[0] = 0;
	$Be[0] = $self->{'Be'};
	for ($ind=1; $ind < scalar @periods; $ind++) {
		my $T = $periods[$ind];
		my ($sa_1, $sd_1) = ($sa[$ind-1], $sd[$ind-1]);
		my ($sa, $sd) = ($sa[$ind], $sd[$ind]);
		if ($T <= 0) {
			$Bh[$ind] = 0;
		} else {
			#print " 100*($kappa*(2*($sa+$sa_1)*($sd-($sd_1+($Dy/$Ay)*($sa-$sa_1)))+((($Bh[$ind-1]/100)/$kappa))*2*$pi*$sd_1*$sa_1)/(2*$pi*$sd*$sa))\n";
			$Bh[$ind] = 100*($kappa*(2*($sa+$sa_1)*($sd-($sd_1+($Dy/$Ay)*($sa-$sa_1)))+((($Bh[$ind-1]/100)/$kappa))*2*$pi*$sd_1*$sa_1)/(2*$pi*$sd*$sa));
		}
		
		if ($Bh[$ind] > $Be[0]) {
			$Be[$ind] = $Bh[$ind];
		} else {
			$Be[$ind] = $Be[0];
		}
	}
	#print Dumper(@Be);
    $self->{'Be'} = \@Be;
	#my $dsf = dsf($fac_id, \@Be);

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
	return 1;
}

# send product to a remote server
sub compute_dsf {
    my ($self, $sm_input) = @_;
	
	my $M = $sm_input->{'magnitude'};
	my $R = $sm_input->{'dist'};
    my $Be = $self->{'Be'};
	
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
	
    $self->{'dsf'} = \@dsf_est;

	return \@dsf_est;
}

# Compute response (and smoothed) spectrum based on ShakeMap parametric data
sub response_spectra {
    my ($self, $sm_input) = @_;
	
	#my $sm_input = {
    #   'magnitude' => $event->{'magnitude'},
	#	'dist' => $dist,
	#	'pga' => $pga,
	#	'psa03' => $psa03,
	#	'psa10' => $psa10,
	#	'psa30' => $psa30,
	#};
    my ($magnitude, $dist, $pga, $psa03, $psa10, $psa30) =
        ($sm_input->{'magnitude'}, $sm_input->{'dist'}, , $sm_input->{'pga'},
        $sm_input->{'psa03'}, $sm_input->{'psa10'}, $sm_input->{'psa30'});
	return 0 if ($sm_input->{'psa03'} <=0 || $sm_input->{'psa10'} <=0);

    $self->{'sm_input'} = $sm_input;
	my $tolerate = 0.0001;
	my @M = (5.5, 5.75, 6, 6.25, 6.5, 6.75, 7, 7.25, 7.5, 7.75, 8, 8.01);
	my @Tl = (1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 8);

	my $ind;
	for ($ind = 0; $ind <= $#M; $ind++) {
		last if ($M[$ind] >= $sm_input->{'magnitude'});
	}
	
	my $domain_periods = {};
	if ($sm_input->{'magnitude'} > $M[$ind] || $sm_input->{'magnitude'} < $M[0]) {
		$domain_periods->{'Tl'} = $Tl[$ind];
	} else {
		$domain_periods->{'Tl'} = $Tl[$ind-1];
	}
	
	$domain_periods->{'Ts'} = (_max($psa10, 3*$psa30)/$psa03 > 0) ? _max($psa10, 3*$psa30)/$psa03 : $tolerate;
	
	$domain_periods->{'T0'} = $domain_periods->{'Ts'}/5;
	$self->{'domain_periods'} = $domain_periods;

    my @periods = @{$CONSTANTS{'PERIODS'}};
	my @smooth_factor;
	for ($ind = 0; $ind <= $#periods; $ind++) {
		$smooth_factor[$ind] = 1-0.1*(($domain_periods->{'Ts'}-0.1)/$domain_periods->{'Ts'})
			* _min($periods[$ind] / $domain_periods->{'Ts'}, $domain_periods->{'Ts'} / $periods[$ind])**4;
	}
	$self->{'smooth_factor'} = \@smooth_factor;

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

	$self->{'sa_smooth'} = $sa_smooth;
	$self->{'sd_smooth'} = $sd_smooth;
	return $domain_periods, $sa_smooth, $sd_smooth, \@smooth_factor;
}

sub compute_kappa {
    my ($self, $sm_input) = @_;
    
    undef $SC::errstr;

	my @kappa_table = (0.6, 0.6, 0.5, 0.5, 0.4, 0.3, 0.3, 0.2, 0.2);

	my @kappa_index_factor = ([0,1,1,2],[4,1,1,2],[5,1,2,3],[7,2,3,4],[10,3,4,5],[13,4,5,6],[16,5,6,7],[20,6,7,8],[35,7,8,9],[50,8,9,9],[1000,8,9,9]);

	my ($M_ind, $R_ind, $kappa);
	if ($sm_input->{'magnitude'} <= 6.5) {
		$M_ind = 1;
	} elsif ($sm_input->{'magnitude'} > 7) {
		$M_ind = 3;
	} else {
		$M_ind = 2;
	}

	for ($R_ind = 1; $R_ind < scalar (@kappa_index_factor); $R_ind++) {
		last if ($sm_input->{'dist'} <= $kappa_index_factor[$R_ind]->[0]);
	}
	$R_ind = $R_ind - 1;
    
	$kappa = $kappa_table[$kappa_index_factor[$R_ind]->[$M_ind]-1];
    $self->{'kappa'} = $kappa;

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
	return $kappa;
}

sub capacity_curve {
    my ($self) = @_;
    
    undef $SC::errstr;

	my ($M_ind, $R_ind);
    my @periods = @{$CONSTANTS{'PERIODS'}};
	my @output_periods;
	for (my $ind=0; $ind< $#periods; $ind++) {
		if ($self->{'Te'} < $periods[$ind+1]) {
			if ($self->{'Te'} > $periods[$ind]) {
				$output_periods[$ind] = $self->{'Te'};
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
	my $tu = 0.32*sqrt($self->{'Du'}/$self->{'Au'});
	for (my $ind=0; $ind <= $#output_periods; $ind++) {
		my ($sa, $sd);
		if ($output_periods[$ind] >= $tu) {
			$sa = $self->{'Au'};
		} elsif ($output_periods[$ind] > $self->{'Te'}) {
			$sa = $self->{'Ay'} + ($self->{'Au'} - $self->{'Ay'}) *
			  sqrt((($output_periods[$ind] - $self->{'Te'}) / $tu));
		} elsif ($output_periods[$ind] <= 0) {
			$sa = 0;
		} else {
			$sa = $self->{'Ay'};
		}
		
		$sd = 9.8 * $sa * $output_periods[$ind]**2;
		push @sa, $sa;
		push @sd, $sd;
	}

	$capacity->{'periods'} = \@output_periods;
	$capacity->{'sd'} = \@sd;
	$capacity->{'sa'} = \@sa;
	$self->{'capacity'} = $capacity;

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
	return $capacity;
}

sub set_mbt_v2 {
    my ($self, $mbt_v2) = @_;
    
    undef $SC::errstr;
    $mbt_v2 = uc($mbt_v2);
    my %mbt;
    if ($CONSTANTS{MBT_V2}->{$mbt_v2}) {
        $self->{'MBT_v2'} = $mbt_v2;
        my $code_era = substr($mbt_v2, -1);
        $self->{'code_era'} = $code_era;
        my $mbt_height = substr($mbt_v2, 0, length($mbt_v2)-1);
        $self->{'MBT_height'} = $CONSTANTS{MBT_HEIGHT}->{$mbt_height};
        my $hazus_mbt = ($mbt_height =~ /W1|W2|S3|PC1|MH/i) ? $mbt_height : substr($mbt_v2, 0, length($mbt_v2)-2);
        $self->{'MBT'} = $hazus_mbt;
        $self->{'Te_param'} = $CONSTANTS{Te}->{$hazus_mbt};
        $self->{'Te'} = $self->compute_Te($CONSTANTS{Te}->{$hazus_mbt});
        $self->{'Cs'} = $self->compute_Cs();
        $self->{'alpha1'} = $self->lookup_alpha1();
        $self->{'alpha2'} = $self->lookup_alpha2();
        $self->{'alpha3'} = $self->lookup_alpha3();
        $self->{'gamma'} = $self->lookup_gamma();
        $self->{'lamda'} = $self->lookup_lamda();
        $self->{'mu'} = $self->lookup_mu();
        $self->{'Be'} = $self->lookup_Be();
        $self->compute_capacity_param();
        $self->compute_str_delta();
        $self->{'Bc'} = 0.4;
        $self->{'Bd'} = 0.4;
        $self->{'betaTds'} = 0.6;
        $self->{'betaTS'} = 0.6;
        $self->{'betaTM'} = 0.6;
        $self->{'betaTE'} = 0.6;
        $self->{'betaTC'} = 0.6;
    }
    
    my $mbt = {
	'MBT'	=> $self->{'MBT'},
	'SDL'	=> $self->{'code_era'},
	'Height'	=> $self->{'MBT_height'}->{'Height'},
	'Te'	=> $self->{'Te'},
	'Cs'	=> $self->{'Cs'},
	'alpha1'	=> $self->{'alpha1'},
	'alpha2'	=> $self->{'alpha2'},
	'alpha3'	=> $self->{'alpha3'},
	'gamma'	=> $self->{'gamma'},
	'lamda'	=> $self->{'lamda'},
	'mu'	=> $self->{'mu'},
	'Be'	=> $self->{'Be'},
	'Bc'	=> $self->{'Bc'},
	'Bd'	=> $self->{'Bd'},
    	'Ay'	=> $self->{'Ay'},
    	'Dy'	=> $self->{'Dy'},
    	'Au'	=> $self->{'Au'},
    	'Du'	=> $self->{'Du'},

    };
    
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $mbt;
}

sub compute_str_delta {
    my ($self) = @_;
    
    undef $SC::errstr;

    my $mbt = $self->{'MBT'};
    my $code_era = $self->{'code_era'};

    return 0 unless ($CONSTANTS{'STR_DELTA'}->{$mbt}->{$code_era});

    $self->{'str_delta'} = $CONSTANTS{'STR_DELTA'}->{$mbt}->{$code_era};

    $self->{'STR_SS'} = 12 * $self->{'MBT_height'}->{'Height'} * $self->{'str_delta'}->{'deltaS'}  * 
        ($self->{'alpha2'} / $self->{'alpha3'});
    $self->{'STR_SM'} = 12 * $self->{'MBT_height'}->{'Height'} * $self->{'str_delta'}->{'deltaM'}  * 
        ($self->{'alpha2'} / $self->{'alpha3'});
    $self->{'STR_SE'} = 12 * $self->{'MBT_height'}->{'Height'} * $self->{'str_delta'}->{'deltaE'}  * 
        ($self->{'alpha2'} / $self->{'alpha3'});
    $self->{'STR_SC'} = 12 * $self->{'MBT_height'}->{'Height'} * $self->{'str_delta'}->{'deltaC'}  * 
        ($self->{'alpha2'} / $self->{'alpha3'});

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return 1;
}

sub compute_capacity_param {
    my ($self) = @_;
    
    undef $SC::errstr;

    $self->{'Ay'} = $self->{'Cs'} * $self->{'gamma'} / $self->{'alpha1'};
    $self->{'Dy'} = 386.4/(4 * 3.14159**2) * $self->{'Ay'} * $self->{'Te'} ** 2;
    $self->{'Au'} = $self->{'Ay'} * $self->{'lamda'};
    $self->{'Du'} = $self->{'Dy'} * $self->{'lamda'} * $self->{'mu'};

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return 1;
}

sub lookup_Be {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %Be_table = (
        'baseline' => {'C1' => 7, 'C2' => 7, 'C3' => 7, 'MH' => 5, 'PC1' => 7, 'PC2' => 7, 'RM1' => 7,
            'RM2' => 7, 'S1' => 5, 'S2' => 5, 'S3' => 5, 'S4' => 5, 'S5' => 5, 'URM' => 7, 'W1' => 10,
            'W1A' => 10, 'W2' => 10},
    );

    my $Be = 10;
    my $mbt = $self->{'MBT'};
    $Be = $Be_table{'baseline'}->{$mbt} if (defined $Be_table{'baseline'}->{$mbt});

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $Be;
}

sub lookup_mu {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %mu_table = (
        'baseline' => {1 => 6.00, 2 => 6.00, 3 => 4.94, 4 => 4.41, 5 => 4.07, 6 => 3.82, 7 => 3.63,
            8 => 3.48, 9 => 3.35, 10 => 3.24, 11 => 3.15, 12 => 3.07, 13 => 3.00, 14 => 3.00, 15 => 3.00},
    );

    my $mu = 3.00;
    my $floors = $self->{'MBT_height'}->{'Typical'};
    $mu = $mu_table{'baseline'}->{$floors} if (defined $mu_table{'baseline'}->{$floors});

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $mu;
}

sub lookup_lamda {
    my ($self) = @_;
    
    undef $SC::errstr;

    my $lamda = 1.67;
    my $mbt = $self->{'MBT'};
    if ($mbt =~ /PC1|URM/) {
        $lamda = 1.33;
    } elsif ($mbt =~ /W1|S1|C1/) {
        $lamda = 2.00;
    } elsif ($mbt =~ /W2|C2/) {
        $lamda = 2.00;
    } elsif ($mbt =~ /S4|C3/) {
        $lamda = 1.83;
    }
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $lamda;
}

sub lookup_gamma {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %gamma_table = (
        'baseline' => {1 => 2.70, 2 => 2.50, 3 => 2.25, 4 => 2.00, 5 => 1.88, 6 => 1.80, 7 => 1.75,
            8 => 1.71, 9 => 1.69, 10 => 1.67, 11 => 1.65, 12 => 1.65, 13 => 1.65, 14 => 1.65, 15 => 1.65},
    );

    my $gamma = 1.65;
    my $floors = $self->{'MBT_height'}->{'Typical'};
    $gamma = $gamma_table{'baseline'}->{$floors} if (defined $gamma_table{'baseline'}->{$floors});

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $gamma;
}

sub lookup_alpha3 {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %alpha3_table = (
        'baseline' => {1 => 1.00, 2 => 1.21, 3 => 1.35, 4 => 1.45, 5 => 1.54, 6 => 1.62, 7 => 1.69,
            8 => 1.75, 9 => 1.81, 10 => 1.86, 11 => 1.91, 12 => 1.96, 13 => 2.00, 14 => 2.04, 15 => 2.08},
        'all_sins' => {1 => 0.75, 2 => 2.03, 3 => 2.50, 4 => 2.50, 5 => 2.50, 6 => 2.50, 7 => 2.50,
            8 => 2.50, 9 => 2.50, 10 => 2.50, 11 => 2.50, 12 => 2.50, 13 => 2.50, 14 => 2.50, 15 => 2.50},
    );

    my $alpha3 = 2.08;
    my $floors = $self->{'MBT_height'}->{'Typical'};
    $alpha3 = $alpha3_table{'baseline'}->{$floors} if (defined $alpha3_table{'baseline'}->{$floors});

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $alpha3;
}

sub lookup_alpha2 {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %alpha2_table = (
        'all' => {1 => 0.75, 2 => 0.75, 3 => 0.75, 4 => 0.75, 5 => 0.75, 6 => 0.72, 7 => 0.69,
            8 => 0.66, 9 => 0.63, 10 => 0.60, 11 => 0.60, 12 => 0.60, 13 => 0.60, 14 => 0.60, 15 => 0.60},
    );

    my $alpha2 = 0.60;
    my $floors = $self->{'MBT_height'}->{'Typical'};
    if ($self->{'MBT'} eq 'MH') {
        $alpha2 = 1;
    } else {
        $alpha2 = $alpha2_table{'all'}->{$floors} if (defined $alpha2_table{'all'}->{$floors});
    }

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $alpha2;
}

sub lookup_alpha1 {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %alpha1_table = (
        'S1_C1' => {1 => 0.75, 2 => 0.75, 3 => 0.75, 4 => 0.75, 5 => 0.75, 6 => 0.73, 7 => 0.71,
            8 => 0.69, 9 => 0.67, 10 => 0.65, 11 => 0.65, 12 => 0.65, 13 => 0.65, 14 => 0.65, 15 => 0.65},
        'other' => {1 => 0.80, 2 => 0.80, 3 => 0.80, 4 => 0.80, 5 => 0.80, 6 => 0.79, 7 => 0.78,
            8 => 0.77, 9 => 0.76, 10 => 0.75, 11 => 0.75, 12 => 0.75, 13 => 0.75, 14 => 0.75, 15 => 0.75},
    );

    my $alpha1 = 0.75;
    my $floors = $self->{'MBT_height'}->{'Typical'};
    if ($self->{'MBT'} eq 'MH') {
        $alpha1 = 1;
    } elsif ($self->{'MBT'} =~ /PC1|URM/) {
        return $alpha1;
    } elsif ($self->{'MBT'} =~ /S1|C1/) {
        $alpha1 = $alpha1_table{'S1_C1'}->{$floors} if (defined $alpha1_table{'S1_C1'}->{$floors});
    } else {
        $alpha1 = $alpha1_table{'other'}->{$floors} if (defined $alpha1_table{'other'}->{$floors});
    }

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $alpha1;
}

sub compute_Cs {
    my ($self) = @_;
    
    undef $SC::errstr;

    my %sdl_scale = ("VH" => 1.4, "H" => 1.4, "M" => 1.5, "L" => 1.6, "P" => 1.7);
    my $T = $self->{'Te'} / $sdl_scale{$self->{'code_era'}};
    $self->{'T'} = $T;

    my $Cs = 8 / 5.5 * 0.4;
    $Cs *= ((1.25*1.5)/($T**(2/3))>2.75) ? 2.75 : (1.25*1.5)/($T**(2/3));

    if ($self->{'MBT'} =~ /S1|C1/i) {
        $Cs = $Cs / 12;
    } elsif ($self->{'MBT'} =~ /S4/i) {
        $Cs = $Cs / 10;
    } elsif ($self->{'MBT'} =~ /RM1|RM2|URM/i) {
        $Cs = $Cs / 6;
    } else {
        $Cs = $Cs / 8;        
    }

    if ($self->{'MBT'} =~ /MH/i) {
        $Cs = $Cs * 1 / 1.375;
    } elsif ($self->{'code_era'} eq 'VH') {
        $Cs = $Cs * 1.5;
    } elsif ($self->{'code_era'} eq 'H') {
        $Cs = $Cs * 1.0;
    } elsif ($self->{'code_era'} eq 'M') {
        $Cs = $Cs * 0.5;
    } else {
        $Cs = $Cs * 0.25;
    }

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $Cs;
}

sub compute_Te {
    my ($class, $Te_param) = @_;
    
    undef $SC::errstr;

    my ($a1, $a2, $x) = ($Te_param->{'Cu_'.$class->{'code_era'}}, $Te_param->{'Cr'}, $Te_param->{'x'});
    my $Te = $a1 * $a2 * $class->{'MBT_height'}->{'Height'} ** $x;

    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return $Te;
}

sub _sum {
    #my $class = shift;
	my $sum=0;
	for (my $ind=0; $ind <= $#_; $ind++) {$sum+=$_[$ind];}
	return $sum;
}

sub _min {
    #my $class = shift;
    (defined $_[0] && (!defined $_[1] || $_[0] <= $_[1])) ? $_[0] : $_[1];
}

sub _max {
    #my $class = shift;
    (defined $_[0] && (!defined $_[1] || $_[0] >= $_[1])) ? $_[0] : $_[1];
}

sub new {
    my $class = shift;
    my $self = bless {} => $class;
    $self->receive_timestamp(SC->time_to_ts);
    Carp::carp "Odd (wrong?) number of parameters in new()" if $^W && (@_ & 1); 
    while (@_) {
	my $method = shift;
	my $value = shift;
	$self->$method($value) if $self->can($method);
    }
    return $self;
}


sub newer_than {
    my ($class, $hwm, $oldest) = @_;
    
    undef $SC::errstr;
    my @newer;
    my @args = ($hwm);
    my $sql =  qq/
        select event_id,
               event_version
          from event
         where seq > ?
           and event_type <> 'TEST'/;
    if ($oldest) {
	$sql .= qq/ and receive_timestamp > $SC::to_date/;
	push @args, $oldest;
    }
    eval {
	my $sth = SC->dbh->prepare($sql);
	$sth->execute(@args);
	while (my $p = $sth->fetchrow_arrayref) {
	    push @newer, $class->from_id(@$p);
	}
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    }
    return \@newer;
}

sub from_id {
    my ($class, $event_id, $event_version) = @_;

    undef $SC::errstr;
    my $event;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
	    select *
	      from event
	     where event_id = ?
	       and event_version = ?/);
	$sth->execute($event_id, $event_version);
	my $p = $sth->fetchrow_hashref('NAME_lc');
	$event = new SC::Event(%$p);
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    } elsif (not defined $event) {
	$SC::errstr = "No event for id-ver $event_id-$event_version";
    }
    return $event;
}

# Given an event ID, return the matching event that is not marked as
# being superceded.
sub current_version {
    my ($class, $event_id) = @_;

    undef $SC::errstr;
    my $event;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
	    select *
	      from event
	     where event_id = ?
	       and (superceded_timestamp IS NULL)/);
	$sth->execute($event_id);
	my $p = $sth->fetchrow_hashref('NAME_lc');
	$event = new SC::Event(%$p);
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    } elsif (not defined $event) {
	$SC::errstr = "No current event for id $event_id";
    }
    return $event;
}

# Given an event ID, return the matching event that is not marked as
# being superceded.
sub current_event {
    my ($class) = @_;

    undef $SC::errstr;
    my $event;
    my $sth;
    eval {
	$sth = SC->dbh->prepare(qq/
		SELECT *
		FROM 
			(grid g INNER JOIN event e on
			g.shakemap_id = e.event_id)
		GROUP BY
			e.event_id
		ORDER BY
			g.grid_id DESC, e.seq DESC
		/);
	$sth->execute();
	my $p = $sth->fetchrow_hashref('NAME_lc');
	$event = new SC::Event(%$p);
	$sth->finish;
    };
    if ($@) {
	$SC::errstr = $@;
	return undef;
    } elsif (not defined $event) {
	$SC::errstr = "No current event";
    }
    return $event;
}

# Delete all events, shakemaps, grids, and products related to a given
# event ID.  Product files and product directories will be deleted, too.
# This method will log an error and do nothing for events
# that have an event_type other than C<TEST>.
# 
# Return true/false for success/failure
sub erase_test_event {
    my ($class, $event_id) = @_;

    my $sth;
    my $event;
    eval {
	my ($nrec) = SC->dbh->selectrow_array(qq/
	    select count(*)
	      from event
	     where event_id = ?
               and event_type <> 'TEST'/, undef, $event_id);
        if ($nrec) {
            $SC::errstr = "Can't erase events whose type is not TEST";
            return 0;
        }

        # Determine the set of grids to be deleted
        my ($gridp) = SC->dbh->selectcol_arrayref(qq/
            select grid_id
              from grid g
                  inner join shakemap s
                     on (g.shakemap_id = s.shakemap_id and
                         g.shakemap_version = s.shakemap_version)
             where s.event_id = ?/, undef, $event_id);

         # Delete grids and associated values
         my $sth_del_grid = SC->dbh->prepare(qq/
             delete from grid
              where grid_id = ?/);
         my $sth_del_value = SC->dbh->prepare(qq/
             delete from grid_value
              where grid_id = ?/);
         foreach my $grid_id (@$gridp) {
             $sth_del_value->execute($grid_id);
             $sth_del_grid->execute($grid_id);
         }

         # Determine the set of shakemaps to be deleted
         my ($smp) = SC->dbh->selectall_arrayref(qq/
             select shakemap_id,
                    shakemap_version
               from shakemap
              where event_id = ?/, undef, $event_id);

         # Delete products
         $sth = SC->dbh->prepare(qq/
             delete from product
              where shakemap_id = ?
                and shakemap_version = ?/);
         foreach my $k (@$smp) {
             $sth->execute(@$k);
             my $shakemap = SC::Shakemap->from_id(@$k);
             my $dir = $shakemap->product_dir;
             SC->log(0, "dir: $dir");
             if (-d $dir) {
                 opendir DIR, $dir;
                 my $file;
                 while (my $file = readdir DIR) {
                     SC->log(0, "file: $file");
                     next unless -f "$dir/$file";
                     unlink "$dir/$file"
                         or SC->log(0, "unlink $dir/$file failed: $!");
                 }
                 closedir DIR;
                 rmdir $dir
                     or SC->log(0, "rmdir $dir failed: $!");
             }
         }

         # Delete associated shakemap metrics
         $sth = SC->dbh->prepare(qq/
             delete from shakemap_metric
              where shakemap_id = ?
                and shakemap_version = ?/);
         foreach my $k (@$smp) {
             $sth->execute(@$k);
         }

         # Delete shakemaps
         SC->dbh->do(qq/
             delete from shakemap
              where event_id = ?/, undef, $event_id);

         # Delete events
         SC->dbh->do(qq/
             delete from event
              where event_id = ?/, undef, $event_id);
    };
    if ($@) {
	$SC::errstr = $@;
	return 0;
    }
    return 1;
}


sub from_xml {
    my ($class, $xml_source) = @_;
    undef $SC::errstr;
    my $xml = SC->xml_in($xml_source);
    return undef unless defined $xml;
    unless (exists $xml->{'event'}) {
	$SC::errstr = 'XML error: event element not found';
	return undef;
    }
    return $class->new(%{ $xml->{'event'} });
}



# ======================================================================
# Instance methods

sub to_xml {
    my $self = shift;
    return SC->to_xml_attrs(
	$self,
	'event',
	[qw(
	    event_id event_version external_event_id
	    event_status event_type
	    event_name event_location_description
	    magnitude lat lon depth  event_region event_source_type
	    event_timestamp mag_type
	    )],
	1);
}

sub as_string {
    my $self = shift;
    return 'event '.  $self->{event_id} . '-' . $self->{event_version};
}

sub write_to_db {
    my $self = shift;
    my $rc = 1;

    undef $SC::errstr;
    eval {
        # see if this is a heartbeat event
        # if so, first delete all events with the same ID.  Leave other
        # heartbeat events alone.  This allows heartbeats from more than
        # one source to propagate without interfering with each other.
        if ($self->event_type eq 'HEARTBEAT') {
            SC->dbh->do(qq/
                delete from event
                 where event_type = 'HEARTBEAT'
                   and event_id = ?/, undef, $self->event_id);
        } elsif ($self->event_status eq 'CANCELLED') {
			SC->dbh->do(qq/
				update event
				   set event_status="CANCELLED"
				 where event_id = ?/, undef, $self->event_id);
			SC->dbh->commit;
			$rc = 1;
			return; # returns from the eval, not the sub!
        } else {
            # check for existing record
            #my $sth_getkey = SC->dbh->prepare_cached(qq/
            #    select event_id
            #      from event
            #     where event_id=?
            #       and event_version=?/);
            #if (SC->dbh->selectrow_array($sth_getkey, undef,
            #        $self->{'event_id'},
            #        $self->{'event_version'})) {
            #    $rc = 2;
            #    return; # returns from the eval, not the sub!
            #}
            # check for existing record
            #my $sth_getkey = SC->dbh->prepare_cached(qq/
            #    select event_id
            #      from event
            #     where event_id=?
			#	   and abs(lat - ?) < 0.01
            #       and abs(lon - ?) < 0.01 
            #       and abs(magnitude - ?) < 0.01 
            #       and abs(depth - ?) < 0.01 
			#	   and event_status <> "cancelled" /);
            #if (SC->dbh->selectrow_array($sth_getkey, undef,
            #        $self->{'event_id'},
            #        $self->{'lat'},
            #        $self->{'lon'},
            #        $self->{'magnitude'},
            #        $self->{'depth'}
			#		)) {
            #    $rc = 2;
            #    return; # returns from the eval, not the sub!
            #}
            # check for possible redundant record with different ID
            #my $sth_getkey = SC->dbh->prepare(qq/
            #    select event_id
            #      from event
            #     where event_id != ?
			#	   and event_type not in ('SCENARIO', 'TEST')
			#	   and abs(lat - ?) < 0.1
            #       and abs(lon - ?) < 0.1 
			#	   and abs( timestampdiff(SECOND , EVENT_TIMESTAMP, ? )) < 10 /);
            #if (my $red_evt = SC->dbh->selectrow_array($sth_getkey, undef,
            #        $self->{'event_id'},
            #        $self->{'lat'},
            #        $self->{'lon'},
            #        $self->{'event_timestamp'})) {
			#	$sth_getkey = SC->dbh->prepare(qq/
			#		select event_id
			#		  from event
			#		 where event_id = ?
			#		   and event_status = "cancelled" /);
			#	if (!SC->dbh->selectrow_array($sth_getkey, undef, $red_evt)) {
			#		$rc = 3;
			#		return $rc if (SC->config->{'REDUNDANT_CHECK'}); # returns from the eval, not the sub!
			#		SC->log(3, $self->as_string, "may already exists with different ids");
			#	}
        #   }
        }

	# Determine whether this is the first version of this event we
	# have received or not, $rc=3 if REDUNDANT_CHECK flag is set
	my $num_recs = SC->dbh->selectrow_array(qq/
	    select count(*)
	      from event
	     where event_id = ?/, undef, $self->event_id);
	#my $num_recs = ($rc == 3) ? 1 :
	#	SC->dbh->selectrow_array(qq/
	#    select count(*)
	#      from event
	#     where event_id = ?/, undef, $self->event_id);
	#if ($num_recs) {
	#	SC->dbh->do(qq/
	#		delete from event
	#		 where event_id = ?/, undef,
	#		$self->event_id);
	#}
	if ($num_recs) {
	SC->dbh->do(qq/
	    update event set
		event_id = ?, 
		event_version = ?,  
		event_status = ?, 
		event_type = ?,
		event_name = ?, 
		event_location_description = ?, 
		event_timestamp = $SC::to_date,
		external_event_id = ?, 
		receive_timestamp = $SC::to_date,
		magnitude = ?, 
		mag_type = ?, 
		lat = ?, 
		lon = ?, 
		depth = ?, 
		event_region = ?, 
		event_source_type = ?, 
		initial_version = ?
		where event_id = ?/,
            undef,
	    $self->event_id,
	    $self->event_version,
	    $self->event_status,
	    $self->event_type,
	    $self->event_name,
	    $self->event_location_description,
	    $self->event_timestamp,
	    $self->external_event_id,
	    $self->receive_timestamp,
	    $self->magnitude,
	    $self->mag_type,
	    $self->lat,
	    $self->lon,
	    $self->depth,
	    $self->event_region,
	    $self->event_source_type,
	    1,
	    $self->event_id);
	} else {
	SC->dbh->do(qq/
	    insert into event (
		event_id, event_version,  event_status, event_type,
		event_name, event_location_description, event_timestamp,
		external_event_id, receive_timestamp,
		magnitude, mag_type, lat, lon, depth, event_region, event_source_type, initial_version)
	      values (?,?,?,?,?,?,$SC::to_date,?,$SC::to_date,?,?,?,?,?,?,?,?)/,
            undef,
	    $self->event_id,
	    $self->event_version,
	    $self->event_status,
	    $self->event_type,
	    $self->event_name,
	    $self->event_location_description,
	    $self->event_timestamp,
	    $self->external_event_id,
	    $self->receive_timestamp,
	    $self->magnitude,
	    $self->mag_type,
	    $self->lat,
	    $self->lon,
	    $self->depth,
	    $self->event_region,
	    $self->event_source_type,
	    1);
	}
	# Supercede all other versions of this event.
	SC->dbh->do(qq/
	    update event
	       set superceded_timestamp = $SC::to_date
	     where event_id = ?
	       and event_version <> ?
	       and superceded_timestamp IS NULL/, undef,
	    SC->time_to_ts(),
	    $self->event_id, $self->event_version);
        # Update HWM
        my ($hwm) = SC->dbh->selectrow_array(qq/
            select seq
              from event
	     where event_id = ?
	       and event_version = ?/, undef,
	    $self->event_id, $self->event_version);
        SC::Server->this_server->update_event_hwm($hwm);
    };
    if ($@) {
        $SC::errstr = $@;
        $rc = 0;
	eval {
	    SC->dbh->rollback;
	};
	# Throw away any error message resulting from the rollback since
	# it would mask the original error (and mysql always complains
	# about not being able to roll back).
    } else {
	SC->dbh->commit;
    }
    return $rc;
}

sub is_local_test {
    my $self = shift;
    return ($self->event_type eq 'TEST');
}

sub process_new_event {
    my $self = shift;

	my $mag_cutoff = (defined SC->config->{'MAG_CUTOFF'}) ? SC->config->{'MAG_CUTOFF'} : 3.0;
	return 0 unless ( $self->magnitude >= $mag_cutoff || $self->event_status eq 'CANCELLED');
    # Add it to the database.
    my $write_status = $self->write_to_db;

    if ($write_status == 0) {
        # write failed, it should have been logged
	return 0;
    } elsif ($write_status == 3) {
	# possible event already exists with different id, do nothing
        SC->log(3, $self->as_string, "may already exists with different ids");
	return 1;
    } elsif ($write_status == 2) {
	# event already exists, do nothing
        SC->log(3, $self->as_string, "already exists");
	return 1;
    } elsif ($write_status == 1) {
		if ($self->event_status ne 'CANCELLED') {
			eval {
				# If the dispatcher is not running this will fail.  However,
				# from the upstream server's perspective this is not an error,
				# so catch any problems, log them, and return success.
				SC::Server->this_server->queue_request(
					'notifyqueue', $self->event_id, $self->event_version);
				SC::Server->this_server->queue_request(
					'comp_gmpe', $self->event_id, $self->event_version)
				if (SC->config->{'COMP_GMPE'});
			};
			if ($@) {
				chomp $@;
				SC->error("$@ [Maybe the dispatcher service is not running?]");
				return 1;
			}
			#if ($self->process_facility_model) {
			#	SC->log(2, "facility model processed");
			#} else {
			#	SC->error($SC::errstr);
				# XXX might not be correct.  Even though we got an error while
				# processing the grid we might want to push the file downstream.
				# Probably we should NOT inform the notifier, though, since the
				# grid hasn't been loaded into the database.
			#	return 0;
			#}
		}
	# A new event record (might be a new version of an existing event)
        return 1 if ($self->is_local_test);
        
	# Forward it to all downstream servers
	# this step only queues exchange requests; the exchanges are
	# completed asynchronously, so it is not known at this time whether
	# or not they succeeded
	eval {
	    # If the dispatcher is not running this will fail.  However,
	    # from the upstream server's perspective this is not an error,
	    # so catch any problems, log them, and return success.
	    foreach my $ds (SC::Server->downstream_servers) {
		$ds->queue_request(
		    'new_event', $self->event_id, $self->event_version);
	    }
	};
	if ($@) {
	    chomp $@;
	    SC->error("$@ [Maybe the dispatcher service is not running?]");
	    return 1;
	}
    } else {
	SC->error("unknown status $write_status from event->write_to_db");
	return 0;
    }
    return 1; 
}

1;


__END__

=head1 NAME

SC::Event - ShakeCast library

=head1 DESCRIPTION

=head2 Class Methods

=head2 Instance Methods

=over 4

=item SC::Event->from_xml('d:/work/sc/work/event.xml');

Creates a new C<SC::Event> from XML, which may be passed directly or can be
read from a file.    

=item new SC::Event(event_type => 'EARTHQUAKE', event_name => 'Northridge');

Creates a new C<SC::Event> with the given attributes.

=item $event->write_to_db

Writes the event to the database.  The event may already exist; in this case
the event is silently ignored.  The return value indicates

  0 for errors (C<$SC::errstr> will be set),
  1 for successful insert, or
  2 if the record already existed.

=cut

