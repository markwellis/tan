package TAN::View::Template::Classic::Error::404;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'errors');

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2 class="TAN-type-link">Page Not found (404)</h2> 
                <img src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/error/404.jpg" width="279" height="412" alt="404" />
            </li>
        </ul>\;
}

1;
