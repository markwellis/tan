<?php

header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

require_once('user.php');
$user = new user();
$id = (int)$_GET['id'];
$plus = (int)$_GET['plus'];
$type = $_GET['type'];
$thumb = (int)$_GET['thumb'];

if ($type === 'picture') { $what = 'picture'; }
if ($type === 'link') { $what = 'link'; }
if ($type === 'blog') { $what = 'blog'; }

if ($user->isLoggedIn()){
    if ($type === 'picture') {
        require_once('picture.php');
        $picture = new picture();
        if ($plus == 1){
            $picture->addPlus($id);
            $res = $picture->getPlus($id);
            $dididoit = $picture->ihavePlus($id);
        }
        if ($plus == -1){
            $picture->addMinus($id);
            $res = $picture->getMinus($id);
            $dididoit = $picture->ihaveMinus($id);
        }
    }
    if ($type === 'link') {
        require_once('link.php');
        $link = new linkobj();
        if ($plus == 1){
            $link->addPlus($id);
            $res = $link->getPlus($id);
            $dididoit = $link->ihavePlus($id);
        }
        if ($plus == -1){
            $link->addMinus($id);
            $res = $link->getMinus($id);
            $dididoit = $link->ihaveMinus($id);
        }
    }
    if ($type === 'blog') {
        require_once('blog.php');
        $blog = new blog();
        if ($plus == 1){
            $blog->addPlus($id);
            $res = $blog->getPlus($id);
            $dididoit = $blog->ihavePlus($id);
        }
        if ($plus == -1){
            $blog->addMinus($id);
            $res = $blog->getMinus($id);
            $dididoit = $blog->ihaveMinus($id);
        }
    }

    if(isset($what)){
        if ($plus == 1){
            print $res . "<a class='addPlus";
            if ($dididoit){
                print " pselected";
            }        
            print "' href='#' onclick=\"javascript:";
            if ($thumb==1){
                print 't';
            }
            print "addPlus($id, '$what', ";
            if ($thumb==1){
                print "'tplus$id')";
            } else {
                print "'plus$id')";
            }
            print ";return false;\">+</a>";
        }

        if ($plus == -1){
            print $res . "<a class='addMinus";
            if ($dididoit){
                 print " mselected";
            }
            print "' href='#' onclick=\"javascript:";
            if ($thumb==1){
                print 't';
            }
            print "addMinus($id, '$what', ";
            if ($thumb==1){
                print "'tminus$id')";
            } else {
                print "'minus$id')";
            }
            print ";return false;\">-</a>";
        }
    }
} else {
    print "<a href='/login'>Login\nFirst</a>";
}

?>
