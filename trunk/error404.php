<?php
require_once('code/header.php');

$title = 'Error 404';
header("HTTP/1.1 404 Not Found");
header("Status: 404 Not Found");
$middle = "<h1>Error 404 : File not found</h1>";

require_once('code/footer.php');
?>
