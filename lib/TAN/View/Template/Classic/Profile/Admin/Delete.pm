package TAN::View::Template::Classic::Profile::Admin::Delete;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'Profile');

    my $deleted = ( $c->stash->{'user'}->deleted eq 'Y' ) ? 1 : 0;
    return 
        qq\<ul class="TAN-inside">
            <li class="TAN-profile-user-admin-form">
                <h2>@{[ $deleted ? 'Undelete' : 'Delete' ]} User</h2>
                <form action="delete" method="post">
                    <fieldset>
                        <label for="reason">Reason</label>
                        <input
                            type="text"
                            id="reason"
                            name="reason" 
                            style="width:100%;"
                        />
                        <input type="submit" value="@{[ $deleted ? 'Undelete' : 'Delete' ]}" />
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

__PACKAGE__->meta->make_immutable;
