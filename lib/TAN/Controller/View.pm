package TAN::Controller::View;
use Moose;
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

sub type: PathPart('view') Chained('/') CaptureArgs(2){
    my ( $self, $c, $type, $object_id ) = @_;

    if (
        !$c->model('object')->valid_public_object( $type )
        || !looks_like_number( $object_id )
    ) {
        $c->detach('/not_found');
    }

    my $object = $c->model('MySQL::Object')->get( $object_id, $type );

    if ( !defined($object) ){
        $c->detach('/not_found');
    }

    if ( $object->deleted ){
        $c->detach('/gone');
    }

    $c->stash(
        object      => $object,
        object_id   => $object_id,
        type        => $type,
        location    => $type,
    );
}

sub index_no_title: PathPart('') Chained('type') Args(0){
    my ( $self, $c ) = @_;

    $c->forward('index');
}

sub index: PathPart('') Chained('type') Args(1) {
    my ( $self, $c, $title ) = @_;

    $c->cache_page( 60 );
#check
# object_id is valid
# url matches (seo n that)
# display article
# load comments etc
    my $type = $c->stash->{'type'};
    my $object = $c->stash->{object};

    my $url = $object->url;
    if ( $c->req->uri->path ne $url ){
        $c->res->redirect( $url, 301 );
        $c->detach();
    }

#this should be cached
    my @comments = $c->model('MySQL::Comment')->search( {
            'me.object_id' => $object->id,
            'me.deleted' => 0,
        }, {
            'prefetch' => ['user', {
                'object' => $type,
            }],
            'order_by' => 'me.created',
        } )->all;
    my @comment_ids = map { $_->id } @comments;
    my $me_plus_minus = $c->user_exists ? $c->user->me_plus_minus( [$object->id], \@comment_ids ) : undef;

    $c->stash(
        me_plus_minus           => $me_plus_minus,
        comments                => \@comments,
        object                  => $object,
        page_title              => $object->$type->title || undef,
        template                => 'view.tt',
        page_meta_description   => $object->$type->description || undef,
    );
}

__PACKAGE__->meta->make_immutable;
