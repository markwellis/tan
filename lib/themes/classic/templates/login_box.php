<div class='news'>
    <h1>Sign In</h1>
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/login.png' alt='Login' />
    <form id='loginform' method='post' action='/login/'>
        <fieldset>
            <input type='hidden' name='location' value='login' />
            <ul>
                <li>
                    <label for='username'>Username </label>
                    <input id='username' name='username' type='text' class='text_input'/>
                </li>
                <li>
                    <label for='password'>Password </label>
                    <input id='password' name='password' type='password' class='text_input'/>
                </li>
                <li>
                    <a href='/forgot_mail/'>Forgot username/password?</a>
                </li>
                <li>
                    <input type='submit' value='Login' />
                </li>
            </ul>
        </fieldset>
    </form>
</div>