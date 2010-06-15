package TAN::Model::ValidateImage;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Data::Validate::Image;

=head1 NAME

TAN::Model::ValidateImage

=head1 DESCRIPTION

Validates an image

=head1 METHODS

=cut

=head2 COMPONENT

B<@args = (@config)>

=over

returns a new Data::Validate::Image(@config)

=back

=cut
sub COMPONENT{
    my ($self, $c, @config) = @_;

    return new Data::Validate::Image(@config);
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
