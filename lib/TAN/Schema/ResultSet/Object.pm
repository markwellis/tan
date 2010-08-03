package TAN::Schema::ResultSet::Object;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Data::Page;

=head1 NAME

TAN::Schema::ResultSet::Comments

=head1 DESCRIPTION

Comments ResultSet

=head1 METHODS

=cut

=head2 index

B<@args = ($location, $page, $upcoming, $order)>

=over

returns ($index_rs, $pager)

=back

=cut
my $int_reg = qr/\D+/;
my $order_reg = qr/^promoted|plus|minus|views|comments$/;

sub index {
    my ($self, $location, $page, $upcoming, $search, $order, $nsfw, $index_type) = @_;
    
    my $location_reg = TAN->model('CommonRegex')->location;
    if ( ($location ne 'all') && ($location !~ m/$location_reg/) ){
        return undef;
    }

    if ($order !~ m/$order_reg/){
        $order = 'created';
    }
    
    $upcoming =~ s/$int_reg//g;
    $page =~ s/$int_reg//g;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $key = "${index_type}:${location}:${page}:${upcoming}:${order}:${nsfw}";

    my $objects = $self->result_source->schema->cache->get("index:${key}");
    my $pager = $self->result_source->schema->cache->get("pager:${key}");

    if ( !$objects || !$pager ){
        my $type;

        if ($upcoming){
            $order ||= 'created'
        } else {
            $order ||= 'promoted';
            $order = 'promoted' if ($order eq 'created');
        }

        if ($location eq 'all'){
            $type = ['link', 'blog', 'picture', 'poll'];
        } else {
            $type = $location;
        }
        
        my %search_opts;
        if ( ($order ne 'created') || ($order ne 'promoted') ){
            if ( $order eq 'comments' ){
                %search_opts = (
                    '+select' => [\'(SELECT COUNT(*) FROM comments WHERE comments.object_id = me.object_id AND deleted = "N") comments'],
                    '+as' => ['comments'],
                );
            } elsif ( $order eq 'views' ){
                %search_opts = (
                    '+select' => [\'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id AND type="internal") views'],
                    '+as' => ['views'],
                );
            } elsif ( $order eq 'plus' ){
                %search_opts = (
                    '+select' => [\'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="plus") plus'],
                    '+as' => ['plus'],
                );
            } elsif ( $order eq 'minus' ){
                %search_opts = (
                    '+select' => [\'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="minus") minus'],
                    '+as' => ['minus'],
                );
            }
        }

        #order by newest to lastest
        if ( ($order eq 'created') || ($order eq 'promoted') ){
            $order = [$order];
        } else {
            if ( $upcoming ){
                $order = [$order, 'created'];
            } else {
                $order = [$order, 'promoted'];
            }
        }
        
        if ( (!defined($nsfw) || !$nsfw) && !defined($search->{'nsfw'}) ){
            $search->{'nsfw'} = 'N';
        }

        my $index_rs = $self->search({
            %{$search},
            'type' => $type,
        },
        {
            'order_by' => {
                -desc => $order,
            },
            'page' => $page,
            'rows' => 27,
            %search_opts
        });

        return undef if !$index_rs;
    
        @{$objects} = $index_rs->all;

        # we construct our own pager so the count(*) from sql 
        # runs now instead of later (cacheable)
        $pager = Data::Page->new($index_rs->pager->total_entries, $index_rs->pager->entries_per_page, $index_rs->pager->current_page);

        $self->result_source->schema->cache->set("index:${key}", $objects, 600);
        $self->result_source->schema->cache->set("pager:${key}", $pager, 600);

#build an index cache..
        my $indexes_in_cache = $self->result_source->schema->cache->get("indexes_in_cache") || {};
        $indexes_in_cache->{$key} = 1;
        $self->result_source->schema->cache->set("indexes_in_cache", $indexes_in_cache, 0);
    }

    return ($objects, $pager);
}


=head2 clear_index_cache

B<@args = (undef)>

=over

clears the index page cache

=back

=cut
sub clear_index_cache{
    my ( $self ) = @_;

    my $indexes_in_cache = $self->result_source->schema->cache->get("indexes_in_cache");
    foreach my $key ( keys(%{$indexes_in_cache}) ){
        $self->result_source->schema->cache->remove("index:${key}");
        $self->result_source->schema->cache->remove("pager:${key}");
        delete($indexes_in_cache->{$key});
    }
    $self->result_source->schema->cache->set("indexes_in_cache", $indexes_in_cache);
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

=head2 get

B<@args = ($object_id, $location)>

=over

gets an article

=back

=cut
sub get{
    my ($self, $object_id, $location) = @_;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $object_rs = $self->result_source->schema->cache->get('object:' . $object_id);

    my $prefetch = [
        'user',
    ];

    if ( $location eq 'poll' ){
        push(@{$prefetch}, {
            'poll' => {
                'answers' => ['votes'],
            },
        });
    } else {
        push(@{$prefetch}, $location);
    }

    if ( !$object_rs ){  
        $object_rs = $self->find({
            'object_id' => $object_id,
        },{
            '+select' => [
                { 'unix_timestamp' => 'me.created' },
                { 'unix_timestamp' => 'me.promoted' },
                \'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id AND type="internal") views',
                \'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id AND type="external") external',
                \'(SELECT COUNT(*) FROM comments WHERE comments.object_id = me.object_id AND deleted = "N") comments',
                \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="plus") plus',
                \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="minus") minus',
            ],
            '+as' => ['created', 'promoted', 'views', 'external', 'comments', 'plus', 'minus'],
            'prefetch' => $prefetch,
            'order_by' => '',
        });
        $self->result_source->schema->cache->set('object:' . $object_id, $object_rs, 600);
    }
    return $object_rs;
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
