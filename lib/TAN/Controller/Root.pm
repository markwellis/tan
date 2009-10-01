package TAN::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Time::HiRes qw(time);
#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

TAN::Controller::Root - Root Controller for TAN

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

sub auto: Private{
    my ( $self, $c ) = @_;

    $c->stash->{'start_time'} = time();
    return 1;
}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('/index/index', ['all', 0, 1]);
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub render : ActionClass('RenderView') { }

sub end : Private {
    my ( $self, $c ) = @_;

    $c->stash->{'end_time'} = time();
    $c->stash->{'sql_queries'} = $c->model('MySQL')->get_query_count();

    $c->forward('render');

    if($c->debug) {
        my $time = $c->model('MySQL')->storage()->debugobj()->{total_time};

        $c->log->debug("Queries this request " . $c->stash->{'sql_queries'} . ": $time seconds");

        if($c->stash->{'sql_queries'} > 15) {
            $c->log->warn("****** Are you sure you need " . $c->stash->{'sql_queries'} . " queries? ******");
        }

        $c->model('MySQL')->reset_count();
    }
}
=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
