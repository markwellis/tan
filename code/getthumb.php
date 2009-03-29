<?php
define('MAGIC', true);
require_once('unified.php');

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
$y = (int)$_GET['y'];

if ($id != null && $x !=null){

	$newimg = &new unified('picture');
	$image = $newimg->resizeImage($id, $x, $y);
    
    header("Content-type: image/{$image[1]}");
	print $image[0];
	exit();
}
?>
