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
            <h2>Super serious admin stuff</h2>
            <ul>
                <li>
                    <form action="_admin/delete" method="post">
                        <fieldset>
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
                        </fieldset>
                    </form>
                </li>
                <li>
                    <ul>
                        <li>
                            <form action="_admin/change_username" method="post">
                                <fieldset>
                                    <input type="submit" value="Change username" />
                                </fieldset>
                            </form>
                        </li>
                        <li>
                            <form action="_admin/change_username" method="post">
                                <fieldset>
                                    <input type="submit" value="Remove avatar" />
                                </fieldset>
                            </form>
                        </li>
                        <li>
                            <form action="_admin/change_username" method="post">
                                <fieldset>
                                    <input type="submit" value="Contact" />
                                </fieldset>
                            </form>
                        </li>
                        <li>
                            <form action="_admin/change_username" method="post">
                                <fieldset>
                                    <input type="submit" value="Ban" />
                                </fieldset>
                            </form>
                        </li>
                    </ul>
                </li>
            </ul>
        </div>\;
}

__PACKAGE__->meta->make_immutable;
