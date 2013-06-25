package TAN::Controller::Index;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {'index' => 1};
    },
);

sub clear_index_caches:
    Event(object_created)
    Event(object_promoted)
    Event(object_deleted)
    Event(object_updated)
    Event(mass_objects_deleted)
{
    my ( $self, $c ) = @_;

    $c->model('MySQL::Object')->clear_index_cache();
    $c->clear_cached_page('/index.*');
}

sub index :Path Args(2) {
    my ( $self, $c, $type, $upcoming ) = @_;

    $c->cache_page( 60 );

    my $page = $c->req->param('page') || 1;

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    if ( $page =~ m/$not_int_reg/ ){
        $page = 1;
    }
    $c->req->params->{'page'} = $page;

    if ( $upcoming =~ m/$not_int_reg/ ){
        $upcoming = 1;
    }
    $upcoming ||= 0;

    #redirect to somewhere sensible if someone has made up some random url...
    if ('/' . $c->req->path() ne "/index/${type}/${upcoming}/" && '/' . $c->req->path() ne '/'){
        $c->res->redirect("/index/${type}/${upcoming}/", 301 );
        $c->detach();
    } 

    my $order = $c->req->param('order') || 'created';

    my $search = {};
    if ( $upcoming ){
        $search->{'promoted'} = \'= 0';
    } else {
        $search->{'promoted'} = \'!= 0';
    }
    my ( $objects, $pager ) = $c->model('MySQL::Object')->index( $type, $page, $upcoming, $search, $order, $c->nsfw, "index" );

    if ( $objects ){
        $c->stash(
            'index' => $c->model('Index')->indexinate($c, $objects, $pager),
            'type' => $type,
            'location' => $type,
            'page' => $page,
            'upcoming' => $upcoming,
            'order' => $order,
            'page_title' => ($upcoming ? 'Upcoming ' : 'Promoted ') . ucfirst($type) . ($type ne 'all' ? 's' : '' ),
            'can_rss' => 1,
#            'no_ads' => $c->nsfw, #no ads if nsfw filter is off
        );
        if ( $type eq 'picture' ){
            $c->stash->{'fancy_picture_index'} = 1;
        }
    }
    
    $c->stash->{'template'} = 'index.tt';
}

__PACKAGE__->meta->make_immutable;
