package TAN::View::Template::Classic::Lib::Object;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};
    my $type = $object->type;

    my $title = $object->url_title;
    my $object_url = $object->url;
    my $is_video = 0;

    if ( $type eq 'link' ){
        $is_video = $c->view->is_video($object->link->url);
        if ( $is_video ){
            $is_video = $c->view->embed_url($object->link->url);
        }
    }

    my $url;
    my $title_url;
    if ( !$c->stash->{'article'} || ( $type eq 'blog' ) || ( $type eq 'poll' ) ){
        $url = $object_url;
        if ( $type eq 'link' ){
            $title_url = '/redirect/external/' . $object->id;
        } else {
            $title_url = $url;
        }
    } else {
        $url = '/redirect/external/' . $object->id;
        $title_url = $url;
    }

    my $comment_url = "${object_url}#comments";

    my $num = $c->stash->{'num'} || 0;
    
    ++$num;
    my $md = $object->$type->picture_id - ($object->$type->picture_id % 1000);

    my $out = $c->view->template('Lib::PlusMinus');

    $out .= qq\
        <div class="TAN-news-image left">
            <a href="@{[ $object->type eq 'picture' ? $object->url : $object->$type->picture->object->url ]}/">
                <img 
                    alt="@{[ $object->$type->picture_id ]}" 
                    src="@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->$type->picture_id ]}/100"
                />
            </a>
        </div>
        <h2>
            <a href="@{[ (($is_video && !$c->stash->{'article'}) ? $object_url : $title_url) ]}" 
                @{[ ($is_video && !$c->stash->{'article'}) ? '' : 'rel="external nofollow"' ]} class="TAN-type-${type}" title="${title}">
                @{[ $c->view->html($object->$type->title) ]}@{[ $object->nsfw eq "Y" ? ' - NSFW' : '' ]}
            </a>
        </h2>
        <img alt="@{[ $c->view->html($object->user->username) ]}" src="@{[ $object->user->avatar($c) ]}" class="TAN-news-avatar left" />
        <ul>
            <li>
                Posted by <a href="@{[ $object->user->profile_url ]}" class="TAN-news-user">
                    @{[ $c->view->html($object->user->username) ]}
                </a>
                @{[ ( $object->promoted ) ? "promoted @{[ $object->promoted ]} ago" : $object->created . ' ago' ]}
                <span class="TAN-type-${type}"> [@{[ $is_video ? "video" : $type ]}]</span>
            </li>
            <li>
                <a href="${comment_url}" class="TAN-news-comment">
                    <img alt="" class="TAN-news-comment-image" src="/static/images/comment.png" /> @{[ $object->get_column('comments') ]}
                </a> | @{[ $object->get_column('views') ]} views
                @{[ ( ($type eq 'poll') ) ?
                     qq#| @{[ $object->poll->votes || 0 ]} votes#
                : '' ]}
                @{[ ( $type eq 'link' ) ?
                     qq#| @{[ $c->view->domain($object->link->url) ]}#
                : '' ]}
                @{[ ( $c->user_exists 
                    && (
                        $c->check_any_user_role(qw/edit_object edit_object_nsfw/)
                        || ( $c->user->id == $object->user_id ) 
                        )
                    ) ?
                    qq#| <a href="/submit/${type}/edit/@{[ $object->id ]}/" class="TAN-news-comment">
                        Edit
                    </a>#
                : '' ]}
            </li>
        </ul>
        <p>
            @{[ $c->view->nl2br($c->view->html($object->$type->description)) ]}
        </p>\;

    if ( $c->stash->{'article'} ){
        $out .= $self->article($c, $type, $object, $is_video, $url);
    }

    return $out;
}

sub article{
    my ( $self, $c, $type, $object, $is_video, $url ) = @_;

    my $out = qq\<p>
        <span class="TAN-tags">\;

    my $loop = 0;
    foreach my $tag ( $object->tags->all ){
        if ( $loop ) {
            $out .= ', ';
        }
        $out .= qq\<a href="/tag/@{[ $tag->tag ]}">@{[ $tag->tag ]}</a>\;
        ++$loop;
    }

    $out .= '</span>';

    if ( $type eq 'blog' ){
        $out .= '</p>';
    }
    if ( $type eq 'link' ){
        if ( $is_video ){
            $out .= qq\<div class="TAN-video">
                ${is_video}
            </div>\;
        } else {
            $out .= qq\<a class="TAN-view_link TAN-type-link" href="${url}" rel="external nofollow">View Link</a>\;
        }
        $out .= '</p>';
    } elsif ( $type eq 'blog' ){
        $out .= qq\<div class="TAN-blog_wrapper TAN-hr">
            @{[ $object->blog->details ]}
        </div>\;
    } elsif ( $type eq 'poll' ){
        $out .= '</p>';
        if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
            $out .= qq\<form action="_vote" method="get" id="poll_vote_form">
                <fieldset>\;
        }
        $out .= '<ul class="TAN-poll">';
        my $total_votes = $object->poll->votes->count;
        my $loop;
        foreach my $poll_answer ( $object->poll->answers->search({}, {'order_by' => 'answer_id'})->all ){
            my $percent = $poll_answer->percent($total_votes);
            $out .= '<li>';
            if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
                $out .= qq\<label for="answer${loop}">
                    <input type="radio" value="@{[ $poll_answer->id ]}" id="answer${loop}" name="answer_id" />\;
            }
            $out .= $c->view->html($poll_answer->answer);
            $out .= qq\<span class="TAN-poll-percent-holder">
                <span class="TAN-poll-percent" style="width:${percent}%"></span>
                </span>
                <span class="TAN-poll-percent-voted">
                    ${percent}%
                </span>\;
            if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
                $out .= '</label>';
            }
            $out .= '</li>';
            ++$loop;
        }
        $out .= qq\
            <li>
                @{[ $c->stash->{'ends'} ? 'Ends in ' . $c->stash->{'ends'} : "Ended" ]}
            </li>
        </ul>\;
        if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
            $out .= qq\<input type="submit" value="Vote" />
                </fieldset>
                </form>\;
        }
    }

    return $out;
}

1;
