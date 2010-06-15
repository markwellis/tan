package TAN::Model::FetchImage;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Fetch::Image;

=head1 NAME

TAN::Model::FetchImage

=head1 DESCRIPTION

Fetches a remote image

=head1 METHODS

=cut

=head2 COMPONENT

B<@args = (@config)>

=over

returns a new Fetch::Image(@config)

=back

=cut
sub COMPONENT{
    my ($self, $c, @config) = @_;

    return new Fetch::Image(@config);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
