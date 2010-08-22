package Catalyst::View::Perl::URL;
use Moose::Role;
use namespace::autoclean;

use URI;

=head2 url

B<@args = ($url, %params)>

=over

returns parsed $url with %params, i.e.

    url('/foo', bar => 1, moo => 2)
    # returns '/foo?bar=1&moo=2'

    url('/foo?bar=1', page => 9, moo => 'meow')
    # returns '/foo?bar=1&page=9&moo=meow'

=back

=cut
sub url{
    my ( $self, $url, %params ) = @_;

    my $uri = URI->new($url);
    $uri->query_form(%params);

    return $uri;
}

=head2 domain

B<@args = ($url)>

=over

returns the domain part of a url

    domain('http://www.example.com/foo/bar')
    # returns 'www.example.com'

=back

=cut
sub domain{
    my ( $self, $url ) = @_;

    my $u = URI->new($url);
    return $u->host;
}
1;
