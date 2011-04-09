package TAN::Controller::Profile::Admin::Delete;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        my $user = $c->stash->{'user'};
        #toggle delete
        my $deleted = ( $user->deleted eq 'Y' ) ? 'N' : 'Y';
        $user->update( {
            'deleted' => $deleted,
        } );

        $c->forward('_force_logout');
        
        $c->model('MySql::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $user->id,
            'action' => 'delete_user',
            'other' => $deleted,
            'reason' => $c->stash->{'reason'},
        } );

# ^ link to delete reason on profile page?
#send email

        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->stash->{'template'} = 'Profile::Admin::Delete';
}

sub _force_logout: Private{
    my ( $self, $c ) = @_;

    my $views_rs = $c->model('MySql::Views')->search( {
        'user_id' => $c->stash->{'user'}->id,
    },{
        'group_by' => 'session_id',
    } );

    foreach my $view ( $views_rs->all ){
        foreach my $key ( ('session','expires') ){
            $c->delete_session_data( "${key}:" . $view->session_id );
        }
    }
}

__PACKAGE__->meta->make_immutable;
