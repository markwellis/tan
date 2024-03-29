package TAN::Controller::Index;
use Moose;
use namespace::autoclean;
use MooseX::MethodAttributes;

extends qw/Catalyst::Controller/;

use Scalar::Util qw/looks_like_number/;

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

    $c->model('DB::Object')->clear_index_cache();
}

sub index :Path Args(2) {
    my ( $self, $c, $type, $upcoming ) = @_;

    my $page = $c->req->param('page') || 1;

    if ( !looks_like_number( $page ) ){
        $page = 1;
    }
    $c->req->params->{'page'} = $page;

    if ( !looks_like_number( $upcoming ) ){
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
        $search->{'promoted'} = undef;
    } else {
        $search->{'promoted'} = {'!=' => undef};
    }
    my ( $objects, $pager ) = $c->model('DB::Object')->index( $type, $page, $upcoming, $search, $order, $c->nsfw, "index" );
    my @object_ids = map { $_->id } @{$objects};
    my $me_plus_minus = $c->user_exists ? $c->user->me_plus_minus( \@object_ids ) : undef;

    if ( $objects ){
        $c->stash(
            me_plus_minus   => $me_plus_minus,
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
