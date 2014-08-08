package TAN::View::TT;
use strict;
use warnings;

use HTML::FormatText;

use URI;
use Number::Format;

use base 'Catalyst::View::TT';

use Carp;
use Data::Dumper::Concise;

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
        'domain' => sub { return domain(shift); },
        'filesize_h' => sub { return filesize_h(shift); },
    },
    expose_methods => [qw/embed_url warn_dumper/],
    render_die => 1,
    ENCODING => 'utf8',
    EVAL_PERL => 1,
});

sub render{
    my ( $self, $c, @args ) = @_;
    
    if ( $c->mobile ){
        $c->stash->{'theme_settings'}->{'name'} = 'mobile';
    }
    
    my $path = $c->config->{'static_path'} . "/themes/" . $c->stash->{'theme_settings'}->{'name'};

    $c->stash->{'theme_settings'} = {
        %{ $c->stash->{'theme_settings'} },
        'css_path' => "${path}/css",
        'js_path' => "${path}/js",
        'image_path' => "${path}/images",
    };

    #set this here and not in config so we can use correct theme
    $self->include_path( [
        $c->path_to( 'root', 'templates', 'shared' ),
        $c->path_to( 'root', 'templates', $c->stash->{'theme_settings'}->{'name'} ),
    ] );

    $self->next::method( $c, @args );
}

my $nl2br_reg = qr/\n\r|\r\n|\n|\r/;
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

sub embed_url {
    my ( $self, $c, $url ) = @_;

    return $c->model('Video')->url_to_embed( $url );
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

sub warn_dumper {
    my $self = shift;
    my $c = shift;

    carp Dumper( @_ );
}

1;
