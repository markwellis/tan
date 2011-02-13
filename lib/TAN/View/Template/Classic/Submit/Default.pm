package TAN::View::Template::Classic::Submit::Default;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $field ) = @_;

    my ( $required, $min_length, $max_length, $other );

    $required = $field->{'required'} && 'required';
    if ( $field->{'length'} ){
        $min_length = $field->{'length'}->{'min'} && 'minLength:' . $field->{'length'}->{'min'};
        $max_length = $field->{'length'}->{'max'} && 'maxLength:' . $field->{'length'}->{'max'};
    }

    if ( $field->{'id'} eq 'url' ){
        $other = "validate-url";
    }
    
    return qq\
        <label for="@{[ $field->{'id'} ]}">@{[ ucfirst($field->{'label'}) ]}</label>
        <input 
            type="@{[ $c->view->html( $field->{'type'} ) ]}" 
            name="@{[ $field->{'id'} ]}"
            id="@{[ $field->{'id'} ]}" 
            value="@{[ $c->view->html( $field->{'value'} ) ]}"
            class="${required} ${min_length} ${max_length} ${other}"
            @{[ $field->{'disabled'} ? 'disabled="disabled"' : '' ]}
        />\;
}

1;
