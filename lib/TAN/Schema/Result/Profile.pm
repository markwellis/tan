package TAN::Schema::Result::Profile;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("profile");
__PACKAGE__->add_columns(qw/profile_id/);
__PACKAGE__->add_columns(
    "details" => {
        accessor => '_details',
    },
);
__PACKAGE__->set_primary_key("profile_id");

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
    
    my $key = "profile.${no_bb}:" . $self->id;

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
  { object_id => "profile_id" },
);

1;
