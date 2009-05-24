<div class='news'>
    <h1>Reset Password</h1>
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/forgot_password.jpg' alt='Login' />
    Enter your new password and click confirm
    <form id='loginform' method='post' action=''>
        <fieldset>
        <input type='hidden' name='location' value='login' />
            <ul>
                <li>
                    <label for='password0'>Password </label>
                    <input id='password0' name='password0' type='password' class='text_input'/>
                </li>
                <li>
                    <label for='password1'>Password again</label>
                    <input id='password1' name='password1' type='password' class='text_input'/>
                </li>
                <li>
                    <input type='submit' value='Confirm' />
                </li>
            </ul>
        </fieldset>
    </form>
</div>