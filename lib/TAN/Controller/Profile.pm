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
    $c->stash->{'links'} = $c->stash->{'user'}->objects->search({
        'type' => 'link',
    });

    $c->stash->{'blogs'} = $c->stash->{'user'}->objects->search({
        'type' => 'blog',
    });

    $c->stash->{'pictures'} = $c->stash->{'user'}->objects->search({
        'type' => 'picture',
    });
#END tardism

#prevent race
    eval{
        $c->model('MySQL')->txn_do(sub{
            $c->stash->{'object'} = $c->model('MySQL::Object')->find_or_create({
                'user_id' => $c->stash->{'user'}->id,
                'type' => 'profile',
            });
            $c->stash->{'object'}->find_or_create_related('profile',{});
        });
    };

    $c->stash->{'template'} = 'profile.tt';
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

    $c->stash->{'comments'} = $c->stash->{'user'}->comments->search(
        {},
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
    
    $c->stash->{'template'} = 'profile/comments.tt';
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

    $c->stash->{'template'} = 'profile/links.tt';
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

    $c->stash->{'template'} = 'profile/links.tt';
}

=head2 pictures: PathPart('pictures') Chained('user') Args(0)

B<@args = undef>

=over

loads pictures for the user

=back

=cut
sub pictures: PathPart('pictures') Chained('user') Args(0){
    my ( $self, $c ) = @_;

    $c->stash->{'location'} = 'picture';
    $c->forward('fetch', ['picture']);

    $c->stash->{'template'} = 'profile/pictures.tt';
}

sub fetch: Private{
    my ( $self, $c, $location ) = @_;

    my $page = $c->req->param('page') || 1;

    my %search_opts;
    if ( !$c->nsfw ){
        $search_opts{'nsfw'} = 'N';
    }

    my $index_rs = $c->stash->{'user'}->objects->search({
        'type' => $location,
        %search_opts,
    },{
        'page' => $page,
        'rows' => 27,
        'order_by' => {
            '-desc' => 'me.created',
        },
        'prefetch' => $location,
    });

    if ( !$index_rs ){
        $c->forward('/default');
        $c->detach;
    }

    my @index;
    foreach my $object ( $index_rs->all ){
        push(@index, $c->model('MySQL::Object')->get( $object->id, $object->type ));
    }

    if ( $c->user_exists ){
        my @ids = map($_->id, @index);
        my $meplus_minus = $c->model('MySQL::PlusMinus')->meplus_minus($c->user->user_id, \@ids);

        foreach my $object ( @index ){
            if ( defined($meplus_minus->{ $object->object_id }->{'plus'}) ){
                $object->{'meplus'} = 1;
            } 
            if ( defined($meplus_minus->{ $object->object_id }->{'minus'}) ){
                $object->{'meminus'} = 1;  
            }
        }
    }

    if ( !scalar(@index) ){
        $c->forward('/default');
        $c->detach;
    }

    my $pager = {
        'current_page' => $index_rs->pager->current_page,
        'total_entries' => $index_rs->pager->total_entries,
        'entries_per_page' => $index_rs->pager->entries_per_page,
    };

    $c->stash->{'index'} = {
        'objects' => \@index,
        'pager' => $pager,
    };
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
