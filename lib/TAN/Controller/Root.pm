package TAN::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Time::HiRes qw(time);
#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{'namespace'} = '';


=head1 NAME

TAN::Controller::Root

=head1 DESCRIPTION

Root controller

=head1 EXAMPLE

I</>

=over

forwards to /index/all/0/1/

=back

=head1 METHODS

=cut

=head2 auto: Private

B<@args = undef>

=over

stashes the start time in start_time

sets up the theme settings B<*SHOULDNT BE HERE*>

sets default location to all

=back

=cut
sub auto: Private{
    my ( $self, $c ) = @_;

    $c->stash->{'start_time'} = time();
    
## this shouldn't be here
    my $theme = 'classic'; 
    $c->stash->{'theme_settings'} = {
        'name' => $theme,
        'path' => $c->config->{'static_path'} . "/themes/${theme}",
    };
## end
    
    # set a default location
    $c->stash->{'location'} = 'all';
    
    return 1;
}

=head2 index: Path: Args(0)

B<@args = undef>

=over

forwards to /index/all/0/1/

=back

=cut
sub index: Path: Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('/index/index', ['all', 0, 1]);
}

=head2 default: Path 

B<@args = undef>

=over

loads error 404 template

=back

=cut
sub default: Path {
    my ( $self, $c ) = @_;

    $c->stash->{'error_404'} = 1;
    $c->stash->{'template'} = 'error404.tt';
    $c->response->status(404);
}

=head2 render: ActionClass('RenderView') 

B<@args = undef>

=over

RenderView

=back

=cut
sub render: ActionClass('RenderView') {}

=head2 end: Private 

B<@args = undef>

=over

forwards to render

if debug warns sql output

=back

=cut
sub end: Private {
    my ( $self, $c ) = @_;

    $c->stash->{'time'} = sub { return time(); };

    $c->forward('render');

    if($c->debug) {
        my $sql_queries = $c->model('MySQL')->get_query_count();
        my $time = $c->model('MySQL')->storage()->debugobj()->{'total_time'};

        $c->log->debug("Queries this request ${sql_queries}: ${time} seconds") if $c->stash->{'sql_queries'};

        if( defined($sql_queries) && $sql_queries > 15) {
            $c->log->warn("****** Are you sure you need ${sql_queries} queries? ******");
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
