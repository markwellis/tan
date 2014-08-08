package TAN::Controller::View::PlusMinus;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;

sub plus: PathPart('_plus') Chained('../type') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('add_plus_minus', ['plus']);
}

sub minus: PathPart('_minus') Chained('../type') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('add_plus_minus', ['minus']);
}

sub add_plus_minus: Private{
    my ( $self, $c, $type ) = @_;

    if ( $c->user_exists ){
    # valid user, do work
        my $object = $c->stash->{object};
        my $created = $object->add_plus_minus( $type, $c->user->id );

        $c->trigger_event('object_plusminus', $object);

        if ( defined($c->req->param('json')) ){
            $c->stash(
                json_data   => {
                    score       => $object->score,
                    created     => $created,
                    plus        => $object->plus,
                    minus       => $object->minus,
                },
                current_view    => 'JSON',
            );
        } else {
        #redirect
            $c->res->redirect( defined($c->req->referer) ? $c->req->referer : $object->url , 303 );
        }
    } else {
    #prompt for login
        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'login' => 1,
            }) );
        } else {
        #redirect
            $c->res->redirect( '/login/', 303 );
        }
    }
    $c->detach();
}

__PACKAGE__->meta->make_immutable;
