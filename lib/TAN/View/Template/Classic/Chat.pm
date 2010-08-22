package TAN::View::Template::Classic::Chat;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    return qq\
        <ul class="TAN-inside">
            <li>
                <iframe width="100%" height="400" scrolling=no style="border:0" src="https://widget.mibbit.com/?server=irc.mibbit.com%3A%2B6697&chatOutputShowTimes=true&autoConnect=true&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93&nick=@{[ $c->user_exists ? $c->view->html($c->user->username) : '' ]}"></iframe>
            </li>
        </ul>\;
}

1;
