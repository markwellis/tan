package TAN::View::Template::Classic::Lib::RecentComments;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c, $position ) = @_;

    my $order = $c->stash->{'order'};
    print '<ul class="TAN-recent-comments left">';
    if ( defined($c->stash->{'index'}) ){
        print qq\
            <li class="TAN-order-by">
                Order <select>
                    <option value="date" @{[ ($order eq 'date') ? 'selected="selected"' : '' ]}>Date</option>
                    <option value="comments" @{[ ($order eq 'comments') ? 'selected="selected"' : '' ]}>Comments</option>
                    <option value="plus" @{[ ($order eq 'plus') ? 'selected="selected"' : '' ]}>IsNews</option>
                    <option value="minus" @{[ ($order eq 'minus') ? 'selected="selected"' : '' ]}>AintNews</option>
                    <option value="views" @{[ ($order eq 'views') ? 'selected="selected"' : '' ]}>Views</option>
                </select>
            </li>\;
    }

    my $grouped_comments = $c->recent_comments;
    foreach my $object_id ( keys(%{$grouped_comments}) ){
        my $type = $grouped_comments->{$object_id}->[0]->object->type;
        my $title = $c->view->html($grouped_comments->{$object_id}->[0]->object->$type->title);
        if ( $grouped_comments->{$object_id}->[0]->object->nsfw eq 'Y' ){
            $title = "[NSFW] ${title}";
        }
        print qq\
        <li>
            <a href="@{[ $grouped_comments->{$object_id}->[0]->object->url ]}" class="TAN-type-${type}" title="${title}">${title}</a>
            <ul>\;
        foreach my $comment ( @{$grouped_comments->{$object_id}} ){
            my $orig_comment = $c->view->strip_tags($comment->comment);
            if ( $comment->object->nsfw eq 'Y' ){
                $orig_comment = "[NSFW] ${orig_comment}";
            }

            my $short_comment = $c->view->html(substr($orig_comment, 0, 50));
            my $long_comment = substr($orig_comment, 0, 400);

            if ( $short_comment ne $orig_comment ){
                $short_comment = "${short_comment}...";
            }
            if ( $long_comment ne $orig_comment ){
                $long_comment = "${long_comment}...";
            }
            
            my $tip_title = $c->view->html($comment->user->username . "::${long_comment}");
            print qq\
                <li>
                    <a href="@{[ $comment->object->url ]}#comment@{[ $comment->comment_id ]}" title="${tip_title}">${short_comment}</a>
                </li>\;
        }
        print qq\
            </ul>
        </li>\;
    }
    print '<li>';
    $c->view->template('Lib::Ad', 'left');
    print qq\
        </li>
    </ul>\;
}

1;
