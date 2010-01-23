<?php
require_once('../header.php');

$location = isset($_GET['location']) ? $_GET['location'] : '';
$edit = isset($_GET['edit']) ? (int)$_GET['edit'] : null;

if ( !$m_user->logged_in() || !$m_user->admin() ){
    header('location: /');
    exit();
}

$m_admin = load_model('m_admin'); 

if ( isset($_GET['username']) ){
    $username = strtolower($_GET['username']);
    $user_details = $m_admin->get_user($username);

    header("Cache-Control: no-cache, must-revalidate");
    header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
    header ("Pragma: no-cache");
    header('Content-type: application/json');

    print json_encode($user_details);
    exit();
}

if ( isset($_POST['ban_id']) ){
    $user_id = $_POST['ban_id'];
    #if we're deleteing someone... :'(
    $session_info = $m_admin->ban_user($user_id);
    if ( isset($session_info) ){
        $m_stash->add_message("purge complete :(");
        header('location: /');
        exit();
    } else {
        $m_stash->add_message("fail :/");
        header('location: /');
        exit();
    }
}

array_push($m_stash->js_includes, $m_stash->theme_settings['js_path'] . '/admin.js');

ob_start();
load_template("admin");
$output_page = ob_get_contents();
ob_clean();

load_template('lib/open_page');
echo $output_page;
load_template('lib/close_page');
?>
