package TAN::View::Template::Classic::Profile::Admin::Ban;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'Profile');

    return 
        qq\<ul class="TAN-inside">
            <li class="TAN-profile-user-admin-form">
                <h2>Ban User</h2>
                <form action="ban" method="post">
                    <fieldset>
                        <label for="reason">Reason</label>
                        <input
                            type="text"
                            id="reason"
                            name="reason" 
                            style="width:100%;"
                        />
                        <input type="submit" value="Ban" />
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

__PACKAGE__->meta->make_immutable;
