package TAN::View::Template::Classic::Error::500;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'errors');

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2 class="TAN-type-link">Massive Cockup (500)</h2> 
                <img src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/boris-johnson.jpg" width="360" height="300" alt="Borris" />
            </li>
        </ul>\;
}

1;
