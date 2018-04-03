#!/usr/local/sc/sc.bin/perl
#!c:/perl/bin/perl

# $Id: system_check.pl 408 2008-03-24 21:54:13Z klin $

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
# klin@usgs.gov.  
#
#############################################################################

$| = 1;

my @packages = (
	'App::cpanminus','Archive::Zip','Authen::SASL',
	'CGI','CGI::Session','Config::General',
	'DBI','DBD::mysql', 
	'GD','GD::Graph','GD::Graph3d','GD::Text',
	'enum',  
	'HTML::TableExtract','HTML::Template',
	'Image::Size', 
	'JSON',
	'LWP::Protocol::https',
	'Math::CDF','MIME::Lite', 
	'Net::SSLeay','Net::SMTP::SSL','Net::SMTPS',
	'PDF::API2','PDF::Table','OMEGA/PDF-Table-0.9.10.tar.gz',
	'Template', 'Text::CSV_XS', 
	'XML::LibXML','XML::LibXML::Simple','XML::Parser','XML::Simple',
		'XML::Twig','XML::Writer',
);
				
print "Checking installed Perl modules \n";
$install_count = 0;
$pack_count = scalar @packages;
while (my $module = shift @packages) {
	$ppm = shift @packages;
	print "Module $module -> ";
	if (eval "use $module; 1" ) {
		print "OK\n";
		$install_count++;
	} else {
		print "Not found.\n";
		if (install_module($module, $ppm)) {
			print "Module $module successfully installed\n";
			$install_count++;
		} else {
			print "Failed to install module $module\n";
		}
	}
}

if ($install_count < $pack_count) {
	print "Perl module check failed. \n\n";
} else {
	print "Looks good. \n\n";
}

require ExtUtils::MakeMaker;
my $yn = ExtUtils::MakeMaker::prompt
	("Press any key to continue.", '');

exit 0;


sub install_module {

	my ($module, $ppd) = @_;
	my $installed = 0;
	
	require ExtUtils::MakeMaker;
	my $yn;
	
	if ($install) {
		$yn = 'y';
	} else {
		$yn = ExtUtils::MakeMaker::prompt
			("  Install $module now?", 'y');
	}
  
	unless ($yn =~ /^y/i) {
		print " *** ShakeCast will not function properly without $module...\n";
		return $installed;
	}

	my @repos;
	if (ref($ppd) eq "ARRAY") {
		push @repos, @$ppd;
	} else {
		push @repos, $ppd;
	}
	
	foreach my $repo (@repos) {
		require Cwd;
		require File::Spec;
		require CPAN;

		# Save this 'cause CPAN will chdir all over the place.
		my $cwd = Cwd::cwd();

		CPAN::Shell->install('$module');
		CPAN::Shell->expand("Module", "$module")->uptodate
			or return $installed;

		chdir $cwd or return $installed;
		return 1 if (eval "use $module; 1");
	}
	
	return $installed;

}

