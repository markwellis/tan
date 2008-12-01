<?php
require_once('code/header.php');

require_once('code/user.php');
$user = new user();
if(!$user->isLoggedIn()){
    require_once('code/recaptchalib.php');
    $publickey = "6LfOtQIAAAAAAKjR5kiq9YLFjG80_bLST2fB696F";
    $errorCap = null;
    $title = 'Login/Register';
    $error= (int)$_SESSION['register_error'];
    $errorCodes = Array("-6" => "Please complete the form",
        "-5" => "Passwords do not match",
        "-4" => "Username can only contain letters or numbers",
        "-3" => "Username already exists",
        "-2" => "Password needs to be a minium of 6 characters",
        "-1" => "Thats not a valid email address",
        "-7" => "Email address already asscoiated with username",
        "-8" => "Captcha words incorrect");

    if ($error != 0) {
        $middle .= "<h2>".$errorCodes[$error]."</h2>";
    }
	$_SESSION['ref'] = $_SERVER['HTTP_REFERER'];
    $middle .= "
        <div class='news'>
        <h1>Sign In</h1>
        <img class='newsImg' src='/sys/images/login.png' alt='Login' />
        <form action='/code/dologin.php' id='loginform' method='post'>
        <p><label style='width:70px;color:#000000;' for='username'>Username </label><input class='textInput' id='username' name='username' type='text'/></p>
        <p><label style='width:70px;color:#000000;' for='password'>Password </label><input class='textInput' id='password' name='password' type='password'/></p>
        <p><input type='submit' value='Login'/></p>
        </form>
        </div>
        
        <div class='news'>
        <h1>Register</h1>
        <img class='newsImg' src='/sys/images/register.png' alt='Register' />
        <form action='/code/doregister.php' id='regform' method='post'>
        <p><label style='width:70px;color:#000000;' for='rusername'>Username </label><input class='textInput' id='rusername' name='rusername' type='text'";
    if ($_GET['username'] != '') {
        $middle .= "value='" . strip_tags($_SESSION['username']) . "'";
    } 
    $middle .= "/></p><p><label style='width:70px;' for='email'>Email address </label><input class='textInput' id='email' name='email' type='text'";
    if ($_SESSION["email"] != '') {
        $middle .= "value='" . strip_tags($_SESSION['email']) . "'";
    } 
    $middle .= "/></p>
        <p><label style='width:70px;color:#000000;' for='rpassword0'>Password </label><input class='textInput' id='rpassword0' name='rpassword0' type='password'/></p>
        <p><label style='width:70px;color:#000000;' for='rpassword1'>Password again </label><input class='textInput' id='rpassword1' name='rpassword1' 
        type='password'/></p>
        <script type='text/javascript'>
        document.getElementById('regform').setAttribute(\"autocomplete\", \"off\"); 
        </script>
        <div style='margin-left:200px;margin-top:10px;'>";
        $middle .= recaptcha_get_html($publickey, $errorCap);
        $middle .= "</div><br />
            <p><input type='submit' value='Register'/></p>
            </form></div>";
} else {
    header("Location: /");
    exit();
}

require_once('code/footer.php');
?>
