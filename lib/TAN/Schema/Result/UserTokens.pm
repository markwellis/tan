package TAN::Schema::Result::UserTokens;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("user_tokens");
__PACKAGE__->add_columns(qw/token_id user_id token expires type/);
__PACKAGE__->set_primary_key("token_id");

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

1;
