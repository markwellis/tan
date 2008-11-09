<?php
header("Cache-Control: no-cache, must-revalidate"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$start = $time;
$title = 'Welcome Home';
$extraScript ='';
$where = 'link';
define('MAGIC', null);

?>
