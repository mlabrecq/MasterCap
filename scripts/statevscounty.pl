use strict;
use warnings;

use lib '../../lib';
use WM::configuration;
use WM::employmentDiffs;

#we will only ever be using the one config file here.

my $config = "../../configurations/statevscounty.cfg";

my $data = WM::configuration->new($config);

my $red = WM::employmentDiffs->new($data);

$red->wipeDataDirectory();

$red->createReport();

my $target = join('/',($data->getDataDirectory(), $data->{artifactName}));

$target =~ s/.gz$//;

qx(gzip -c $target > $target.gz);



#kick off the next transforms.
#$config = "../../configurations/statevscounty.cfg";

#my $data = WM::configuration->new($config);

#$data->readyForProcessing();

