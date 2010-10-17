package TAN::View::Template::Classic::Profile::User;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my %search_opts;
    my $user = $c->stash->{'user'};
    if ( !$c->nsfw ){
        %search_opts = (
            'nsfw' => 'N',
        );
    }

    my $comment_count = $user->comments->count || 0;
    my $link_count = $user->objects->search({
            'type' => 'link',
            %search_opts,
        })->count || 0;

    my $blog_count = $user->objects->search({
            'type' => 'blog',
            %search_opts,
        })->count || 0;

    my $pic_count = $user->objects->search({
            'type' => 'picture',
            %search_opts,
        })->count || 0;

    my $poll_count = $user->objects->search({
            'type' => 'poll',
            %search_opts,
        })->count || 0;

    push(@{$c->stash->{'css_includes'}}, 'profile');

    my $avatar_http = "@{[ $c->config->{'avatar_path'} ]}/@{[ $user->user_id ]}";
    my $avatar_image = "@{[ $c->path_to('root') ]}${avatar_http}";
    my $avatar_mtime;

    if ( -e $avatar_image ){
    #avatar exists
        $avatar_mtime = $c->view->file_mtime($avatar_image);
    } else {
        $avatar_http = "@{[ $c->config->{'static_path'} ]}/images/_user.png";
    }

    return qq\
        <ul class="TAN-inside">
            <li>
                <h1>@{[ $c->view->html($user->username) ]}</h1>
            </li>
            <li>
                <ul class="TAN-id-card">
                    <li>
                        <img class="TAN-news-avatar" src="${avatar_http}?m=${avatar_mtime}" alt="@{[ $c->view->html($user->username) ]}" />
                        <br />
                        <br />
                        @{[
                            ( $c->user_exists && ($c->user->username eq $user->username) ) ?
                                qq'<a href="/profile/_avatar/">Change Avatar</a>'
                            :
                                ''
                        ]}
                    </li>
                    <li>
                        <ul>
                            <li>Joined on: @{[ $c->view->html($user->join_date) ]}</li>
                            <li>
                                @{[ $comment_count ? '<a href="comments">' : '' ]}
                                    Comments: ${comment_count}
                                @{[ $comment_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $link_count ? '<a href="links">' : '' ]}
                                    Links: ${link_count}
                                @{[ $link_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $blog_count ? '<a href="blogs">' : '' ]}
                                    Blogs: ${blog_count}
                                @{[ $blog_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $pic_count ? '<a href="pictures">' : '' ]}
                                    Pictures: ${pic_count}
                                @{[ $pic_count ? '</a>' : '' ]}
                            </li>
                            <li>
                                @{[ $poll_count ? '<a href="polls">' : '' ]}
                                    Polls: ${poll_count}
                                @{[ $poll_count ? '</a>' : '' ]}
                            </li>
                        </ul>
                    </li>
                </ul>
            </li>
            <li>
                @{[ $c->stash->{'object'}->profile->details ]}
                <br />
                @{[
                    ( $c->user_exists && ($c->user->username eq $user->username) ) ?
                        qq'<a href="/profile/@{[ $c->view->html($c->user->username) ]}/edit">Edit</a>'
                    :
                        ''
                ]}
            </li>
        </ul>\;
}

1;
