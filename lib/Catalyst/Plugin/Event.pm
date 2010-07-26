package Catalyst::Plugin::Event;

use Moose::Role;
use namespace::autoclean;
use Text::SimpleTable;

=head1 NAME

Catalyst::Model::Event

=head1 DESCRIPTION

Allows you to register and trigger custom events as necessary, 
say for cache managment, index rebuilding etc.

=head1 METHODS

=cut

my $_registered_events;

after 'setup_finalize' => sub {
    my ( $c, @args ) = @_;

    foreach my $action ( values %{$c->dispatcher->_action_hash} ){
        foreach my $event ( @{$action->attributes->{'Event'}} ){
            push(@{$_registered_events->{$event}}, '/' . $action->reverse );
        }
    }

    if ( $c->debug ){
        my $events_table = Text::SimpleTable->new( [ 35, 'Event' ], [ 36, 'Action' ] );
        foreach my $event ( keys(%{$_registered_events}) ){
            foreach my $action ( @{$_registered_events->{$event}} ){
                $events_table->row( $event, $action );
                $event = '';
            }
        }

        $c->log->debug( "Registered Events:\n" . $events_table->draw . "\n" );
    }
};

sub trigger_event{
    my ( $c, $event, @args ) = @_;

    return undef if ( !defined($_registered_events->{ $event }) );
    my @actions = @{$_registered_events->{ $event }};
    return undef if ( !scalar(@actions) );
    foreach my $action ( @actions ){
        $c->forward($action, \@args);
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
