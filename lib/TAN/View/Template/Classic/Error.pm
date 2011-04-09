package TAN::View::Template::Classic::Error;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'errors');

    my $error_code = $c->stash->{'error_code'};

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2 class="TAN-type-link">${error_code} @{[ $c->stash->{'error'} ]}</h2> 
                <img src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/error/${error_code}.jpg" alt="${error_code}" />
            </li>
        </ul>\;
}

1;
