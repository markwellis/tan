<?php
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
require_once('unified.php');

if ($_GET['type'] === 'picture'){
    $pic = new unified('picture');
    $det = $pic->getRandom();
    header("location:  /viewpic/".$det['picture_id']."/".str_replace(" ", "_",$det['title']));
    exit();
}
if ($_GET['type'] === 'link'){
    $link = new unified('link');
    $det = $link->getRandom();
    header("location:  /viewlink/".$det['link_id']."/".str_replace(" ", "_",$det['title']));
    exit();
}

if ($_GET['type'] === 'blog'){
    $blog = new unified('blog');
    $det = $blog->getRandom();
    header("location:  /viewblog/".$det['blog_id']."/".str_replace(" ", "_",$det['title']));
    exit();
}


?>
