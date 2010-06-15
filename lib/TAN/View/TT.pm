package TAN::View::TT;
use strict;
use warnings;

use HTML::TreeBuilder;
use HTML::FormatText;

use HTML::Video::Embed;

use base 'Catalyst::View::TT';

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

__PACKAGE__->config({
    CATALYST_VAR => 'c',
    INCLUDE_PATH => [
        TAN->path_to( 'root', 'templates', 'classic' ),
    ],
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
        'url_title' => sub { return url_title(shift); },
        'embed_url' => sub { return embed_url(shift); },
        'is_video' => sub { return is_video(shift); },
    },
    render_die => 1,
    ENCODING => 'utf8',
});

=head1 NAME

TAN::View::TT

=head1 DESCRIPTION

Template Toolkit view

=head1 FILTERS

=cut

=head2 nl2br_reg

B<@args = ($text)>

=over

converts \n's to <br />'s

=back

=cut
my $nl2br_reg = qr/\n/;
sub nl2br{
    my $text = shift;
    chomp($text);

    $text =~ s/$nl2br_reg/\<br\ \/\>/msg;

    return $text;
}

=head2 file_exists

B<@args = ($file)>

=over

true if a file exists

=back

=cut
sub file_exists{
    my $file = shift;
    
    return (-e $file) ? 1 : 0; 
}

=head2 file_mtime

B<@args = ($file)>

=over

returns file mtime

=back

=cut
sub file_mtime{
    my $file = shift;
    my @stats = stat($file);

    return $stats[9];
}

=head2 url_title

B<@args = ($title)>

=over

makes a title url/seo safe

=back

=cut
my $url_title = qr/[^a-zA-Z0-9]/;
sub url_title{
    my $title = shift;

    $title =~ s/$url_title/-/g;

    return $title;
}

=head2 strip_tags

B<@args = ($text)>

=over

strips the html tags out of a passed in string

=back

=cut
sub strip_tags{
    my $text = shift;
    
    # Without this HTML::TreeBuilder truncates the last part of the string.
    $text .= " \n";

    my $tree = HTML::TreeBuilder->new;
    $tree->parse($text);

    if ($tree) {
        $text = $tree->as_text();
        $tree = $tree->delete;
    }

    return $text;
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
    return $embedder->url_to_embed( shift );
}

sub is_video{
    if ($embedder->is_video( shift )){
        return 1;
    }
    return 0;
}

=head1 SEE ALSO

L<TAN>

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
