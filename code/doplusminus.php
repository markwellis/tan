<?php

header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

require_once('user.php');
$user = new user();
$id = (int)$_GET['id'];
$plus = (int)$_GET['plus'];
$thumb = (int)$_GET['thumb'];
$type = $_GET['type'];
$kinds = array ('picture', 'link', 'blog');

if (in_array($type, $kinds, true)){
/*  is equal to something in the array, so its safe  */

    if ($user->isLoggedIn()){
        require_once('unified.php');
        $object = new unified($type);

        $object->addPlusMinus($id, $plus);

        $res = $object->getPlusMinus($id, $plus);

        if ($plus === 1){
            $keyword = 'plus';
        } elseif ($plus === -1){
            $keyword = 'minus';
        }
        print $res['count'] . "<a class='add". ucwords($keyword) ."";
        if ($res['me'.$keyword]){
            print " ". substr($keyword, 0, 1) ."selected";
        }
        print "' href='#' onclick=\"javascript:";
        if ($thumb==1){
            print 't';
        }
        print "add". ucwords($keyword) ."($id, '$type', ";
        if ($thumb==1){
            print "'t{$keyword}{$id}')";
        } else {
            print "'{$keyword}{$id}')";
        }
        print ";return false;\">+</a>";
    } else {
        print "<a href='/login/'>Login\nFirst</a>";
    }
} else {
    print "<a href='/login/'>Login\nFirst</a>";
}

?>
