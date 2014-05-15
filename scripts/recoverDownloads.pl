use strict;
use warnings;

use lib '../../lib';

use WM::configuration;
use WM::qwipu_interaction;
use WM::data_carrier;

#we will only ever be using the one config file here.

my $config = "../../configurations/config.cfg";

my $data = WM::configuration->new($config);

my $qwip = WM::qwipu_interaction->new($data);



my @states = $data->getStates();

my $dir = $data->getLogDirectory();

for my $state(@states) {
    my $stateLog = $dir . '/' . lc($state) . ".log";
	

    if (-e $stateLog && -s $stateLog) {
	next;
	#we already did this one.
    }
    print "$state\n";
    my @raw = $qwip->getRawData($state);
}

$qwip->joinDataFiles();

$qwip->zipFiles();

print "HA!\n";


#kick off the next transforms.
$config = "../../configurations/reduce.cfg";

$data = WM::configuration->new($config);

$data->readyForProcessing();
