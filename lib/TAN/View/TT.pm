package TAN::View::TT;
use strict;
use warnings;

use HTML::FormatText;

use HTML::Video::Embed;
use URI;
use Number::Format;

use base 'Catalyst::View::TT';

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

__PACKAGE__->config({
    CATALYST_VAR => 'c',
    PRE_PROCESS  => 'lib/config.tt',
    WRAPPER      => 'lib/wrapper.tt',
    TIMER        => 0,
    TEMPLATE_EXTENSION => '.tt',
    'COMPILE_DIR' => '/tmp/tan_template_cache',
    DEBUG => 1,
    WARNINGS => 1,
    FILTERS => {
        'nl2br' => sub { return nl2br(shift); },
        'file_exists' => sub { return file_exists(shift); },
        'strip_tags' => sub { return strip_tags(shift); },
        'file_mtime' => sub { return file_mtime(shift); },
        'embed_url' => sub { return embed_url(shift); },
        'domain' => sub { return domain(shift); },
        'filesize_h' => sub { return filesize_h(shift); },
    },
    render_die => 1,
    ENCODING => 'utf8',
    EVAL_PERL => 1,
});

sub process{
    my ( $self, $c ) = @_;

    #set this here and not in config so we can use correct theme
    $self->include_path( [
        $c->path_to( 'root', 'templates', 'shared' ),
        $c->path_to( 'root', 'templates', $c->stash->{'theme_settings'}->{'name'} ),
    ] );

    $self->next::method( $c );
}

my $nl2br_reg = qr/\n/;
sub nl2br{
    my $text = shift;
    chomp($text);

    $text =~ s/$nl2br_reg/\<br\ \/\>/msg;

    return $text;
}

sub file_exists{
    my $file = shift;
    
    return (-e $file) ? 1 : 0; 
}

sub file_mtime{
    my @stats = stat(shift);

    return $stats[9];
}

sub strip_tags{
    return HTML::FormatText->format_string(
        shift,
        'leftmargin' => 0,
        'rightmargin' => 72,
    );
}

my $embedder = new HTML::Video::Embed({
    'width' => 500,
    'height' => 410,
});
sub embed_url{
    return $embedder->url_to_embed( shift );
}

sub domain{
    my $u = URI->new(shift);
    return $u->host;
}

sub filesize_h{
    my ( $size ) = @_;

    if ( !$size ){
        return 0;
    }

    if ( $size > 1024 ){
        return Number::Format::format_number(($size / 1024)) . 'MB';
    } else {
        return Number::Format::format_number($size) . 'KB';
    }
}

1;
