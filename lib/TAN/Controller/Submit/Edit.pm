package TAN::Controller::Submit::Edit;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub validate_user: PathPart('edit') Chained('../type') CaptureArgs(1){
    my ( $self, $c, $object_id ) = @_;

    my $object = $c->model('MySQL::Object')->get( $object_id, $c->stash->{'type'} );

    if ( 
        !defined($object)
        || (
            !$c->check_any_user_role(qw/edit_object edit_object_nsfw/) 
            && ( $c->user->id != $object->user_id )
        )
    ){
        $c->detach('/access_denied');
    }

    $c->stash(
        'object' => $object,
        'edit' => 1,
    );
}

sub index: PathPart('') Chained('validate_user') Args(){
    my ( $self, $c ) = @_;

    my $type = $c->stash->{'type'};
    $c->stash(
        'template' => 'submit.tt',
        'page_title' => 'Edit ' . ($c->stash->{'object'}->$type->title || ''),
    );
}

sub post: PathPart('post') Chained('validate_user') Args(){
    my ( $self, $c ) = @_;

    my $object = $c->stash->{'object'};
    my $redirect_url;
    if ( 
        defined( $c->req->param('delete') )
        && ( $c->req->param('delete') eq 'Delete' ) 
        && $c->check_user_roles(qw/delete_object/)
    ){
        $c->model('MySql::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $object->user_id,
            'action' => 'delete_object',
            'reason' => $c->req->param('_edit-reason') || ' ',
            'object_id' => $object->id,
        } );

        $object->update( {
            'deleted' => 'Y',
        } );
        $c->trigger_event( 'object_deleted', $object );

        $redirect_url = "/index/all/0/";
    } else {
        my $prepared = $c->forward('/submit/validate_and_prepare');

        $c->model('MySQL')->txn_do( sub {
            $c->forward( 'update_object', [ $prepared ] );

            $c->trigger_event( 'object_updated', $object );
        } );

        $redirect_url = $object->url;
    }

    $c->flash->{'message'} = 'Edit complete';
    $c->res->redirect( $redirect_url, 303 );

    $c->detach();
}

sub update_object: Private{
    my ( $self, $c, $prepared ) = @_;

    delete( $prepared->{'type'} ); #don't need this on edit, can't turn a link into a video or vice versa, so disregard it
    my $type = $c->stash->{'type'};
    my $tags = delete( $prepared->{'tags'} );

    my $to_update = {};

    my $object = $c->stash->{'object'};
    my $new_nsfw = defined( $c->req->param('nsfw') ) ? 'Y' : 'N';

    if ( $object->nsfw ne $new_nsfw ){
        $object->update( {
            'nsfw' => $new_nsfw,
        } );
    }

    if (
        $c->check_any_user_role(qw/edit_object_nsfw/)
        && ( $object->user_id != $c->user->user_id )
    ){
        my $picture_id = $prepared->{'picture_id'};
        $prepared = {}; #reset this
        $prepared->{'picture_id'} = $picture_id if $picture_id;
    }

    foreach my $key ( keys( %{$prepared} ) ){
        if ( ref( $prepared->{ $key } ) eq 'ARRAY' ){
            my @existing = $object->$type->$key->search->all;

            foreach my $new ( @{$prepared->{ $key }} ){
                my $found = shift( @existing );

                if ( $found ){
                    $found->update( $new );
                } else {
                    $object->$type->$key->create( $new );
                }
            }
            foreach my $spare ( @existing ){
                $spare->delete;
            }
        } else {
            $to_update->{ $key } = $prepared->{ $key };
        }
    }

    my $change_type = $c->req->param('change_type');
    if ( 
        $change_type
        && ( $change_type ne $type )
        && $c->model('Object')->valid_public_object( $change_type ) 
    ){
        $c->model('MySQL::' . ucfirst( $change_type ))->create( {
            "${change_type}_id" => $object->id,
            %{ $to_update },
        } );

        $object->$type->delete;
        
        $object->update({
            'type' => $change_type,
        })->discard_changes;
    } else {
        $object->$type->update( $to_update );
    }

    if ( 
        $c->check_any_user_role(qw/edit_object edit_object_nsfw/)
    ){
        if ( $c->check_any_user_role(qw/edit_object/) ){
            $c->forward( '/submit/add_tags', [ $object, $tags ] );
        }

        $c->model('MySql::AdminLog')->log_event( {
            'admin_id' => $c->user->id,
            'user_id' => $object->user_id,
            'action' => 'edit_object',
            'reason' => $c->req->param('_edit-reason') || ' ',
            'object_id' => $object->id,
        } );
    }
}

__PACKAGE__->meta->make_immutable;
