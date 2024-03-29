package TAN::Controller::Profile::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {
            'user_index' => 1,
            'comment' => 1,
            'view' => 1,
        };
    },
);

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

    my $user = $c->stash->{'user'};
    my $object;
#prevent race
    eval{
        $c->model('DB')->txn_do(sub{
            $object = $c->model('DB::Object')->find_or_create({
                'user_id' => $user->id,
                'type' => 'profile',
            });
            $object->find_or_create_related('profile',{});
        });
    };

    my %search_opts = (
        'me.deleted' => 0,
    );
    if ( !$c->nsfw ){
        $search_opts{'nsfw'} = 0;
    }

    my $comment_count = $user->comments->search( {
        %search_opts,
        'object.deleted' => 0,
    }, {
        'prefetch' => 'object',
    } )->count || 0;
    
    foreach my $public_object ( @{$c->model('Object')->public} ){
        $c->stash->{"${public_object}_count"} = $user->objects->search({
            'type' => $public_object,
            %search_opts,
        })->count || 0;
    }
    $c->stash(
        'object' => $object,
        'page_title' => $user->username . "'s Profile",
        'template' => 'profile/user.tt',
        'comment_count' => $comment_count,
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
        $c->stash->{'object'} = $c->model('DB::Object')->find({
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
        $c->stash->{'template'} = 'profile/user/edit.tt';
        $c->detach;
    }

    $c->res->redirect("/profile/@{[ $c->stash->{'user'}->username ]}/", 303);
    $c->detach;
}

sub comment: PathPart('comment') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    my $page = $c->req->param('page') || 1;
    my $int_reg = $c->model('CommonRegex')->not_int;
    $page =~ s/$int_reg//g;
    $page ||= 1;

    my %search_opts = (
        'me.deleted' => 0,
        'object.deleted' => 0,
    );
    if ( !$c->nsfw ){
        $search_opts{'nsfw'} = 0;
    }

    my $comments_rs = $c->stash->{'user'}->comments->search( {
        %search_opts,
    }, {
        'prefetch' => ['user', {
            'object' => TAN->model('Object')->public,
        }],
        'page' => $page,
        'rows' => 50,
        'order_by' => {
            '-desc' => 'me.created',
        },
    } );

    my $pager = $comments_rs->pager;
    my @comments = $comments_rs->all;

    if ( !scalar( @comments ) ){
        $c->detach('/default');
    }

    $c->stash(
        'page_title' => $c->stash->{'user'}->username . "'s Comments",
        'index' => $c->model('Index')->indexinate($c, \@comments, $pager),
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub view: PathPart('') Chained('user') Args(1){
    my ( $self, $c, $type ) = @_;

    if ( !$c->model('object')->valid_public_object( $type ) ){
        $c->detach('/default');
    }
    $c->forward('fetch', [$type]);

    $c->stash(
        'template' => 'index.tt',
        'can_rss' => 1,
    );
}

sub fetch: Private{
    my ( $self, $c, $type ) = @_;

    my $page = $c->req->param('page') || 1;
    my $int_reg = $c->model('CommonRegex')->not_int;
    $page =~ s/$int_reg//g;
    $page ||= 1;
    
    my $order = $c->req->param('order') || 'created';

    my ( $objects, $pager ) = $c->stash->{'user'}->objects->index( $type, $page, 1, {}, $order, $c->nsfw, "profile:" . $c->stash->{'user'}->id );

    if ( defined( $objects ) && scalar(@{$objects}) ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'order' => $order,
            'page_title' => $c->stash->{'user'}->username . "'s " . ucfirst($type) . "s",
            'type' => $type,
        );
    }
}

__PACKAGE__->meta->make_immutable;
