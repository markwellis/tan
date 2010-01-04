package Parse::BBCode::TAN;
use strict;
use warnings;

use base qw/ Parse::BBCode /;

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

=back

=cut
sub new {
    my ( $class ) = @_;

    my $self = $class->SUPER::new({
        'tags' => {
            'quote' => 'block:<div class="quote_holder"><span class="quoted_username">%{user}attr wrote:</span>'
                .'<div class="quote">%s</div></div>',
            '' => sub { return $_[2]; },
        },
        'tag_validation' => qr/^([^\]]*)?]/, 
    });

    return $self;
}

1;
