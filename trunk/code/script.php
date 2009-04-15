<?php
define('MAGIC', true);

$type = (int)$_GET['type'];

switch ($type) {
	case 1:
    	$spath = '../sys/script/clientside.js';
    	header("Content-Type: application/x-javascript");
    	$jsmin = 1;
    	break;

	case 3:
	    $spath = '../sys/script/scriptaculous/prototype.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 4:
	    $spath = '../sys/script/scriptaculous/effects.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 5:
	    $spath = '../sys/script/scriptaculous/builder.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 6:
	    $spath = '../sys/script/scriptaculous/controls.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 7:
	    $spath = '../sys/script/scriptaculous/dragdrop.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 8:
	    $spath = '../sys/script/scriptaculous/scriptaculous.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 9:
	    $spath = '../sys/script/scriptaculous/slider.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
		break;
	
	case 10:
	    $spath = '../sys/script/scriptaculous/sound.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
	    break;
	case 11:
	    $spath = '../sys/script/nicEdit.js';
	    header("Content-Type: application/x-javascript");
	    $jsmin = 1;
	    break;
	case 12:
	    $spath = '../sys/script/nicEditorIcons.gif';
	    header("Content-Type: image/gif");
	    $jsmin = 0;
	    break;
}

if ($spath){
    $script = file_get_contents($spath);
    if ($jsmin){
    	require_once('jsmin-1.1.1.php');
    	$script =  JSMin::minify($script);
    }
    $etag = '"11f3ae-29f-454'.filemtime($spath).'"';
    header("Etag: $etag");
    if (trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
        header("HTTP/1.1 304 Not Modified");
        exit;
    }
    print $script; 
}

?>
