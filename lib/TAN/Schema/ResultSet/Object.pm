package TAN::Schema::ResultSet::Object;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

TAN::Schema::ResultSet::Comments

=head1 DESCRIPTION

Comments ResultSet

=head1 METHODS

=cut

=head2 index

B<@args = ($location, $page, $upcoming, $order)>

=over

gets the stuff for the index

=back

=cut
sub index {
    my ($self, $location, $page, $upcoming, $order, $nsfw) = @_;
    
    my ($type, $search, $prefetch);

    if ($upcoming){
        $search = \'= 0';
        $order ||= 'me.created'
    } else {
        $search = \'!= 0';
        $order ||= 'me.promoted';
        $order = 'me.promoted' if ($order eq 'created');
    }

    if ($location eq 'all'){
        $type = ['link', 'blog'];
    } else {
        $type = $location;
    }
    
    my %nsfw_opts;
    if ( !defined($nsfw) || !$nsfw ){
        $nsfw_opts{'nsfw'} = 'N';
    }
    
    return $self->search({
        'promoted' => $search,
        'type' => $type,
        %nsfw_opts
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
        'order_by' => {
            -desc => [$order],
        },
        'page' => $page,
        'rows' => 27,
        'prefetch' => [$type, 'user'],
    });
}

=head2 random

B<@args = ($location, $nsfw)>

=over

gets a random article

=back

=cut
sub random{
    my ($self, $location, $nsfw) = @_;

    my $search = {};
    if ($location eq 'all'){
        my $rand = int(rand(3));
        my @types = ('link', 'blog', 'picture');
        $location = $types[$rand];
    }
    $search->{'type'} = $location;
    my %nsfw_opts;
    if ( !defined($nsfw) || !$nsfw ){
        $search->{'nsfw'} = 'N';
    }

    return $self->search(
        $search,
        {
            'rows' => 1,
            '+select' => \"(SELECT title FROM ${location} WHERE ${location}.${location}_id = me.object_id) title",
            '+as' => 'title',
            'order_by' => \'RAND()',
        }
    )->first;

}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
