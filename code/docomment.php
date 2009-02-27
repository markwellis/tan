<?php

if($_SERVER['REQUEST_METHOD']==='POST') {
	define('MAGIC', true);
	require_once('inputfilter.php');
	require_once('user.php');
	$user = new user();
	
	$type = $_POST['type'];
	$kinds = array ('picture', 'link', 'blog');
	
	if (in_array($type, $kinds, true)){
	/*  is equal to something in the array, so its safe  */
	    if ($user->isLoggedIn()){
	        $filter = new InputFilter();
	        $comment = $filter->process(stripslashes($_POST['comment']));
#	        $comment =mysql_escape_string(preg_replace("/\[youtube\]\s*(.+?)\s?.*?\[\/youtube\]/", '<object type="application/x-shockwave-flash" style="width:425px; height:350px;" data="http://www.youtube.com/v/$1"><param name="movie" value="http://www.youtube.com/v/$1" /></object>', $comment));
		$comment =mysql_escape_string(preg_replace("/\[youtube\](.+?)\[\/youtube\]/", '<object type="application/x-shockwave-flash" style="width:425px; he
ight:350px;" data="http://www.youtube.com/v/$1"><param name="movie" value="http://www.youtube.com/v/$1" /></object>', $comment));
	        $comment = str_replace(array('\r','\t','\n'), '', $comment);
            require_once('unified.php');
            $id = (int)$_POST['id'];
            $object = new unified($type);
            $object->leaveComment($id, $comment);
            header("location: ".$_SERVER['HTTP_REFERER']);
            exit();
	    } else {
	    	header("Location: /");
	    	exit();
	    }
	} else {
		die('error');
		exit();
	}
} else {
		die('error');
}

?>
