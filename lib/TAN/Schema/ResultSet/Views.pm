package TAN::Schema::ResultSet::Views;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub whos_online {
    my ( $self ) = @_;

    my $who = $self->result_source->schema->cache->get("whos_online");

    if ( !$who ){
        my $whos_online_rs = $self->search({
            created => {
                '>' => \"(current_timestamp - interval '5' minute)",
            },
        },{
            select   => [{ DISTINCT => 'me.user_id' } ],
            as       => 'user_id',
            join     => 'user',
            rows     => 30,
            prefetch => 'user',
        });

        #make this into an array ref
        $who = [];
        foreach my $user ( $whos_online_rs->all ){
            push( @{$who}, $user->user );
        }
        
        $self->result_source->schema->cache->set("whos_online", $who, 60);
    }

    return $who;
}

1;
