package TAN::Schema::Result::Forum;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("forum");
__PACKAGE__->add_columns(qw/forum_id picture_id title description/);
__PACKAGE__->add_columns(
    "details" => {
        accessor => '_details',
  },
);
__PACKAGE__->set_primary_key("forum_id");

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
    
    my $key = "forum.${no_bb}:" . $self->id;

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
  { object_id => "forum_id" },
);
__PACKAGE__->belongs_to(
  "picture",
  "TAN::Schema::Result::Picture",
  { picture_id => "picture_id" },
);

1;
