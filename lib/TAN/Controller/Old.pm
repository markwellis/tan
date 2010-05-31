package TAN::Controller::Old;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Old

=head1 DESCRIPTION

redirects from a old object url to the new one

=head1 EXAMPLE

I</old/$type/$id>

=head1 METHODS

=cut

=head2 index: Path Args(2)

B<@args = $type, $old_id>

=over

redirects to internal object url 

=back

=cut
sub index :Path Args(2){
    my ( $self, $c, $type, $old_id ) = @_;

    if ( $type eq 'pic' ){
    #consistancy ftw...
        $type = 'picture';
    }
    my $lookup = $c->model('MySQL::OldLookup')->find({
        'type' => $type,
        'old_id' => $old_id,
    });

    if ( defined($lookup) ){
        my $object = $c->model('MySQL::Object')->find({
            'object_id' => $lookup->new_id,
        });

        $c->res->redirect( "/view/" . $object->type . "/" . $object->id . "/" . $object->url_title, 301);
        $c->detach();
    }

    $c->forward('/default');
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
