package TAN::Controller::Profile::Admin::DeleteAvatar;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete_avatar: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
#log reason
#send email
        my @outfile_path = split('/', "root/@{[ $c->config->{'avatar_path'} ]}/@{[ $c->stash->{'user'}->id ]}");
        my $outfile = $c->path_to( @outfile_path );

        if ( -e $outfile ){
            unlink( $outfile );
        }

        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
    }

    $c->stash->{'template'} = 'Profile::Admin::DeleteAvatar';
}

__PACKAGE__->meta->make_immutable;
