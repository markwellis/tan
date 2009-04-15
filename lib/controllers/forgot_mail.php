<?php
header("Cache-Control: no-cache, must-revalidate");
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
header ("Pragma: no-cache");
require_once('../header.php');

if ( $_SERVER['REQUEST_METHOD'] === 'POST' ){
    if ( check_referer() ){
        $email = $_POST['email'];
        if ($email){
            $m_registration = load_model('m_registration');
            if ( $m_registration->validate_email($email) ){
                $m_stash->user_id = $m_registration->check_email($email);
                if ( $m_stash->user_id ){
                    $m_registration->setup_token($m_stash->user_id, 'forgot');
                    $m_stash->token = $m_registration->token;
                    $m_stash->username = $m_user->user_id_to_username($m_stash->user_id);
                    $m_mail = load_model('m_mail');
                    $m_mail->to = $email;
                    $m_mail->subject = 'User details';

                    ob_start();
                    load_template('lib/forgot_email');
                    $m_mail->message = ob_get_contents();
                    ob_clean();

                    $m_mail->send();
                    $m_stash->add_message('Email sent');
                    header('location: /');
                    exit();
                } else {
                     $m_stash->add_message('Not a valid email');
                }
            } else {
                $m_stash->add_message('Not a valid email');
            }
        } else {
            $m_stash->add_message('Please complete the form');
        }
    }
}

load_template('lib/open_page');
load_template('forgot_box');
load_template('lib/close_page');
?>