package admin;

use strict;
use warnings;

use LWP::UserAgent;
use Cwd;

use lib '../../lib';
use WM::configuration;

use base qw(Test::Unit::TestCase);

sub test_admin_basic {
    my ($self) = @_;

    #my $loc = getcwd;

    #print "@INC\n$loc\n";

    my $data = WM::configuration->new();

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);

    my $response = $ua->get( $data->getRoot() . '/admin.html');
 
    #is the admin page present
    $self->assert($response->is_success, 'Admin page is not present');

    

}
sub test_admin_list_tranforms {
    my ($self) = @_;
    
    print "Not Implemented\n";

    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'the admin perl does not list all of the transforms');

    

}


# does the admin perl list all of the data sets
sub test_admin_list_datasets {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'the admin perl does not list all of the datasets');

    

}
# does the admin perl list all of the websites 
sub test_admin_list_websites {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'the admin perl does not list all of the websites');

    

}

# does the admin perl list all of the data keys
sub test_admin_list_datakeys {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'the admin perl does not list all of the datakeys');

    

}
# can the admin perl delete a data set
sub test_admin_delete_datasets {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'can admin perl delete the datasets');
}
# can the admin perl delete a transform
sub test_admin_delete_tranforms {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'can admin perl delete the transform');
}

# can the admin perl change a website
sub test_admin_change_website {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'can admin perl change the website');
}
# can the admin perl change a data key
sub test_admin_change_datakey {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'can admin perl change the datakey');
}
# can the admin perl add a data key
sub test_admin_add_datakey {
    my ($self) = @_;
print "Not Implemented\n";
    # does the admin perl list all of the transforms
    #$self->assert_equals(0, 1, 'can admin perl change the datakey');
}
1;
