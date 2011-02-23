package TAN::View::Template::Classic::View::Picture;
use Moose;

extends 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};
    my $object_size = $c->view->filesize_h($object->picture->size);
    my $md = $object->id - ($object->id % 1000);

    my $filename = "@{[$c->config->{'pic_path'} ]}/@{[ $object->picture->filename ]}";
    my $type = 'picture';

    my $out = qq\
        <h2 style="margin-left:0px;">
            <a class="TAN-type-picture" href="${filename}">
                @{[ $c->view->html($object->picture->title) ]}@{[ ($object->nsfw eq 'Y') ? ' - NSFW' : '' ]}
            </a>
        </h2>\;

    $out .= $c->view->template('Lib::PlusMinus');
    $out .= qq\
        <img alt="@{[ $c->view->html($object->user->username) ]}" src="@{[ $object->user->avatar($c) ]}" class="TAN-news-avatar left" />
        <ul>
            <li>
                Posted by <a href="/profile/@{[ $c->view->html($object->user->username) ]}/" class="TAN-news-user">@{[ $c->view->html($object->user->username) ]}</a>
                @{[
                    ($object->promoted) ? 
                        qq#promoted @{[ $object->promoted ]} ago#
                    : 
                        qq#@{[ $object->created ]} ago#
                ]}
                <span class="TAN-type-picture"> [picture]</span>
            </li>
            <li>
                <a href="@{[ $c->stash->{'comment_url'} ]}#comments" class="TAN-news-comment">
                    <img alt="" class="TAN-news-comment-image" src="/static/images/comment.png" />
                    @{[ $object->get_column('comments') ]}
                </a>
                | @{[ $object->get_column('views') ]} views
                | @{[ $object->picture->x ]}x@{[ $object->picture->y ]}
                | @{[ $object_size ]}\;

    if ( $c->user_exists && ($c->user->admin || $c->user->id == $object->user_id) ){
        $out .= qq\
                | <a href="/submit/@{[ $object->type ]}/edit/@{[ $object->id ]}/" class="TAN-news-comment">Edit</a>\;
    }
    $out .= qq\
            </li>
        </ul>
        <span class="TAN-tags" style="margin-left:0px">\;

    my $loop = 0;
    foreach my $tag ( $object->tags->all ){
        if ( $loop ){
            $out .= ', ';
        }
        $out .= qq\<a href="/tag/@{[ $tag->tag ]}">@{[ $tag->tag ]}</a>\;
        ++$loop;
    }
    $out .= qq\
        </span>

    <div class="TAN-video">
        <a class="big_center_cell" href="${filename}">
            <img class='big_picture' src="@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->picture->id ]}/600" alt=" "/>
        </a>
    </div>\;

    my $description = $object->picture->description;

    if ( defined($description) ){
        $out .= $c->view->nl2br($c->view->html($description));
    }

    return $out;
}

__PACKAGE__->meta->make_immutable;
