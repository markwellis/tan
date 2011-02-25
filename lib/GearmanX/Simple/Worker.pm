package GearmanX::Simple::Worker;
use strict;
use warnings;

use App::Daemon;
use Gearman::Worker;

sub new{
    my ( $invocant, $servers, $functions ) = @_;

    my $class = ref($invocant) || $invocant;
    my $self = { };
    bless($self, $class);

    $self->{'worker'} = Gearman::Worker->new;
    $self->{'worker'}->job_servers( @{$servers} );

    if ( $functions && ( ref( $functions ) eq 'HASH' ) ){
        foreach my $function ( keys( %{$functions} ) ){
            $self->register( $function => $functions->{ $function } );
        }
    }

    return $self;
}

sub register{
    my ( $self, $name, $sub ) = @_;

    $self->{'worker'}->register_function( $name => $sub );
}

sub work{
    my ( $self ) = @_;

    App::Daemon::daemonize();
    $self->{'worker'}->work while 1;
}

1;
