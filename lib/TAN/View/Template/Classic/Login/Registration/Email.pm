package TAN::View::Template::Classic::Login::Registration::Email;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $user_id = $c->stash->{'user_id'};
    my $token = $c->stash->{'token'};

    return qq\
        <html>
        <h1>Welcome to This Aint News</h1><br />
        <br />
        You're just one step away from using the site:<br />
        <br />
        Please click <a href="@{[ $c->uri_for('/login/registration/confirm', $user_id, $token) ]}">here</a><br/>
        or copy and paste @{[ $c->uri_for('/login/registration/confirm', $user_id, $token) ]} into your browsers address bar<br />
        <br />
        Thanks for registering<br />
        </html>\;
}

1;
