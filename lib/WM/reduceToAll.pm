package WM::reduceToAll;

use strict;
use warnings; 

use File::Basename;

use parent qw(WM::data_carrier);

sub new {
    my ($class, @arguments) = @_;


    my $this = $class->SUPER::new(@arguments);

    return $this;


}

sub getFilesToReduce {
    my ($this) = @_;

    my @targetFiles = $this->getDependantDataSources();

    return @targetFiles;

}

sub getDataSets {
    my ($this) = @_;

    my @targets = $this->getFilesToReduce();

    #I now have 3 files per state/dc
    
    #they need to be placed in order.

    #i know too much about these files.
    
    my %qwi;
    my %qual;
    my %race;

    for my $target(@targets) {

	my $base = basename($target, 'csv');
	
	if ($base =~ /^r/) {
	    $race{$base} = $target;
	    next;
	}
	if ($base =~ /^qu/) {
	    $qual{$base} = $target;
	    next;
	}
	$qwi{$base} = $target;
	
    }

    my @matchedSets;

    

    for my $key (sort(keys(%qual))){
	
	my @array = ($qual{$key});
	push(@matchedSets, \@array);
	

    }
    my $i = 0;
    for my $key (sort(keys(%qwi))){
	my $mine = $matchedSets[$i];
	push(@$mine, $qwi{$key});
	
	
	$i++;
    }

    $i = 0;
    for my $key (sort(keys(%race))){
	my $mine = $matchedSets[$i];
	push(@$mine, $race{$key});
	
	
	$i++;
    }

    return @matchedSets;


}

sub reduce {
    my ($this)  = @_;
    
    my @data = $this->getDataSets();

    my $target = join('/', ($this->{data}->getSiteRoot(), $this->{data}->{data}, $this->{data}->{artifactName}));
    
    $target =~ s/.gz$//;

    open(my $OUT, '>', $target) or die;
    
    my $firstLine = 0;

    for my $set (@data) {
	my @set = @$set;

	open(my $QUAL, '<', $set[0]) or die;
	open(my $RAW, '<', $set[1]) or die;
	open(my $RACE, '<', $set[2]) or die;

	my $raw = <$RAW>;
	my $qual = <$QUAL>;
	my $junk = <$RACE>;
	
	if ($firstLine ==0) {

	    chomp($raw);
	    chomp($qual);
	    my $first = join(',', ($raw, $qual));
	    print $OUT "$first";
	    $firstLine = 1;
	}
	
	while(<$QUAL>){
	    
	    my $line = <$RAW>;
	    
	    my @raw  = split(',', $line);

	    if (scalar(@raw) <= 4){
		next;
	    }


	    if ( $raw[4] =~ /^A$/ or $raw[4] == 4) {

	    }
	    else {
		next;
	    }

	    if ($raw[6] =~ /^A00$/) {

	    }
	    else {
		next;
	    }

	    my @race = split(',', <$RACE>);
	    

	    if ($race[0] == 0) {

	    }
	    else {
		next;
	    }
	    if ($race[1] =~ /^A00$/) {

	    }
	    else {
		next;
	    }

	    if ($race[2] =~ /^A0$/) {

	    }
	    else {
		next;
	    }
	    if ($race[3] =~ /^A0$/) {
	        
	    }
	    else {
		next;
	    }
	    if ($race[4] =~ /^E0$/) {
		
	    }
	    else {
		next;
	    }
	    
	    if ($race[5] == 0) {

	    }
	    else {
		next;
	    }
	    chomp($race[6]);
	    if ($race[6] == 0) {

	    }
	    else {
		next;
	    }
	    
	    chomp($line);
	    
	    chomp($_);
	    my $output = join(',', ($line, $_));
	    
	    print $OUT "\n$output";
	    

	}
	
	

    }
    

}

1;
