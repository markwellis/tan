<?php
require_once('class.inputfilter_clean.php5');
require_once('user.php');
$user = new user();
if ($user->isLoggedIn()){
    $filter = new InputFilter();
    $comment = $filter->process(stripslashes($_POST['comment']));
    $comment =mysql_escape_string(preg_replace("/\[youtube\](.+?)\[\/youtube\]/", '<object type="application/x-shockwave-flash" style="width:425px; height:350px;" data="http://www.youtube.com/v/$1"><param name="movie" value="http://www.youtube.com/v/$1" /></object>', $comment));
    $comment = str_replace(array('\r','\t','\n'), '', $comment);

    if($_SERVER['REQUEST_METHOD']==='POST') {
        $id = (int)$_POST['id'];
        $type = $_POST['type'];
        if ($type === 'picture'){
            require_once('picture.php');
            $picture = new picture();
            $picture->leaveComment($id, $comment);
            header("location: ".$_SERVER['HTTP_REFERER']);
    print $comment;
        }
        if ($type === 'link'){
            require_once('link.php');
            $link = new linkobj();
            $link->leaveComment($id, $comment);
            header("location: ".$_SERVER['HTTP_REFERER']);
        }
        if ($type === 'blog'){
            require_once('blog.php');
            $blog = new blog();
            $blog->leaveComment($id, $comment);
            header("location: ".$_SERVER['HTTP_REFERER']);
        }
        
    } else { die('error');}
} else { header("Location: /");}
?>
