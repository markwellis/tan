package TAN::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Time::HiRes qw(time);

__PACKAGE__->config(namespace => '');

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {
            'chat' => 1,
            'error' => 1,
            'default' => 1,
            'recent_comments' => 1,
        };
    },
);

sub auto: Private{
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

sub index: Private{
    my ( $self, $c ) = @_;

    $c->res->redirect('/index/all/0/');
    $c->detach;
}

sub access_denied: Private{
    my ( $self, $c ) = @_;

    $c->forward('/error', [401, 'Access denied']);
}

sub default: Local{
    my ( $self, $c ) = @_;

    # check for a cms page
    $c->forward('/cms/cms');

    $c->forward('/error', [404, 'Not found']);
}

sub gone: Private{
    my ( $self, $c ) = @_;

    $c->forward('/error', [410, 'Gone!']);
}

sub server_error: Private{
    my ( $self, $c ) = @_;

    $c->forward('/error', [500, 'Massive cockup']);
}

sub error: Private{
    my ( $self, $c, $error_code, $error ) = @_;

    $c->stash(
        'template' => "error.tt",
        'error_code' => $error_code,
        'error' => $error,
    );

    $c->response->status( $error_code );
}

sub filter: Local Args(0){
    my ( $self, $c ) = @_;

    #bitwise ftw
    $c->nsfw($c->nsfw ^ 1);

    my $ref = $c->req->referer;
    if (!defined($ref)){
        $ref = '/';
    }

    $c->res->redirect( $ref, 303 );
    $c->detach();
}

sub random: Local Args(1){
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

sub chat: Local Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page( 3600 );

    $c->stash(
        'page_title' => 'Chat',
        'template' => 'chat.tt',
    );
}

sub recent_comments: Local{
    my ( $self, $c ) = @_;

    $c->stash(
        'recent_comments' => $c->model('MySQL::RecentComments')->grouped,
        'template' => 'recent_comments.tt',
    );
}

sub render: ActionClass('RenderView'){}

sub end: Private{
    my ( $self, $c ) = @_;

    if ( !$c->res->output ){
    #dont render if redirect or ajax etc
        if ( $c->stash->{'can_rss'} && $c->req->param('rss') ){
            $c->forward( $c->view('RSS') );
        } else {
            $c->forward('render');
        }
    }

    if($c->debug) {
        my $sql_queries = $c->model('MySQL')->get_query_count();
        my $time = $c->model('MySQL')->storage()->debugobj()->{'total_time'};

        $c->log->debug("Queries this request ${sql_queries}: ${time} seconds") if $c->stash->{'sql_queries'};

        if( defined($sql_queries) && $sql_queries > 15) {
            $c->log->warn("****** Are you sure you need ${sql_queries} queries? ******");
        }
        $c->model('MySQL')->reset_count();
    }
}

__PACKAGE__->meta->make_immutable;
