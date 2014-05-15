package configuration;

use strict;
use warnings;

use lib '../../lib';
use WM::configuration;
use WM::qwipu_interaction;

use Cwd;

use base qw(Test::Unit::TestCase);

sub test_configuration_mock_data {
    my ($self) = @_;

    my $current = getcwd;
    $current =~ s!/php$!!;
    my $data = WM::configuration->new('/../../test/fakeconfigfile.cfg');

    my $root = $data->getSiteRoot();

    $self->assert_equals($root, $current);

}

sub test_state_abbrev {
    my ($self) = @_;

    my $data = WM::configuration->new();

    my @states = $data->getStates();

    $self->assert_equals(scalar(@states), 51, 'we do not have all 50 states plus dc');  

}

sub test_get_qwipu {
    my ($self) = @_;

    my $data = WM::configuration->new();

    my $qwipu = $data->getQWIPU();

    $self->assert(qr/lehd.ces.census.gov/, $qwipu);  

}

sub test_get_name {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');

    $self->assert(qr/^Raw Qwipu Test$/, $data->getName());

}


sub test_get_order {
    my ($self) = @_;
    
    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    
    $self->assert_equals(0, $data->order());

    $data = WM::configuration->new('/../../test/configurations/subtestconfig.cfg');

    $self->assert_equals(1, $data->order());
    
}

sub test_get_status_info {
    my ($self) = @_;
    
    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $qwip = WM::qwipu_interaction->new($data);

    #evil pre cleanup
    $qwip->wipeDataDirectory();
    $qwip->removeSemaphore();


    $self->assert(qr/^Not Started$/, $data->getStatus());
    $self->assert(qr/^Not Applicable$/, $data->getErrors());
    $self->assert_equals(0, $data->link);
    
    

    $qwip->getRawData('fa');

    $self->assert(qr/^Working:/, $data->getStatus());
    $self->assert_equals(0, $data->link);

    $qwip->getRawData('xx');
    
    $self->assert(qr/XX not available/, $data->getErrors());

    $qwip->joinDataFiles();

    $self->assert(qr/joining/, $data->getStatus());
    $self->assert_equals(0, $data->link);

    $qwip->zipFiles();

    $self->assert(qr/^Complete$/, $data->getStatus());
    $self->assert_equals(1, $data->link);

    #good post cleanup
    $qwip->wipeDataDirectory();
    $qwip->removeSemaphore();

}

sub test_get_artifact {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');

    $self->assert(qr!mlabrecq.org/masterCap/test/data/raw/merged.csv.gz!, $data->getArtifactName);  

}

1;
