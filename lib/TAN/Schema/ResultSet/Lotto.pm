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

1;
