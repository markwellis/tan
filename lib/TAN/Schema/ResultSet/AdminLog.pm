package TAN::Schema::ResultSet::AdminLog;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use JSON;

sub log_event {
    my ( $self, $params ) = @_;

    foreach my $item ( qw/bulk other/ ){
        $params->{ $item } = to_json( $params->{ $item } ) 
            if ref( $params->{ $item } );
    }

    my $admin_log_rs = $self->create( $params );

    return $admin_log_rs;
}

1;
