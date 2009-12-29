package TAN::Controller::Filter;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Filter

=head1 DESCRIPTION

Mibbit iframe embedded in-page

=head1 EXAMPLE

''/filter''

=head1 METHODS

=cut

=head2 index: Path

'''@args = undef'''

 * enables/disables NSFW filter
 * redirects to referer or / 

=cut
sub index :Path {
    my ( $self, $c ) = @_;

    #bitwise ftw
    $c->nsfw($c->nsfw ^ 1);

    my $ref = $c->req->referer;
    if (!defined($ref)){
        $ref = '/';
    }

    $c->res->redirect($ref);
    $c->detach();
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
