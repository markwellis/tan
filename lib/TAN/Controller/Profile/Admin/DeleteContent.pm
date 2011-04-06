package TAN::Controller::Profile::Admin::DeleteContent;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete_content: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        my @objects = $c->req->param('objects');
        if ( scalar( @objects ) ){
            my $objects_rs = $c->model('MySql')->search( {
                'type' => \@objects,
                'deleted' => 'N',
            } );
            
            if ( $objects_rs ){
                $objects_rs->update( {
                    'deleted' => 'Y',
                } );

                #make this work!
                $c->trigger_event( 'mass_objects_deleted', $objects_rs );
            }
        }
#delete comments (check user has right to delete comments!)
#log reason
#send email
#        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->stash->{'template'} = 'Profile::Admin::DeleteContent';
}

__PACKAGE__->meta->make_immutable;
