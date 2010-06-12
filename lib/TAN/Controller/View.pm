package TAN::Controller::View;
use strict;
use warnings;

use parent 'Catalyst::Controller';

use JSON;

my $int_reg = qr/\D+/;

=head1 NAME

TAN::Controller::View

=head1 DESCRIPTION

View Controller

=head1 EXAMPLE

I</view/$location/$id/$title>

=over

view article

=over

$location => link|blog|picture

$id = int

$title = url title

=back

=back

=head1 METHODS

=cut

=head2 location: PathPart('view') Chained('/') CaptureArgs(1)

B<@args = ($location)>

=over

checks the location is valid

=back

=cut
my $location_reg = qr/^link|blog|picture$/;
sub location: PathPart('view') Chained('/') CaptureArgs(2){
    my ( $self, $c, $location, $object_id ) = @_;

    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }

    $object_id =~ s/$int_reg//g;
    if ( !$object_id ){
        $c->forward('/default');
        $c->detach();
    }

    $c->stash->{'object_id'} = $object_id;
    $c->stash->{'location'} = $location;
}

=head2 index: PathPart('') Chained('location') Args(2) 

B<@args = ($title)>

=over

$title is never used, lol

loads the article

=back

=cut
sub index: PathPart('') Chained('location') Args(1) {
    my ( $self, $c, $title ) = @_;

#    $c->cache_page( 60 );
#check
# object_id is valid
# url matches (seo n that)
# display article
# load comments etc
    $c->stash->{'object'} = $c->model('MySQL::Object')->get($c->stash->{'object_id'}, $c->stash->{'location'});

    if ( !defined($c->stash->{'object'}) ){
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

    @{$c->stash->{'comments'}} = $c->model('MySQL::Comments')->search({
        'object_id' => $c->stash->{'object_id'},
        'me.deleted' => 'N',
    },{
        '+select' => [
            { 'unix_timestamp' => 'me.created' },
        ],
        '+as' => ['created'],
        'prefetch' => ['user'],
        'order_by' => 'created',
    })->all;


    $title = eval('$c->stash->{"object"}->' . $c->stash->{'location'} . "->title");
    $c->stash->{'page_title'} = $title;

    $c->stash->{'template'} = 'view.tt';
}

=head2 comment: PathPart('_comment') Chained('location') Args(0)

B<@args = undef>

=over

comments on an article

=back

=cut
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
            $c->forward('delete_comment_caches', [$comment_rs]);
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
                $c->res->redirect( '/login/' );
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
            $c->res->redirect( $object_rs->object->url . "#comment${comment_id}" );
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

    $c->stash->{'comment'} = {
        'comment' => $comment_rs->comment,
        'comment_id' => $comment_rs->comment_id,
        'number' => $comment_rs->number,
        'user' => {
            'user_id' => $c->user->user_id,
            'username' => $c->user->username,
        }
    };
    $c->stash->{'object'} = $comment_rs->object;

    $c->stash->{'template'} = 'view/comment.tt';
    $c->forward( $c->view('NoWrapper') );
}

sub edit_comment: PathPart('_edit_comment') Chained('location') Args(1) {
    my ( $self, $c, $comment_id ) = @_;

    $comment_id =~ s/$int_reg//g;
    my $object_rs = $c->model('MySQL::Object')->find({
        'object_id' => $c->stash->{'object_id'},
    });

    if ( !$comment_id ){
#FAIL (no comment id)
        if ( !defined($c->req->param('ajax')) ){
            $c->flash->{'message'} = 'No comment Id';
            $c->res->redirect( $object_rs->url );
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
            $c->res->redirect( $object_rs->url );
        } else {
            $c->res->output("Comment not found");
            $c->res->status(404);
        }
        $c->detach();
    }

    if ( $comment_rs->user_id != $c->user->user_id ){
#FAIL (comment not users)
        if ( !defined($c->req->param('ajax')) ){
            $c->flash->{'message'} = 'Not your comment';
            $c->res->redirect( $comment_rs->object->url );
        } else {
            $c->res->output("Not your comment");
            $c->res->status(403);
        }

        $c->detach();
    }

    if ( $c->req->method eq 'POST' ){
        if ( defined($c->req->param('delete')) ){
#DELETE comment
            $comment_rs->update({
                'deleted' => 'Y',
            });
            $c->forward('delete_comment_caches', [$comment_rs]);

            if ( !defined($c->req->param('ajax')) ){
                $c->flash->{'message'} = 'Comment deleted';
                $c->res->redirect( $comment_rs->object->url );
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
                $c->forward('delete_comment_caches', [$comment_rs]);
            }
            if ( !defined($c->req->param('ajax')) ){
                $c->res->redirect( $comment_rs->object->url . '#comment' . $comment_rs->comment_id);
            } else {
# RETURN COMMENT HERE
                $c->forward('ajax_comment', [$comment_rs]);
            }

            $c->detach();
        }
    }

    $c->stash->{'comment_id'} = $comment_id;
    $c->stash->{'comment'} = $comment_rs->comment_nobb;
    $c->stash->{'template'} = 'view/edit_comment.tt';

    if ( $c->req->param('ajax') ){
        $c->forward( $c->view('NoWrapper') );
        $c->detach();
    }
}

sub delete_comment_caches: Private{
    my ( $self, $c, $comment_rs ) = @_;

    #clear recent_comments
    $c->cache->remove("recent_comments");
    #clear comment cache
    $c->cache->remove("comment.0:" . $comment_rs->id);
    $c->cache->remove("comment.1:" . $comment_rs->id);
    #clear cobject
    if ( $c->stash->{'object_id'} ){
        $c->cache->remove("object:" . $c->stash->{'object_id'});
    }

    $c->clear_cached_page( $comment_rs->object->url . '.*' );
}

=head2 plus: PathPart('_plus') Chained('location') Args(0)

B<@args = undef>

=over

forwards to add_plus_minus('plus')

=back

=cut
sub plus: PathPart('_plus') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('add_plus_minus', ['plus']);
}

=head2 minus: PathPart('_minus') Chained('location') Args(0)

B<@args = undef>

=over

forwards to add_plus_minus('minus')

=back

=cut
sub minus: PathPart('_minus') Chained('location') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('add_plus_minus', ['minus']);
}

=head2 add_plus_minus: Private

B<@args = ($type)>

=over

adds/removes a plus/minus

set ?json=1 for json

else redirects to article

=back

=cut
sub add_plus_minus: Private{
    my ( $self, $c, $type ) = @_;

    if ( $c->user_exists ){
    # valid user, do work
        my $plus_minus_rs = $c->model('MySQL::PlusMinus')->add(
            $type, $c->stash->{'object_id'}, $c->user->user_id
        );
        $c->cache->remove("object:" . $c->stash->{'object_id'});

        my $object = $c->model('MySQL::Object')->find({
            'object_id' => $c->stash->{'object_id'}
        });
        $c->clear_cached_page( $object->url . '.*' ) if ( defined($object) );

        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'count' => $plus_minus_rs->count,
            }) );
        } else {
        #redirect
            $c->res->redirect( $plus_minus_rs->first->object->url );
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
            $c->res->redirect( '/login/' );
        }
    }
    $c->detach();
}
=head2 post_saved_comments: Private

B<@args = undef>

=over

used by on login to post any saved comments, in this controller because its 
where the comment stuff is

=back

=cut
sub post_saved_comments: Private{
    my ( $self, $c ) = @_;

    if ( $c->user_exists ){
    #logged in, post
        foreach my $saved_comment ( @{$c->session->{'comments'}} ){
            my $comment_rs = $c->model('MySQL::Comments')->create_comment( 
                $saved_comment->{'object_id'}, 
                $c->user->user_id, 
                $saved_comment->{'comment'} 
            );
            $c->forward('delete_comment_caches', [$comment_rs]);
        }
        $c->session->{'comments'} = undef;
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
