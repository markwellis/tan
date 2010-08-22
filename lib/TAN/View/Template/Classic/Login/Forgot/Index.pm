package TAN::View::Template::Classic::Login::Forgot::Index;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'login');

    print qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2>Forgotten details</h2>
                <img class="newsImg" src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/forgot_password.jpg" alt="Forgot" />
                <p>
                    Please enter your email address, you will be emailed your information
                </p>
                <form method="post" action="/login/forgot/step1">
                    <fieldset>
                        <ul>
                            <li>
                                <label for="email">Enter you email address</label>
                                <input id="email" name="email" type="text" />
                            </li>
                            <li>
                                <input type="submit" value="Mail Me!" />
                            </li>
                        </ul>
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

1;
