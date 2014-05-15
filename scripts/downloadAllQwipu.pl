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

$qwip->wipeDataDirectory();

my @states = $data->getStates();

for my $state(@states) {

    my @raw = $qwip->getRawData($state);
}

$qwip->joinDataFiles();

$qwip->zipFiles();

print "HA!\n";


#kick off the next transforms.
$config = "../../configurations/reduce.cfg";

my $data = WM::configuration->new($config);

$data->readyForProcessing();
