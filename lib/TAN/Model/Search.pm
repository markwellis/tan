package TAN::Model::Search;
use Moose;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'KinoSearchX::Simple' );

=head1 NAME

TAN::Model::Search

=head1 DESCRIPTION

Interface to L<KinoSearchX::Simple>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
