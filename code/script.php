<?php
require_once('page.php');
require_once('jsmin-1.1.1.php');
$page = new page();

$type = (int)$_GET['type'];

if ($type === 1){
    $spath = '../sys/script/1.js';
    header("Content-Type: application/x-javascript");
    $jsmin = 1;
}
if ($type === 2){
    $spath = '../sys/script/2.css';
    header("Content-Type: text/css");
}

if ($spath){
    $last_modified_time = filemtime($spath);
    $etag = '"'.md5_file($spath).'"';
    $expires_time= time()+(60*60*24*365*10);

    header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
    header("Etag: $etag");
    header("Expires: ".gmdate("D, d M Y H:i:s", $expires_time)." GMT");
    header('Cache-Control: maxage='.(60*60*24*365*10).', public');
    if (@strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $last_modified_time ||
        trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
        header("HTTP/1.1 304 Not Modified");
        exit;
    }
    $script = file_get_contents($spath);
    if ($jsmin){
        $script =  JSMin::minify($script);
    }
    print $page->compress($script); 
}

?>
