package TAN::Controller::Random;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head2 index

=cut
sub index :Path :Args(1) {
    my ( $self, $c, $location ) = @_;
    
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
