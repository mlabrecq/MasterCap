package WM::data_carrier;

use strict;
use warnings;

use File::Basename;
use File::Path;

sub new {
    my ($class, $data) = @_;

    my $this;

    $this->{data} = $data;

    bless($this, $class);
    
    #we will without doubt need our data directory.
    if(!-e $data->getDataDirectory()) {
	mkpath($data->getDataDirectory());
    }

    return($this);

}

sub removeSemaphore {
    my ($this) = @_;

    unlink($this->{data}->getSemaphore());

}

sub createSemaphore {
    my ($this, $status) = @_;
    
    my $sem = $this->{data}->getSemaphore();

    open(my $SEM, '>', $sem) or die "$! $sem";
    
    print $SEM "$status\n";
    

}

sub getSemaphore {
    my ($this, $data) = @_;

    if (-e $this->{data}->getSemaphore()) {
	return 1;
    }
    return 0;

}

sub wipeDataDirectory {
    my ($this) = @_;

    unlink glob $this->{data}->getDataDirectory() . '/*';
    unlink glob $this->{data}->getLogDirectory() . '/*';
    
}

sub readLog {
    my ($this, $state) = @_;
    my $log = $this->_getLog($state);

    open(my $FILE, '<', $log) or return "$state not started\n";

    my @lines = <$FILE>;

    close($FILE);

    if (scalar @lines == 0) {
	return "$state currently processing\n";
    }

    if (scalar @lines == 1 && $lines[-1] == 1) {
	return "$state completed\n";
	
    }
    elsif ($lines[-1] == 404) {
	return "$state not available\n";
	
    }
    
    return join("/n", @lines);

}

sub startLog {
    my ($this, $state) = @_;
    
    my $log = $this->_getLog($state);
    open(my $FILE, '>', $log) or die "unable to open file $!";
    close($FILE);
    return;

}

sub completeLog {
    my ($this, $state) = @_;
    my $log = $this->_getLog($state);
    open(my $FILE, '>>', $log) or die "unable to open file $!";
    print $FILE "1\n";
    close($FILE);

  return;
}

sub notFoundLog {
    my ($this, $state) = @_;
    my $log = $this->_getLog($state);
    open(my $FILE, '>>', $log) or die "unable to open file $!";
    print $FILE "404\n";
    close($FILE);

  return;
}

sub cleanLog {
    my ($this, $state) = @_;
    my $log = $this->_getLog($state);
    unlink($log);
}

sub errorLog {
    my ($this, $state, $line, $lineNumber) = @_;
    my $log = $this->_getLog($state);
    open(my $FILE, '>>', $log) or die "unable to open file $!";
    print $FILE "Error on line $lineNumber while processing $state\n";
    print $FILE "\n\tMoving on as if nothing has happened.\n\nOriginal data:\n";
    print $FILE "\n$line\n";
    close($FILE);

  return;


}

sub _getLog {
    my ($this, $state) = @_;
    if (!-e $this->{data}->getLogDirectory()) {
	mkpath($this->{data}->getLogDirectory()) or die "$!";
    }
    return $this->{data}->getLogDirectory() . "/" . lc($state) . ".log";

}

#this method tells us where the usable artifact is
#we will have other raw data files that we will use for future transforms.
sub linkForDownload {
    my ($this) = @_;

    my $root = $this->{data}->getRoot();

    my $dataDir = $this->{data}->{data};

    my $downloadTarget = $this->{userTarget};

    return join('/', ($root, $dataDir, $downloadTarget));

}

#the files that can be used in future tranforms
# These files can be the same as the userTarget
# They can also be entirely different.
sub filesForExport {
    my ($this) = @_;

    #notice that we do not use the webroot here.
    
    #this for internal ussage.

    my $root = $this->{data}->getSiteRoot();

    my $dataDir = $this->{data}->{data};

    my $searchPattern = $this->{data}->{filePatternForExport};

    opendir(my $DIR, join('/', ($root, $dataDir))) or return 0;
    
    my @results;
    
    while(my $file = readdir $DIR) {
	if ($file =~ /$searchPattern/) {
	    push(@results, join('/', ($root, $dataDir,$file)));
	}
    }
    
    return @results;
}

#I am a config that depends on someone else.
#let me get all the files that I depend on.
sub getDependantDataSources {
    my ($this) = @_;

    my $depends = $this->{data}->{depends};
    my @depends = split(',', $depends);

    my $root = dirname($this->{data}->{configuration_file});

    my @filesForExport;
    
    for my $config (@depends) {
	my $dependsData = WM::configuration->new(join('/', ($root, $config)));
	my $dependsDataCarrier = WM::data_carrier->new($dependsData);
	push(@filesForExport, $dependsDataCarrier->filesForExport);
    }
    #create a new config that i depend on
    #create a new data carrier
    
    #ask data carrier, files for export
    
    return @filesForExport;
    


}

1;
