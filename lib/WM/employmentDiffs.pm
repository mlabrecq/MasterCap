package WM::employmentDiffs;

use strict;
use warnings;
use WM::data_carrier;

use parent qw(WM::data_carrier);



sub new {
    my ($class, @arguments) = @_;

    my $this = $class->SUPER::new(@arguments);
    
    bless($this,$class);

    return $this;


}

sub createReport {
    my ($this) = @_;

    my ($FILE, $OUT) = $this->getFileHandlesForTransform();

    my $sql = <$FILE>;
    my $title = <$FILE>;

    #this is perhaps too much info... i know the data starts here.
    my $stateM = '02';
    my $yearM = '2000';

    my %stateNaics;
    my %countyNaics;
    
    print $OUT "state, year, naics, state, county, %different\n";
    
    while(<$FILE>) {
	my @parts = split(',', $_);

	my $location = $parts[0];
	my $industry = $parts[1];
	my $year     = $parts[2];
	my $emp      = $parts[3];
	
	if ($yearM !~ /^$year$/) {
	    #clean out the memory, and print the info.
	    
	    for my $naics( sort(keys(%stateNaics))) {
		my $state = $stateNaics{$naics};
		my $county = 0;
		if (defined $countyNaics{$industry}) {
		   $county = $countyNaics{$naics};
		}
		my $different = 0;
		if($state) {
		     $different = (($county - $state) / $state) * 100;
		}
		print $OUT "$stateM, $yearM, $naics, $state, $county, $different\n";


	    }
	    %stateNaics = ();
	    %countyNaics = ();
	    $yearM = $year;
	    $stateM = $location;

	}

	if (length($location) == 2) {
	   
	    if (defined $stateNaics{$industry}) {
		
		
		die "assumption failure!!\n";
	    }
	    $stateNaics{$industry} = $emp;
	    next;
	}
	
	if (!defined $countyNaics{$industry}) {
	    $countyNaics{$industry} = 0;
	}
	$countyNaics{$industry} += $emp;

    }


}


1;
