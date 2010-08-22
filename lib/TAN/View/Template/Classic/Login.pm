package TAN::View::Template::Classic::Login;

use base 'Catalyst::View::Perl::Template';

sub process{
    my ( $self, $c ) = @_;

    push(@{$c->stash->{'css_includes'}}, 'login');

    return qq\
        <ul class="TAN-inside">
            <li class="TAN-news">
                <h2>Sign In</h2>
                <img class="newsImg" src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/login.png" alt="Login" />
                <form id="loginform" method="post" action="/login/login">
                    <fieldset>
                        <ul>
                            <li>
                                <label for="username" class="login_label">Username </label>
                                <input id="username" name="username" type="text" />
                            </li>
                            <li>
                                <label for="password" class="login_label">Password </label>
                                <input id="password" name="password" type="password" />
                            </li>
                            <li>
                                <a href="/login/forgot/">Forgot username/password?</a>
                            </li>
                            <li>
                                <input type="submit" value="Login" />
                            </li>
                        </ul>
                    </fieldset>
                </form>
            </li>
            <li class="TAN-news TAN-news-alternate">
                <h2>Register</h2>
                <img class="newsImg" src="@{[ $c->stash->{'theme_settings'}->{'image_path'} ]}/register.png" alt="Register" />
                <form action="/login/registration" id="regform" method="post">
                    <fieldset>
                        <ul>
                            <li>
                                <label for="rusername" class="login_label">Username </label>
                                <input id="rusername" name="rusername" type="text" value="@{[ $c->view->html($c->flash->{'username'}) ]}" />
                            </li>
                            <li>
                                <label for="remail" class="login_label">Email address </label>
                                <input id="remail" name="remail" type="text" value="@{[ $c->view->html($c->flash->{'email'}) ]}" />
                            </li>
                            <li>
                                <label for="rpassword0" class="login_label">Password </label>
                                <input id="rpassword0" name="rpassword0" type="password" />
                            </li>
                            <li>
                                <label for="rpassword1" class="login_label">Password again </label>
                                <input id="rpassword1" name="rpassword1" type="password" />
                            </li>
                            <li>
                                @{[ $c->stash->{'recaptcha_html'} ]}
                            </li>
                            <li>
                                <input type="submit" value="Register"/>
                            </li>
                        </ul>
                        <script type="text/javascript">
                            //<![CDATA[
                            document.getElementById("regform").setAttribute("autocomplete", "off"); 
                            //]]>
                        </script>
                    </fieldset>
                </form>
            </li>
        </ul>\;
}

1;
