package TAN::View::Template::Classic::Lib::PlusMinus;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'js_includes'}}, 'plusminus');
    my $object = $c->stash->{'object'};
    my $type = $object->type;
    
    print qq\
        <div class="TAN-plusminus right">
            <div class="TAN-plus">
                <span>@{[ $object->get_column('plus') ]}</span>
                <a href="/view/${type}/@{[ $object->$type->id ]}/_plus" @{[ ($object->{'meplus'}) ? 'class="TAN-plus-selected"' : '' ]}>IsNews</a>
            </div>
            <div class="TAN-minus">
                <span>@{[ $object->get_column('minus') ]}</span>
                <a href="/view/${type}/@{[ $object->$type->id ]}/_minus" @{[ ($object->{'meminus'}) ? 'class="TAN-minus-selected"' : '' ]}>AintNews</a>
            </div>
        </div>\;
}

1;
