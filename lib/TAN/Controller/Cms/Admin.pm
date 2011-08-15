package TAN::Controller::Cms::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Try::Tiny;

sub validate_user: PathPart('cms/admin') Chained('/') CaptureArgs(0){
    my ( $self, $c ) = @_;

    if ( 
        !$c->check_any_user_role(qw/cms/) 
    ){
        $c->detach('/access_denied');
    }
}

sub index: PathPart('') Chained('validate_user') Args(0){
    my ( $self, $c ) = @_;

    my $page = $c->req->param('page') || 1;

    my $int_reg = $c->model('CommonRegex')->not_int;
    $page =~ s/$int_reg//g;
    $page ||= 1;

    my $cms_pages = try {
        $c->model('MySql::Cms')->index( $page );
    } catch {
        return undef;
    };

    $c->stash(
        'cms_pages' => $cms_pages,
        'template' => 'cms/admin/index.tt',
        'page_title' => 'Cms Pages',
    );
}

sub create: Chained('validate_user') Args(0){
    my ( $self, $c ) = @_;

    if ( $c->req->method eq 'POST' ){
        #create page
        my $url = $c->req->param('url');
        $url =~ s/^\\//; #remove leading slash

        my $cms_page = $c->model('MySql::Cms')->create( {
            'title' => $c->req->param('title'),
            'url' => $url,
            'content' => $c->req->param('content'),
            'created' => \'NOW()',
            'user_id' => $c->user->id,
            'revision' => 0,
            'comment' => $c->req->param('comment'),
            'system' => ( $c->req->param('system') ) ? 'Y' : 'N',
            'deleted' => ( $c->req->param('delete') ) ? 'Y' : 'N',
        } );

        #redirect to index
        $c->res->redirect( '/cms/admin/', 302 );
        $c->detach;
    }

    $c->stash(
        'template' => 'cms/admin/create.tt',
        'page_title' => 'Create New Cms Page',
    );
}

sub edit: Chained('validate_user') Args(1){
    my ( $self, $c, $cms_id ) = @_;

    my $cms_page = $c->model('MySql::Cms')->find( $cms_id );

    $c->stash(
        'cms_page' => $cms_page,
        'template' => 'cms/admin/create.tt',
        'page_title' => 'Edit Cms Page',
    );
}

__PACKAGE__->meta->make_immutable;
