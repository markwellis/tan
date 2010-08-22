package TAN::View::Template::Classic::Index::Picture;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;
    
    my $type = 'picture';
    my $object = $c->stash->{'object'};
    my $object_size = $c->filesize_h( $object->picture->size );
    my $md = $object->id - ($object->id % 1000);
    my $url = $object->url;

    my $output = qq\
        <h2>
            <a class="TAN-type-picture big_font" href="@{[ $c->config->{'pic_path'} ]}/@{[ $object->picture->filename ]}">
                @{[ $c->view->html($object->picture->title) ]}@{[ ($object->nsfw eq 'Y') ? ' - NSFW' : '' ]}
            </a>
        </h2>

        <img alt="@{[ $c->view->html($object->user->username) ]}" 
            src="@{[ $c->stash->{'avatar_http'} ]}?m=@{[ $c->stash->{'avatar_mtime'} ? $c->stash->{'avatar_mtime'} : '' ]}" 
            class="TAN-news-avatar left"
        />
        <ul>
            <li>
                <a href="/profile/@{[ $c->view->html($object->user->username) ]}/" class="TAN-news-user">@{[ $c->view->html($object->user->username) ]}</a>
            </li>
            <li>
                <a href="${url}#comments">
                    <img src="@{[ $c->config->{'static_path'} ]}/images/comment.png" alt="" class="TAN-news-comment left"/>
                    @{[ $object->get_column('comments') ]}
                </a>
            </li>
            <li>
                @{[ $object->get_column('views') ]} views
            </li>\;

    if ( $c->user_exists && ($c->user->admin || ($c->user->id == $object->user_id)) ){
        $output .= qq\
            <li>
                <a href="/submit/@{[ $object->type ]}/edit/@{[ $object->id ]}/" class="TAN-news-comment">Edit</a>
            </li>\;
    }

    $output .= qq\
            <li class="TAN-menu-last">
                @{[ $object->picture->x ]}x@{[ $object->picture->y ]}
            </li>
        </ul>
        <div>\;

    $output .= qq\
            @{[ $c->view->template('Lib::PlusMinus') ]}
            <a class="left" href="${url}">
                <img src="@{[ $c->config->{'thumb_path'} ]}/${md}/@{[ $object->picture->id ]}/160" alt=" "/>
            </a>
        </div>\;

    return $output;
}

1;
