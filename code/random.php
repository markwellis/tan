<?php
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

define('MAGIC', true);
require_once('unified.php');

switch ($_GET['type']) {
	case 'link' :
		$where = 'link';
		$urlk = $where ;
		break;
	case 'blog' :
		$where = 'blog';
		$urlk = $where ;
		break;
	case 'picture' :
		$where = 'picture';
		$urlk = 'pic';
		break;
}

if ($where) {
    $obj = new unified($where);
    $det = $obj->getRandom();
    header("location:  /view{$urlk}/".$det["{$where}_id"]."/".str_replace(" ", "_",$det['title']));
    exit();
} else {
	header("Location: /");
	exit();
}
?>
