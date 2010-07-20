package TAN::Controller::Root;
use strict;
use warnings;

use parent 'Catalyst::Controller';

use Time::HiRes qw(time);
#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

TAN::Controller::Root

=head1 DESCRIPTION

Root controller

=head1 EXAMPLE

I</>

=over

forwards to /index/all/0/1/

=back

=head1 METHODS

=cut

=head2 auto: Private

B<@args = undef>

=over

stashes the start time in start_time

sets up the theme settings B<*SHOULDNT BE HERE*>

sets default location to all

=back

=cut
sub auto: Private{
    my ( $self, $c ) = @_;

## theme shouldn't be set here!!
    my $theme = 'classic';
    $c->stash(
        'start_time' => time(),    
        'theme_settings' => {
            'name' => $theme,
            'path' => $c->config->{'static_path'} . "/themes/${theme}",
        },
        'location' => 'all',
    );
    
    return 1;
}

=head2 index: Path Args(0)

B<@args = undef>

=over

forwards to /index/all/0/

=back

=cut
sub index: Private{
    my ( $self, $c ) = @_;

    $c->forward('/index/index', ['all', 0] );
}

=head2 default: Path 

B<@args = undef>

=over

loads error 404 template

=back

=cut
sub default: Path{
    my ( $self, $c ) = @_;

    $c->forward('/error404');
}

=head2 error404: Local Args(0)

B<@args = undef>

=over

loads error 404 template

=back

=cut
sub error404: Local Args(0){
    my ( $self, $c ) = @_;

    $c->stash(
        'error_404' => 1,
        'template' => 'errors/404.tt',
    );

    $c->response->status(404);
}

=head2 filter: Local Args(0)

B<@args = undef>

=over

enables/disables NSFW filter

redirects to referer or / 

=back

=cut
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

=head2 random: Local Args(1)

B<@args = ($location)>

=over

validates params

loads a random object (based on $location) and redirects to it

404's

=back

=cut
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

=head2 chat: Local Args(0)

B<@args = undef>

=over

loads chat template... 

=back

=cut
sub chat: Local Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page( 3600 );

    $c->stash(
        'page_title' => 'Chat',
        'template' => 'chat.tt',
    );
}

=head2 faq: Local Args(0)

B<@args = undef>

=over

loads chat template... 

=back

=cut
sub faq: Local Args(0){
    my ( $self, $c ) = @_;

    $c->cache_page( 3600 );

    $c->stash(
        'page_title' => 'FAQ',
        'template' => 'faq.tt',
    );
}

=head2 google: Path('/googledc796c4dad406173.html')

B<@args = undef>

=over

google confirm key

=back

=cut
sub google: Path('/google540d7580f0fb6a3b.html'){
    my ( $self, $c ) = @_;

    #google just check if the path exists
    $c->res->output(1);
    $c->detach();
}

=head2 yahoo: Path('/googledc796c4dad406173.html')

B<@args = undef>

=over

yahoo confirm key

=back

=cut
sub yahoo: Path('/y_key_242ef28969a04b9c.html'){
    my ( $self, $c ) = @_;

    #yahoo needs this key
    $c->res->output('adf14f5d24cef99f');
    $c->detach();
}

=head2 robots: Path('/robots.txt')

B<@args = undef>

=over

robots.txt

=back

=cut
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

=head2 render: ActionClass('RenderView') 

B<@args = undef>

=over

RenderView

=back

=cut
sub render: ActionClass('RenderView'){
    my ( $self, $c ) = @_;

    $c->stash->{'time'} = sub { return time(); };
}

=head2 end: Private 

B<@args = undef>

=over

forwards to render

if debug warns sql output

=back

=cut
sub end: Private{
    my ( $self, $c ) = @_;

    if ( !$c->res->output || ($c->res->status < 300) ){
    #dont render if redirect or ajax etc

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

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
