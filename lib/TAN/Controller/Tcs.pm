package TAN::Controller::Tcs;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use 5.014;

sub index: Path{
    my ( $self, $c ) = @_;

    my $cms_page = $c->model('MySql::Cms')->load('tcs');

    $c->stash(
        'page_title' => $cms_page->title,
        'template' => 'tcs.tt',
        'tcs' => $cms_page,
    );
}

sub submit: Local{
    my ( $self, $c ) = @_;

    given( $c->req->param('accept') ){
        when('Agree'){
            $c->forward('agree');
        }
        default {
            $c->forward('decline');
        }
    }

    my $ref = $c->flash->{'ref'};
    if (!defined($ref) || $ref =~ m/\/login\//){
        $ref = '/index/all/0/';
    }

    $c->res->redirect( $ref, 303 );
    $c->detach;
}

sub agree: Private{
    my ( $self, $c ) = @_;

    my $cms_page = $c->model('MySql::Cms')->load('tcs');
    $c->user->update( {
        'tcs' => $cms_page->revision,
    } );
    #update user info in the session
    $c->persist_user;
}

sub decline: Private{
    my ( $self, $c ) = @_;

    $c->logout;
    $c->flash->{'message'} = "You need to agree to the terms and conditions to continue";
}

__PACKAGE__->meta->make_immutable;
