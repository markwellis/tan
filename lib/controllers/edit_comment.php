<?php
/*
 * Created on 11 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package edit
 */

require_once('../header.php');

global $m_user;
$m_user = &load_model('m_user');

$comment_id = (int)$_GET['comment_id'];

$m_comment = &load_model('m_comment', array($comment_id));
$user_id = (int)$m_user->user_id();
$comment_details = $m_comment->get();
$comment_details = $comment_details[0];
$comment_user_id = (int)$comment_details['user_id'];

if($_SERVER['REQUEST_METHOD'] === 'POST'){
    if ($m_user->logged_in() && ($user_id === $comment_user_id) ){
        if($_POST['delete_comment']){
            $m_comment->delete();
        } else {
            require_once (THIRD_PARTY_PATH . '/htmlpurifier/loader.php');
            $purifier = &new purifier();
            $comment = $purifier->purify(stripslashes($_POST["comment_edit_{$comment_id}"]));
            $comment = str_replace(array('\r','\t','\n'), '', $comment);
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
$comment_details = $m_comment->get();
$comment_details = $comment_details[0];
$comment_user_id = (int)$comment_details['user_id'];


if (!$m_user->logged_in() || ($user_id !== $comment_user_id) ){
    header('HTTP/1.1 403 Forbidden');
    die("Forbidden");
}

$m_stash->comment = $comment_details['details'];
$m_stash->comment_id = $comment_details['comment_id'];

?>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<?php

ob_start();
    load_template('edit_comment');
ob_end_flush();

?>