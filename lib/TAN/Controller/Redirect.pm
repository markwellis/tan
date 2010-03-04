package TAN::Controller::Redirect;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Redirect

=head1 DESCRIPTION

redirects to a objects url

=head1 EXAMPLE

I</redirect/45990>

=head1 METHODS

=cut

=head2 index: Path

B<@args = id>

=over

redirects to object url 

=back

=cut
my $int_reg = qr/\D+/;
sub index :Path {
    my ( $self, $c, $id ) = @_;

    $id =~ s/$int_reg//g;

    my $object_rs = $c->model('MySQL::Object')->find($id);
    my $url;
    if ( defined($object_rs) && ($object_rs->type eq 'link') ){
    #links have urls
        $url = $object_rs->link->url;
    } else {
    # not a link
        $url = '/';
    }
    $c->res->redirect( $url );
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
