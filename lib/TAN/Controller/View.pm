package TAN::Controller::View;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;

sub spam_twitter: Event('object_promoted'){
    my ( $self, $c, $object ) = @_;

    my $location = $object->type;
    my $title = $object->$location->title;

    $c->model('Gearman')->run( 'twitter_spam', {
        'title' => $title,
        'nsfw' => $object->nsfw,
        'url' => $c->req->base . $object->url,
    } );
}

sub remove_blog_cache: Event(object_updated){
    my ( $self, $c, $object ) = @_;

    if ( $object->type eq 'blog' ){
        $c->cache->remove("blog.0:" . $object->id);
        $c->cache->remove("blog.1:" . $object->id);
    }
}

sub remove_comment_cache: 
    Event(comment_created) 
    Event(comment_deleted) 
    Event(comment_updated) 
    Event(object_updated) 
    Event(object_deleted)
{
    my ( $self, $c, $comment ) = @_;

    #clear recent_comments
    $c->cache->remove("recent_comments");
    #clear comment cache

    if ( $comment && ( ref($comment) eq 'TAN::Model::MySQL::Comments' ) ){
        $c->cache->remove("comment.0:" . $comment->id);
        $c->cache->remove("comment.1:" . $comment->id);
    }
}

sub remove_object_cache: 
    Event(object_created)
    Event(object_deleted)
    Event(object_updated)
    Event(object_plusminus)
    Event(comment_created)
    Event(comment_deleted)
    Event(comment_updated)
    Event(poll_vote)
{
    my ( $self, $c, $object ) = @_;
    return if ( !defined($object) );

    if ( ref($object) ne 'TAN::Model::MySQL::Object' ){
    #$object_rs is something else with a ->object relationshop
        $object = $object->object;
    }

    $c->cache->remove("object:" . $object->id); #no_extra
    $c->clear_cached_page( $object->url . '.*' );
}

sub location: PathPart('view') Chained('/') CaptureArgs(2){
    my ( $self, $c, $location, $object_id ) = @_;

    my $location_reg = $c->model('CommonRegex')->location;
    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $object_id =~ s/$not_int_reg//g;
    if ( !$object_id ){
        $c->forward('/default');
        $c->detach();
    }

    $c->stash->{'object_id'} = $object_id;
    $c->stash->{'location'} = $location;
}

sub index: PathPart('') Chained('location') Args(1) {
    my ( $self, $c, $title ) = @_;

    $c->cache_page( 60 );
#check
# object_id is valid
# url matches (seo n that)
# display article
# load comments etc
    $c->stash->{'object'} = $c->model('MySQL::Object')->get($c->stash->{'object_id'}, $c->stash->{'location'});

    if ( !defined($c->stash->{'object'}) || ( $c->stash->{'object'}->deleted eq 'Y' ) ){
        $c->forward('/default');
        $c->detach();
    }

    my $url = $c->stash->{'object'}->url;
    if ( $c->req->uri->path ne $url ){
        $c->res->redirect( $url, 301 );
        $c->detach();
    }

    if ( $c->user_exists ){
        #get me plus info
        my $meplus_minus = $c->stash->{'object'}->plus_minus->meplus_minus( $c->user->user_id );

        if ( defined($meplus_minus->{ $c->stash->{'object'}->object_id }->{'plus'}) ){
            $c->stash->{'object'}->{'meplus'} = 1;
        }
        if ( defined($meplus_minus->{ $c->stash->{'object'}->object_id }->{'minus'}) ){
            $c->stash->{'object'}->{'meminus'} = 1;  
        }
    }

    @{$c->stash->{'comments'}} = 
    $c->model('MySQL::Comments')->search({
        'me.object_id' => $c->stash->{'object_id'},
        'me.deleted' => 'N',
    },{
        'prefetch' => ['user', {
            'object' => $c->stash->{'location'},
        }],
        'order_by' => 'me.created',
    })->all;

    $title = eval('$c->stash->{"object"}->' . $c->stash->{'location'} . "->title");
    $c->stash(
        'page_title' => $title,
        'template' => 'View',
    );
}

sub comment: PathPart('_comment') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    my $comment_id;
    if ( $c->user_exists ){
    #logged in, post
        if ( my $comment = $c->req->param('comment') ){
        #comment
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
        my $type = $c->stash->{'location'};
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

    $c->stash->{'template'} = 'View::Comment';
    $c->forward( $c->view('NoWrapper') );
}

sub edit_comment: PathPart('_edit_comment') Chained('location') Args(1) {
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
            $c->flash->{'message'} = 'Comment not found';
            $c->res->redirect( $object_rs->url, 303 );
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
            $c->flash->{'message'} = 'Not your comment';
            $c->res->redirect( $comment_rs->object->url, 303 );
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
                $comment_rs->update({
                    'comment' => $c->req->param("edit_comment_${comment_id}"),
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

    $c->stash->{'comment_id'} = $comment_id;
    $c->stash->{'comment'} = $comment_rs->comment_nobb;
    $c->stash->{'template'} = 'View::EditComment';

    if ( $c->req->param('ajax') ){
        $c->forward( $c->view('NoWrapper') );
        $c->detach();
    }
}

sub plus: PathPart('_plus') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('add_plus_minus', ['plus']);
}

sub minus: PathPart('_minus') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('add_plus_minus', ['minus']);
}

sub add_plus_minus: Private{
    my ( $self, $c, $type ) = @_;

    if ( $c->user_exists ){
    # valid user, do work
        my ( $count, $promoted, $deleted ) = $c->model('MySQL::PlusMinus')->add(
            $type, $c->stash->{'object_id'}, $c->user->user_id
        );

        my $object = $c->model('MySQL::Object')->find({
            'object_id' => $c->stash->{'object_id'}
        });

        $c->trigger_event('object_plusminus', $object);
        if ( $promoted ){
            $c->trigger_event('object_promoted', $object);
        }

        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'count' => $count,
                'deleted' => $deleted,
            }) );
        } else {
        #redirect
            $c->res->redirect( $object->url, 303 );
        }
    } else {
    #prompt for login
        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'login' => 1,
            }) );
        } else {
        #redirect
            $c->res->redirect( '/login/', 303 );
        }
    }
    $c->detach();
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

sub vote: PathPart('_vote') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->user_exists ){
    # valid user, do work
        my $poll = $c->model('MySQL::Poll')->find({
            'poll_id' => $c->stash->{'object_id'},
        });

#check that $poll exists
#check that $c->req->param('answer_id') exists
        if ( !$poll || !$c->req->param('answer_id') ){
            $c->forward('/default');
            $c->detach;
        }

        if ( $poll ){
            my $vote;
#check if user has already voted

            $vote = $poll->vote($c->user->user_id, $c->req->param('answer_id'));
            if ( $vote ){
                $c->trigger_event('poll_vote', $poll);
            }
        }

        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            my @results;
            my $total_votes = $poll->votes->count;
            foreach my $answer ( $poll->answers->all ){
                push(@results, {
                    'name' => $answer->answer, 
                    'percent' => $answer->percent($total_votes),
                });
            }
            $c->res->body( to_json(\@results) );
        } else {
        #redirect
            $c->res->redirect( $poll->object->url, 303 );
        }
    } else {
    #prompt for login
        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'login' => 1,
            }) );
        } else {
        #redirect
            $c->res->redirect( '/login/', 303 );
        }
    }
    $c->detach();

}

__PACKAGE__->meta->make_immutable;
