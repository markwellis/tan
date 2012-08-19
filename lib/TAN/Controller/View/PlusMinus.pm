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
        my $created = $c->model('MySQL::PlusMinus')->add(
            $type, $c->stash->{'object_id'}, $c->user->user_id
        );

        my $object = $c->model('MySQL::Object')->find( {
                'object_id' => $c->stash->{'object_id'}
            },{
                'prefetch' => $c->stash->{'type'},
            } );

        $c->trigger_event('object_plusminus', $object);

        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'score' => $object->score,
                'created' => $created,
                'plus' => $object->get_column('plus'),
                'minus' => $object->get_column('minus'),
            }) );
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
