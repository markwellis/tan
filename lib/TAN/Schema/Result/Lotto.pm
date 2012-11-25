package TAN::Schema::Result::Lotto;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components(qw/Core InflateColumn::DateTime/);
__PACKAGE__->table("lotto");
__PACKAGE__->add_columns(qw/lotto_id user_id number confirmed winner txn_id/);
__PACKAGE__->add_columns(
    "created" => {
        data_type => 'datetime',
        datetime_undef_if_invalid => 1,
    },
);
__PACKAGE__->set_primary_key(qw/lotto_id/);

__PACKAGE__->belongs_to(
  "user",
  "TAN::Schema::Result::User",
  { user_id => "user_id" },
);

1;
