use strict;
use warnings;

use lib '../../lib';
use WM::configuration;
use WM::yearlyAverage;

#we will only ever be using the one config file here.

my $config = "../../configurations/average.cfg";

my $data = WM::configuration->new($config);

my $red = WM::yearlyAverage->new($data);

$red->wipeDataDirectory();

$red->getAvg();

my $target = join('/',($data->getDataDirectory(), $data->{artifactName}));

$target =~ s/.gz$//;

qx(gzip -c $target > $target.gz);
print "HA!\n";
