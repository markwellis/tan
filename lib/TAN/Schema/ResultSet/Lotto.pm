package TAN::Schema::ResultSet::Lotto;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub used_numbers{
    my ( $self ) = @_;

    my $numbers = {};
    foreach my $number ( $self->this_month->all ){
        $numbers->{ $number->number } = 1;
    }

    return $numbers;
}

sub number_available{
    my ( $self, $number ) = @_;
    
    if ( 
        $self->this_month->find( { 
            'number' => $number,
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

sub confirm_number{
    my ( $self, $number, $txn_id ) = @_;

    my $number_rs = $self->this_month->find( { 
        'number' => $number,
    } );

    $number_rs->update( {
        'confirmed' => 'Y',
        'txn_id' => $txn_id,
    } );
}

sub remove_number{
    my ( $self, $number ) = @_;

    $self->this_month->find( { 
        'number' => $number,
        'confirmed' => 'N',
    } )->delete;
}

sub this_month{
    my ( $self ) = @_;

    my @time = localtime( time );
    my $month = $time[4] + 1;
    my $year = $time[5] + 1900;
    
    return $self->search( {
         -and => [
            \[ 'MONTH(created) = ?', [ plain_value => $month ] ],
            \[ 'YEAR(created) = ?', [ plain_value => $year ] ],
        ],
    } );

1;
