package WM::yearlyAverage;

use strict;
use warnings;

use parent qw(WM::data_carrier);

sub new {
    my ($class, @arguments) = @_;

    my $this = $class->SUPER::new(@arguments);
    
    bless($this,$class);

    return $this;


}

sub getAvg {
    my ($this) = @_;

    my @targetFiles = $this->getDependantDataSources();

    #its only one file.
    
    my $target = $targetFiles[0];
    my $averageFile = join('/', ($this->{data}->getSiteRoot(), $this->{data}->{data}, $this->{data}->{artifactName}));

    $target =~ s/.gz$//;

    $averageFile =~ s/.gz$//;

    open(my $FILE, '<', $target) or die;



    open(my $OUT, '>', $averageFile) or die;

    my %average;

    my $title = <$FILE>;

    
    my @parts = $this->getInterestingParts($title);
    chomp(@parts);


    splice(@parts, 3, 1);


    my $top = join(',', @parts);

    #this is hard coded because I have not yet written a better way to do it.
    #I could probably write a utitlity class that knows all of the answers

    #an sqlification as it were.

    #I think this will be warrented later, but right now, to get the stuff
    #into the database today, 
    print $OUT "CHAR(8), CHAR(4), SMALLINT(4), DOUBLE(14, 2), SMALLINT(1),FLOAT(4, 2), SMALLINT(1)\n";
    
    print $OUT "$top\n";

    my $memory = '0000';

    while(<$FILE>) {
	my @parts = split(',', $_);

	#parts 0 is always Q. lets throw it away.
	#parts 1 is always U. lets throw it away.
	#parts 2 is either S or C. ... lets throw it away.
	#parts 3 we need to keep and it is one of our keys.

	my $place = $parts[3];
	

	#parts 4 is industry level - not really useful - either A or 4. lets throw it away
	#parts 5 is the naics code. Need that!

	my $naics = $parts[5];

	#parts 6 is the owner code. That should have been dropped by reduce.
	#oops. skip it.
	
	#part 7 is the year. we need that too

	my $year = $parts[7];

	if ($year !~ /^$memory$/) {
	    %average = ();
	    print "clearing $memory from $place\n";
	    $memory = $year;
	}

	#parts 8 is the quarter, when we have 4 of these, we can do our work

	my $quarter = $parts[8];

	my $size = scalar(@parts);

	my $remaining = join(',', @parts[9..$size-1]);

	my $key = join('|', ($place, $naics, $year, $quarter));

	$average{$key} = $remaining;
	
	if ($quarter eq '4') {
	    my $q1 = join('|', ($place, $naics, $year, '1'));
	    if (defined($average{$q1})) {
		my $q2 = join('|', ($place, $naics, $year, '2'));
		if (defined($average{$q2})) {
		    my $q3 = join('|', ($place, $naics, $year, '3'));
		    if (defined($average{$q3})) {
			$this->average($OUT, \%average,$key, $q1, $q2, $q3);
		    }
		}
	    }

	}

    }


}

sub getInterestingParts {
    my ($this, $string) = @_;

    my @parts = split(',', $string);

    my @interestingArray;

    #parts 0 is always Q. lets throw it away.
    #parts 1 is always U. lets throw it away.
    #parts 2 is either S or C. ... lets throw it away.
    #parts 3 we need to keep and it is one of our keys.
    
    my $place = $parts[3];
    
    #parts 4 is industry level - not really useful - either A or 4. lets throw it away
    #parts 5 is the naics code. Need that!
    
    my $naics = $parts[5];
    
    #parts 6 is the owner code. That should have been dropped by reduce.
    #oops. skip it.
    
    #part 7 is the year. we need that too
    
    my $year = $parts[7];
    
    #parts 8 is the quarter, when we have 4 of these, we can do our work
    my $size = scalar(@parts);
    my $quarter = $parts[8];

    push(@interestingArray, $place);
    push(@interestingArray, $naics);
    push(@interestingArray, $year);
    push(@interestingArray, $quarter);
    push(@interestingArray, $parts[9]);
    push(@interestingArray, 'QuartersReported');
    push(@interestingArray, @parts[10..$size-1]);
    push(@interestingArray, 'QuartersReported');
    

    return @interestingArray;

}



sub average {
    my ($this, $FILE, $hash, @keys) = @_;

    my %average;

    for my $key(@keys) {
	my $start  = -1;
	for my $value (split(',', $hash->{$key})) {
	    $start++;
	    if (!defined $average{$start}) {
		$average{$start} = $value;
		next;
	    } 

	    $average{$start} = $average{$start} . '+' . $value;
	    
	    


	}

    }
    
    my @parts = split(/\|/, $keys[0]);
    
    pop(@parts);
    
    my $string =  join(',', @parts);;
    
    for my $key (sort(keys(%average))) {
	my $averageThis = $average{$key};
	my @values = split(/\+/, $averageThis);
	my $sum = 0;
	my $div = 0;
	my $quarters = 0;
	for my $val (@values) {
	    if ($val =~ /^$/){
		next;
	    }
	    $sum += $val;
	    $div++;
	    $quarters += 1;
	}
	my $avg = 0;
	$avg = sprintf("%.2f", $avg);
		
	$string .= ',' . $avg . ',' . $quarters;
    }

    $string =~ s/\.00//g;
    
    print $FILE "$string\n";

}

1;
