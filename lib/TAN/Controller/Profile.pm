package TAN::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub clear_index_caches: Event(object_created) Event(object_deleted) Event(comment_created){
    my ( $self, $c, $object ) = @_;

    $c->clear_cached_page('/profile/.*/links');
    $c->clear_cached_page('/profile/.*/blogs');
    $c->clear_cached_page('/profile/.*/pictures');
    $c->clear_cached_page('/profile/.*/polls');
    $c->clear_cached_page('/profile/.*/videos');
}

sub clear_comment_caches: Event(comment_deleted){
    my ( $self, $c, $object ) = @_;

    $c->clear_cached_page('/profile/.*/comments');
}

sub index: Private{
    my ( $self, $c ) = @_;

    $c->cache_page(600);

    my $users = $c->model('MySQL::User')->search({
        'deleted' => 'N',
    },{
        'columns' => [
            'user_id', 
            'username',
        ],
    });

    $c->stash(
        'users' => $users,
        'template' => 'profile.tt', 
        'page_title' => "User List",
    );
}

sub user: PathPart('profile') Chained('/') CaptureArgs(1){
    my ( $self, $c, $username ) = @_;

    my $user = $c->find_user( {
        'username' => $username,
    } );

    if ( !$user ){
        $c->detach('/default');
    }

    $c->stash(
        'user' => $user,
    );
}

sub user_index: PathPart('') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->path !~ m#/$# ){
        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->cache_page(600);

    my $user = $c->stash->{'user'};
    my $object;
#prevent race
    eval{
        $c->model('MySQL')->txn_do(sub{
            $object = $c->model('MySQL::Object')->find_or_create({
                'user_id' => $user->id,
                'type' => 'profile',
            });
            $object->find_or_create_related('profile',{});
        });
    };

    $c->stash(
        'object' => $object,
        'page_title' => $user->username . "'s Profile",
        'template' => 'Profile::User',
    );
}

sub edit: PathPart('edit') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->user_exists 
        && (
            ( $c->stash->{'user'}->id == $c->user->id )
            || $c->check_user_roles(qw/edit_user/)
        )
    ){
        $c->stash->{'object'} = $c->model('MySQL::Object')->find({
            'user_id' => $c->stash->{'user'}->id,
            'type' => 'profile',
        });

        if ( $c->req->method eq 'POST' && defined($c->req->param('profile')) ){
            if ( defined($c->stash->{'object'}) ){
                my $profile = $c->stash->{'object'}->profile;
                
                if ( defined($profile) ){
                    $profile->update({
                        'details' => $c->req->param('profile'),
                    });

                    $c->cache->remove("profile.0:" . $c->stash->{'object'}->id);
                    $c->cache->remove("profile.1:" . $c->stash->{'object'}->id);
                }
            }
            $c->res->redirect('/profile/' . $c->stash->{'user'}->username, 303);
            $c->detach;
        }
        $c->stash->{'template'} = 'Profile::Edit';
        $c->detach;
    }

    $c->res->redirect("/profile/@{[ $c->stash->{'user'}->username ]}/", 303);
    $c->detach;
}

sub comments: PathPart('comments') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page(600);

    my $page = $c->req->param('page') || 1;

    $c->stash->{'comments'} = $c->stash->{'user'}->comments->search({
            'me.deleted' => 'N',
            'object.deleted' => 'N',
        },
        {
            'prefetch' => ['user', {
                'object' => ['link', 'blog', 'picture', 'poll', 'video'],
            }],
            'page' => $page,
            'rows' => 50,
            'order_by' => {
                '-desc' => 'me.created',
            },
        }
    );

    if ( !$c->stash->{'comments'} ) {
        $c->forward('/default');
        $c->detach;
    }

    $c->stash(
        'page_title' => $c->stash->{'user'}->username . "'s Comments",
        'template' => 'Profile::Comments',
    );
}

sub links: PathPart('links') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['link']);

    $c->stash(
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub blogs: PathPart('blogs') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['blog']);

    $c->stash(
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub pictures: PathPart('pictures') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['picture']);

    $c->stash(
        'fancy_picture_index' => 1,
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub polls: PathPart('polls') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['poll']);

    $c->stash(
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub videos: PathPart('videos') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['video']);

    $c->stash(
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub fetch: Private{
    my ( $self, $c, $type ) = @_;

    $c->cache_page(600);

    my $page = $c->req->param('page') || 1;
    my $order = $c->req->param('order') || 'created';

    my ( $objects, $pager ) = $c->stash->{'user'}->objects->index( $type, $page, 1, {}, $order, $c->nsfw, "profile:" . $c->stash->{'user'}->id );

    if ( scalar(@{$objects}) ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'order' => $order,
            'page_title' => $c->stash->{'user'}->username . "'s " . ucfirst($type) . "s",
            'type' => $type,
        );
    } else {
        $c->forward('/default');
        $c->detach;
    }
}

__PACKAGE__->meta->make_immutable;
