package TAN::View::Template::Classic::Profile::Edit;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'Profile');

    return qq\
        <ul class="TAN-inside">
            <li>
                <form action="edit" id="submit_form" method="post">
                    <fieldset>
                        @{[
                            $c->view->template('Lib::Editor', {
                                'name' => "profile",
                                'value' => $c->stash->{'object'}->profile->details_nobb,
                                'height' => '600px',
                            })
                        ]}
                       <br />
                       <input type="submit" value="Submit" />
                   </fieldset>
               </form>
            </li>
        </ul>\;
}

1;
