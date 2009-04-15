<div class='news'>
    <h1>Reset Password</h1>
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/forgot_password.jpg' alt='Login' />
    Enter your new password and click confirm
    <form id='loginform' method='post' action=''>
        <input type='hidden' name='location' value='login' />
        <table>
            <tr>
                <td>
                    <label for='password0'>Password </label>
                </td>
                <td>
                    <input id='password0' name='password0' type='password'/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for='password1'>Password again</label>
                </td>
                <td>
                    <input id='password1' name='password1' type='password'/>
                </td>
            </tr>
        </table>
        <input type='submit' value='Confirm' />
    </form>
    <br />
</div>