package WM::configuration;

use strict;
use warnings;

use Cwd;

use WM::data_carrier;

sub new {
    my ($class, $file_location) = @_;
    #file location is only used in testing
    #it should be undefined at all other times.

    my $this;
   
    if (defined($file_location) && -e $file_location) {
	$this->{configuration_file} = $file_location;
    }
    else {
	my $path = getcwd;
	if (!defined $file_location) {
	    $this->{configuration_file} = $path . '/../../configurations/config.cfg';
	}
	else {
	    $this->{configuration_file} = $path . '/' . $file_location; 
	}
    }
    $this->{read} = 0;

    bless($this, $class);

    return $this;

}

sub _readConfigFile {
    my ($this) = @_;

    if ($this->{read}) {
	return;
    }
    
    -e $this->{configuration_file} or die "$this->{configuration_file} DNE";

    open(my $FILE, '<', $this->{configuration_file}) or die;

    while (<$FILE>) {
	my @parts = split('=', $_);
	chomp(@parts);

	$this->{$parts[0]} = $parts[1];
    }
    $this->{read} = 1;
}

#this gets the root of the website.
sub getRoot {
    my ($this) = @_;
    $this->_readConfigFile;
    return $this->{webroot};

}
#this gets the root of the webserver. 
sub getSiteRoot {
    my ($this) = @_;
    $this->_readConfigFile;
    return $this->{siteroot};

}

#this gets all of the state abbreviations. 
sub getStates {
    my ($this) = @_;
    $this->_readConfigFile;
    my $states = $this->{states};
    my @states = split(',', $states);

    return @states;

}
#this gets the cornell qwipu site
sub getQWIPU {
    my ($this) = @_;
    $this->_readConfigFile;
    return $this->{QWIPU};

}

#this gets us the current target for data 
sub getDataDirectory {
    my ($this) = @_;
    $this->_readConfigFile;
    return join('/', ($this->getSiteRoot,$this->{data}));
}

sub getLogDirectory {
    my ($this) = @_;
    $this->_readConfigFile;
    return join('/', ($this->getSiteRoot,$this->{logsdir},$this->{data}));
}

sub getStatus {
    my ($this) = @_;
    $this->_readConfigFile;
    my $checkExist = 0;

    open(my $FILE, '<', join('/',$this->getSemaphore)) or $checkExist = 1;

    #we have no semaphore. 
    ##This could be because we are done!

    #it could also because we haven't started up yet.
    if ($checkExist) {
	my $target = join('/',($this->getDataDirectory, $this->{artifactName}));
	


	if(-e $target) {
	    
	    return 'Complete';
	}
	return 'Not Started';

    }

    return <$FILE>;

    
}

sub getSemaphore {
    my ($this) = @_;
    $this->_readConfigFile;
    my $sem = join('/',($this->getSiteRoot(), 'semaphores', $this->getName()));

    return $sem;

}

sub order {
    my ($this) = @_;
    $this->_readConfigFile;
    my $config = $this->{configuration_file};
    
    my $list = $this->{depends};
    
    if (!defined($list)) {
	return 0;
    }

    my @count = split(',', $list);

    return scalar @count;
        
}

sub getName {
    my ($this) = @_;
    $this->_readConfigFile;
    my $config = $this->{configuration_file};
    my $name = $this->{name};
    
    
    return $this->{name};
}

sub getArtifactName {
    my ($this) = @_;
    $this->_readConfigFile;
    return join('/', ($this->getRoot(), $this->{data}, $this->{artifactName}));;
}

sub getErrors {
    my ($this) = @_;
    $this->_readConfigFile;
    my $dataCarrier = WM::data_carrier->new($this);

    my @states = $this->getStates();

    my $errors = 0;
    my $na = 0;

    my $list = '';

    for my $state (@states) {
	my $out = $dataCarrier->readLog($state);
	if ($out =~ /^$|^1$/) {
	    next;
	}
	elsif ($out =~ /not started/) {
	    $na++;
	    next;

	}
	else {
	    $errors++;
	    $list .= "Error: $state: \n\n$out\n\n";
	}
    }

    if (!$errors && !$na) {
	return 'No Errors';
    }
    if (!$errors && $na) {

	return 'Not Applicable';
    }
    
    return $list;
    

}

#should the link be active?
#this may belong on data carrier...
sub link {
    my ($this) = @_;
    $this->_readConfigFile;
    if (-e join('/',($this->getDataDirectory, $this->{artifactName}))) {
	return 1;
    }

    return 0;

    

}

sub readyForProcessing {
    my ($this) = @_;

    # we need to drop a token with our name on it.

    my $token = $this->getToken();

    open(my $FILE, '>', $token) or die 'cannot create new processes';
  
    print $FILE "go\n";


}

sub getToken {
    my ($this) = @_;

    my $token = join('/', ($this->getSiteRoot(), 'semaphores', $this->{name}));

    return $token;


}

1;
