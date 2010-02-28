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

loads the article

=back

=cut
sub index: PathPart('') Chained('location') Args(1) {
    my ( $self, $c, $title ) = @_;

#check
# object_id is valid
# url matches (seo n that)
# display article
# load comments etc

    my $url_title = $c->forward('object_title');
    if ( $c->req->uri->path ne $url_title ){
        $c->res->redirect( $url_title, 301 );
        $c->detach();
    }

    $c->stash->{'object'} = $c->model('MySQL::Object')->find({
        'object_id' => $c->stash->{'object_id'},
    },{
        '+select' => [
            { 'unix_timestamp' => 'me.created' },
            { 'unix_timestamp' => 'me.promoted' },
            \'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id) views',
            \'(SELECT COUNT(*) FROM comments WHERE comments.object_id = me.object_id) comments',
            \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="plus") plus',
            \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="minus") minus',
        ],
        '+as' => ['created', 'promoted', 'views', 'comments', 'plus', 'minus'],
        'prefetch' => [$c->stash->{'location'}, 'user'],
        'order_by' => '',
    });

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

    if ( !defined($c->stash->{'object'}) ){
        $c->foward('/default');
        $c->detach();
    }

    @{$c->stash->{'comments'}} = $c->model('MySQL::Comments')->search({
        'object_id' => $c->stash->{'object_id'},
    },{
        '+select' => [
            { 'unix_timestamp' => 'me.created' },
        ],
        '+as' => ['created'],
        'prefetch' => ['user'],
        'order_by' => 'created',
    })->all;

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

        if ( defined($object_rs) && (my $title = $object_rs->title) ){
        #redirect to the object
            $c->res->redirect( $c->forward('object_title') );
            $c->detach();
        } else {
        #no object, redirect to /
            $c->res->redirect( '/' );
            $c->detach();
        }
    } else {
    #ajax 
        #return the comment, filtered and all that
        my $comment_rs = $c->model('MySQL::Comments')->find($comment_id);

        #better add some validation in
        if ( !defined($comment_rs) ){
            $c->res->output("error");
            $c->detach();
        }
        
        #construct object, no point doing extra sql
        $c->stash->{'comment'} = {
            'created' => $comment_rs->created,
            'comment' => $comment_rs->comment,
            'comment_id' => $comment_rs->comment_id,
            'user' => {
                'user_id' => $c->user->user_id,
                'username' => $c->user->username,
                'join_date' => $c->user->join_date,
            }
        };

        $c->stash->{'template'} = 'lib/comment.tt';
        $c->forward( $c->view('NoWrapper') );
        
        $c->detach();
    }
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
        my $count = $c->model('MySQL::PlusMinus')->add(
            $type, $c->stash->{'object_id'}, $c->user->user_id
        );

        if ( defined($c->req->param('json')) ){
        #json
            $c->res->header('Content-Type' => 'application/json');
            $c->res->body( to_json({
                'count' => $count,
            }) );
        } else {
        #redirect
            $c->res->redirect( $c->forward('object_title') );
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
        }
        $c->session->{'comments'} = undef;
    }
}

sub object_title: Private{
    my ( $self, $c ) = @_;
    my $object_meta_rs = $c->model('MySQL::' 
        . ucfirst( $c->stash->{'location'} ))->find( $c->stash->{'object_id'} );
    
    if ( !defined($object_meta_rs) ){
        return;
    }
    
    $c->stash->{'page_title'} = $object_meta_rs->title;
    return "/view/" . $c->stash->{'location'} . '/' 
        . $c->stash->{'object_id'} .'/' 
        . $c->url_title( $object_meta_rs->title );
}
=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
