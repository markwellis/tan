package TAN::View::Template::Classic::Profile::User::Admin;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

#role checkings
    return qq\
        <div class="TAN-profile-user-admin-form">
            <h2>Admin</h2>
            <ul>
                <li>
                    <a href="admin/change_username">Change Username</a>
                </li>
                <li>
                    <a href="admin/delete_content">Delete Content</a>
                </li>
                <li>
                    <a href="admin/delete_avatar">Delete Avatar</a>
                </li>
                <li>
                    <a href="admin/contact">Contact</a>
                </li>
                @{[
                    $c->check_user_roles(qw/delete_user/) ?
                        qq#<li>
                            <a href="admin/delete">
                                @{[ ( $c->stash->{'user'}->deleted eq 'N' ) ? 'Delete' : 'Undelete' ]}
                            </a>
                        </li>#
                    :
                        ''
                ]}
            </ul>
        </div>\;
}

__PACKAGE__->meta->make_immutable;
