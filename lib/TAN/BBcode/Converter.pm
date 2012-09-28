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

                return "[video]${text}\[/video]";
            },
        },
        'linebreaks' => 0,
        'direct_attributes' => 0,
    } );
}

my $wrote_regex = qr/ wrote:/;
my $last_newline_regex = qr/\n$/;
sub parse{
    my ( $self, $input ) = @_;

    my $tree = HTML::TreeBuilder->new(
        no_expand_entities => 1,
    );
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
    while( my $quote_holder = $tree->look_down(
        '_tag' => 'div', 
        'class' => 'quote_holder'
        )
    ){
        my @content = $quote_holder->content_list;
        my ( $username, $quote ) = ('', '');
        foreach my $content ( @content ){
            if ( 
                ( $content->tag eq 'span' )
                && ( $content->attr('class') eq 'quoted_username' )
            ){
                ( $username ) = $content->content_list;
                $username =~ s/$wrote_regex//g;
            }

            if ( 
                ( $content->tag )
                && ( $content->attr('class') )
                && ( $content->tag eq 'div' )
                && ( $content->attr('class') eq 'quote' )
            ){
                my @quotes = $content->content_list;
                foreach my $q ( @quotes ){
                    if ( ref( $q ) eq 'HTML::Element' ){
                        $quote .= $q->as_XML;
                        $quote =~ s/$last_newline_regex//;
                    } else {
                        $quote = $q;
                    }
                }
            }
        }

        my $nt = HTML::TreeBuilder->new(
            no_expand_entities => 1,
        );
        $nt->parse_content("[quote user=${username}]${quote}\[/quote]");

        $quote_holder->replace_with(
            $nt->disembowel,
        )->delete;
    }
    my @contents = $tree->disembowel;
    my $q;
    foreach my $c ( @contents ){
        if ( ref( $c ) ){
            $q .= $c->as_XML;
            $q =~ s/$last_newline_regex//;
        } else {
            $q .= $c
        }
    }
    $input = $q;
    return $self->bbcode->render( $input );
}

__PACKAGE__->meta->make_immutable;
