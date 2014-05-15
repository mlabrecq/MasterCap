use strict;
use warnings;

use lib '../../lib';
use WM::configuration;
use WM::empOnly;

#we will only ever be using the one config file here.

my $config = "../../configurations/employmentOnly.cfg";

my $data = WM::configuration->new($config);

my $red = WM::empOnly->new($data);

$red->wipeDataDirectory();

$red->trimToEmpOnly();

my $target = join('/',($data->getDataDirectory(), $data->{artifactName}));

$target =~ s/.gz$//;

qx(gzip -c $target > $target.gz);
print "complyed reduction to employment only!\n";

#kick off the next transforms.
$config = "../../configurations/average.cfg";

$data = WM::configuration->new($config);

$data->readyForProcessing();
