package TAN::View::Template::Classic::Profile::Admin::DeleteContent;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'Profile');

    return 
        qq\<ul class="TAN-inside">
            <li class="TAN-profile-user-admin-form">
                <h2>Delete Content</h2>
                <form action="delete_content" method="post">
                    <fieldset>
                        <ul>
                            @{[
                                $c->check_user_roles('edit_comment') ?
                                    qq#<li>
                                        <input type="checkbox" name="comments" value="comments" id="delete_comments" />
                                        <label for="delete_comments">Comments</label>
                                    </li>#
                                : ''
                            ]}
                            @{[
                                #check this works
                                $c->check_user_roles('delete_object') ?
                                    qq#<li>
                                        <input type="checkbox" name="objects" value="link" id="delete_links" />
                                        <label for="delete_links">Links</label>
                                    </li>
                                    <li>
                                        <input type="checkbox" name="objects" value="blog" id="delete_blogs" />
                                        <label for="delete_blogs">Blogs</label>
                                    </li>
                                    <li>
                                        <input type="checkbox" name="objects" value="picture" id="delete_pictures" />
                                        <label for="delete_pictures">Pictures</label>
                                    </li>
                                    <li>
                                        <input type="checkbox" name="objects" value="poll" id="delete_polls" />
                                        <label for="delete_polls">Polls</label>
                                    </li>#
                                :
                                    ''
                            ]}
                        </ul>
                        <label for="reason">Reason</label>
                        <input
                            type="text"
                            id="reason"
                            name="reason" 
                            style="width:100%;"
                        />
                        <input type="submit" value="Delete" />
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

__PACKAGE__->meta->make_immutable;
