package Parse::BBCode::TAN;
use strict;
use warnings;

use Parse::BBCode;

use URI;
use URI::QueryParam;
use Data::Validate::URI qw/ is_uri /;

our $VERSION = '0.01';

=head1 NAME

Parse::BBCode::TAN

=head1 DESCRIPTION

Parse::BBCode customised for TAN

=head1 EXAMPLE

    use Parse::BBCode::TAN;
    my $p = Parse::BBCode::TAN->new();
    my $code = 'some [youtube]youtube_url[/youtube]';
    my $parsed = $p->render($code);

=head1 METHODS

Inherits all methods from Parse::BBCode

=head1 SUPPORTED TAGS

The following tags are supported

=over

=item *

[quote user=username]quoted text[/quote]

=over

<div class="quote_holder"><span class="quoted_username">username wrote:</span><div class="quote">quoted text</div></div>

=back

=item *

[youtube]youtube_id OR youtube_url[/youtube]

=over

<object data="http://www.youtube.com/v/KmDmyM97_EA" style="width: 425px; height: 350px;" type="application/x-shockwave-flash"><param value="transparent" name="wmode" /><param value="http://www.youtube.com/v/KmDmyM97_EA" name="movie" /></object>

=back

=back

=cut
my $youtube_validate_reg = qr/^[a-zA-Z0-9-_]{11}$/;
sub new {
    return Parse::BBCode->new({
        'tags' => {
            'quote' => {
                'code' => sub {
                    my ($parser, $attr, $content, $attribute_fallback, $tag_tree) = @_;
                    # for some reason, $attr isnt set right :/
                    # but it is now!
                    $attr = $tag_tree->get_attr->[1]->[1];

                    return '<div class="quote_holder"><span class="quoted_username">' . $attr . ' wrote:</span>'
                        .'<div class="quote">' . ${$content} . '</div></div>';
                },
                'class' => 'block',
                'parse' => 0,
            },
            '' => sub { return $_[2]; },
            'youtube' => 'block:%{youtube}s',
        },
        'escapes' => {
            'youtube' => sub {
                my ( $parser, $tag, $text ) = @_;

                my $youtube_id;

                if ( is_uri($text) ){
                    $youtube_id = URI->new($text)->query_param('v');
                } else {
                    $youtube_id = $text;
                }

                if ( defined($youtube_id) && $youtube_id =~ m/$youtube_validate_reg/ ) {
                    return '<object data="http://www.youtube.com/v/' . $youtube_id . '" '
                            .'style="width: 425px; height: 350px;" type="application/x-shockwave-flash">'
                        .'<param value="transparent" name="wmode" />'
                        .'<param value="http://www.youtube.com/v/' . $youtube_id . '" name="movie" /></object>';
                }

                return '';
            },
        },
        'tag_validation' => qr/^([^\]]*)?]/,
    });
}

1;
