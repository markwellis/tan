package TAN::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index: Private{
    my ( $self, $c ) = @_;

    my $users = $c->model('DB::User')->search({
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
