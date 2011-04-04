package TAN::Controller::Profile::Admin::DeleteContent;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete_content: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
#delete content
#trigger mass delete event for object/comments
#log reason
#send email
        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->stash->{'template'} = 'Profile::Admin::DeleteContent';
}

__PACKAGE__->meta->make_immutable;
