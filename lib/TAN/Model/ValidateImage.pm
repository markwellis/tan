package TAN::Model::ValidateImage;

use strict;
use warnings;
use parent 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Data::Validate::Image' );

=head1 NAME

TAN::Model::ValidateImage

=head1 DESCRIPTION

Validates an image L<Data::Validate::Image>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
