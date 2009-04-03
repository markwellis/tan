<?php
/*
 * Created on 11 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package edit
 */

/**
 * TODO
 * MOVE FROM HERE
 */

define('BASE_PATH', $_SERVER['DOCUMENT_ROOT']);
define('SYS_PATH', BASE_PATH . '/sys');
define('LIB_PATH', BASE_PATH . '/lib');
define('MODEL_PATH', LIB_PATH . '/models');
define('TEMPLATE_PATH', LIB_PATH .'/templates');

/**
 * END TODO
 */
require_once(BASE_PATH . '/code/header.php');
require_once(MODEL_PATH . '/m_comment.php');
require_once(BASE_PATH . '/code/sql.php');
global $sql;
global $user;

$sql = &new sql();
$user = &new user();

$comment_id = (int)$_GET['comment_id'];

$m_comment = &new m_comment($comment_id);

if($_SERVER['REQUEST_METHOD'] === 'POST'){
    $user_id = (int)$user->getUserId();
    $comment_details = $m_comment->get();
    $comment_user_id = (int)$comment_details['user_id'];

    if ($user->isLoggedIn() && ($user_id === $comment_user_id) ){
        if($_POST['delete_comment']){
            $m_comment->delete();
        } else {
            require_once(BASE_PATH . '/code/inputfilter.php');
            $filter = &new InputFilter();
            $comment = $filter->process(stripslashes($_POST["comment_edit_{$comment_id}"]));
            $comment = mysql_escape_string(str_replace(array('\r','\t','\n'), '', $comment));
            $m_comment->update($comment);
        }
        if ($comment_details['link_id']){
            $location = 'link';
            $id = $comment_details['link_id'];
        } elseif ($comment_details['blog_id']){
            $location = 'blog';
            $id = $comment_details['blog_id'];
        } elseif ($comment_details['picture_id']){
            $location = 'pic';
            $id = $comment_details['picture_id'];
        } 
        header("location: /view{$location}/{$id}/#comment{$comment_details['comment_id']}");
        exit();
    }
}
$user_id = (int)$user->getUserId();
$comment_details = $m_comment->get();
$comment_user_id = (int)$comment_details['user_id'];
if (!$user->isLoggedIn() || ($user_id !== $comment_user_id) ){
    header('HTTP/1.1 403 Forbidden');
    die("Forbidden");
}

$comment = $comment_details['details'];
$comment_id = $comment_details['comment_id'];
?>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<?php

ob_start();
    require(TEMPLATE_PATH . '/edit_comment.php');
ob_end_flush();

?>



