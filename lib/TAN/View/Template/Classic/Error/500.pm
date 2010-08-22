package TAN::View::Template::Classic::Error::500;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'errors');

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2 class="TAN-type-link">Massive Cockup (500)</h2> 
                <img src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/mokey_facepalm.jpg" width="279" height="412" alt="Monkey" />
            </li>
        </ul>\;
}

1;
