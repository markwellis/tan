package TAN::View::Template::Classic::Error::404;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'errors');

    print qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2 class="TAN-type-link">Page Not found (404)</h2> 
                <img src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/mokey_facepalm.jpg" width="279" height="412" alt="Monkey" />
            </li>
        </ul>\;
}

1;
