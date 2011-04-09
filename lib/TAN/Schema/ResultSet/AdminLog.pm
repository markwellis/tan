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

#no moose here :(
my $prefetch = [
    {
        'object' => [qw/link blog picture poll/]
    },
    qw/admin user comment/
];

sub index{
    my ( $self, $page ) = @_;

    my $admin_logs = $self->search( {}, {
        'prefetch' => $prefetch,
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

sub view{
    my ( $self, $id ) = @_;

    my $admin_log = $self->find( {
        'log_id' => $id
    }, {
        'prefetch' => $prefetch,
    } );

    if ( !$admin_log ){
        Exception::Simple->throw;
    }

    return $admin_log;
}

1;
