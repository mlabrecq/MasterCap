package mainProcess;

use strict;
use warnings;

use lib '../../lib';
use WM::mainProcess;
use WM::configuration;

use base qw(Test::Unit::TestCase);

sub test_semaphore_real_data {
    my ($self) = @_;

    my $data = WM::configuration->new();
 
    my $m = WM::mainProcess->new($data);
   
    my $exp = $data->getSiteRoot() . '/semaphores';

    $self->assert(qr/$exp/, $m->getWatchDir());

}

sub test_semaphore_mock_data {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $m = WM::mainProcess->new($data);

    
    my $exp = $data->getSiteRoot() . '/semaphores';

    $self->assert(qr/$exp/, $m->getWatchDir());

}

sub test_KickOff_empty {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $m = WM::mainProcess->new($data);

    $self->assert_equals(0, $m->kickOff());

    

}

sub test_PlaceSemaphore {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $m = WM::mainProcess->new($data);

    $data->readyForProcessing();

    $self->assert_equals(1, $m->kickOff());

    

}

sub test_no_doubles {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $m = WM::mainProcess->new($data);

    $data->readyForProcessing();

    $self->assert_equals(1, $m->kickOff());
    $self->assert_equals(0, $m->kickOff());

    

}


1;
