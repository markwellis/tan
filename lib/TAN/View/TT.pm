package TAN::View::TT;
use strict;
use warnings;

use HTML::TreeBuilder;
use HTML::FormatText;

use base 'Catalyst::View::TT';

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tt');

__PACKAGE__->config({
    CATALYST_VAR => 'c',
    INCLUDE_PATH => [
        TAN->path_to( 'lib', 'templates', 'themes', 'classic' ),
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
    },
});

=head2 nl2br
converts \n's to <br />'s
=cut
my $nl2br_reg = qr/\n/;
sub nl2br{
    my $text = shift;
    chomp($text);

    $text =~ s/$nl2br_reg/\<br\ \/\>/msg;

    return $text;
}

=head2 file_exists
true if a file exists
=cut
sub file_exists{
    my $file = shift;
    
    return (-e $file) ? 1 : 0; 
}

=head2 file_mtime
returns file mtime
=cut
sub file_mtime{
    my $file = shift;
    my @stats = stat($file);

    return $stats[9];
}

=head2 url_title
makes a title url/seo safe
=cut
my $url_title = qr/\W+/;
sub url_title{
    my $title = shift;

    $title =~ s/$url_title/-/ig;

    return $title;
}

=head2 strip_tags
strips the html tags out of a passed in string.
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


=head1 NAME

TAN::View::TT - TT View for TAN

=head1 DESCRIPTION

TT View for TAN.

=head1 SEE ALSO

L<TAN>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
