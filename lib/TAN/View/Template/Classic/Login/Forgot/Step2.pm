package TAN::View::Template::Classic::Login::Forgot::Step2;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'login');

    print qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2>Reset Password</h2>
                <img class="newsImg" src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/forgot_password.jpg" alt="Forgot" />
                <p>
                    Enter your new password and click confirm
                </p>
                <form method="post" action="/login/forgot/step2/@{[ $c->stash->{'user_id'} ]}/@{[ $c->stash->{'token'} ]}">
                    <fieldset>
                        <ul>
                            <li>
                                <label for="password0">Password</label>
                                <input id="password0" name="password0" type="password" />
                            </li>
                            <li>
                                <label for="password1">Password again</label>
                                <input id="password1" name="password1" type="password" />
                            </li>

                            <li>
                                <input type="submit" value="Confirm" />
                            </li>
                        </ul>
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

1;
