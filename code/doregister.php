<?php
if($_SERVER['REQUEST_METHOD']==='POST') {
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

    if (!$resp->is_valid) {
        header("Location: ../login/-8/$email/$username");
        exit();
    }

    $user = new user;

    $return = $user->register($username, $password0, $password1, $email);
    if ($return==1){
        if ($user->login($username, $password0)) {
            if ($_POST["rref"] != ''){
                header("Location: " .$_POST["rref"]);
            }else {
                header("Location: /");
            }
        } 
    } else {
            header("Location: ../login/$return/$email/$username");
            exit();
    }
} else { die('error');}
?>
