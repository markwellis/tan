package TAN::Controller::Cms::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub validate_user: PathPart('admin') Chained('/') CaptureArgs(0){
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
        $c->detach('/default');
    };

    $c->stash(
        'cms_pages' => $cms_pages,
        'template' => 'cms/admin/index.tt',
        'page_title' => 'Cms Pages',
    );
}

__PACKAGE__->meta->make_immutable;
