package TAN::Schema::ResultSet::Object;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Data::Page;

my $order_reg = qr/^(?:promoted|plus|minus|views|comments|score)$/;
sub index {
    my ($self, $type, $page, $upcoming, $search, $order, $nsfw, $index_type) = @_;
    
    if ( 
        ( $type ne 'all' ) 
        && ( !TAN->model('object')->valid_public_object( $type ) )
    ){
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
            $type = TAN->model('Object')->public;
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
            $search->{'nsfw'} = 0;
        }

        my $index_rs = $self->search({
            %{$search},
            'type' => $type,
            'deleted' => 0,
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
        my $types = TAN->model('Object')->public;
        $type = $types->[ int(rand(scalar(@{$types} - 1))) ];
    }
    $search->{'type'} = $type;
    my %nsfw_opts;
    if ( !defined($nsfw) || !$nsfw ){
        $search->{'nsfw'} = 0;
    }

    return $self->search( {
        'deleted' => 0,
        %{$search},
    }, {
        'rows' => 1,
        '+select' => $self->result_source->schema->resultset( ucfirst( $type ) )->search( {
            "${type}_id" => { 
                '=' => { 
                    '-ident' => 'me.object_id' 
                },
            },
        }, {
            'alias' => 'sub',
        } )->get_column('title')->as_query,
        '+as' => 'title',
        'order_by' => \'random()',
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
        $object_rs->update_score;
        $self->result_source->schema->cache->set( $cache_key, $object_rs, 600);
    }

    return $object_rs;
}

sub _recent {
    my ( $self ) = @_;

    $self->search( {
            type            => { '!=' => 'profile'},
            'me.deleted'    => 0,
        }, {
            rows            => 20,
            order_by        => {-desc => 'me.created'},
            prefetch        => [
                    'link',
                    'blog',
                    'picture',
                    'poll',
                    'video',
                    'forum',
                ],
        } );
}

sub recent_promoted {
    my ( $self ) = @_;

    $self->_recent->search( {
            promoted    => { '!=' => undef },
        } );
}

sub recent_upcoming {
    my ( $self ) = @_;

    $self->_recent->search( {
            promoted    => undef,
        } );
}

1;
