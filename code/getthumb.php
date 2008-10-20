<?php
require_once('unified.php');

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
$y = (int)$_GET['y'];

$newimg = new unified('picture');
print $newimg->resizeImage($id, $x, $y);
?>
