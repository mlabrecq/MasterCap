use strict;
use warnings;

#we are always called from the working dir directory.
use lib '../../lib';
use WM::configuration;

my $config = shift;

my $data = WM::configuration->new($config);

my @states = $data->getStates();

my @output;

for my $state (@states) {

    push(@output, lc($state));

}

my $states = join(',', @output);

print "$states";
