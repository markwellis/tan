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
            //youtube
            preg_match("/\[youtube\](?<id>.+?)\[\/youtube\]/", $comment, $matches);
            $youtube_id = trim($matches['id']);
            $youtube_id = split(' ', $youtube_id);
            $youtube_id = $youtube_id[0];
            $comment = preg_replace("/\[youtube\](.+?)\[\/youtube\]/", "<object type='application/x-shockwave-flash' 
                style='width:425px; height:350px;' data='http://www.youtube.com/v/{$youtube_id}'><param name='movie' value='http://www.youtube.com/v/$1' /></object>", $comment);

            //gcast
            preg_match("/\[gcast\](?<id>.+?)\[\/gcast\]/", $comment, $matches);
            $gcast_id = trim($matches['id']);
            $gcast_id = split(' ', $gcast_id);
            $gcast_id = $gcast_id[0];
            $comment = preg_replace("/\[gcast\](.+?)\[\/gcast\]/", "<embed src='http://www.gcast.com/go/gcastplayer?xmlurl=http://www.gcast.com/u/{$gcast_id}/main.xml&autoplay=no&repeat=yes&colorChoice=3' type='application/x-shockwave-flash' quality='high' pluginspage='http://www.macromedia.com/go/getflashplayer' width='145' height='155'></embed>", $comment);

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
