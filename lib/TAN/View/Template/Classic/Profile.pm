package TAN::View::Template::Classic::Profile;
use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'profile');

    my $out = '<ul class="TAN-inside">';

    foreach my $user ( $c->stash->{'users'}->all ){
        my $username = $c->view->html($user->username);
        $out .= qq\
            <li class="TAN-profile-avatar">
                <a href="${username}/" title="${username}">
                    <img class="TAN-news-avatar" src="@{[ $user->avatar($c) ]}" alt="${username}"/><br/>
                    ${username}
                </a>
            </li>\;
    }
    $out .= '</ul>';
    return $out;
}

1;
