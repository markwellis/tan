<?php
define('MAGIC', true);
require_once('unified.php');

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
$y = (int)$_GET['y'];

if ($id != null && $x !=null){

	header("Content-Type: image/jpeg");

	$newimg = &new unified('picture');
	$image = $newimg->resizeImage($id, $x, $y);
	print $image;
	exit();
}
?>
