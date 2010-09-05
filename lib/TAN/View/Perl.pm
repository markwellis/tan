package TAN::View::Perl;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl';
with 'Catalyst::View::Perl::URL';

no Moose;

use HTML::Video::Embed;

__PACKAGE__->config({
    'config' => 'Lib::Config',
    'wrapper' => 'Lib::Wrapper',
});

=head2 file_mtime

B<@args = ($file)>

=over

returns file mtime

=back

=cut
sub file_mtime{
    my ( $self, $file ) = @_;

    my @stats = stat($file);

    return $stats[9];
}

=head2 embed_url

B<@args = ($url)>

=over

interface to L<HTML::Video::Embed>->url_to_embed( $url )

=back

=cut
my $embedder = new HTML::Video::Embed({
    'width' => 500,
    'height' => 410,
});
sub embed_url{
    my ( $self, $url ) = @_;

    return $embedder->url_to_embed( $url );
}

=head2 is_video

B<@args = ($url)>

=over

returns true if url is a L<HTML::Video::Embed> video

=back

=cut
sub is_video{
    my ( $self, $url ) = @_;

    if ($embedder->is_video( $url )){
        return 1;
    }
    return 0;
}

__PACKAGE__->meta->make_immutable;

1;
