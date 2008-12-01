<?php
define('MAGIC', true);
require_once('unified.php');

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
$y = (int)$_GET['y'];

if ($id != null && $x !=null){
	$memcache = new Memcache;
	$memcache_key ="id:{$id}:x:{$x}";
	@$memcache->connect('127.0.0.1', 11211);
	$cached = @$memcache->get($memcache_key);
	header("Content-Type: image/jpeg");
	if (!$cached){
		$newimg = new unified('picture');
		$image = $newimg->resizeImage($id, $x, $y);
		@$memcache->set($memcache_key, $image, false, 1800);
		ob_start();
		print $image;
		ob_end_flush();
		exit();
	}
	ob_start();
    print $cached;
    ob_end_flush();
    exit();
}
?>
