package TAN::Controller::Login::Forgot;
use strict;
use warnings;

use parent 'Catalyst::Controller';
use Data::Validate::Email;

=head1 NAME

TAN::Controller::Login::Forgot

=head1 DESCRIPTION

User forgot username/password

=head1 EXAMPLE

I</login/forgot>

=over

show email form

=back

=head1 METHODS

=cut

=head2 index: Path: Args(0)

B<@args = undef>

=over

redirects to / if user logged in

loads the forgot template

=back

=cut
sub index: Path Args(0){
    my ( $self, $c ) = @_;
   
    if ( $c->user_exists ){
        $c->flash->{'message'} = "You're already logged in";
        $c->res->redirect('/');
        $c->detach();
    }

    $c->flash->{'ref'} = defined($c->req->referer) ? $c->req->referer : '/';
    
    $c->stash->{'template'} = 'login/forgot/index.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
