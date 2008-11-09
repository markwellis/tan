<?php
require_once('user.php');

$sort = (int) $_GET['sortby'];
$user= new user;

$_SESSION['sortby'] = $sort;
$goto = $_SERVER['HTTP_REFERER'];
if (!$goto) {
    $goto = '/';
}
header("Location: $goto");
exit();
?>
