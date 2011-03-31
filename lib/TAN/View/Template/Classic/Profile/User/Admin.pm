package TAN::View::Template::Classic::Profile::User::Admin;
use Moose;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

#role checkings
    push(@{$c->stash->{'js_includes'}}, 'profile@Admin');

    return qq\
        <form action="admin" class="TAN-profile-user-admin-form" method="post">
            <fieldset>
                <h2>Super serious admin stuff</h2>
                <ul>
                    <li>
                        <ul>
                            <li>
                                <input type="checkbox" name="delete" value="comments" id="delete_comments" />
                                <label for="delete_comments">Comments</label>
                            </li>
                            <li>
                                <input type="checkbox" name="delete" value="links" id="delete_links" />
                                <label for="delete_links">Links</label>
                            </li>
                            <li>
                                <input type="checkbox" name="delete" value="blogs" id="delete_blogs" />
                                <label for="delete_blogs">Blogs</label>
                            </li>
                            <li>
                                <input type="checkbox" name="delete" value="pictures" id="delete_pictures" />
                                <label for="delete_pictures">Pictures</label>
                            </li>
                            <li>
                                <input type="checkbox" name="delete" value="polls" id="delete_polls" />
                                <label for="delete_polls">Polls</label>
                            </li>
                            <li>
                                <input type="submit" value="Delete All" />
                            </li>
                        </ul>
                    </li>
                    <li>
                        <ul>
                            <li>
                                <input type="text" name="username" value="@{[ $c->view->html( $c->stash->{'user'}->username ) ]}" />
                            </li>
                            <li>
                                <input type="submit" name="update_username" value="Change username" />
                            </li>
                            <li>
                                <input type="submit" name="ban" value="Ban" />
                            </li>
                            <li>
                                <input type="submit" name="remove_avatar" value="Remove avatar" />
                            </li>
                        </ul>
                    </li>
                </ul>
            </fieldset>
        </form>\;
}

__PACKAGE__->meta->make_immutable;
