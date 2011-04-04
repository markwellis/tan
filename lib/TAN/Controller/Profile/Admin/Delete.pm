package TAN::Controller::Profile::Admin::Delete;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        #toggle delete
        $c->stash->{'user'}->update( {
            'deleted' => ( $c->stash->{'user'}->deleted eq 'Y' ) ? 'N' : 'Y',
        } );

        $c->forward('/profile/admin/_force_logout');
#log action - reason
# ^ link to delete reason on profile page?
#send email

        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->stash->{'template'} = 'Profile::Admin::Delete';
}

__PACKAGE__->meta->make_immutable;
