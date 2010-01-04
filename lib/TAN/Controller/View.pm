package TAN::Controller::View;

use strict;
use warnings;
use parent 'Catalyst::Controller';

my $int_reg = qr/\D+/;

=head1 NAME

TAN::Controller::View

=head1 DESCRIPTION

View Controller

=head1 EXAMPLE

I</view/$location/$id/$title>

=over

view article

=over

$location => link|blog|picture

$id = int

$title = url title

=back

=back

=head1 METHODS

=cut

=head2 location: PathPart('view') Chained('/') CaptureArgs(1)

B<@args = ($location)>

=over

checks the location is valid

=back

=cut
my $location_reg = qr/^link|blog|picture$/;
sub location: PathPart('view') Chained('/') CaptureArgs(1){
    my ( $self, $c, $location ) = @_;

    if ($location !~ m/$location_reg/){
        $c->forward('/default');
        $c->detach();
    }
    $c->stash->{'location'} = $location;
}


=head2 index: PathPart('') Chained('location') Args(2) 

B<@args = ($id, $title)>

=over

loads the article

=back

=cut
sub index: PathPart('') Chained('location') Args(2) {
    my ( $self, $c, $id, $title ) = @_;

#check
# id is valid
# url matches (seo n that)
# display article
# load comments etc
    

    $id =~ s/$int_reg//g;

    if ( $id ){
        my $object = $c->model('MySQL::Object')->find({
            'object_id' => $id,
        },{
            '+select' => [
                { 'unix_timestamp' => 'me.created' },
                { 'unix_timestamp' => 'me.promoted' },
                \'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id) views',
                \'(SELECT COUNT(*) FROM comments WHERE comments.object_id = me.object_id) comments',
                \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="plus") plus',
                \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="minus") minus',
            ],
            '+as' => ['created', 'promoted', 'views', 'comments', 'plus', 'minus'],
            'prefetch' => [$c->stash->{'location'}, 'user', 'comments'],
            'order_by' => '',
        });
        $c->stash->{'object'} = $object;

        $c->stash->{'template'} = 'view.tt';
    } 
    
    if ( !defined($c->stash->{'template'}) ){
        $c->foward('/default');
        $c->detach();
    }
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
