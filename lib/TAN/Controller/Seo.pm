package TAN::Controller::Seo;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Seo

=head1 DESCRIPTION

Seo Controller - Not technically SEO, but w/e yo

=head1 EXAMPLE

I</googledc796c4dad406173.html>
I</y_key_242ef28969a04b9c.html>

=over

search engine confirm keys

=back

=head1 METHODS

=cut

=head2 google: Path('/googledc796c4dad406173.html')

B<@args = undef>

=over

google confirm key

=back

=cut
sub google: Path('/googledc796c4dad406173.html'){
    my ( $self, $c ) = @_;

    #google just check if the path exists
    $c->res->output(1);
    $c->detach();
}

=head2 yahoo: Path('/googledc796c4dad406173.html')

B<@args = undef>

=over

yahoo confirm key

=back

=cut
sub yahoo: Path('/y_key_242ef28969a04b9c.html'){
    my ( $self, $c ) = @_;

    #yahoo needs this key
    $c->res->output('adf14f5d24cef99f');
    $c->detach();
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
