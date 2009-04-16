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
        <input type='hidden' name='location' value='register' />
        <table>
            <tr>
                <td>
                    <label for='rusername'>Username </label>
                </td>
                <td>
                    <input id='rusername' name='rusername' type='text' value='<? echo $m_stash->flash('username'); ?>' class='text_input'/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for='email'>Email address </label>
                </td>
                <td>
                    <input id='email' name='email' type='text' value='<? echo $m_stash->flash('email'); ?>' class='text_input'/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for='rpassword0'>Password </label>
                </td>
                <td>
                    <input id='rpassword0' name='rpassword0' type='password' class='text_input'/>
                </td>
            </tr>
            <tr>
                <td>
                    <label for='rpassword1'>Password again </label>
                </td>
                <td>
                    <input id='rpassword1' name='rpassword1' type='password' class='text_input'/>
                </td>
            </tr>
        </table>
        <div>
            <? echo $m_stash->recaptcha_html ?>
        </div>
        <input type='submit' value='Register'/>
        <script type='text/javascript'>
            //<![CDATA[
            document.getElementById('regform').setAttribute("autocomplete", "off"); 
            //]]>
        </script>
    </form>
    <br />
</div>