use utf8;
package TAN::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07041 @ 2014-08-11 21:01:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kW4tfk3YPdQrAmj98EXV9g

has cache => (
    is  => 'rw',
);

has trigger_event => (
    is  => 'rw',
);

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;
