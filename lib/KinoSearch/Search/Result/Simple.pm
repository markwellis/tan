package KinoSearch::Search::Result::Simple;
use Moose;
use namespace::autoclean;

use Moose::Util::TypeConstraints;

sub BUILD{
    my ( $self, $config ) = @_;

    foreach my $key ( keys(%{$config}) ){
        has $key => (
            'is' => 'ro',
            'isa' => 'Any',
            'lazy' => 1,
            'default' => $config->{$key},
        );
    }
}

1;
