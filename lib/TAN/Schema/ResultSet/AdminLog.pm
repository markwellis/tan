package TAN::Schema::ResultSet::AdminLog;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Storable;

sub log_event {
    my ( $self, $params ) = @_;

    $params->{'bulk'} = freeze( $params->{'bulk'} ) 
        if ref($params->{'bulk'});

    my $admin_log_rs = $self->create( $params );

    return $admin_log_rs;
}

1;
