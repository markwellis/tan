package TAN::Controller::Random;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Random

=head1 DESCRIPTION

Redirect to a random page

=head1 EXAMPLE

''/random/$location''

 * $location => type of object

=head1 METHODS

=cut

=head2 index: Path: Args(1)

'''@args = ($location)'''

 * validates params
 * loads a random object (based on $location) and redirects to it
 * 404's

=cut
my $location_reg = qr/^(all|link|blog|picture)$/;
sub index: Path: Args(1) {
    my ( $self, $c, $location ) = @_;
    
    if ($location !~ m/$location_reg/){
        $location = 'all';
    }

    my $object = $c->model('MySQL::Object')->random($location);

    if ($object){
        $c->res->redirect('/view/' . $object->type . '/' . $object->id . '/' . $c->url_title($object->get_column('title')));
        $c->detach();
    }

    $c->forward('/default');
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
