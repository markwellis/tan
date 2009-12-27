package TAN::DBProfiler;

use base 'DBIx::Class::Storage::Statistics';

use strict;
use Time::HiRes qw(time);
use Text::Wrap;

my $start;

sub query_start {
    if (defined($ENV{'CATALYST_DEBUG'})){
        my ( $self, $sql, @params ) = @_;

        $self->{'start_time'} = time();

        my $regex = qr/\?/;
        foreach my $param ( @params ){
            $sql =~ s/$regex/$param/;
        }
        $self->{'full_sql_with_params'} = $sql;
    }
}

sub query_end {
    my ( $self ) = @_;

    $self->{'_queries'}++;
    if (defined($ENV{'CATALYST_DEBUG'})){
        my $sql = shift;
        my @params = @_;

        my $time = sprintf("%0.4f",time() - $self->{start_time});
        $self->{total_time} += $time;

        my $error = "\n";
        if ($time > 0.05) {
            $error .= "\n\n" . 'v='x18 . 'v SLOW v' . '=v'x18 . "\n\n";
        }
        $error .= 'Query #' . $self->{'_queries'} . ": execution time = ${time}\n" 
            . Text::Wrap::wrap("\t","\t",$self->{'full_sql_with_params'}) . "\n\n";
        if ($time > 0.05) {
            $error .= "\n" . '^='x40 . "\n\n\n";
        }

        warn $error;
    }
}

1;
