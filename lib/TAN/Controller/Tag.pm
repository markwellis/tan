package TAN::Controller::Tag;
use strict;
use warnings;

use parent 'Catalyst::Controller';

=head1 NAME

TAN::Controller::Tag

=head1 DESCRIPTION

Tag Controller

=head1 EXAMPLE

I</tag/$tag>

=over

lists things with this tag

=back

=head1 METHODS

=cut

=head2 index: Path('') Args(1) 

B<@args = ($tag)>

=over

loads things with $tag

=back

=cut
sub index: Path('') Args(1) {
    my ( $self, $c, $tag ) = @_;

    $c->cache_page( 60 );
#get list of things with $tag
#assemble index

    my $page = $c->req->param('page') || 0;

    my $tags_rs = $c->model('MySQL::Tags')->search({
        'tag' => $tag,
    })->first;

    if ( !defined($tags_rs) ){
        $c->forward('/default');
        $c->detach;
    }

    my %search_opts;
    if ( !$c->nsfw ){
        $search_opts{'nsfw'} = 'N';
    }

    my $index_count = $tags_rs->objects->search({
        %search_opts
    })->count;

    my $index_rs = $tags_rs->objects->search({
        %search_opts,
    },
    {
        'page' => $page,
        'rows' => 27,
        'order_by' => {
            '-desc' => 'me.created',
        },
        'prefetch' => ['link', 'blog', 'picture'],
    });

    my @index;
    foreach my $object ( $index_rs->all ){
        push(@index, $c->model('MySQL::Object')->get( $object->id, $object->type ));
    }

    if ( $c->user_exists ){
        my @ids = map($_->id, @index);
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

    if ( !scalar(@index) ){
        $c->forward('/default');
        $c->detach;
    }

    my $pager = {
        'current_page' => $page,
        'total_entries' => $index_count,
        'entries_per_page' => 27,
    };

    $c->stash->{'index'} = {
        'objects' => \@index,
        'pager' => $pager,
    };

    $c->stash->{'template'} = 'tag.tt';
}

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
