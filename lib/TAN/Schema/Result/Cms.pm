package TAN::Schema::Result::Cms;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("cms");
__PACKAGE__->add_columns(qw/cms_id url revision user_id title comment  deleted system nowrapper/);
__PACKAGE__->add_columns(
    "content" => {
        accessor => '_content',
    },
    "created" => {
        data_type => 'datetime',
        datetime_undef_if_invalid => 1,
    },
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
