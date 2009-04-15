<?php
header("Cache-Control: no-cache, must-revalidate");
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
header ("Pragma: no-cache");
require_once('../header.php');

$m_registration = load_model('m_registration');
$user_id = (int)$_GET['user_id'];
$token = $_GET['token'];

if ($m_registration->compare_token($user_id, $token, 'forgot')){
    if ($_SERVER['REQUEST_METHOD'] === 'POST'){
        if ( check_referer() ){
            if ($m_stash->flash('token_confirmed') === $token ){
                if ($user_id === $m_stash->flash('user_id_confirmed')){
                    $password0 = $_POST['password0'];
                    $password1 = $_POST['password1'];
                    if ($m_registration->validate_passwords_match($password0, $password1)) {
                        if ($m_registration->validate_password_length($password0)) {
                            #good stuff
                            $m_registration->change_password($user_id, $password0);
                            $m_stash->add_message('Your password has been changed');
                            header('location: /login/');
                            exit();
                        } else {
                            $m_stash->add_message('Password needs to be at least 6 letters');
                        }
                    } else {
                        $m_stash->add_message('Passwords do not match');
                    }
                }
            }
        }
    }

    $m_stash->flash('token_confirmed', $token);
    $m_stash->flash('user_id_confirmed', $user_id);

    load_template('lib/open_page');
    load_template('forgot_confirm');
    load_template('lib/close_page');
} else {
    header('location: /forgot_mail/');
    exit();
}
?>
