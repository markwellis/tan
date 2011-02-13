package TAN::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Time::HiRes qw(time);

__PACKAGE__->config(namespace => '');

sub auto: Private{
    my ( $self, $c ) = @_;

## theme shouldn't be set here!!
    $c->stash(
        'theme_settings' => {
            'name' => 'classic',
        },
        'location' => 'all',
        'template_namespace' => 'Template::Classic',
    );
    
    return 1;
}

sub index: Private{
    my ( $self, $c ) = @_;

    $c->forward('/index/index', ['all', 0] );
}

sub default: Path{
    my ( $self, $c ) = @_;

    $c->forward('/error404');
}

sub error404: Local Args(0){
    my ( $self, $c ) = @_;

    $c->stash(
        'error_404' => 1,
        'template' => 'Error::404',
    );

    $c->response->status(404);
}

sub filter: Local Args(0){
    my ( $self, $c ) = @_;

    #bitwise ftw
    $c->nsfw($c->nsfw ^ 1);

    my $ref = $c->req->referer;
    if (!defined($ref)){
        $ref = '/';
    }

    $c->res->redirect($ref);
    $c->detach();
}

sub random: Local Args(1){
    my ( $self, $c, $location ) = @_;
    
    my $location_reg = $c->model('CommonRegex')->location;

    if ( ($location ne 'all') && ($location !~ m/$location_reg/) ){
        $location = 'all';
    }

    my $object = $c->model('MySQL::Object')->random($location, $c->nsfw);

    if ($object){
        $c->res->redirect($object->url);
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
        'template' => 'Chat',
    );
}

sub faq: Local Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page( 3600 );

    $c->stash(
        'page_title' => 'FAQ',
        'template' => 'FAQ',
    );
}

sub google: Path('/google540d7580f0fb6a3b.html'){
    my ( $self, $c ) = @_;

    #google just check if the path exists
    $c->res->output('google-site-verification: google540d7580f0fb6a3b.html');
    $c->detach();
}

sub yahoo: Path('/y_key_242ef28969a04b9c.html'){
    my ( $self, $c ) = @_;

    #yahoo needs this key
    $c->res->output('adf14f5d24cef99f');
    $c->detach();
}

sub robots: Path('/robots.txt'){
    my ( $self, $c ) = @_;

    $c->cache_page(3600);

    $c->res->output(
"User-agent: *
Disallow: /view/*/*/_plus
Disallow: /view/*/*/_minus
Disallow: /view/*/*/_comment
Disallow: /login*
Disallow: /filter*
Disallow: /random*
Disallow: /submit*
Disallow: /profile*
Disallow: /redirect*
Disallow: /chat*
Disallow: /static/cache*
Disallow: /static/user/avatar*
Disallow: /redirect*
Disallow: /tag*
Disallow: /search*

Sitemap: http://thisaintnews.com/sitemap"
    );
    $c->res->header('Content-Type' => 'text/plain');
    $c->detach();
}

sub render: ActionClass('RenderView'){}

sub end: Private{
    my ( $self, $c ) = @_;

    if ( !$c->res->output ){
    #dont render if redirect or ajax etc
        if ( $c->stash->{'can_rss'} && $c->req->param('rss') ){
            $c->stash->{'theme_settings'}->{'name'} = 'rss';
            $c->stash->{'template_namespace'} = 'Template::RSS';
        }
        $c->forward('render');
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
