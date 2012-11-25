package TAN::Schema::Result::Blog;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("blog");
__PACKAGE__->add_columns(qw/blog_id picture_id title description/);
__PACKAGE__->add_columns(
    "details" => {
        accessor => '_details',
    },
);
__PACKAGE__->set_primary_key("blog_id");

sub details{
    my ( $self ) = @_;

    return $self->get_details(0);
}

sub details_nobb{
    my ( $self ) = @_;

    return $self->get_details(1);
}

sub get_details{
    my ( $self, $no_bb ) = @_;

    $no_bb ||= 0;
    
    my $key = "blog.${no_bb}:" . $self->id;

    my $details = $self->result_source->schema->cache->get($key);
    if ( !$details ){
        $details = TAN->model('ParseHTML')->parse( $self->_details, $no_bb );
        $self->result_source->schema->cache->set($key, $details, 600);
    } else {
#decode cached coz otherwise its double encoded!
        utf8::decode($details);
    }

    return $details;
}

__PACKAGE__->belongs_to(
  "object",
  "TAN::Schema::Result::Object",
  { object_id => "blog_id" },
);
__PACKAGE__->belongs_to(
  "picture",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);

1;
