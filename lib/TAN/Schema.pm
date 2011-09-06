package TAN::Schema;

use strict;
use warnings;

use base qw/DBIx::Class::Schema Class::Accessor/;

__PACKAGE__->load_namespaces;

__PACKAGE__->mk_accessors(qw/cache trigger_event/);

# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-11-04 22:01:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LRDXeebcPAIrWOa6Y/DI2Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
