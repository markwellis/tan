package TAN::View::Template::Classic::Index::Picture;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;
    
    my $type = 'picture';
    my $object = $c->stash->{'object'};
    my $object_size = $c->view->filesize_h( $object->picture->size );
    my $md = $object->id - ($object->id % 1000);
    my $url = $object->url;
    my $username = $c->view->html($object->user->username);

    my $output = qq\
        <h2>
            <a class="TAN-type-picture big_font" href="@{[ $c->config->{'pic_path'} ]}/@{[ $object->picture->filename ]}">
                @{[ $c->view->html($object->picture->title) ]}@{[ ($object->nsfw eq 'Y') ? ' - NSFW' : '' ]}
            </a>
        </h2>

        <img alt="${username}" src="@{[ $object->user->avatar($c) ]}" class="TAN-news-avatar left" />
        <ul>
            <li>
                <a href="@{[ $object->user->profile_url ]}" class="TAN-news-user">${username}</a>
            </li>
            <li>
                <a href="${url}#comments">
                    <img src="@{[ $c->config->{'static_path'} ]}/images/comment.png" alt="" class="TAN-news-comment left"/>&nbsp;
                    @{[ $object->get_column('comments') ]}
                </a>
            </li>
            <li>
                @{[ $object->get_column('views') ]} views
            </li>\;

    if ( $c->user_exists 
        && (
            $c->check_any_user_role(qw/edit_object edit_object_nsfw/)
            || ( $c->user->id == $object->user_id )
        ) 
    ){
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
