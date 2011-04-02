package TAN::View::Template::Classic::Error::401;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'errors');

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2 class="TAN-type-link">Access Denied (401)</h2> 
                <img src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/error/401.jpg" width="320" height="319" alt="401" />
            </li>
        </ul>\;
}

1;
