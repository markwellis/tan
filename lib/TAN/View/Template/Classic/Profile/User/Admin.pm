package TAN::View::Template::Classic::Profile::User::Admin;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

#role checkings
    push(@{$c->stash->{'js_includes'}}, 'profile@Admin');

    return qq\
        <div class="TAN-profile-user-admin-form">
            <h2>Admin</h2>
            <ul>
                <li>
                    <a href="admin/change_username">Change Username</a>
                </li>
                <li>
                    <a href="admin/remove_content">Remove Content</a>
                </li>
                <li>
                    <a href="admin/remove_avatar">Remove Avatar</a>
                </li>
                <li>
                    <a href="admin/contact">Contact</a>
                </li>
                <li>
                    @{[ ( $c->stash->{'user'}->deleted eq 'N' ) 
                        ? 
                            qq#<a href="admin/ban">Ban</a>#
                        : 
                            qq#<a href="admin/unban">Unban</a>#
                   ]}                        
                </li>
            </ul>
        </div>\;
}

__PACKAGE__->meta->make_immutable;
