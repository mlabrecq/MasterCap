use strict;
use warnings;

use lib '../../lib';

use WM::configuration;
use WM::mainProcess;

#we load up all the config files.
my $m = WM::mainProcess->new();

my @kickoff = ();

for my $file ($m->readConfigFiles(shift)) {
    $m->{data} = WM::configuration->new($file);
    
    if ($m->kickOff() == 1) {
	
	#we check for semaphores.
#if we don't have any we bail.
	
	push(@kickoff, $m->{data});
	
    }
    else {
	print "foo\n";
    }
}

#we figure out which order we need to process them in
#we fire off the scripts in order.

for my $data (@kickoff) {
    my $script = $data->{script};

    my $target = join('/', ($data->getSiteRoot(), 'scripts', $script)); 
    print "$target\n";
    
    my @output = qx(perl $target);
    
    for my $out(@output) {
	print "$out\n";

    }

}




