package TAN::View::Template::Classic::Submit::Tags;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $field ) = @_;

    if ( $c->stash->{'location'} ne 'picture' ){
        push(@{$c->stash->{'js_includes'}}, 'Submit@Tags'); #half done, waiting on js upgrades
    }

    my ( $required, $min_length, $max_length );

    $required = $field->{'required'} && 'required';
    if ( $field->{'length'} ){
        $min_length = $field->{'length'}->{'min'} && 'minLength:' . $field->{'length'}->{'min'};
        $max_length = $field->{'length'}->{'max'} && 'maxLength:' . $field->{'length'}->{'max'};
    }

    my $out = qq\
        <label for="tags">Tags</label>
        <input 
            type="text"
            name="tags"
            id="tags"
            value="@{[ $c->view->html( $field->{'value'} ) ]}"
            class="${required} ${min_length} ${max_length}"
        />\;

    if ( $c->stash->{'location'} ne 'picture' ){
        $out .= '<a href="#" class="refresh_thumbs right">MORE!</a>';
    }

    $out .= qq\
        <br />
        <div id="thumb_tags"></div>\;


    if ( $field->{'value'} ){
        $out .= qq#
            <script type="text/javascript">
                window.addEvent('domready', function(){
                    get_thumbs( \$('picture_id').value );
                } );
            </script>#;
    }

    return $out;
}

1;
