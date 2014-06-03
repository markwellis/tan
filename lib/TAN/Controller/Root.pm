package TAN::Controller::Root;
use Moose;
use namespace::autoclean;
use MooseX::MethodAttributes;

extends 'Catalyst::Controller';

__PACKAGE__->config(namespace => '');

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {
            'chat' => 1,
            'default' => 1,
            'gone' => 1,
            'server_error' => 1,
            'recent_comments' => 1,
        };
    },
);

sub auto: Private {
    my ( $self, $c ) = @_;

## theme shouldn't be set here!!
    $c->stash(
        'theme_settings' => {
            'name' => 'classic',
        },
        'type' => 'all',
        'location' => 'all',
    );

    if (
        ( $c->action eq 'view/index' )
        || ( $c->action eq 'index/index' )
    ){
        if ( !$c->check_usr_tcs ){
            $c->res->redirect('/tcs');
            $c->detach;
        }
    }

    return 1;
}

sub index: Private {
    my ( $self, $c ) = @_;

    $c->res->redirect( '/index/all/0' . $c->req->uri->path_query );
    $c->detach;
}

sub default: Private {
    my ( $self, $c ) = @_;

    # check for a cms page
    $c->forward('/cms/cms');

    $self->error( $c, 404, 'Not Found' );
}

sub access_denied: Private {
    my ( $self, $c ) = @_;

    $self->error( $c, 401, 'Access denied' );
}

sub gone: Private {
    my ( $self, $c ) = @_;

    $self->error( $c, 410, 'Gone!' );
}

sub server_error: Private {
    my ( $self, $c ) = @_;

    $self->error( $c, 500, 'Massive cockup' );
}

sub error {
    my ( $self, $c, $error_code, $error ) = @_;

    $c->stash(
        'template' => "error.tt",
        'error_code' => $error_code,
        'error' => $error,
    );

    $c->response->status( $error_code );
    $c->detach;
}

sub random: Chained(/) Args(1) {
    my ( $self, $c, $type ) = @_;

    if (
        ($type ne 'all')
        && ( !$c->model('object')->valid_public_object( $type ) )
    ){
        $type = 'all';
    }

    my $object = $c->model('MySQL::Object')->random($type, $c->nsfw);

    if ($object){
        $c->res->redirect( $object->url, 303 );
        $c->detach();
    }

    $c->forward('/default');
    $c->detach();
}

sub chat: Chained(/) Args(0) {
    my ( $self, $c ) = @_;

    $c->cache_page( 3600 );

    $c->stash(
        'page_title' => 'Chat',
        'template' => 'chat.tt',
    );
}

sub recent_comments: Chained(/) Args(0) {
    my ( $self, $c ) = @_;

    $c->stash(
        'recent_comments' => $c->model('MySQL::RecentComments')->grouped,
        'template' => 'recent_comments.tt',
    );
}

sub render: ActionClass('RenderView') {}

sub end: Private {
    my ( $self, $c ) = @_;

    if ( !$c->res->output ){
    #dont render if redirect or ajax etc
        if ( $c->stash->{'can_rss'} && $c->req->param('rss') ){
            $c->forward( $c->view('RSS') );
        } else {
            $c->forward('render');
        }
    }
}

__PACKAGE__->meta->make_immutable;
