package TAN::Controller::Index;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Index

=head1 DESCRIPTION

Main index page

=head1 EXAMPLE

I</index/$location/$upcoming/$page/>

=over

$location => all|link|blog|picture 

$upcoming  => boolean

$page => page number

=back

=head1 METHODS

=cut

=head2 index: Path: Args(3)

B<@args = ($location, $upcoming, $page)>
B<@params = (order)>

=over

validates the params

gets the index items

loads index template

=back

=cut
my $location_reg = qr/^(all|link|blog|picture)$/;
my $int_reg = qr/\D+/;
my $order_reg = qr/^(promoted|plus|minus|views|comments)$/;

sub index :Path :Args(3) {
    my ( $self, $c, $location, $upcoming, $page ) = @_;

    $c->stash->{'cache_time'} = 120;

    if ($location !~ m/$location_reg/){
        $location = 'all';
    }

    $upcoming =~ s/$int_reg//g;
    $page =~ s/$int_reg//g;

    $upcoming ||= 0;
    $page ||= 1;
    
    
    my $order = $c->req->param('order') || 'created';
    if ($order !~ m/$order_reg/){
        $order = 'created';
    }
    $c->stash->{'order'} = $order;

    #redirect to somewhere sensible if someone has made up some random url...
    if ('/' . $c->req->path() ne "/index/${location}/${upcoming}/${page}/" && '/' . $c->req->path() ne '/'){
        $c->res->redirect("/index/${location}/${upcoming}/${page}/", 301 );
        $c->detach();
    }

    $c->stash->{'location'} = $location;
    $c->stash->{'page'} = $page;
    $c->stash->{'upcoming'} = $upcoming;
    
    my $index_objects = $c->model('MySQL::Object')->index( $location, $page, $upcoming, $order, $c->nsfw );
    my @index = $index_objects->all;

    if ( $c->user_exists ){
        my @ids = map($_->object_id, @index);
        my $meplus_minus = $c->model('MySQL::PlusMinus')->meplus_minus($c->user->user_id, \@ids);

        foreach my $object ( @index ){
            if ( defined($meplus_minus->{ $object->object_id }->{'plus'}) ){
                $object->{'meplus'} = 1;
            } 
            if ( defined($meplus_minus->{ $object->object_id }->{'minus'}) ){
                $object->{'meminus'} = 1;  
            }
        }
    }

    $c->stash->{'index_objects'} = {
        'objects' => \@index,
        'pager' => $index_objects->pager,
    };

    if ( !$c->stash->{'index_objects'}->{'objects'} ){
        $c->forward('/default');
        $c->detach();
    }
    
    $c->stash->{'template'} = 'index.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
