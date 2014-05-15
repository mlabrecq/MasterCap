package WM::mainProcess;

use strict;
use warnings;

sub new {
    my ($class, $data) = @_;

    my $this = {};

    $this->{data} = $data;

    bless($this, $class);

    return $this;

}

sub getWatchDir {
    my ($this) = @_;

    my $path = join('/', ($this->{data}->getSiteRoot, 'semaphores'));

    return $path;


}

sub kickOff {
    my ($this) = @_;

    my $dir = $this->getWatchDir();

    if (-e $this->{data}->getToken) {
	my $token = $this->{data}->getToken();

	open(my $FILE, '<', $token);

	if (<$FILE> =~ /^go$/){
	    
	    chomp($token);
	
	    unlink($token) or warn "$0. $!";

	
	    return 1;
	}

    }
    return 0;

}

sub readConfigFiles {
    my ($this, $target) = @_;

#we need to get the root. 
#this one has it.
    my $data = WM::configuration->new('../../configurations/config.cfg');

    my $root = $data->getSiteRoot();

    my $dir = join('/', ($root, $target, 'configurations'));

    my @out = qx(ls -1 $dir);

    chomp(@out);
    
    my @configFiles;

    for my $out (@out) {
    
	my $file = join('/', ($dir, $out));
	push(@configFiles, $file);

    }

    return @configFiles;

}

1;
