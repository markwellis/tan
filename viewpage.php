<?php
/*
 * Created on 19 Oct 2008
 *
 * viewpage.php
 * Page that displays things, such as link, blog, picture etc
 */
require_once('code/header.php');
require_once ('code/unified.php');

$article_id = (int) $_GET['id'];

switch ($_GET['kindofpage']) {
	case 'link' :
		$where = 'link';
		break;
	case 'blog' :
		$where = 'blog';
		break;
	case 'picture' :
		$where = 'picture';
		break;
}

if ($where) {
	$article = new unified($where);
	
	$details = $article->getPageObjects(null, null, null, null, $article_id);
	$details = $details[0];
	
	if (sizeOf($details) > 1) {
		if ($details['promoted'] != '0000-00-00 00:00:00') {
			$upcoming = 0;
		} else {
			$upcoming = 1;
		}
		$title = stripslashes($details['title']);
		$middle .= $article->CreateObjectHTML($details, $upcoming, 1);
        $description = nl2br(stripslashes($details['description']));
        $res = $article->create_top_random($upcoming, $where);
        $sort_by .= $article->CreateRandomHTML($res);
		$middle .= $article->CreateCommentHTML(
    		$article->getComments($details["${where}_id"]), $details["${where}_id"]);
	} else {
		$middle .= $article->error404();
	}
} else {
	header("Location: /");
	exit();
}
require_once('code/footer.php');
?>
