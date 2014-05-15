package empOnly;

use strict;
use warnings;

use lib '../../lib';
use WM::empOnly;
use WM::configuration;

use base qw(Test::Unit::TestCase);


sub test_KickOff_empty {
    my ($self) = @_;
    
    my $data = WM::configuration->new('/../../test/configurations/subtestconfig.cfg');
    my $emp = WM::empOnly->new($data);

    qx(rm -rf ../../test/data/raw/*);

    qx(cp ../../test/fakedatafiles/fishing.csv ../../test/data/raw/qwi_al_rh_f_gc_n4_oslp_u.csv);

    $emp->trimToEmpOnly();
    
    qx(rm ../../test/data/raw/qwi_al_rh_f_gc_n4_oslp_u.csv);
    
    my @artifacts = $emp->filesForExport();
  
    open(my $file, '<', $artifacts[0]) or die;

    my @lines = <$file>;
    
    my $line = $lines[0];

    my @count = split(',', $line);

    $self->assert_equals(11, scalar(@count));


}



1;

    
