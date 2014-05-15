package WM::empOnly;

use strict;
use warnings;

use parent qw(WM::data_carrier);

sub new {
    my ($class, @arguments) = @_;

    my $this = $class->SUPER::new(@arguments);

    $this->{userTarget} = 'merged_qwipu_raw.csv.gz';
    

    return $this;

}


sub trimToEmpOnly {
    my ($this) = @_;


    my @targetFiles = $this->getDependantDataSources();

    my $target = $targetFiles[0];
    my $reduceFile = join('/', ($this->{data}->getSiteRoot(), $this->{data}->{data}, $this->{data}->{artifactName}));

    $target =~ s/.gz$//;

    $reduceFile =~ s/.gz$//;

    open(my $FILE, '<', $target) or die;

    open(my $OUT, '>', $reduceFile) or die;

    while(<$FILE>){
	my @parts = split(',', $_);

	my $line = join(',', (@parts[0..9], $parts[41]));

	print $OUT "$line\n";

    }

    


}

1;
