package yearlyAverage;

use strict;
use warnings;

use lib '../../lib';
use WM::yearlyAverage;
use WM::configuration;

use base qw(Test::Unit::TestCase);


sub test_get_matches {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/subtestconfig.cfg');
    my $avg = WM::yearlyAverage->new($data);

    qx(rm -rf ../../test/data/raw/*);

    qx(cp ../../test/fakedatafiles/fishing.csv ../../test/data/raw/qwi_al_rh_f_gc_n4_oslp_u.csv);

    $avg->getAvg();
    
    qx(rm ../../test/data/raw/qwi_al_rh_f_gc_n4_oslp_u.csv);
    
    my @artifacts = $avg->filesForExport();
  
    open(my $file, '<', $artifacts[0]) or die;

    my @lines = <$file>;
    
    $self->assert_equals(66, scalar(@lines));


}



1;
