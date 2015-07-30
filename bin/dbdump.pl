use strict;
use warnings;

use FindBin '$Bin';
use lib "../$Bin";

use DBIx::Class::Schema::Loader qw/ make_schema_at /;

make_schema_at(
    'TAN::Schema',
    {
        dump_directory      => './lib',
        use_moose           => 1,
        components          => 'TimeStamp',
        generate_pod        => 0,
        moniker_map         => {
            cms     => 'Cms',
            views   => 'Views', #TODO fix this
        },
        col_accessor_map    => sub {
            my ( $column_name, $accessor, $info, $cb ) = @_;
            my $table = $info->{table};

            if ( $table eq 'comments' ) {
                return $cb->( {
                    created => '_created',
                    comment => '_comment',
                } );
            }

            if ( $table eq 'cms' ) {
                return $cb->( {
                    content => '_content',
                } );
            }

        },
    },
    [
        'dbi:DB:tan',
        'thisaintnews',
        'caBi2ieL',
    ],
);
