<?php
require_once('../header.php');

$comment_id = (int)$_GET['comment_id'];

$m_edit_comment = &load_model('m_edit_comment', array($comment_id));
$user_id = (int)$m_user->user_id();
$comment_details = $m_edit_comment->get();
$comment_user_id = (int)$comment_details[0]['user_id'];

if($_SERVER['REQUEST_METHOD'] === 'POST'){
    if ($m_user->logged_in() && ($user_id === $comment_user_id)){
        if(isset($_POST['delete_comment'])){
            $m_edit_comment->delete();
        } else {
            require_once (THIRD_PARTY_PATH . '/htmlpurifier/loader.php');
            $purifier = &new purifier();
            $comment = $purifier->purify(stripslashes($_POST["comment_edit_{$comment_id}"]));
            $m_edit_comment->update($comment);
        }
        if ($comment_details[0]['link_id']){
            $location = 'link';
            $id = $comment_details[0]['link_id'];
        } elseif ($comment_details[0]['blog_id']){
            $location = 'blog';
            $id = $comment_details[0]['blog_id'];
        } elseif ($comment_details[0]['picture_id']){
            $location = 'pic';
            $id = $comment_details[0]['picture_id'];
        } 
        header("location: /view{$location}/{$id}/#comment{$comment_details[0]['comment_id']}");
        exit();
    }
}
$comment_details = $m_edit_comment->get();
$comment_user_id = (int)$comment_details[0]['user_id'];

if (!$m_user->logged_in() || ($user_id !== $comment_user_id) ){
    header('HTTP/1.1 403 Forbidden');
    die("Forbidden");
}

$m_stash->comment = $comment_details[0]['details'];
$m_stash->comment_id = $comment_details[0]['comment_id'];

load_template('edit_comment');

?>
