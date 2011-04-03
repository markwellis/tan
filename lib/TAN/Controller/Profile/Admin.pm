package TAN::Controller::Profile::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub check_permissions: Chained('/profile/user') PathPart('admin') CaptureArgs(0){
    my ( $self, $c ) = @_;

    if ( !$c->user_exists || !$c->check_user_roles(qw/edit_user/) ){
        $c->detach('/access_denied');
    }
}

sub _force_logout: Private{
    my ( $self, $c ) = @_;
}

sub ban: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;

    $c->stash->{'template'} = 'Profile::Admin::Ban';

    if ( $c->req->method eq 'POST' ){
#check we have a reason
        my $reason = $c->req->param('reason');
        my $trim_req = $c->model('CommonRegex')->trim;
        $reason =~ s/$trim_req//;

        if ( !$reason ){
            #error message
            #redirect somewhere
        }
        
        my $deleted = ( $c->stash->{'user'}->deleted eq 'Y' ) ? 1 : 0;

        if ( $deleted ){
            #ban
        } else {
            #unban
        }

#redirect back to user profile
#add banned status to user profile
    }
}

sub contact: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;
}

sub remove_avatar: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;
}

sub change_username: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;
}

sub remove_content: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;
}

__PACKAGE__->meta->make_immutable;
