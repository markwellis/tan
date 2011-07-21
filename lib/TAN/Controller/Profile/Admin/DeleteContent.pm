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

    $c->stash(
        'template' => 'profile/admin/delete_content.tt',
        'page_title' => 'Delete Content',
    );
}

sub delete_objects: Private{
    my ( $self, $c ) = @_;

    my @object_types = $c->req->param('objects');
    if ( scalar( @object_types ) ){
        my $search_terms = {
            'type' => \@object_types,
            'deleted' => 'N',
            'user_id' => $c->stash->{'user'}->id,
        };

        my $objects_rs = $c->model('MySql::Object')->search( $search_terms, {
            'prefetch' => \@object_types,
        } );
        
        if ( $objects_rs ){
            my @objects = $objects_rs->all;
            my @object_ids;
            foreach my $object ( @objects ){
                push( @object_ids, $object->id );
            }

            $c->model('MySql::AdminLog')->log_event( {
                'admin_id' => $c->user->id,
                'user_id' => $c->stash->{'user'}->id,
                'action' => 'mass_delete_objects',
                'bulk' => \@object_ids,
                'other' => \@object_types,
                'reason' => $c->stash->{'reason'},
            } );

            # do this again beacuse it'll do an indvidual query 
            # for each update otherwise (coz of the prefetch)
            $c->model('MySql::Object')->search( $search_terms )->update( {
                'deleted' => 'Y',
            } );

            $c->trigger_event( 'mass_objects_deleted', \@objects );
        }
    }
}

sub delete_comments: Private{
    my ( $self, $c ) = @_;

    if ( $c->req->param('comments') ){
        my $search_terms = {
            'me.deleted' => 'N',
            'me.user_id' => $c->stash->{'user'}->id,
        };

        my $comments_rs = $c->model('MySql::Comments')->search( $search_terms, {
            'prefetch' => {
                'object' => [qw/link blog picture poll/]
            },
        } );

        if ( $comments_rs ){
            my @comments = $comments_rs->all;
            my @comment_ids;
            foreach my $comment ( @comments ){
                push( @comment_ids, $comment->id );
            }

            $c->model('MySql::AdminLog')->log_event( {
                'admin_id' => $c->user->id,
                'user_id' => $c->stash->{'user'}->id,
                'action' => 'mass_delete_comments',
                'bulk' => \@comment_ids,
                'reason' => $c->stash->{'reason'},
            } );

            $c->model('MySql::Comments')->search( $search_terms )->update( {
                'deleted' => 'Y',
            } );

            $c->trigger_event( 'mass_comments_deleted', \@comments );
        }
    }
}

__PACKAGE__->meta->make_immutable;
