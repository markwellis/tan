package TAN::BBcode::Converter;
use 5.014;
use Moose;

use Parse::BBCode;
use Data::Validate::URI qw/is_web_uri/;

my $youtube_validate_reg = qr/^[a-zA-Z0-9-_]{11}$/;
has 'bbcode' => (
    'is' => 'ro',
    'isa' => 'Parse::BBCode',
    'lazy_build' => 1,
);

sub _build_bbcode{
    return Parse::BBCode->new( {
        'tags' => {
            'youtube' => 'block:%{youtube}s',
        },
        'escapes' => {
            'youtube' => sub {
                my ( $parser, $tag, $text ) = @_;

                if ( !is_web_uri($text) ){
                    if ( $text =~ m/$youtube_validate_reg/ ){
                        $text = "http://www.youtube.com/watch?v=${text}";
                    } else {
                        return "[video]${text}[/video]";
                    }
                }

                return "[video]${text}[/video]";
            },
        },
        'linebreaks' => 0,
        'direct_attributes' => 0,
    } );
}

sub parse{
    my ( $self, $input ) = @_;

    return $self->bbcode->render( $input );
}

__PACKAGE__->meta->make_immutable;
