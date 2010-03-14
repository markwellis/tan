package Parse::HTML;
use strict;
use warnings;

use HTML::TokeParser;

sub new {
    my $invocant = shift;

    my $class = ref($invocant) || $invocant;
    my $self = { };
    bless($self,$class);

    return $self;
}


sub parse{
    my ( $self, $input_text ) = @_;

    if ( !defined($input_text) ){
    #exit if input text undef
        return undef;
    }

    my $filtered = '';
    my $p = HTML::TokeParser->new( \$input_text );

    while (my $token = $p->get_token) {
        my $token_type = shift @{$token};

        #define these here
        my ( $tag, $attr, $attrseq, $text, $is_data, $token0 );
        if ( $token_type eq 'S'){
        #start tag
            ( $tag, $attr, $attrseq, $text ) = @{$token};
            if ( $tag eq 'a' ){
            #add in rel="nofollow external"
                $attr->{'rel'} = 'nofollow external';

                my @attrs;
                foreach my $attr_key ( keys( %{$attr} ) ){
                #re create attrs for $text
                    push(@attrs, 
                        $attr_key . '="' . $attr->{ $attr_key } . '"'
                    );
                }
                $text = '<' . $tag .'  ' . join(' ', @attrs) . '>';
            }
        } elsif ( $token_type eq 'E'){
        #end tag
            ($tag, $text ) = @{$token};

        } elsif ( $token_type eq 'T'){
        #text
            ( $text, $is_data ) = @{$token};

        } elsif ( $token_type eq 'C'){
        #comment
            ( $text ) = @{$token};

        } elsif ( $token_type eq 'D'){
        #declaration
            ( $text ) = @{$token};

        } elsif ( $token_type eq 'PI'){
        #process instructions
            ( $token0, $text ) = @{$token};
        }

        $filtered .= $text;
    }

    return $filtered;
}

1;
