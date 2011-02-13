package TAN::View::Template::Classic::Submit::Hidden;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $field ) = @_;

    return qq\
        <input 
            type="hidden" 
            name="@{[ $field->{'id'} ]}"
            id="@{[ $field->{'id'} ]}" 
            value="@{[ $c->view->html( $field->{'value'} ) ]}"
        />
        <div id="@{[ $field->{'id'} ]}-advice"></div>\;
}

1;
