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
    if ( !$c->stash->{'article'} || ( $type eq 'blog' ) ){
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

    $c->view->template('Lib::PlusMinus');

    print qq\
        <div class="TAN-news-image left">
            <img alt="@{[ $object->$type->picture_id ]}" src="@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->$type->picture_id ]}/100"/>
        </div>
        <h2>
            <a href="@{[ (($is_video && !$c->stash->{'article'}) ? $object_url : $title_url) ]}" 
                @{[ ($is_video && !$c->stash->{'article'}) ? '' : 'rel="external nofollow"' ]} class="TAN-type-${type}" title="${title}">
                @{[ $c->view->html($object->$type->title) ]}@{[ $object->nsfw eq "Y" ? ' - NSFW' : '' ]}
            </a>
        </h2>
        <img alt="@{[ $c->view->html($object->user->username) ]}" src="@{[ $c->stash->{'avatar_http'} ]}?m=@{[ $c->stash->{'avatar_mtime'} || '' ]}" class="TAN-news-avatar left" />
        <ul>
            <li>
                Posted by <a href="/profile/@{[ $c->view->html($object->user->username) ]}/" class="TAN-news-user">
                    @{[ $c->view->html($object->user->username) ]}
                </a>
                @{[ ( $object->promoted ) ? "promoted @{[ $object->promoted ]} ago" : $object->created . ' ago' ]}
                <span class="TAN-type-${type}"> [@{[ $is_video ? "video" : $type ]}]</span>
            </li>
            <li>
                <a href="${comment_url}" class="TAN-news-comment">
                    <img alt="" class="TAN-news-comment-image" src="/static/images/comment.png" /> @{[ $object->get_column('comments') ]}
                </a> | @{[ $object->get_column('views') ]} views
                @{[ ( ($type eq 'link') && (!$is_video) ) ?
                     qq#| @{[ $object->get_column('external') || 0 ]} external views#
                : '' ]}
                @{[ ( ($type eq 'poll') ) ?
                     qq#| @{[ $object->poll->votes || 0 ]} votes#
                : '' ]}
                @{[ ( $type eq 'link' ) ?
                     qq#| @{[ $c->view->domain($object->link->url) ]}#
                : '' ]}
                @{[ ( $c->user_exists && ($c->user->admin || $c->user->id == $object->user_id) ) ?
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
        $self->article($c, $type, $object, $is_video, $url);
    }
}

sub article{
    my ( $self, $c, $type, $object, $is_video, $url ) = @_;

    print qq\<p>
        <span class="TAN-tags">\;

    my $loop = 0;
    foreach my $tag ( $object->tags->all ){
        if ( $loop ) {
            print ', ';
        }
        print qq\<a href="/tag/@{[ $tag->tag ]}">@{[ $tag->tag ]}</a>\;
        ++$loop;
    }

    print '</span>';

    if ( $type eq 'blog' ){
        print '</p>';
    }
    if ( $type eq 'link' ){
        if ( $is_video ){
            print qq\<div class="TAN-video">
                ${is_video}
            </div>\;
        } else {
            print qq\<a class="TAN-view_link TAN-type-link" href="${url}" rel="external nofollow">View Link</a>\;
        }
        print '</p>';
    } elsif ( $type eq 'blog' ){
        print qq\<div class="TAN-blog_wrapper TAN-hr">
            @{[ $object->blog->details ]}
        </div>\;
    } elsif ( $type eq 'poll' ){
        print '</p>';
        if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
            print qq\<form action="_vote" method="get" id="poll_vote_form">
                <fieldset>\;
        }
        print '<ul class="TAN-poll">';
        my $total_votes = $object->poll->votes->count;
        my $loop;
        foreach my $poll_answer ( $object->poll->answers->search({}, {'order_by' => 'answer_id'})->all ){
            my $percent = $poll_answer->percent($total_votes);
            print '<li>';
            if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
                print qq\<label for="answer${loop}">
                    <input type="radio" value="@{[ $poll_answer->id ]}" id="answer${loop}" name="answer_id" />\;
            }
            print $c->view->html($poll_answer->answer);
            print qq\<span class="TAN-poll-percent-holder">
                <span class="TAN-poll-percent" style="width:${percent}%"></span>
                </span>
                <span class="TAN-poll-percent-voted">
                    ${percent}%
                </span>\;
            if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
                print '</label>';
            }
            print '</li>';
            ++$loop;
        }
        print qq\
            <li>
                @{[ $c->stash->{'ends'} ? 'Ends in ' . $c->stash->{'ends'} : "Ended" ]}
            </li>
        </ul>\;
        if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
            print qq\<input type="submit" value="Vote" />
                </fieldset>
                </form>\;
        }
    }
}

1;
