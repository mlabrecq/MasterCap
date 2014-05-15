package reducetoall;

use strict;
use warnings;

use lib '../../lib';
use WM::reduceToAll;
use WM::configuration;
use WM::qwipu_interaction;

use base qw(Test::Unit::TestCase);


sub test_get_dataSource {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/subtestconfig.cfg');
    my $avg = WM::reduceToAll->new($data);

    my $otherData = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $qwipu = WM::qwipu_interaction->new($otherData);

    my @artifacts = $qwipu->filesForExport();

    $self->assert_equals(6, scalar(@artifacts));
    
    my @dataSources = $avg->getFilesToReduce();

    $self->assert_equals(6, scalar(@dataSources));


    $self->assert_equals($dataSources[0], $artifacts[0]);
    $self->assert_equals($dataSources[5], $artifacts[5]);
}

sub test_match_sets {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/subtestconfig.cfg');

    my $red = WM::reduceToAll->new($data);

    my @sets = $red->getDataSets();

    $self->assert_equals(2, scalar(@sets));

    my $set = $sets[0];
    my @set = @$set;

    $self->assert_equals(3, scalar(@set));

    $self->assert(qr/\/quality/, $set[0]);
    $self->assert(qr/\/qwi/, $set[1]);
    $self->assert(qr/\/race/, $set[2]);


}

sub test_reduction {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/subtestconfig.cfg');

    my $red = WM::reduceToAll->new($data);

    $red->reduce();
    
    my @artifacts = $red->filesForExport();
    
    $self->assert_equals(1, scalar(@artifacts));
    
    open(my $file, '<', $artifacts[0]) or die;

    my @lines = <$file>;
    
    $self->assert_equals(3, scalar(@lines));

    


}



1;
