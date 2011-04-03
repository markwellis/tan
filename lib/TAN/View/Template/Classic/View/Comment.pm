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
                    <a href="@{[ $comment->user->profile_url ]}" class="TAN-news-user">@{[ $c->view->html($comment->user->username) ]}</a>
                </li>\;

    if ( $comment->created ){
        $out .= qq\
                <li>
                    @{[ $comment->created ]}&#160;ago
                </li>\;
    }

    $out .= qq\
                <li>
                    <img class="TAN-news-avatar TAN-comment_avatar" src="@{[ $comment->user->avatar($c) ]}" alt="@{[ $c->view->html($comment->user->username) ]}" />
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
    
    if ( ($c->user_exists) 
        && ( 
            $c->check_user_roles(qw/edit_comment/)
            || ( $c->user->id == $comment->user->user_id )
        ) 
    ){
        $out .= qq\
                    <li>
                        <a class="comment_edit" href="@{[ $comment->object->url ]}/../_edit_comment/@{[ $comment->id ]}">Edit Comment</a>
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
