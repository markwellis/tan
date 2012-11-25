package TAN::Schema::ResultSet::Cms;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Exception::Simple;

sub index{
    my ( $self, $page ) = @_;

    my $cms_pages = $self->search( {
        'revision' => $self->_max_revision,
    }, {
        'page' => $page,
        'rows' => 50,
        'group_by' => 'url',
        'order_by' => {
            '-desc' => 'me.created',
        },
    } );

    if ( !$cms_pages ){
        Exception::Simple->throw;
    }

    return $cms_pages;
}

sub menu_items{
    my ( $self ) = @_;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $grouped_items = $self->result_source->schema->cache->get("cms:menu_items");

    if ( !defined( $grouped_items ) ){
        my $items = $self->search( {
            'deleted' => 0,
            'system' => 0,
            'revision' => $self->_max_revision,
        } );

        if ( $items ){
            foreach my $item ( $items->all ){
                push( @{$grouped_items}, [ $item->title, $item->url ] );
            }
        }
        if ( $grouped_items ){
            $self->result_source->schema->cache->set("cms:menu_items", $grouped_items, 3600);
        } else {
            $self->result_source->schema->cache->set("cms:menu_items", [], 3600);
        }
    }

    return $grouped_items;
}

sub load{
    my ( $self, $url ) = @_;

    local $DBIx::Class::ResultSourceHandle::thaw_schema = $self->result_source->schema;

    my $cms_page = $self->result_source->schema->cache->get("cms:page:${url}");

    if ( !defined( $cms_page ) ){
        $cms_page = $self->search( {
            'url' => $url,
            'revision' => $self->_max_revision,
            'deleted' => 0,
        } )->first;
        
        $self->result_source->schema->cache->set("cms:page:${url}", $cms_page, 3600) if ( $cms_page );
    }

    return $cms_page;
}

sub _max_revision{
    my ( $self ) = @_;

    return {
        '=' => $self->search( {
            'url' => { '=' => { '-ident' => 'me.url' } }
        },
        {
            'alias' => 'sub',
        } )->get_column('revision')->max_rs->as_query,
    };
}

1;
