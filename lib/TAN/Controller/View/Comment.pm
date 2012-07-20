package TAN::Controller::View::Comment;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {'edit_comment' => 1};
    },
);

sub comment: PathPart('_comment') Chained('../type') Args(0) {
    my ( $self, $c ) = @_;

    my $comment_id;
    if ( $c->user_exists ){
    #logged in, post
        if ( my $comment = $c->req->param('comment') ){
        #comment
            if ( $c->req->param('mobile') ){
                $comment = TAN::View::TT::nl2br( $comment );
            }
            my $comment_rs = $c->model('MySQL::Comments')->create_comment( 
                $c->stash->{'object_id'}, 
                $c->user->user_id, 
                $comment
            );
            $comment_id = $comment_rs->comment_id;
            $c->trigger_event('comment_created', $comment_rs);
        }
    } else {
    #save for later
        if ( my $comment = $c->req->param('comment') ){
        # save comment in session for later
            push( @{$c->session->{'comments'}}, {
                'object_id' => $c->stash->{'object_id'},
                'comment'   => $comment,
            });

            if ( !defined($c->req->param('ajax')) ){
                $c->flash->{'message'} = 'Your comment has been saved, please login/register';
                $c->res->redirect( '/login/', 303 );
            } else {
                $c->res->output("login");
            }
            $c->detach();
        }
    }

    if ( !defined($c->req->param('ajax')) ){
    #not an ajax request
        my $type = $c->stash->{'type'};
        my $object_rs = $c->model('MySQL::' . ucfirst($type) )->find( $c->stash->{'object_id'} );

        if ( defined($object_rs) ){
        #redirect to the object
            $c->res->redirect( "@{[ $object_rs->object->url ]}#comment@{[ $comment_id || 's' ]}", 303 );
            $c->detach();
        } else {
        #no object, redirect to /
            $c->forward('/default');
            $c->detach();
        }
    } else {
    #ajax 
        #return the comment, filtered and all that
        my $comment_rs = $c->model('MySQL::Comments')->find({
            'comment_id' => $comment_id,
        });

        #better add some validation in
        if ( !defined($comment_rs) ){
            $c->res->output("error");
            $c->detach();
        }
        
        #construct object, no point doing extra sql
        $c->forward('ajax_comment', [$comment_rs]);
        $c->detach();
    }
}

sub ajax_comment: Private{
    my ( $self, $c, $comment_rs ) = @_;

    $c->stash->{'comment'} = $comment_rs;

    $c->stash->{'template'} = 'view/comment.tt';
    $c->forward( $c->view('NoWrapper') );
}

sub edit_comment: PathPart('_edit_comment') Chained('../type') Args(1) {
    my ( $self, $c, $comment_id ) = @_;

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $comment_id =~ s/$not_int_reg//g;
    my $object_rs = $c->model('MySQL::Object')->find({
        'object_id' => $c->stash->{'object_id'},
    });

    if ( !$comment_id ){
#FAIL (no comment id)
        if ( !defined($c->req->param('ajax')) ){
            $c->flash->{'message'} = 'No comment Id';
            $c->res->redirect( $object_rs->url, 303 );
        } else {
            $c->res->output("No comment Id");
            $c->res->status(400);
        }
        $c->detach();
    }

    my $comment_rs = $c->model('MySQL::Comments')->find( $comment_id );

    if ( !defined($comment_rs) ){
#FAIL (comment not found)
        if ( !defined($c->req->param('ajax')) ){
            $c->detach('/default');
        } else {
            $c->res->output("Comment not found");
            $c->res->status(404);
        }
        $c->detach();
    }

    if ( !$c->user_exists
        || (
            !$c->check_user_roles(qw/edit_comment/)
            && ( $comment_rs->user_id != $c->user->user_id ) 
        )
    ){
#FAIL (comment not users)
        if ( !defined($c->req->param('ajax')) ){
            $c->detach('/access_denied');
        } else {
            $c->res->output("Not your comment");
            $c->res->status(403);
        }

        $c->detach();
    }
    if ( $c->req->method eq 'POST' ){
        if ( defined($c->req->param("delete${comment_id}"))
            && ( $c->req->param("delete${comment_id}") eq 'Delete' )
        ){
#DELETE comment
            $comment_rs->update({
                'deleted' => 'Y',
            });
            $c->trigger_event('comment_deleted', $comment_rs);

            if ( $c->check_user_roles(qw/edit_comment/)
                && ( $comment_rs->user_id != $c->user->user_id ) 
            ){
                $c->model('MySql::AdminLog')->log_event( {
                    'admin_id' => $c->user->id,
                    'user_id' => $comment_rs->user_id,
                    'action' => 'delete_comment',
                    'reason' => $c->req->param('_edit-reason') || ' ',
                    'comment_id' => $comment_rs->id,
                    'object_id' => $comment_rs->object_id,
                } );
            }

            if ( !defined($c->req->param('ajax')) ){
                $c->flash->{'message'} = 'Comment deleted';
                $c->res->redirect( $comment_rs->object->url, 303 );
            } else {
                $c->res->output("Comment deleted");
            }
            $c->detach();
        } else {
#UPDATE comment
            if ( defined($c->req->param("edit_comment_${comment_id}")) ){
                if ( $c->check_user_roles(qw/edit_comment/)
                    && ( $comment_rs->user_id != $c->user->user_id ) 
                ){
                    $c->model('MySql::AdminLog')->log_event( {
                        'admin_id' => $c->user->id,
                        'user_id' => $comment_rs->user_id,
                        'action' => 'edit_comment',
                        'reason' => $c->req->param('_edit-reason') || ' ',
                        'bulk' => {
                            'original' => $comment_rs->comment,
                            'new' => $c->req->param("edit_comment_${comment_id}"),
                        },
                        'comment_id' => $comment_rs->id,
                        'object_id' => $comment_rs->object_id,
                    } );
                }
                my $comment = $c->req->param("edit_comment_${comment_id}");
                if ( $c->req->param('mobile') ){
                    $comment = TAN::View::TT::nl2br( $comment );
                }
                $comment_rs->update({
                    'comment' => $comment,
                });
                $c->trigger_event('comment_updated', $comment_rs);
            }
            if ( !defined($c->req->param('ajax')) ){
                $c->res->redirect( $comment_rs->object->url . '#comment' . $comment_rs->comment_id, 303 );
            } else {
# RETURN COMMENT HERE
                $c->forward('ajax_comment', [$comment_rs]);
            }

            $c->detach();
        }
    }

    $c->stash(
        'comment' => $comment_rs,
        'template' => 'view/edit_comment.tt',
    );

    if ( $c->req->param('ajax') ){
        $c->detach( $c->view('NoWrapper') );
    }
}

sub post_saved_comments: Private{
    my ( $self, $c ) = @_;

    if ( $c->user_exists ){
    #logged in, post
        foreach my $saved_comment ( @{$c->session->{'comments'}} ){
            if ( defined($saved_comment->{'object_id'}) && defined($saved_comment->{'comment'}) ){
                my $comment_rs = $c->model('MySQL::Comments')->create_comment( 
                    $saved_comment->{'object_id'}, 
                    $c->user->user_id, 
                    $saved_comment->{'comment'} 
                );
                $c->trigger_event('comment_created', $comment_rs);
            }
        }
        $c->session->{'comments'} = undef;
    }
}

__PACKAGE__->meta->make_immutable;
