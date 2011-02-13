package TAN::View::Template::Classic::Submit::Wysiwyg;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $field ) = @_;

    push(@{$c->stash->{'js_includes'}}, 'Submit@Wysiwyg');

    return $c->view->template('Lib::Editor', {
        'name' => $field->{'id'},
        'value' => $field->{'value'},
        'height' => '600px',
        'required' => $field->{'required'},
        'length' => $field->{'length'},        
    });
}

1;
