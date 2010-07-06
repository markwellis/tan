package KinoSearch::Search::Result::TAN;
use Moose;
use Moose::Util::TypeConstraints;

has 'id'  => (
    'isa' => 'Num',
    'is' => 'ro',
    'required' => 1,
);

has 'score'  => (
    'isa' => 'Num',
    'is' => 'ro',
    'required' => 1,
);

subtype 'ObjectType'
    => as 'Str'
    => where { /^(?:link|blog|picture)$/ }
    => message { "$_ invalid type" };

has 'type'  => (
    'isa' => 'ObjectType',
    'is' => 'ro',
    'required' => 1,
);

has 'title'  => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

has 'description'  => (
    'isa' => 'Str',
    'is' => 'ro',
    'required' => 1,
);

__PACKAGE__->meta->make_immutable;

1;
