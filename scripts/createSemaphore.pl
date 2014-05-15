use strict;
use warnings;

use lib '../../lib';

use WM::configuration;

my $m = WM::configuration->new('../../configurations/config.cfg');

$m->readyForProcessing();
