<?php
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

if ($_GET['type'] === 'picture'){
require_once('picture.php');
    $pic = new picture();
    $det = $pic->getRandom();
    header("location:  /viewpic/".$det['picture_id']."/".str_replace(" ", "_",$det['title']));
}
if ($_GET['type'] == 'link'){
    require_once('link.php');
    $link = new linkobj();
    $det = $link->getRandom();
    header("location:  /viewlink/".$det['link_id']."/".str_replace(" ", "_",$det['title']));
}

if ($_GET['type'] == 'blog'){
    require_once('blog.php');
    $blog = new blog();
    $det = $blog->getRandom();
    header("location:  /viewblog/".$det['blog_id']."/".str_replace(" ", "_",$det['title']));
}


?>
