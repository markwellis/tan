package TAN::Controller::Profile::Admin::DeleteUser;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {
            'delete_user' => 1,
        };
    },
);

sub delete_user: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        my $user = $c->stash->{'user'};
        #toggle delete
        my $deleted = ( $user->deleted ) ? 0 : 1;
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

    $c->stash(
        'template' => 'profile/user/admin/delete_user.tt',
        'page_title' => 'Delete User',
    );
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
