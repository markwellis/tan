package TAN::View::Template::Classic::Submit;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'submit');
    push(@{$c->stash->{'js_includes'}}, 'submit');

    my $flashed_object = $c->flash->{'object'};
    if ( $flashed_object ){
        $c->stash->{'object'} = $flashed_object;
    }
    print qq\
        <ul class="TAN-inside">
            <li class="TAN-news">\;

    $c->view->template("Submit::@{[ ucfirst($c->stash->{'location'}) ]}");

    print qq\
            </li>
        </ul>\;
}

1;
