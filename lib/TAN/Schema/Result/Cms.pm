use utf8;
package TAN::Schema::Result::Cms;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';
__PACKAGE__->load_components("TimeStamp");
__PACKAGE__->table("cms");
__PACKAGE__->add_columns(
  "cms_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "url",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "content",
  { accessor => "_content", data_type => "mediumtext", is_nullable => 0 },
  "user_id",
  {
    data_type => "mediumint",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "revision",
  { data_type => "mediumint", extra => { unsigned => 1 }, is_nullable => 0 },
  "created",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "title",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "comment",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "deleted",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "system",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "nowrapper",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("cms_id");
__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2014-08-29 19:24:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MsVg0Hs33dvaoTxTE8SVCw

__PACKAGE__->add_columns( '+created' => { set_on_create => 1 } );

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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
