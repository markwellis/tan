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
        'deleted' => 0,
    },{
        'columns' => [
            'user_id', 
            'username',
            'avatar',
        ],
    });

    $c->stash(
        'users' => $users,
        'template' => 'profile.tt', 
        'page_title' => "User List",
    );
}

__PACKAGE__->meta->make_immutable;
