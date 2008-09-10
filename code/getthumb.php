<?php
require_once('picture.php');
$picture = new picture();

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
$y = (int)$_GET['y'];

$newimage = $picture->resizeImage($id, $x, $y);
print $newimage;

?>
