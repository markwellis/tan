<?php
require_once("user.php");
$user = new user();

$type = (int)$_GET['type'];
// 0 = disable
// 1 = enable

$_SESSION['filteroff'] = $type;
header("location: " .$_SERVER['HTTP_REFERER']);

?>
