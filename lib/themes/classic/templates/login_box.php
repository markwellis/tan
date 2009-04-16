<div class='news'>
    <h1>Sign In</h1>
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/login.png' alt='Login' />
    <form id='loginform' method='post' action='/login/'>
        <input type='hidden' name='location' value='login' />
        <table>
            <tr>
                <td>
                    <label for='username'>Username </label>
                </td>
                <td>
                    <input id='username' name='username' type='text' class='text_input'/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for='password'>Password </label>
                </td>
                <td>
                    <input id='password' name='password' type='password' class='text_input'/>
                </td>
            </tr>
        </table>
        <input type='submit' value='Login' />
        <a href='/forgot_mail/'>Forgot username/password?</a>
    </form>
    <br />
</div>