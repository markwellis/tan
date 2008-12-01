<?php
define('MAGIC', true);
require_once('user.php');
$user = new user();

if ($user->isLoggedIn()){
    require_once('unified.php');
    if($_SERVER['REQUEST_METHOD']==='POST') {
        $type = mysql_escape_string(strip_tags($_POST["type"]));

        if ($type === "link"){
            require_once('inputfilter.php');
            require_once('tag.php');
            $filter = new InputFilter();
            $tag = new tag();

            $link = new unified('link');
            $url = mysql_escape_string(strip_tags(htmlentities($_POST["url"],ENT_QUOTES,'UTF-8')));
            $title = mysql_escape_string(ucwords(strip_tags(htmlentities(trim($_POST["title"]),ENT_QUOTES,'UTF-8'))));
            $description = mysql_escape_string(strip_tags(htmlentities($_POST["description"],ENT_QUOTES,'UTF-8')));
            $tags = $_POST["tags"]; // Gets cleaned up by tags class
            $cat = (int)$_POST['cat'];
            $linkValid = $link->isValid($url, $title, $description);
            if ($linkValid === null){
                $linkid = $link->addtoDatabase($url, $title, $description, $cat);
                $tag->doTag($type, $linkid, $tags);
                header ("location: /link/1/1/0/");
            } else {
                header ("location: /submit/link/$linkValid");
            }
        }

        if ($type === "blog"){
            require_once('inputfilter.php');
            require_once('tag.php');
            $filter = new InputFilter();
            $tag = new tag();
            $blog = new unified('blog');

            $main = $filter->process(stripslashes($_POST['blogmain']));
            $main = mysql_escape_string(preg_replace("/\[youtube\](.+?)\[\/youtube\]/", '<object type="application/x-shockwave-flash" 
                style="width:425px; height:350px;" data="http://www.youtube. com/v/$1"><param name="movie" value="http://www.youtube.com/v/$1" /></object>',$main));
            $main = str_replace(array('\r','\t','\n'), '', $main);
            $title = mysql_escape_string(ucwords(strip_tags(htmlentities(trim($_POST["title"]),ENT_QUOTES,'UTF-8'))));
            $description = mysql_escape_string(strip_tags(htmlentities($_POST["description"],ENT_QUOTES,'UTF-8')));
            $tags = $_POST["tags"]; // Gets cleaned up by tags class
            $cat = (int)$_POST['cat'];

            if ($main != '' && $title != '' && $description != '' && $cat != 0){
                $blogid = $blog->addtoDatabase($main, $title, $description, $cat);
                $tag->doTag($type, $blogid, $tags);
                header ("location: /blog/1/1/0/");
            } else {
                header ("location: /submit/blog/Please complete the form");
            }
        }

        if ($type === "picture"){
            require_once('inputfilter.php');
            require_once('tag.php');
            $filter = new InputFilter();
            $tag = new tag();
            $picture = new unified('picture');

            $title = mysql_escape_string(ucwords(strip_tags(htmlentities(trim($_POST["title"]),ENT_QUOTES,'UTF-8'))));
            $description = mysql_escape_string(strip_tags(htmlentities($_POST["description"],ENT_QUOTES,'UTF-8')));
            $tags = $_POST["tags"]; // Gets cleaned up by tags class
            $cat = (int)$_POST['cat'];
            
            $picValid = $picture->isValid(null, $title, $description);
            if ($picValid[0] === null){
                $picMove  = $picture->move_uploaded('picture');
                if ($picMove[0] === null){
                    $picid = $picture->addtoDatabase($picMove[1], $title, $description, $cat, array($picValid[1], $picValid[2]));
                    $tag->doTag($type, $picid, $tags);
                    header ("location: /picture/1/1/0/");
                    exit();
                } else {
                    header ("location: /submit/picture/$picMove");
                    exit();
                }
            } else {
                header ("location: /submit/picture/$picValid");
                exit();
            }
        }
    } else { 
    	die('error');
    }
} else {
	die('error');
}
?>
