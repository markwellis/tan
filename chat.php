<?php
require_once('code/header.php');

require_once("code/user.php");
$user = new user();
$title = 'webchat';

$uname = $user->getUserName();
if ($uname == ''){
    $uname = 'n00b';
} 

$middle .= '<div style="text-align:center;">'
    .'<iframe width=720 height=400 scrolling=no style="border:0" '
    .'src="https://widget.mibbit.com/?server=irc.thisaintnews.com%3A%2B6697'
    .'&chatOutputShowTimes=true&autoConnect=true'
    .'&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93&nick='.$uname.'">'
    .'</iframe></div>';

require_once('code/footer.php');
?>
