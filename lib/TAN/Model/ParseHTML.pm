package TAN::Model::ParseHTML;
use Moose;
use namespace::autoclean;

use HTML::StripScripts::Parser;
use Parse::BBCode;
use Data::Validate::URI qw/is_web_uri/;
use HTML::TreeBuilder 5 -weak;
use Cwd 'abs_path';
use File::Basename;
use URI::Find;
use Data::Validate::URI;

#hack to use URI::Find regex, coz Regexp::Common::URI::http doesn't pick up query or fragment :/
my $finder = URI::Find->new(sub{});
my $uri_reg = $finder->uri_re;

my $a_match_reg = qr|(<a.+?href=['"]?($uri_reg)['"]?(?:.+?)?>(?:.+?)?</a>)|;
my $href_match_reg = qr/(?:href|src|alt)=['"]?/;
my $uri_find_url_reg = qr/((?:$href_match_reg)?$uri_reg.?)/;

extends 'Catalyst::Model';

has 'hss' => (
    'is' => 'ro',
    'isa' => 'HTML::StripScripts::Parser',
    'lazy_build' => 1,
);

has 'smilies_dir' => (
    'is' => 'ro',
    'isa' => 'Str',
    'required' => 1,
);

has 'smilies' => (
    'is' => 'rw',
    'isa' => 'HashRef',
    'default' => sub{ return {} },
);

has '_smilies_reg' => (
    'is' => 'ro',
    'init_arg' => undef,
    'lazy_build' => 1
);

sub _build__smilies_reg{
    my ( $self ) = @_;

    my $icons = $self->smilies;

    my $dir = dirname( abs_path( __FILE__ ) ) . "/../../../root/" . $self->smilies_dir; #TODO HACK maybe get rid of the /../../../ bit ...

    opendir( my $dh, "$dir" ) || die "failed to opendir $dir: $!";
    while ( my $smilie = readdir( $dh ) ){
        #load each image and strip .png add prefix off : and register
        if ( $smilie =~ m/^\./ ){
            next;
        }

        my $alias = ':' . fileparse( $smilie, ".png", ".gif" );
        $icons->{ $alias } = $smilie;

    }
    closedir( $dh );

    #by the time get to looking for the smilies,
    # the xss stripper has changed ' to &#39; etc so we have to escape
    my $icons_escaped = {};
    foreach my $key ( keys( %{ $icons } ) ){
        my $key_escaped = Parse::BBCode::escape_html( $key );
        $icons_escaped->{ $key_escaped } = $icons->{ $key };
    }
    $self->smilies( $icons_escaped );

    my $re = join '|', map { quotemeta $_ } sort { length $b <=> length $a }
        keys %{ $icons_escaped };

    return qr/(^|\s|&#160;|&nbsp;|>)(${re})(\s|&#160;|&nbsp;|<|$)/;
};


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

my $quote_reg = qr/\&quot\;/;
sub _build_bbcode{
    my ( $self ) = @_;

    my $embedder = TAN->model('Video');

    return Parse::BBCode->new( {
        'direct_attributes' => 0,
        'linebreaks' => 0,
        'text_processor' => sub{
            my ( $text ) = @_;

            #order matters!
                # 1st - hyperlinks that should be videos
                # 2nd - plaintext urls/videos
                # 3rd - smilies

            #replace video hyperlinks with embed code, or leave untouched
            $text =~ s{$a_match_reg}{
                #we're in a hyperlink element...
                #$2 is the url, $1 is the whole element
                $embedder->url_to_embed( $2 ) || $1;
            }gsex;

            #find plain text urls/vidoes
            $text =~ s{$uri_find_url_reg}{
                my $url = $1;

                if (
                    ( $url !~ m/$href_match_reg/ )
                ){
                    $url =~ s{($uri_reg)}{
                        $url = $1;
                        if (
                            defined Data::Validate::URI::is_web_uri( $url )
                        ){
                            $url =
                                $embedder->url_to_embed( $1 )
                                || sprintf( '<a href="%s" rel="external nofollow">%s</a>', $1, $1 ); #auto escaped
                        }
                        $url;
                    }gsex;
                }

                $url;
            }gsex;

            #smilies
#do it like this or the match fails coz we change the string we're trying to match in some cases, so you end up with edge cases that fail to convert, eg ":) :) :)" will convert the first and the last and leave the middle. this way they're all converted.
            while ($text =~ s{${ $self->_smilies_reg }}{
                my $url = $self->smilies_dir . $self->smilies->{ $2 };
                my $image = sprintf( '<img src="%s" alt="%s" />', $url, $2 );
                "${1}${image}${3}";
            }msex){};

            return $text;
        },
        'tags' => {
            'quote' => {
                'code' => sub {
                    my ($parser, $attr, $content, $attribute_fallback, $tag_tree) = @_;
                    # for some reason, $attr isnt set right :/
                    # but it is now!
                    my $username = $tag_tree->get_attr->[1]->[1] || '';
                    $username =~ s/$quote_reg//g;
                    $content ||= '';

                    return qq|<div class="quote_holder"><span class="quoted_username">${username} wrote:</span><div class="quote">${$content}</div></div>|;
                },
                'class' => 'block',
                'parse' => 1,
            },
            'video' => 'block:%{video}s',
        },
        'escapes' => {
            'video' => sub {
                my ( $parser, $tag, $text ) = @_;

#is $text a html a element?
                my $tree = HTML::TreeBuilder->new(
                    no_expand_entities => 1,
                );
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
