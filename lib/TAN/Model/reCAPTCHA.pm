package TAN::Model::reCAPTCHA;

use strict;
use warnings;
use parent 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Captcha::reCAPTCHA' );

=head1 NAME

TAN::Model::reCAPTCHA

=head1 DESCRIPTION

Direct L<Captcha::reCAPTCHA>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
