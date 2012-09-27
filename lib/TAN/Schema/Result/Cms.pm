package TAN::Schema::Result::Cms;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("cms");
__PACKAGE__->add_columns(
  "cms_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "url",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255 },
  "created",
  {
      data_type => 'datetime',
      is_nullable => 0,
      datetime_undef_if_invalid => 1,
      size => 14,
  },
  "revision",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "content",
  {
    data_type => "MEDIUMTEXT",
    default_value => undef,
    is_nullable => 0,
    size => 16777215,
    accessor => '_content',
  },
  "title",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255 },
  "comment",
  { data_type => "VARCHAR", default_value => undef, is_nullable => 0, size => 255 },
  "deleted",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "system",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
  "nowrapper",
  { data_type => "ENUM", default_value => "N", is_nullable => 0, size => 1 },
);
__PACKAGE__->set_primary_key("cms_id");

sub content{
    my ( $self ) = @_;

    my $key = "cms:content:" . $self->url;

    my $content = $self->result_source->schema->cache->get( $key );
    if ( !$content ){
        $content = TAN->model('ParseHTML')->parse( $self->_content, 1 );
        $self->result_source->schema->cache->set( $key, $content, 600 );
    } else {
#decode cached coz otherwise its double encoded!
        utf8::decode( $content );
    }

    return $content;
}

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

1;
