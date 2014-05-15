use strict;
use warnings;

use lib '../../lib';

use WM::configuration;
use WM::mainProcess;

my $m = WM::mainProcess->new();

for my $file ($m->readConfigFiles(shift)) {
    print "-----\n";
    
    open(my $FILE, '<', $file) or die "$!: $file";

    while(<$FILE>) {
	chomp($_);
	print "$_\n";

    }
    my $data = WM::configuration->new($file);
    my $line = 'status='. $data->getStatus();
    print "$line\n";
    $line = 'errors='. $data->getErrors();
    print "$line\n";
    $line = 'order='. $data->order();
    print "$line\n";
    $line = 'link='. $data->link();
    print "$line\n";
    $line = 'artifact='. $data->getArtifactName();
    print "$line\n";
}
print "-----\n";
