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
    
    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $key = "${location}:${page}:${upcoming}:${order}:${nsfw}";
    my $indexes = $self->result_source->schema->cache->get("index:${key}");
    my $pager = $self->result_source->schema->cache->get("pager:${key}");

    if ( !$indexes || !$pager ){
        my ($type, $search);

        if ($upcoming){
            $search = \'= 0';
            $order ||= 'created'
        } else {
            $search = \'!= 0';
            $order ||= 'promoted';
            $order = 'promoted' if ($order eq 'created');
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

        my $index_rs = $self->search({
            'promoted' => $search,
            'type' => $type,
            %nsfw_opts
        },
        {
            'order_by' => {
                -desc => [$order],
            },
            'page' => $page,
            'rows' => 27,
            %search_opts
        });

        @{$indexes} = $index_rs->all;
        $pager = {
            'current_page' => $index_rs->pager->current_page,
            'total_entries' => $index_rs->pager->total_entries,
            'entries_per_page' => $index_rs->pager->entries_per_page,
        };

        $self->result_source->schema->cache->set("index:${key}", $indexes, 600);
        $self->result_source->schema->cache->set("pager:${key}", $pager, 600);

#build an index cache..
        my $indexes_in_cache = $self->result_source->schema->cache->get("indexes_in_cache");
        $indexes_in_cache->{$key} = 1;
        $self->result_source->schema->cache->set("indexes_in_cache", $indexes_in_cache, 0);
    }

    my @index;
    foreach my $object ( @{$indexes} ){
        push(@index, $self->get( $object->id, $object->type ));
    }

    return {
        'objects' => \@index,
        'pager' => $pager,
    };
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

    if ( !$object_rs ){  
        $object_rs = $self->find({
            'object_id' => $object_id,
        },{
            '+select' => [
                { 'unix_timestamp' => 'me.created' },
                { 'unix_timestamp' => 'me.promoted' },
                \'(SELECT COUNT(*) FROM views WHERE views.object_id = me.object_id AND type="internal") views',
                \'(SELECT COUNT(*) FROM comments WHERE comments.object_id = me.object_id AND deleted = "N") comments',
                \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="plus") plus',
                \'(SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = me.object_id AND type="minus") minus',
            ],
            '+as' => ['created', 'promoted', 'views', 'comments', 'plus', 'minus'],
            'prefetch' => [$location, 'user'],
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
