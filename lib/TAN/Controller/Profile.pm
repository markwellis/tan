package TAN::Controller::Profile;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Profile

=head1 DESCRIPTION

FAQ page

=head1 EXAMPLE

I</profile/$username/>

=head1 METHODS

=cut

=head2 user: PathPart('submit') Chained('/') CaptureArgs(1)

B<@args = ($username)>

=over

loads the user

=back

=cut
sub user: PathPart('profile') Chained('/') CaptureArgs(1){
    my ( $self, $c, $username ) = @_;

    $c->stash->{'user'} = $c->model('MySQL::User')->find({
        'username' => $username,
    });

    if ( !$c->stash->{'user'} ){
        $c->forward('/default');
        $c->detach();
    }
}

=head2 index: PathPart('') Chained('user') Args(0)

B<@args = undef>

=over

loads profile page for the user 

=back

=cut
sub index: PathPart('') Chained('user') Args(0){
    my ( $self, $c ) = @_;

#TT is tarded
    my $user = $c->stash->{'user'};

    my %search_opts;
    if ( !$c->nsfw ){
        %search_opts = (
            'nsfw' => 'N',
        );
    }

    $c->stash->{'comments'} = $user->comments->search({
        'deleted' => 'N',
    });

    $c->stash->{'links'} = $user->objects->search({
        'type' => 'link',
        %search_opts,
    });

    $c->stash->{'blogs'} = $user->objects->search({
        'type' => 'blog',
        %search_opts,
    });

    $c->stash->{'pictures'} = $user->objects->search({
        'type' => 'picture',
        %search_opts,
    });
#END tardism

#prevent race
    eval{
        $c->model('MySQL')->txn_do(sub{
            $c->stash->{'object'} = $c->model('MySQL::Object')->find_or_create({
                'user_id' => $user->id,
                'type' => 'profile',
            });
            $c->stash->{'object'}->find_or_create_related('profile',{});
        });
    };

    $c->stash(
        'page_title' => $user->username . "'s Profile",
        'template' => 'profile.tt',
    );
}

sub edit: PathPart('edit') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->user_exists && ($c->stash->{'user'}->id == $c->user->id) ){
        $c->stash->{'object'} = $c->model('MySQL::Object')->find({
            'user_id' => $c->stash->{'user'}->id,
            'type' => 'profile',
        });

        if ( $c->req->method eq 'POST' && defined($c->req->param('profile')) ){
            if ( defined($c->stash->{'object'}) ){
                my $profile = $c->stash->{'object'}->profile;
                
                if ( defined($profile) ){
                    $profile->update({
                        'details' => $c->req->param('profile'),
                    });

                    $c->cache->remove("profile.0:" . $c->stash->{'object'}->id);
                    $c->cache->remove("profile.1:" . $c->stash->{'object'}->id);
                }
            }
            $c->res->redirect('/profile/' . $c->stash->{'user'}->username);
            $c->detach;
        }
        $c->stash->{'template'} = 'profile/edit.tt';
        $c->detach;
    }

    $c->res->redirect('/profile/' . $c->stash->{'user'}->username);
    $c->detach;
}

=head2 comments: PathPart('comments') Chained('user') Args(0)

B<@args = undef>

=over

loads comments for the user

=back

=cut
sub comments: PathPart('comments') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    my $page = $c->req->param('page') || 1;

    $c->stash->{'comments'} = $c->stash->{'user'}->comments->search({
            'me.deleted' => 'N',
        },
        {
            '+select' => [
                { 'unix_timestamp' => 'me.created' },
            ],
            '+as' => ['created'],
            'prefetch' => ['user', {
                'object' => ['link', 'blog', 'picture'],
            }],
            'page' => $page,
            'rows' => 50,
            'order_by' => {
                '-desc' => 'me.created',
            },
        }
    );

    if ( !$c->stash->{'comments'} ) {
        $c->forward('/default');
        $c->detach;
    }

    $c->stash(
        'page_title' => $c->stash->{'user'}->username . "'s Comments",
        'template' => 'profile/comments.tt',
    );
}

=head2 links: PathPart('links') Chained('user') Args(0)

B<@args = undef>

=over

loads links for the user

=back

=cut
sub links: PathPart('links') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['link']);

    $c->stash(
        'template' => 'profile/links.tt',
    );
}

=head2 blogs: PathPart('blogs') Chained('user') Args(0)

B<@args = undef>

=over

loads blogs for the user

=back

=cut
sub blogs: PathPart('blogs') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['blog']);

    $c->stash(
        'template' => 'profile/links.tt',
    );
}

=head2 pictures: PathPart('pictures') Chained('user') Args(0)

B<@args = undef>

=over

loads pictures for the user

=back

=cut
sub pictures: PathPart('pictures') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('fetch', ['picture']);

    $c->stash(
        'template' => 'profile/pictures.tt',
    );
}

sub fetch: Private{
    my ( $self, $c, $location ) = @_;

    my $page = $c->req->param('page') || 1;
    my $order = $c->req->param('order') || 'created';

    my ( $objects, $pager ) = $c->stash->{'user'}->objects->index( $location, $page, 1, {}, $order, $c->nsfw, "profile:" . $c->stash->{'user'}->id );

    if ( scalar(@{$objects}) ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'order' => $order,
            'page_title' => $c->stash->{'user'}->username . "'s " . ucfirst($location) . "s",
            'location' => $location,
        );
    } else {
        $c->forward('/default');
        $c->detach;
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
