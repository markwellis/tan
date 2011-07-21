package TAN::Controller::Profile::Admin::DeleteAvatar;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete_avatar: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    my $user = $c->stash->{'user'};

    if ( $c->req->method eq 'POST' ){
        my @outfile_path = split('/', "root/@{[ $c->config->{'avatar_path'} ]}/@{[ $user->id ]}");
        my $outfile = $c->path_to( @outfile_path );

        if ( -e $outfile ){
            unlink( $outfile );
        }

        $c->model('MySql::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $user->id,
            'action' => 'delete_avatar',
            'reason' => $c->stash->{'reason'},
        } );
#send email

        $c->res->redirect( $user->profile_url, 303 );
        $c->detach;
    }

    $c->stash(
        'template' => 'profile/admin/delete_avatar.tt',
        'page_title' => 'Delete Avatar',
    );  
}

__PACKAGE__->meta->make_immutable;
