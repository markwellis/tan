package TAN::View::Template::Classic::Login::Forgot::Email;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    my $user_id = $c->stash->{'user'}->id;
    my $token = $c->stash->{'token'};
    
    print qq\
        <html>
        <br />
        Your username is: @{[ $c->view->html($c->stash->{'user'}->username) ]}<br />
        <br />
        Please click <a href="@{[ $c->uri_for('/login/forgot/step2', $user_id, $token) ]}">here</a> to reset your password if you need to.<br/>
        or copy and paste @{[ $c->uri_for('/login/forgot/step2', $user_id, $token) ]} into your browsers address bar<br />
        </html>\;
}

1;
