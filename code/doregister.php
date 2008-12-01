<?php
if($_SERVER['REQUEST_METHOD']==='POST') {
	define('MAGIC', true);
    require_once("user.php") ;
    $password0 = mysql_escape_string(strip_tags($_POST["rpassword0"]));
    $password1 = mysql_escape_string(strip_tags($_POST["rpassword1"]));
    $username = mysql_escape_string(htmlentities(strip_tags($_POST["rusername"]), ENT_QUOTES,'UTF-8'));
    $email = mysql_escape_string(strip_tags($_POST["email"]));

    require_once('recaptchalib.php');
    $privatekey = "6LfOtQIAAAAAAK0DnRYVGRWVP0aBtfG158_OYGok";
    $resp = recaptcha_check_answer ($privatekey,
                                    $_SERVER["REMOTE_ADDR"],
                                    $_POST["recaptcha_challenge_field"],
                                    $_POST["recaptcha_response_field"]);
	$user = new user;

    if (!$resp->is_valid) {
    	$_SESSION['username'] = $username;
    	$_SESSION['email'] = $email;
    	$_SESSION['register_error'] = -8;
        header("Location: /login/");
        exit();
    }
    $return = $user->register($username, $password0, $password1, $email);

    if ($return){
        if ($user->login($username, $password0)) {
            if ($_SESSION['ref'] != '' ){
            	if ($_SESSION['ref'] === '/login/') {
            		$_SESSION['ref'] = '/';
            	}
                header("Location: " .$_SESSION['ref']);
                exit();
            }else {
                header("Location: /");
                exit();
            }
        } 
    } else {
	    	$_SESSION['username'] = $username;
	    	$_SESSION['email'] = $email;
	    	$_SESSION['register_error'] = $return;
            header("Location: /login/");
            exit();
    }
} else { 
    header("Location: /error404/");
    exit();
}
?>
