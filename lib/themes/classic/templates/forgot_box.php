<div class='news'>
    <h1>Forgotten details</h1>
    Please enter your email address, you will be mailed your information
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/forgot_password.jpg' alt='Forgot' />
    <form id='forgotform' method='post' action='' style='margin-top:50px;'>
        <table>
            <tr>
                <td>
                    <label for='email'>Enter you email address</label>
                </td>
                <td>
                    <input id='email' name='email' type='text' class='text_input'/>
                </td>
            </tr>
        </table>
        <input type='submit' value='Mail Me!' />
        <br />
    </form>
    <br />
</div>