package WM::qwipu_interaction;

use strict;
use warnings; 

use parent qw(WM::data_carrier);

use LWP::Simple;
use Archive::Extract;
use File::Basename;

use WM::configuration;

sub new {
    my ($class, @arguments) = @_;

    my $this = $class->SUPER::new(@arguments);

    $this->{userTarget} = 'merged_qwipu_raw.csv.gz';
    

    return $this;

}

sub lastModified {
    my ($this) = @_;

    return 'R2013Q2';

}

sub lastQuarter {
    my ($this) = @_;
    return 'latest_release';
}

sub _getRawDataUrl {

    my ($this, $state) = @_;

    my $url = $this->{data}->getQWIPU();

    my $demographic = 'rh';

    my $firmSize = 'f';

    my $geoUnit = 'gc';

    my $naics = 'n4';

    my $ownership = 'oslp';

    my $seasonal = 'u';

    my $file = join('_', ('qwi', lc($state), $demographic,$firmSize, $geoUnit, $naics, $ownership, $seasonal));

    my $fullcsv = $file . '.csv';
    my $fullDL = $fullcsv . '.gz';
    
    $url = join('/', ($url, lc($state), $this->lastQuarter(),'DVD-' . $demographic .'_'. $firmSize, $fullDL));
    

    return ($url);

}

sub getRawData {
    my ($this, $state) = @_;

    $this->createSemaphore('Working: downloading');

    #we need:
    #state - already have it passed in
    
    #Demographic
    
    $this->startLog($state);

    my $path = $this->_getRawDataUrl($state);

    my $fullDL = $path;
    $fullDL =~ s/.*qwi_/qwi_/;
    
    my $fullcsv = $fullDL;
    
    $fullcsv =~ s/\.gz//;
    
    my $filename = $fullDL;
 
    my $request = getstore($path, $filename);

    if (!(-e $filename)) {
	if ($request =~ /404/) {
	    $this->notFoundLog($state);
	    return (0);
	    #we need a special case here that does the right thing.
	    #print "$filename is not available\n";
	    #next;
	    
	}
	else {
	    die "$filename does not exist!\n $request, does $path look right?";
	}
    }

    my $ae = Archive::Extract->new( archive => $filename );
    $ae->extract () or die "could not unzip: $!";
    
    open(my $unzipped, '<',  $fullcsv) or die "count not read $fullcsv $!";
    
    my $name = fileparse($fullcsv);
    
    my $dataFile = join('/',($this->{data}->getDataDirectory(), $name ));
    my $raceFile = join('/',($this->{data}->getDataDirectory(), 'race_'.$name ));
    my $qualityFile = join('/',($this->{data}->getDataDirectory(), 'quality_'.$name ));
    
    my @datafiles = ($dataFile, $raceFile, $qualityFile);

    open(my $RAW, '>', $dataFile) or die "cound not open $dataFile: $!";
    open(my $RACE, '>', $raceFile) or die "cound not open: $!";
    open(my $QUAL, '>', $qualityFile) or die "cound not open: $!";
    
    
    while (<$unzipped>) {
	my @dataparts = split(',', $_);
	
	if(scalar @dataparts != 80) {
	    $this->errorLog($state, $_, $.);
	    #continue as if nothing happened. 
	}

	#write the raw data file
	my $raw = join(',', @dataparts[0..6]);
	my $more= join(',' ,@dataparts[14..47]);
	$raw = join(',' ,$raw, $more);
	print $RAW "$raw\n";
	
	#write the race data file
	my $race = join(',', @dataparts[7..13]);
	print $RACE "$race\n";
	
	#write the quality data file
	#write the race data file
	my $qual = join(',', @dataparts[48..75]);
	print $QUAL "$qual\n";

	#qual will have the newline from the file.
    }
    
    close($unzipped);
    unlink($filename);
    unlink($fullcsv);
    close($RAW);
   
    $this->completeLog($state);
    return @datafiles;
}

sub joinDataFiles {
    my ($this) = @_;

    #get all the files in the directory
    
    #split them into thier 3 different types

    #merge them up in the same order so that they are in sync.

    $this->createSemaphore('Working: joining');

    opendir(my $DIR, $this->{data}->getDataDirectory()) or die "cannot open current directory";

    my %results;

    my @dataFiles;
    my @raceFiles;
    my @qualFiles;

    while(my $file = readdir $DIR) {
	if ($file =~ /race_|quality_/) {
	    if($file =~ /race_/) {
		push(@raceFiles, $file);
	    }
	    else {
		push(@qualFiles, $file);
	    }
	}
	else {
	    if ($file =~ /^qwi_.*.csv$/) {
		push(@dataFiles, $file);
	    }
	}

    }

    $this->_joinFiles($this->{data}->getDataDirectory() . '/rawData.csv', sort(@dataFiles));
    $this->_joinFiles($this->{data}->getDataDirectory() . '/rawRaceData.csv', sort(@raceFiles));
    $this->_joinFiles($this->{data}->getDataDirectory() . '/qualData.csv', sort(@qualFiles));

}

sub zipFiles {

    my ($this) = @_;

    $this->createSemaphore('Working: zipping');
    my $file = $this->{data}->getDataDirectory() . '/rawData.csv';
    qx(gzip $file);
    
    my $target = join('/',($this->{data}->getDataDirectory(), $this->{data}->{artifactName}));
    
   
    qx(mv $file.gz $target);

    $file = $this->{data}->getDataDirectory() . '/rawRaceData.csv';
    qx(gzip $file);
    $file = $this->{data}->getDataDirectory() . '/qualData.csv';
    qx(gzip $file);

    

    $this->removeSemaphore();
}
sub _joinFiles {
    my ($this, $target, @files) = @_;
    
    open(my $FILE, '>', $target) or die "target cannot be written to";

    my $top = 1;

    for my $source (@files) {

	open(my $read, '<', $this->{data}->getDataDirectory() . '/' . $source) or die "file not valid: $source";

	my $firstline = <$read>;
	
	if ($top) {
	    print $FILE "$firstline";
	    $top = 0;
	}

	while(<$read>) {

	    print $FILE "$_";
	}
    }
  
}



1;
