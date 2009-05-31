<?php
/**
 * Created on 29 Dec 2008
 * Copyright 2008 - mark
 * License is in the root directory, entitled LICENSE
 * @package register_box
 */
?>
<div class='news'>
    <h1>Register</h1>
    <br/>
    <img class='newsImg' src='<? echo $m_stash->theme_settings['image_path'] ?>/register.png' alt='Register' />
    <form action='' id='regform' method='post'>
        <fieldset>
            <input type='hidden' name='location' value='register' />
            <ul>
                <li>
                    <label for='rusername' class='login_label'>Username </label>
                    <input id='rusername' name='rusername' type='text' value='<? echo $m_stash->flash('username'); ?>' class='text_input'/>
                </li>
                <li>
                    <label for='email' class='login_label'>Email address </label>
                    <input id='email' name='email' type='text' value='<? echo $m_stash->flash('email'); ?>' class='text_input'/>
                </li>
                <li>
                    <label for='rpassword0' class='login_label'>Password </label>
                    <input id='rpassword0' name='rpassword0' type='password' class='text_input'/>
                </li>
                <li>
                    <label for='rpassword1' class='login_label'>Password again </label>
                    <input id='rpassword1' name='rpassword1' type='password' class='text_input'/>
                </li>
                <li>
                    <? echo $m_stash->recaptcha_html ?>
                </li>
                <li>
                    <input type='submit' value='Register'/>
                </li>
            </ul>
            <script type='text/javascript'>
                //<![CDATA[
                document.getElementById('regform').setAttribute("autocomplete", "off"); 
                //]]>
            </script>
        </fieldset>
    </form>
</div>