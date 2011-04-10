package TAN::Schema::ResultSet::AdminLog;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use JSON;
use Exception::Simple;

sub log_event {
    my ( $self, $params ) = @_;

    foreach my $item ( qw/bulk other/ ){
        $params->{ $item } = to_json( $params->{ $item } ) 
            if ref( $params->{ $item } );
    }

    my $admin_log_rs = $self->create( $params );

    return $admin_log_rs;
}

sub index{
    my ( $self, $page ) = @_;

    my $admin_logs = $self->search( {}, {
        'prefetch' => [
            {
                'object' => [qw/link blog picture poll/]
            },
            qw/admin user comment/,
        ],
        'page' => $page,
        'rows' => 50,
        'order_by' => {
            '-desc' => 'me.created',
        },
    } );

    if ( !$admin_logs ){
        Exception::Simple->throw;
    }

    return $admin_logs;
}

1;
