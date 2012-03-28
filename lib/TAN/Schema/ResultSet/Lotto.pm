package TAN::Schema::ResultSet::Lotto;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub used_numbers{
    my ( $self, $page ) = @_;

    my $numbers = {};
    eval{
        $self->result_source->schema->txn_do(sub{
            my @time = localtime( time );
            my $month = $time[4] + 1;
            my $year = $time[5] + 1900;

            my $numbers_rs = $self->search( { -and => [
                \[ 'MONTH(created) = ?', [ plain_value => $month ] ],
                \[ 'YEAR(created) = ?', [ plain_value => $year ] ],
            ] } );

            foreach my $number ( $numbers_rs->all ){
                $numbers->{ $number->number } = 1;
            }
        });
    };

    return $numbers;
}

sub number_available{
    my ( $self, $number ) = @_;
    
    my @time = localtime( time );
    my $month = $time[4] + 1;
    my $year = $time[5] + 1900;

    if ( 
        $self->find( { 
            'number' => $number,
            -and => [
                \[ 'MONTH(created) = ?', [ plain_value => $month ] ],
                \[ 'YEAR(created) = ?', [ plain_value => $year ] ],
            ]
        } )
    ){
        return 0;
    }
    
    return 1;
}

sub set_unavailble{
    my ( $self, $number, $user_id ) = @_;
    
    return $self->create( {
        'number' => $number,
        'user' => $user_id,
        'confirmed' => 'N',
        'winner' => 'N',
    } );
}

1;
