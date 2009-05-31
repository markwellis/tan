<?php
header("Cache-Control: no-cache, must-revalidate");
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
header ("Pragma: no-cache");
header('Content-type: application/json');

define('MAGIC', true);
require_once('../header.php');
$m_tag = load_model('m_tag', array('picture'));

$tagss = urldecode($_GET['tags']);
$res = $m_tag->thumbs_tags($tagss);

print json_encode($res);
exit();
?>
