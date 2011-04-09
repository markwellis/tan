package TAN::Schema::ResultSet::Object;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Data::Page;

my $order_reg = qr/^promoted|plus|minus|views|comments$/;
sub index {
    my ($self, $type, $page, $upcoming, $search, $order, $nsfw, $index_type) = @_;
    
    my $type_reg = TAN->model('CommonRegex')->type;
    if ( ($type ne 'all') && ($type !~ m/$type_reg/) ){
        return undef;
    }

    if ($order !~ m/$order_reg/){
        $order = 'created';
    }
   
    my $not_int_reg = TAN->model('CommonRegex')->not_int;
    $upcoming =~ s/$not_int_reg//g;
    $page =~ s/$not_int_reg//g;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $key = "${index_type}:${type}:${page}:${upcoming}:${order}:${nsfw}";

    my $objects = $self->result_source->schema->cache->get("index:${key}");
    my $pager = $self->result_source->schema->cache->get("pager:${key}");

    if ( !$objects || !$pager ){
        if ($upcoming){
            $order ||= 'created'
        } else {
            $order ||= 'promoted';
            $order = 'promoted' if ($order eq 'created');
        }

        if ($type eq 'all'){
            $type = ['link', 'blog', 'picture', 'poll'];
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
            'deleted' => 'N',
        },
        {
            'order_by' => {
                -desc => $order,
            },
            'page' => $page,
            'rows' => 27,
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

sub random{
    my ($self, $type, $nsfw) = @_;

    my $search = {};
    if ($type eq 'all'){
        my $rand = int(rand(3));
        my @types = ('link', 'blog', 'picture', 'poll');
        $type = $types[$rand];
    }
    $search->{'type'} = $type;
    my %nsfw_opts;
    if ( !defined($nsfw) || !$nsfw ){
        $search->{'nsfw'} = 'N';
    }

    return $self->search( {
        'deleted' => 'N',
        %{$search},
    }, {
        'rows' => 1,
        '+select' => \"(SELECT title FROM ${type} WHERE ${type}.${type}_id = me.object_id) title",
        '+as' => 'title',
        'order_by' => \'RAND()',
    } )->first;

}

sub get{
    my ( $self, $object_id, $type ) = @_;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $cache_key = "object:${object_id}";

    my $object_rs = $self->result_source->schema->cache->get( $cache_key );
    return $object_rs if ( $object_rs );

    my $order_by = ''; #don't know why, but it orders wrong if this is unset, set to '' for speedy correct ordering
    my $prefetch = [
        'user',
    ];

    if ( $type ne 'picture' ){
        my %fetcher; 
        if ( $type eq 'poll' ){
            $fetcher{'answers'} = [];
            $order_by = 'answers.answer_id';
        }

        push( @{$prefetch}, {
            $type => {
                %fetcher,
                'picture' => {
                    'object' => 'picture',
                },
            },
        } );
    } else {
        push(@{$prefetch}, $type);
    }

    $object_rs = $self->find({
        'object_id' => $object_id,
    },{
        'prefetch' => $prefetch,
        'order_by' => $order_by,
    });

    if ( defined( $object_rs ) ){
        $self->result_source->schema->cache->set( $cache_key, $object_rs, 600);
    }
    return $object_rs;
}

1;
