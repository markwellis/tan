package TAN::Controller::Profile::Admin::DeleteContent;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub delete_content: Chained('../admin') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        if ( $c->check_user_roles('delete_object') ){
            $c->forward('delete_objects');
        }

        if ( $c->check_user_roles('edit_comment') ){
            $c->forward('delete_comments');
        }

#log reason
#send email
        $c->res->redirect( $c->stash->{'user'}->profile_url, 303 );
        $c->detach;
    }

    $c->stash->{'template'} = 'Profile::Admin::DeleteContent';
}

sub delete_objects: Private{
    my ( $self, $c ) = @_;

    my @object_types = $c->req->param('objects');
    if ( scalar( @object_types ) ){
        my $objects_rs = $c->model('MySql::Object')->search( {
            'type' => \@object_types,
            'deleted' => 'N',
            'user_id' => $c->stash->{'user'}->id,
        } );
        
        if ( $objects_rs ){
            $objects_rs->update( {
                'deleted' => 'Y',
            } );

#make this work!
            $c->trigger_event( 'mass_objects_deleted', $objects_rs );
        }
    }
}

sub delete_comments: Private{
    my ( $self, $c ) = @_;

    if ( $c->req->param('comments') ){
        my $comments_rs = $c->model('MySql::Comments')->search( {
            'deleted' => 'N',
            'user_id' => $c->stash->{'user'}->id,
        } );

        if ( $comments_rs ){
            $comments_rs->update( {
                'deleted' => 'Y',
            } );

#make this work!
            $c->trigger_event( 'mass_comments_deleted', $comments_rs );
        }
    }
}

__PACKAGE__->meta->make_immutable;
