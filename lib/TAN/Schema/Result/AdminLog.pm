package TAN::Schema::Result::AdminLog;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("admin_log");
__PACKAGE__->add_columns( qw/log_id admin_id action reason bulk user_id comment_id object_id created/ );
__PACKAGE__->set_primary_key("log_id");

__PACKAGE__->belongs_to(
  "admin",
  "TAN::Schema::Result::User",
  { "foreign.user_id" => "self.admin_id" },
);

__PACKAGE__->has_one(
  "user",
  "TAN::Schema::Result::User",
  { "foreign.user_id" => "self.user_id" },
);

__PACKAGE__->might_have(
  "comment",
  "TAN::Schema::Result::Comment",
  { "foreign.comment_id" => "self.comment_id" },
);

__PACKAGE__->might_have(
  "object",
  "TAN::Schema::Result::Object",
  { "foreign.object_id" => "self.object_id" },
);

1;
