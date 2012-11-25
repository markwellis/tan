package TAN::Controller::View;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON;
use Try::Tiny;

has '_mobile' => (
    'is' => 'ro',
    'isa' => 'HashRef',
    'default' => sub{
        return {'index' => 1};
    },
);

sub type: PathPart('view') Chained('/') CaptureArgs(2){
    my ( $self, $c, $type, $object_id ) = @_;

    if ( !$c->model('object')->valid_public_object( $type ) ){
        $c->detach('/default');
    }

    my $not_int_reg = $c->model('CommonRegex')->not_int;
    $object_id =~ s/$not_int_reg//g;
    if ( !$object_id ){
        $c->forward('/default');
        $c->detach();
    }

    $c->stash(
        'object_id' => $object_id,
        'type' => $type,
        'location' => $type,
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
    my $object = $c->model('MySQL::Object')->get($c->stash->{'object_id'}, $type);

    if ( !defined($object) ){
        $c->forward('/default');
        $c->detach();
    }

    if ( $object->deleted ){
        $c->forward('/gone');
        $c->detach();
    }

    my $url = $object->url;
    if ( $c->req->uri->path ne $url ){
        $c->res->redirect( $url, 301 );
        $c->detach();
    }

    if ( $c->user_exists ){
        #get me plus info
        my $meplus_minus = $object->plus_minus->meplus_minus( $c->user->user_id );

        if ( defined($meplus_minus->{ $object->object_id }->{'plus'}) ){
            $object->{'meplus'} = 1;
        }
        if ( defined($meplus_minus->{ $object->object_id }->{'minus'}) ){
            $object->{'meminus'} = 1;  
        }
    }

#this should be cached
    @{$c->stash->{'comments'}} = 
    $c->model('MySQL::Comments')->search({
        'me.object_id' => $c->stash->{'object_id'},
        'me.deleted' => 0,
    },{
        'prefetch' => ['user', {
            'object' => $type,
        }],
        'order_by' => 'me.created',
    })->all;

    $c->stash(
        'object' => $object,
        'page_title' => $object->$type->title || undef,
        'template' => 'view.tt',
        'page_meta_description' => $object->$type->description || undef,
    );
}

__PACKAGE__->meta->make_immutable;
