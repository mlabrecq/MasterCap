use strict;
use warnings;

#we are always called from the working dir directory.
use lib '../../lib';
use WM::configuration;
use WM::qwipu_interaction;

my $config = shift;

my $state = shift;

my $data = WM::configuration->new($config);

my $quip = WM::qwipu_interaction->new($data);

my $out = $quip->readLog($state);

print "$out\n";
