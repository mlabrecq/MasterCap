use strict;
use warnings;

use lib '../../lib';
use WM::configuration;
use WM::reduceToAll;

#we will only ever be using the one config file here.

my $config = "../../configurations/reduce.cfg";

my $data = WM::configuration->new($config);

my $red = WM::reduceToAll->new($data);

$red->wipeDataDirectory();

$red->reduce();

my $target = join('/',($data->getDataDirectory(), $data->{artifactName}));

$target =~ s/.gz$//;

qx(gzip -c $target > $target.gz);
print "HA!\n";


#kick off the next transforms.
$config = "../../configurations/employmentOnly.cfg";

my $data = WM::configuration->new($config);

$data->readyForProcessing();
