package TAN::View::Template::Classic::View;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'view');
    push(@{$c->stash->{'js_includes'}}, 'comment');

    my $object = $c->stash->{'object'};

    if ( $c->stash->{'location'} eq 'poll' ){
        $c->stash->{'voted'} = ($c->user_exists) ? $object->poll->voted($c->user->id) : undef;
        $c->stash->{'ends'} = $object->poll->ends;

        if ( !$c->stash->{'voted'} && $c->stash->{'ends'} ){
            push(@{$c->stash->{'js_includes'}}, 'poll');
        }
    }

    my $avatar_http = "@{[ $c->config->{'avatar_path'} ]}/@{[ $object->user_id ]}";
    my $avatar_image = "@{[ $c->path_to('root') ]}${avatar_http}";

    if ( -e $avatar_image ){
    #avatar exists
        $c->stash->{'avatar_mtime'} = $c->view->file_mtime($avatar_image);
        $c->stash->{'avatar_http'} = $avatar_http;
    } else {
        $c->stash->{'avatar_http'} = "@{[ $c->config->{'static_path'} ]}/images/_user.png";
    }

    print qq\
    <ul class="TAN-inside">
        <li class="TAN-news">\;

    $c->stash->{'article'} = 1;
    if ( $object->type eq 'picture' ){
        $c->view->template('View::Picture');
    } else {
        $c->view->template('Lib::Object');
    }

    print qq\
        </li>
        <li class="TAN-news" id="comments">\;
    
    $c->view->template('View::Comments');
    print qq\
        </li>
    </ul>\;
}

1;
