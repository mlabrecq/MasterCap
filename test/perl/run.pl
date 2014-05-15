

use strict;
use warnings;

use Try::Tiny;

use lib '../perl/lib';

use Test::Unit::TestRunner;

my @tests = ('configuration','admin', 'qwipu_interaction', 'mainProcess');

push(@tests, 'empOnly');
push(@tests, 'reducetoall');
push(@tests, 'yearlyAverage');

my $testName = shift;

if (defined $testName) {

    @tests = ($testName);

}

for my $test (@tests) {
    my $testrunner = Test::Unit::TestRunner->new();

    try {
	$testrunner->start($test);
    } catch {
	print "$test did not parse. $_\n";
    };

}
 
