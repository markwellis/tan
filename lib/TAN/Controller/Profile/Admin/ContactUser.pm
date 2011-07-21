package TAN::Controller::Profile::Admin::ContactUser;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub contact_user: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        my $user = $c->stash->{'user'};

#email user here... $c->stash->{'message'}
        $c->model('MySql::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $user->id,
            'action' => 'contact_user',
            'reason' => $c->stash->{'reason'},
        } );

        $c->res->redirect( $user->profile_url, 303 );
        $c->detach;
    }

    $c->stash(
        'template' => 'profile/user/admin/contact_user.tt',
        'page_title' => 'Contact User',
    );
}

__PACKAGE__->meta->make_immutable;
