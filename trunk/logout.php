<?php
require_once('code/header.php');
require_once("code/user.php");

$user = new user;
$user->logout();
if ($_SERVER['HTTP_REFERER'] != ''){
    header("Location: ".$_SERVER['HTTP_REFERER']);
} else {
    header("location: /");
}
exit();
?>
