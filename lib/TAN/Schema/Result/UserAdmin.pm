package TAN::Schema::Result::UserAdmin;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_admin");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
  "admin_id",
  { data_type => "BIGINT", default_value => undef, is_nullable => 0, size => 20 },
);
__PACKAGE__->set_primary_key(qw/user_id admin_id/);

1;
