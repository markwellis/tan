package TAN::Model::ParseHTML;
use Moose;
use namespace::autoclean;

use HTML::StripScripts::Parser;
use Parse::BBCode;
use HTML::Video::Embed;
use Data::Validate::URI qw/is_web_uri/;
use HTML::TreeBuilder;

extends 'Catalyst::Model';

has 'hss' => (
    'is' => 'ro',
    'isa' => 'HTML::StripScripts::Parser',
    'lazy_build' => 1,
);

sub _build_hss{
    my $hss = HTML::StripScripts::Parser->new( 
        { 
            'Context'     => 'Flow',
            'AllowSrc'    => 1,
            'AllowHref'   => 1,
            'AllowRelURL' => 1,
            'BanList'     => {
                'script'  => 1
            },
            'Rules' => {
                'a' => sub {
                    my ( $filter, $element ) = @_;

                    #inject rel=nofollow
                    $element->{'attr'}{'rel'} = 'external nofollow';
                    return 1;
                },
            },
        },
        'strict_comment'  => 1,
        'strict_names'    => 1,
    );
    my $context_whitelist = $hss->init_context_whitelist;
    my $attrib_whitelist = $hss->init_attrib_whitelist;
    my $style_whitelist = $hss->init_style_whitelist;
    my $attval_whitelist = $hss->init_attval_whitelist;

#copy and paste from HTML::StripScripts, only with longer urls allowed...
    $attval_whitelist->{'href'} = sub{
        my ( $filter, $tag, $attr_name, $attr_val ) = @_;
#rel url check from HTML::StripScripts:1447
#reason for overide is to allow longer urls

        if ( 
            is_web_uri($attr_val)
            || ( $attr_val =~ /^((?:[\w\-.!~*|;\/?=+\$,%#]|&amp;))+$/ )
        ){
            return $attr_val;
        }

        return undef;
    };

#allow size to be number or word...
    $style_whitelist->{'font-size'} = 'word';
    $style_whitelist->{'text-decoration'} = 'word';

# set additionally allowed html tag attributes
    $attrib_whitelist->{'a'}->{'title'} = 'text';
    $attrib_whitelist->{'a'}->{'href'} = 'href';
    $attrib_whitelist->{'a'}->{'target'} = 'text';
    $attrib_whitelist->{'a'}->{'class'} = 'text';

    $attrib_whitelist->{'img'}->{'title'} = 'text';
    $attrib_whitelist->{'img'}->{'src'} = 'text';

    $attrib_whitelist->{'div'}->{'class'} = 'wordlist';
    $attrib_whitelist->{'div'}->{'style'} = 'style';
    $attrib_whitelist->{'span'}->{'style'} = 'style';

    return $hss;
}

has 'bbcode' => (
    'is' => 'ro',
    'isa' => 'Parse::BBCode',
    'lazy_build' => 1,
);

sub _build_bbcode{
    my $embedder = HTML::Video::Embed->new( {
        'class' => "TAN-video-embed",
    } );

    return Parse::BBCode->new( {
        'tags' => {
            'quote' => {
                'code' => sub {
                    my ($parser, $attr, $content, $attribute_fallback, $tag_tree) = @_;
                    # for some reason, $attr isnt set right :/
                    # but it is now!
                    $attr = $tag_tree->get_attr->[1]->[1];
                    $attr ||= '';
                    $content ||= '';


                    return '<div class="quote_holder"><span class="quoted_username">' . $attr . ' wrote:</span>'
                        .'<div class="quote">' . ${$content} . '</div></div>';
                },
                'class' => 'block',
                'parse' => 1,
            },
            '' => sub { return $_[2]; },
            'video' => 'block:%{video}s',
        },
        'escapes' => {
            'video' => sub {
                my ( $parser, $tag, $text ) = @_;

#is $text a html a element?
                my $tree = HTML::TreeBuilder->new;
                $tree->implicit_tags(0);
                $tree->parse_content( $text );
                my ( $node ) = $tree->guts(); #only use first item
                if ( ref( $node ) eq 'HTML::Element'){
                    if ( $node->tag eq 'a' ){
                        $text = $node->attr('href');
                    }
                }

                return $embedder->url_to_embed( $text ) || "[video]${text}[/video]";
            },
        },
        'linebreaks' => 0,
        'direct_attributes' => 0,
    } );
}

sub parse{
    my ( $self, $input_text, $no_bbcode ) = @_;

    my $output_text;
#strip XSS
    $output_text = $self->hss->filter_html( $input_text );

    if ( !$no_bbcode ){
    # do bbcode stuff
    # has to be after XSS striping or the embeds will get stripped!
        $output_text = $self->bbcode->render( $output_text );
    }

    return $output_text;
}

__PACKAGE__->meta->make_immutable;
