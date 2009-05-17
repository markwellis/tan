<div class='news'>
    <h1>Forgotten details</h1>
    Please enter your email address, you will be mailed your information
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/forgot_password.jpg' alt='Forgot' />
    <form id='forgotform' method='post' action='' style='margin-top:50px;'>
        <fieldset>
            <ul>
                <li>
                    <label for='email'>Enter you email address</label>
                    <input id='email' name='email' type='text' class='text_input'/>
                </li>
                <li>
                    <input type='submit' value='Mail Me!' />
                </li>
            </ul>
        </fieldset>
    </form>
</div>