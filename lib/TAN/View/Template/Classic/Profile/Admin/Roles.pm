package TAN::View::Template::Classic::Profile::Admin::Roles;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'Profile');

    my $user = $c->stash->{'user'};

    my $out = 
        qq\<ul class="TAN-inside">
            <li class="TAN-profile-user-admin-form">
                <h2>Edit user roles</h2>
                <form action="roles" method="post">
                    <fieldset>
                        <ul>\;

    foreach my $role ( $c->stash->{'roles'}->all ){
        $out .= qq\
            <li>
                <input 
                    type="checkbox" 
                    name="roles" 
                    value="@{[ $role->role ]}" 
                    id="role_@{[ $role->id ]}"
                    @{[
                        $c->check_user_roles( $user, $role->role) ?
                            'checked="checked"'
                        :
                            ''
                    ]}
                />
                <label for="role_@{[ $role->id ]}">@{[ $role->role ]}</label>
            </li>
            \;
    }
    $out .= 
                        qq\</ul>
                        <label for="reason">Reason</label>
                        <input
                            type="text"
                            id="reason"
                            name="reason" 
                            style="width:100%;"
                        />
                        <input type="submit" value="Edit" />
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

__PACKAGE__->meta->make_immutable;
