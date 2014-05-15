package qwipu_interaction;

use strict;
use warnings;



use lib '../../lib';
use WM::qwipu_interaction;
use WM::configuration;

use base qw(Test::Unit::TestCase);

sub test_latest_modified {
    my ($self) = @_;
    
    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $qwip = WM::qwipu_interaction->new($data);
    
    my $value = $qwip->lastModified();
    
    $self->assert_equals('R2013Q2', $value, "V2 feature");

}

sub test_latest_data_date {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $qwip = WM::qwipu_interaction->new($data);

    my $value = $qwip->lastQuarter();

    $self->assert_equals('latest_release', $value);

}

sub test_get_raw_data {
    my ($self) = @_;

    
    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $qwip = WM::qwipu_interaction->new($data);

    
    $self->assert_equals(0, $qwip->getSemaphore($data));

    my @raw = $qwip->getRawData('al');

    $self->assert_equals(1, $qwip->getSemaphore($data));


    $self->assert(qr/qwi_al/, $raw[0], 'incorrect state was downloaded: ' . $raw[0]); 

    open(my $FILE, '<', $raw[0]) or die "failed test! $!";

    

    my $line = <$FILE>;

    my @parts = split(',',$line);

    $self->assert_equals(scalar(@parts), 41, 'Main transform file is malformed '. scalar @parts . ' items in the list, instead of 41: ' . $line); 

    close($FILE);

    open($FILE, '<', $raw[1]) or die "failed test! $!";

    $line = <$FILE>;

    @parts = split(',',$line);

    $self->assert_equals(scalar(@parts), 7, 'Race and ethnicity data is malformed: ' . $line); 

    close($FILE);

    open($FILE, '<', $raw[2]) or die "failed test! $!";

    $line = <$FILE>;

    @parts = split(',',$line);

    $self->assert_equals(scalar(@parts), 28, 'Data quality is malformed: ' . scalar @parts . '    ' . $line); 

    close($FILE);

    my $count = scalar @raw;
    $self->assert_equals(3, $count, "should have only 3: why @raw");
    
    unlink($raw[0]);
    unlink($raw[1]);
    unlink($raw[2]);

    $qwip->removeSemaphore();
}


sub test_loging {
    my ($self) = @_;
    
    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');
    my $qwip = WM::qwipu_interaction->new($data);


    #evil test cleaning up after previous tests.
    $qwip->cleanLog('al');

    $self->assert(qr/al not started/,$qwip->readLog('al'));

    $qwip->startLog('al');

    $self->assert(qr/al currently processing/,$qwip->readLog('al'));

    $qwip->completeLog('al');

    $self->assert(qr/al completed/,$qwip->readLog('al'));

    $qwip->cleanLog('al');

    $self->assert(qr/al not started/,$qwip->readLog('al'));

    $qwip->notFoundLog('al');

    $self->assert(qr/al not available/,$qwip->readLog('al'));
    
    $qwip->cleanLog('al');

}

sub test_wrong_commas {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');

    my $qwip = WM::qwipu_interaction->new($data);

    #evil test cleaning up after previous tests.
    $qwip->cleanLog('hi');

    my @raw = $qwip->getRawData('hi');

    $self->assert(qr/Error on line 3 while processing hi/,$qwip->readLog('hi'));

    $qwip->cleanLog('hi');

    unlink($raw[0]);
    unlink($raw[1]);
    unlink($raw[2]);

    $qwip->removeSemaphore();

}

sub test_join_files {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');

    my $qwip = WM::qwipu_interaction->new($data);
    
    #evil clean up of drool
    $qwip->wipeDataDirectory();

    $qwip->getRawData('al');
    $qwip->getRawData('fa');

    $qwip->joinDataFiles();

    my $dir = $data->getDataDirectory();


    opendir(my $DIR, $dir) or die "cannot open data directory";

    my @results;

    while(my $file = readdir $DIR) {
	
	push(@results, $file);
    }

    $self->assert_equals(11,scalar(@results), "not enough files: @results");

    $self->assert_equals(1, $qwip->getSemaphore($data));
    
    $qwip->zipFiles();

    $self->assert_equals(0, $qwip->getSemaphore($data));

    opendir($DIR, $dir) or die "cannot open data directory";

    @results = ();

    while(my $file = readdir $DIR) {
	
	push(@results, $file);
    }

    $self->assert_equals(11,scalar(@results), "not enough files: " . scalar(@results) . "@results");

    #$self->assert(0,1, 'finish writing the test!');

}

sub test_final_files {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');

    my $qwip = WM::qwipu_interaction->new($data);
    
    my $displayProduct = $qwip->linkForDownload();

    $self->assert(qr/merged_qwipu_raw.csv.gz/, $displayProduct);

}

sub test_data_for_export {
    my ($self) = @_;

    my $data = WM::configuration->new('/../../test/configurations/maintestconfig.cfg');

    my $qwip = WM::qwipu_interaction->new($data);
    $qwip->getRawData('al');
    $qwip->getRawData('fa');
    my @export = $qwip->filesForExport();

    $self->assert_equals(6, scalar(@export));

}

1;
