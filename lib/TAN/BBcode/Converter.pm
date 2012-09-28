package TAN::BBcode::Converter;
use 5.014;
use Moose;

use Parse::BBCode;
use Data::Validate::URI qw/is_web_uri/;
use HTML::TreeBuilder 5 -weak;

my $youtube_validate_reg = qr/^[a-zA-Z0-9-_]{11}$/;
has 'bbcode' => (
    'is' => 'ro',
    'isa' => 'Parse::BBCode',
    'lazy_build' => 1,
);

sub _build_bbcode{
    return Parse::BBCode->new( {
        'tags' => {
            '' => sub { return $_[2]; },
            'youtube' => 'block:%{youtube}s',
        },
        'escapes' => {
            'youtube' => sub {
                my ( $parser, $tag, $text ) = @_;

                if ( !is_web_uri($text) ){
                    if ( $text =~ m/$youtube_validate_reg/ ){
                        $text = "http://www.youtube.com/watch?v=${text}";
                    }
                }

                return "[video]${text}[/video]";
            },
        },
        'linebreaks' => 0,
        'direct_attributes' => 0,
    } );
}

my $wrote_regex = qr/ wrote:/;
sub parse{
    my ( $self, $input ) = @_;

use Data::Dumper;

    my $tree = HTML::TreeBuilder->new;
    $tree->implicit_tags(0);
    $tree->parse_content( $input );
#go through tree
# find <div class="quote_holder">
#  find <span class="quoted_username">
#   get content, remove " wrote:"
#    find <div class="quote">
#     get content
#      replace all with [quote user=username]content[/quote]
#       repeat
    my @quotes = $tree->look_down(
        '_tag' => 'div', 
        'class' => 'quote_holder'
    );


    foreach my $quote ( @quotes ){
        my @content = $quote->content_list;
        my ( $username, $quote_content );
        foreach my $content ( @content ){
            if ( 
                ( $content->tag eq 'span' )
                && ( $content->attr('class') eq 'quoted_username' )
            ){
                ( $username ) = $content->content_list;
                $username =~ s/$wrote_regex//g;
            }

            if ( 
                ( $content->tag eq 'div' )
                && ( $content->attr('class') eq 'quote' )
            ){
                ( $quote_content ) = $content->content_list;
                if ( ref( $quote_content ) eq 'HTML::Element' ){
                    $quote_content = $quote_content->as_HTML;
                }
            }
        }
        $quote->replace_with(
            "[quote user=${username}]" . $quote_content . '[/quote]' 
        );
    }
    my @nodes = $tree->guts;
    ( $input ) = $nodes[0]->content_list if ( ref( $nodes[0] ) eq 'HTML::Element' );
    return $self->bbcode->render( $input );
}

__PACKAGE__->meta->make_immutable;
