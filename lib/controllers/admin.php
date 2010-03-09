<?php
require_once('../header.php');

# check logged in and is admin
if ( !$m_user->logged_in() || !$m_user->admin() ){
    header('location: /');
    exit();
}

$m_admin = load_model('m_admin'); 

## get logic
if ( isset($_GET['link_id']) ){
#link
    $get_id = $_GET['link_id'];
    $get_type = 'link';
} elseif ( isset($_GET['blog_id']) ){
#blog
    $get_id = $_GET['blog_id'];
    $get_type = 'blog';
} elseif ( isset($_GET['picture_id']) ){
#picture
    $get_id = $_GET['picture_id'];
    $get_type = 'picture';
} elseif ( isset($_GET['user_id']) ){
#user
    $get_id = $_GET['user_id'];
    $get_type = 'user';
}



if ( isset($get_type) && isset($get_id) ){
#get and print
    if ( $get_type === 'user' ){
        $details = $m_admin->get_user($get_id);
    } else {
        $details = $m_admin->get_object($get_id, $get_type);
    }
    print_json($details);
}

## delete logic
if ( isset($_POST['link_id']) ){
#link
    $del_id = $_POST['link_id'];
    $del_type = 'link';
} elseif ( isset($_POST['blog_id']) ){
#blog
    $del_id = $_POST['blog_id'];
    $del_type = 'blog';
} elseif ( isset($_POST['picture_id']) ){
#picture
    $del_id = $_POST['picture_id'];
    $del_type = 'picture';
} elseif ( isset($_POST['user_id']) ){
#user
    $del_id = $_POST['user_id'];
    $delete_comments = isset($_POST['delete_comments']) ? 1 : 0;

    $del_type = 'user';
}

if ( isset($del_type) && isset($del_id)){
#we're deleting something

    if ( ($reason =  $_POST['reason']) && isset($reason) ){
        if ( $del_type === 'user' ){
#deleting user
            $m_admin->ban_user($del_id, $delete_comments);
        } else {
#deleting object
            $m_admin->delete_object($del_id, $del_type);
        }
        $m_admin->add_to_log($m_user->user_id(), $del_id, $del_type, $reason);

        $m_stash->add_message("${del_type} deleted");
        header('location: /');
        exit();
    } else {
        $m_stash->add_message("no reason specified");
    }
}

#boring shit...
array_push($m_stash->js_includes, $m_stash->theme_settings['js_path'] . '/admin.js?1=2');

ob_start();
load_template("admin");
$output_page = ob_get_contents();
ob_clean();

load_template('lib/open_page');
echo $output_page;
load_template('lib/close_page');
?>
