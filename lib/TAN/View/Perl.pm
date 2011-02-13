package TAN::View::Perl;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl';
with 'Catalyst::View::Perl::URL';

no Moose;

use HTML::Video::Embed;
use Number::Format;

__PACKAGE__->config({
    'config' => 'Lib::Config',
    'wrapper' => 'Lib::Wrapper',
});

sub file_mtime{
    my ( $self, $file ) = @_;

    my @stats = stat($file);

    return $stats[9];
}

my $embedder = new HTML::Video::Embed({
    'width' => 500,
    'height' => 410,
});
sub embed_url{
    my ( $self, $url ) = @_;

    return $embedder->url_to_embed( $url );
}

sub is_video{
    my ( $self, $url ) = @_;

    if ($embedder->is_video( $url )){
        return 1;
    }
    return 0;
}

sub filesize_h{
    my ($c, $size) = @_;

    if ( !$size ){
        return 0;
    }

    if ( $size > 1024 ){
        return Number::Format::format_number(($size / 1024)) . 'MB';
    } else {
        return Number::Format::format_number($size) . 'KB';
    }
}

__PACKAGE__->meta->make_immutable;
