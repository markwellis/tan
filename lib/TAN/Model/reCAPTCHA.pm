package TAN::Model::reCAPTCHA;

use strict;
use warnings;
use parent 'Catalyst::Model';

use Captcha::reCAPTCHA;

=head1 NAME

TAN::Model::reCAPTCHA

=head1 DESCRIPTION

Direct L<Captcha::reCAPTCHA>

=head1 METHODS

=cut

=head2 COMPONENT

B<@args = (undef)>

=over

returns a new Captcha::reCAPTCHA

=back

=cut
sub COMPONENT{
    my ($self, $c) = @_;

    return Captcha::reCAPTCHA->new;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
