<?php

if($_SERVER['REQUEST_METHOD']==='POST') {
	define('MAGIC', true);

	require_once('user.php');
    global $user;
	$user = &new user();
	
	$type = $_POST['type'];
	$kinds = array ('picture', 'link', 'blog');
	
	if (in_array($type, $kinds, true)){
	/*  is equal to something in the array, so its safe  */
	    if ($user->isLoggedIn()){
            require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/loader.php');
            $purifier = &new purifier();
            $comment = $purifier->purify(stripslashes($_POST['comment']));

	        $comment = mysql_escape_string(str_replace(array('\r','\t','\n'), '', $comment));
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
