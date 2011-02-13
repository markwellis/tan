package TAN::View::Template::Classic::Submit::Array;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $field ) = @_;
    
    push(@{$c->stash->{'js_includes'}}, 'Submit@Array');

    my $out;
    my $loop = 0;

    my @answers;
    if ( $field->{'value'} ){
        if ( ref( $field->{'value'} ) eq 'DBIx::Class::ResultSet' ){
        #object
            foreach my $answer ( $field->{'value'}->all ){
                push( @answers, $answer->answer );
            }
        } elsif( ref( $field->{'value'} ) eq 'ARRAY' ){
        #array
            @answers = @{$field->{'value'}};
        }
        
    } else {
        @answers = ( undef, undef );
    }
    foreach my $answer ( @answers ){
        $out .= qq\
            <li>
                <label for="array-${loop}">@{[ ucfirst($field->{'label'}) ]} ${loop}</label>
                <input
                    type="text" 
                    name="@{[ $field->{'id'} ]}"
                    id="array-${loop}" 
                    value="@{[ $c->view->html( $answer ) ]}"
                    class="TAN-array"
                />
            </li>\;
        ++$loop;
    }

    return qq\
        ${out}
        <li>
            <a href="#" class="right TAN-array-more">MORE!</a>
        </li>\;
}

1;
