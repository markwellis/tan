package TAN::Controller::Profile::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub check_permissions: Chained('/profile/user') CaptureArgs(0){
    my ( $self, $c ) = @_;

    die 'fibble';
    if ( 1 || !$c->user_exists || !$c->check_user_roles(qw/edit_user/) ){
        $c->detach('/access_denied');
    }
}

sub _force_logout: Private{
    my ( $self, $c ) = @_;
}

sub ban: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;
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

sub delete: Chained('check_permissions') Args(0){
    my ( $self, $c ) = @_;
}

__PACKAGE__->meta->make_immutable;
