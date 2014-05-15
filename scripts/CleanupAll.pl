use strict;
use warnings;

use lib '../../lib';
use WM::configuration;

my $config = shift;

my $data = WM::configuration->new($config);

my $file = $data->getDataDirectory();

qx(rm -rf $file/*);

print "$file clean\n";
