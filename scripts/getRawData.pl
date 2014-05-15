use strict;
use warnings;

use lib '../../lib';
use WM::qwipu_interaction;
use WM::configuration;


my $config = shift;

my $state = shift;

my $data = WM::configuration->new($config);

my $qwip = WM::qwipu_interaction->new($data);
my @raw = $qwip->getRawData($state);

