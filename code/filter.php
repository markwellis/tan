<?php
/*
 * Created on 28 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package nsfw filter
 */
DEFINE('MAGIC', 12);
require_once('user.php');
require_once('sql.php');

global $user;
global $sql;

$sql = &new sql();
$user = &new user();

if (!$_SESSION['nsfw']){
    $_SESSION['nsfw'] = 1;
} else {
    $_SESSION['nsfw'] = 0;
}

$return_to = $_SERVER['HTTP_REFERER'];
if (!$return_to){
 $return_to = '/';
}

header("location: {$return_to}");
exit();
?>
