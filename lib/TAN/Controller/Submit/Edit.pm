package TAN::Controller::Submit::Edit;
use strict;
use warnings;

use parent 'Catalyst::Controller';

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

=head2 index: PathPart('') Chained('location') Args(1) 

B<@args = $object_id>

=over

loads the object info and then the submit template

=back

=cut
sub index: PathPart('') Chained('validate_user') Args() {
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'submit.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
