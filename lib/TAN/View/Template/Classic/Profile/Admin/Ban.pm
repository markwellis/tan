package TAN::View::Template::Classic::Profile::Admin::Ban;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'profile');

    return 
        qq\<ul class="TAN-inside">
            <li>
                <h2>Ban User</h2>
                <form action="." method="post">
                    <fieldset>
                        <textarea 
                            class="required minLength:3 maxLength:1000" 
                            rows="5" 
                            cols="1" 
                            name="reason" 
                            style="width: 100%;"
                        >
                        </textarea>
                        <input type="submit" value="Ban" />
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

__PACKAGE__->meta->make_immutable;
