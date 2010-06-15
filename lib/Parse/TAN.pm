package Parse::TAN;
use strict;
use warnings;

use Parse::BBCode::TAN;
use HTML::StripScripts::Parser;
use Data::Validate::URI qw/ is_uri /;

#initilise these here for performance reasons
my $bbcode = new Parse::BBCode::TAN;

sub new {
    my ( $invocant ) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = {};
    bless($self, $class);

    $self->init();

    return $self;
}

sub init{
    my ( $self ) = @_;

# XSS Parser
    $self->{'hss'} = HTML::StripScripts::Parser->new(
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
    my $context_whitelist = $self->{'hss'}->init_context_whitelist();
    my $attrib_whitelist = $self->{'hss'}->init_attrib_whitelist();
    my $style_whitelist = $self->{'hss'}->init_style_whitelist();
    my $attval_whitelist = $self->{'hss'}->init_attval_whitelist();

#copy and paste from HTML::StripScripts, only with longer urls allowed...
    $attval_whitelist->{'href'} = sub{
        my ( $filter, $tag, $attr_name, $attr_val ) = @_;

        if ( is_uri($attr_val) ){
            return $attr_val;
        }
        return undef;
    };

#allow size to be number or word...
    $style_whitelist->{'font-size'} = 'word';

# set additionally allowed html tag attributes
    $attrib_whitelist->{'a'}->{'title'} = 'text';
    $attrib_whitelist->{'a'}->{'href'} = 'href';
    $attrib_whitelist->{'a'}->{'target'} = 'text';

    $attrib_whitelist->{'img'}->{'title'} = 'text';
    $attrib_whitelist->{'img'}->{'src'} = 'text';

    $attrib_whitelist->{'div'}->{'class'} = 'wordlist';
    $attrib_whitelist->{'div'}->{'style'} = 'style';
    $attrib_whitelist->{'span'}->{'style'} = 'style';

# BBCode
    $self->{'bbcode'} = new Parse::BBCode::TAN;
}


sub parse{
    my ( $self, $input_text, $no_bbcode ) = @_;

    my $output_text;
#strip XSS
    $output_text = $self->{'hss'}->filter_html( $input_text );

    if ( !$no_bbcode ){
    # do bbcode stuff
    # has to be after XSS striping or the embeds will get stripped!
        $output_text = $self->{'bbcode'}->render( $output_text );
    }

    return $output_text;
}

1;
