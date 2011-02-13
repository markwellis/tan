package TAN::View::Template::Classic::Submit::Textarea;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $field ) = @_;

    my ( $required, $min_length, $max_length );

    $required = $field->{'required'} && 'required';
    if ( $field->{'length'} ){
        $min_length = $field->{'length'}->{'min'} && 'minLength:' . $field->{'length'}->{'min'};
        $max_length = $field->{'length'}->{'max'} && 'maxLength:' . $field->{'length'}->{'max'};
    }
    
    return qq\
        <label for="@{[ $field->{'id'} ]}">@{[ ucfirst($field->{'label'}) ]}</label>
        <textarea
            name="@{[ $field->{'id'} ]}"
            id="@{[ $field->{'id'} ]}"
            cols="1"
            rows="5"
            class="${required} ${min_length} ${max_length}"
        >@{[ 
            $c->view->html( $field->{'value'} ) 
        ]}</textarea>\;
}

1;
