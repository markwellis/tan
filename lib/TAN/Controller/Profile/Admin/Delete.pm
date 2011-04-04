package TAN::Controller::Profile::Admin::Delete;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        #check we have a reason
        my $reason = $c->req->param('reason');
        my $trim_req = $c->model('CommonRegex')->trim;
        $reason =~ s/$trim_req//;

        if ( !$reason ){
            $c->flash->{'message'} = 'No reason given';
            $c->res->redirect( $c->stash->{'user'}->profile_url . 'admin/delete', 303 );
            $c->detach;
        }
        
        #toggle delete
        $c->stash->{'user'}->update( {
            'deleted' => ( $c->stash->{'user'}->deleted eq 'Y' ) ? 'N' : 'Y',
        } );

        $c->forward('/profile/admin/_force_logout');
#log action - reason
# ^ link to delete reason on profile page?
#send email

        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
    }

    $c->stash->{'template'} = 'Profile::Admin::Delete';
}

__PACKAGE__->meta->make_immutable;
