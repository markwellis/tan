<?php
require_once('../header.php');

if ($_GET['logout']) {
    $m_user->logout();
    if ($_SERVER['HTTP_REFERER'] != ''){
        header("location: {$_SERVER['HTTP_REFERER']}");
    } else {
        header("location: /");
    }
    exit();
}

if ($m_user->logged_in()){
    $m_stash->add_message('You are already logged in');
    header("location: /");
    exit();
}

if ($_GET['token'] && $_GET['user_id']) {
    $user_id = (int)$_GET['user_id'];
    $m_registration = load_model('m_registration');
    
    if ($m_registration->compare_token($user_id, $_GET['token'])){
        $m_registration->confirm($user_id);
        $m_stash->add_message('Your email has been confirmed, please login');
    } else {
        $m_stash->add_message('There has been a problem');
    }
    header("location: /login/");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST'){
    if ( check_referer() ){
        if ($_POST['location'] === 'login'){
            $password = strip_tags($_POST["password"]);
            $username = htmlentities(strip_tags($_POST["username"]),ENT_QUOTES,'UTF-8');
            $login = $m_user->login($username, $password);
            if ($login) {
                $ref = $m_stash->flash('ref');
                if ($ref == '' || strpos($ref, '/login/') || strpos($ref, '/forgot_') ){
                    $ref = '/';
                }
                $m_stash->add_message("You have logged in");
                header("location: {$ref}");
                exit();
            } elseif ($login === false) {
                $m_stash->add_message("Couldn't find you with that username and password");
            } elseif ($login === null) {
                $m_stash->add_message("You need to confirm your email address");
            }
        } elseif ($_POST['location'] === 'register') {
            require_once(THIRD_PARTY_PATH . '/recaptchalib.php');
            $resp = recaptcha_check_answer(
                RECAPTCHA_PRIVATE_KEY,
                $_SERVER["REMOTE_ADDR"],
                $_POST["recaptcha_challenge_field"],
                $_POST["recaptcha_response_field"]
            );

            if (!$resp->is_valid) {
                $m_stash->flash('username', $username);
                $m_stash->flash('email', $email);
                $m_stash->add_message('Captcha words do not match');
                header("location: /login/");
                exit();
            }

            $m_registration = load_model('m_registration');
            $password0 = strip_tags($_POST["rpassword0"]);
            $password1 = strip_tags($_POST["rpassword1"]);
            $username = htmlentities(strip_tags($_POST["rusername"]), ENT_QUOTES,'UTF-8');
            $email = strip_tags($_POST["email"]);

            //returns null on success, or string containing error
            $return = $m_registration->new_user($username, $password0, $password1, $email);
            if ($return === null) {
                    $m_stash->token = $m_registration->token;
                    $m_stash->user_id = $m_registration->user_id;
                    $m_mail = load_model('m_mail');
                    $m_mail->to = $email;
                    $m_mail->subject = 'Confirm email address';

                    ob_start();
                    load_template('lib/confirm_registration');
                    $m_mail->message = ob_get_contents();
                    ob_clean();
                    $m_mail->send();

                    $ref = $m_stash->flash('ref');
                    if ($ref == '' || preg_match('/\/login\//', $ref)){
                        $ref = '/';
                    }
                    $m_stash->add_message('Thanks for registering, you will recieve a confirmation email shortly');
            } else {
                $m_stash->flash('username', $username);
                $m_stash->flash('email', $email);
                $m_stash->add_message($return);
                $ref = '/login/';
            }
            header("location: {$ref}");
            exit();
        }
    }

    // login failed, or user not posting from one of our pages.
    header("Location: /login/" . time());
    exit();
}

$m_stash->flash('ref', $_SERVER['HTTP_REFERER']);

require_once(THIRD_PARTY_PATH . '/recaptchalib.php');
$error_cap = null;
$m_stash->recaptcha_html = recaptcha_get_html(RECAPTCHA_PUBLIC_KEY, $error_cap);

load_template('lib/open_page');

load_template('login_box');
load_template('register_box');

load_template('lib/close_page');
?>