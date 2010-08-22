package TAN::View::Template::Classic::View::Comment;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $comment ) = @_;

    #ajax comment
    $comment ||= $c->stash->{'comment'};

    my $out =  qq\
        <div class="TAN-comment_holder TAN-hr" id="comment@{[ $comment->id ]}">
            <ul class="left">
                <li>
                    <a href="/profile/@{[ $c->view->html($comment->user->username) ]}/" class="TAN-news-user">@{[ $c->view->html($comment->user->username) ]}</a>
                </li>\;

    if ( $comment->created ){
        $out .= qq\
                <li>
                    @{[ $comment->created ]}&#160;ago
                </li>\;
    }

    my $avatar_http = "@{[ $c->config->{'avatar_path'} ]}/@{[ $comment->user_id ]}";
    my $avatar_image = "@{[ $c->path_to('root') ]}${avatar_http}";
    my $avatar_mtime;

    if ( -e $avatar_image ){
    #avatar exists
        $avatar_mtime = $c->view->file_mtime($avatar_image);
    } else {
        $avatar_http = "@{[ $c->config->{'static_path'} ]}/images/_user.png";
    }

    $out .= qq\
                <li>
                    <img class="TAN-news-avatar TAN-comment_avatar" src="${avatar_http}?m=${avatar_mtime}" alt="@{[ $c->view->html($comment->user->username) ]}" />
                </li>
                <li>
                    Comment #@{[ $comment->number || 1 ]}
                </li>
                <li>
                    <ul class="TAN-comment_tools">
                        <li>
                            <a href="@{[ $comment->object->url ]}#comment@{[ $comment->id ]}">Link</a>
                            |
                            <a href="" class="quote_link" title="@{[ $c->view->html($comment->user->username) ]}::@{[ $comment->id ]}">Quote</a>
                        </li>\;
    
    if ( ($c->user_exists) && ( $c->user->id == $comment->user->user_id ) ){
        $out .= qq\
                    <li>
                        <a class="comment_edit" href="_edit_comment/@{[ $comment->id ]}">Edit Comment</a>
                    </li>\;
    }

    $out .= qq\
                    </ul>
                </li>
            </ul>
            <div class="TAN-comment_inner">
                @{[ $comment->comment ]}
                <br />
            </div>
        </div>\;

    return $out;
}

1;
