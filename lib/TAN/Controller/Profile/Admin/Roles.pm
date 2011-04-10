package TAN::Controller::Profile::Admin::Roles;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub roles: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
#update $c->stash->{'user'} roles here
        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    my $roles = $c->model('MySql::Admin')->search;
    $c->stash(
        'template' => 'Profile::Admin::Roles',
        'roles' => $roles,
    );
}

__PACKAGE__->meta->make_immutable;
