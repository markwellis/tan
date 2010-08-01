package TAN::Controller::Submit::Edit;
use strict;
use warnings;

use parent 'Catalyst::Controller';
my $tag_reg = qr/[^a-zA-Z0-9]/;

=head1 NAME

TAN::Controller::Submit::Edit

=head1 DESCRIPTION

Edit controller

=head1 EXAMPLE

I</submit/edit/$id>

=over

loads an object and then displays the submit templates

=back

=head1 METHODS

=cut

=head2 validate_user: PathPart('') Chained('/submit/location') CaptureArgs(0)

B<@args = undef>

=over

validates that the object is owned by the current user

or current user is an admin

=back

=cut
sub validate_user: PathPart('edit') Chained('/submit/location') CaptureArgs(1){
    my ( $self, $c, $object_id ) = @_;

    $c->stash->{'object'} = $c->model('MySQL::Object')->find({
        'object_id' => $object_id,
    },{
        'prefetch' => $c->stash->{'location'},
    });

    if ( 
        !defined($c->stash->{'object'})
        || !$c->user_exists 
        || (
            !$c->user->admin 
            && ($c->user->id != $c->stash->{'object'}->user_id)
        )
    ){
        $c->forward('/default');
        $c->detach();
    }
}

=head2 index: PathPart('') Chained('location') Args() 

B<@args = undef>

=over

loads the object info and then the submit template

=back

=cut
sub index: PathPart('') Chained('validate_user') Args() {
    my ( $self, $c ) = @_;

    my $type = $c->stash->{'location'};
    $c->stash(
        'template' => 'submit.tt',
        'page_title' => 'Edit ' . ($c->stash->{'object'}->$type->title || ''),
        'edit' => 1,
    );
}

=head2 post: PathPart('post') Chained('validate_user') Args(0) 

B<@args = undef>

=over

edits something

=back

=cut
sub post: PathPart('post') Chained('validate_user') Args(0) {
    my ( $self, $c ) = @_;

    #can't chain coz of some bullshit
    $c->forward('/submit/validate');
    if ( $c->stash->{'error'} ){
        $c->flash->{'message'} = $c->stash->{'error'};
        $c->res->redirect('/submit/' . $c->stash->{'location'} . '/edit/' . $c->stash->{'object'}->id . '/');
        $c->detach();
    }

    if ( $c->stash->{'location'} eq 'link' ){
        $c->stash->{"object"}->link->update({
            'title' => $c->req->param('title'),
            'description' => $c->req->param('description'),
            'picture_id' => $c->req->param('cat'),
            'url' => $c->req->param('url'),
        });
    } elsif ( $c->stash->{'location'} eq 'blog' ){
        $c->stash->{"object"}->blog->update({
            'title' => $c->req->param('title'),
            'description' => $c->req->param('description'),
            'picture_id' => $c->req->param('cat'),
            'details' => $c->req->param('blogmain'),
        });

        $c->trigger_event('blog_updated', $c->stash->{'object'});
    } elsif ( $c->stash->{'location'} eq 'picture' ){
        $c->stash->{"object"}->update({
            'nsfw' => defined($c->req->param('nsfw')) ? 'Y' : 'N',
        });
        $c->stash->{"object"}->picture->update({
            'title' => $c->req->param('title'),
            'description' => $c->req->param('pdescription'),
        });
    } elsif ( $c->stash->{'location'} eq 'poll' ){
        $c->stash->{"object"}->poll->update({
            'title' => $c->req->param('title'),
            'description' => $c->req->param('description'),
            'picture_id' => $c->req->param('cat'),
        });
        
        my @new_answers = $c->req->param('answers');
        my @existing_answers = $c->stash->{"object"}->poll->answers->search({}, {'order_by' => 'answer_id'})->all;

        my $loop = 0;
        foreach my $answer ( @new_answers ){
            if ( $answer ){
                if ( $existing_answers[$loop] ){
                    $existing_answers[$loop]->update({
                        'answer' => $answer,
                    });
                } else {
                    $c->stash->{"object"}->poll->answers->create({
                        'answer' => $answer,
                    });
                }
            } else {
                if ( $existing_answers[$loop] ){
                    $existing_answers[$loop]->delete;
                }
            }
            ++$loop;
        }
    }

    #seems not very nice
    $c->stash->{'object'}->tag_objects->delete();
    $c->forward('/submit/add_tags', [$c->stash->{'object'}]);

    $c->trigger_event('object_updated', $c->stash->{'object'});

    $c->flash->{'message'} = 'Edit complete';
    $c->res->redirect($c->stash->{'object'}->url);
    $c->detach();
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
