<?php
header("Cache-Control: no-cache, must-revalidate"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
header("Pragma: no-cache");
header('P3P: CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"');

$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$start = $time;
$title = 'Welcome Home';
$extraScript ='';
$where = 'link';
define('MAGIC', true);
require_once('user.php');
?>
