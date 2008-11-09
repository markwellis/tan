<?php

require_once('code/header.php');
require_once('code/unified.php');
require_once('code/user.php');
require_once('code/sql.php');
require_once('code/user.php');
#require_once('code/link.php');


$user = new user();
$sql = new sql();

$where = '0';
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

$unified_object = new unified($where);

$page = (int)$_GET['page'];
if ($page==0) { $page = 1; }
$username = mysql_escape_string(strip_tags($_GET['username']));

# Make use the session
# I dont use sessions enough!!

if ($_GET['ptype'] === 'plus'){ $ptype = 0;}
if ($_GET['ptype'] === 'minus'){ $ptype = 1;}

$uid = $user->usernameToId($username);
$uid = $uid['user_id'];
   
$title = "$username&#039;s profile";
 
$middle .= "<h1>$username&#039;s profile</h1>";
$middle .= "<span style='margin-left:15px;'>
<a class='profLink' href='/users/$username/plus/$page/'>Plus</a> 
<a class='profLink' href='/users/$username/minus/$page/'>Minus</a> 
<a class='profLink' href='/users/$username/submitted/$page/'>Submitted</a><br/><br/></span>";

$plink = 'plus';
$page_objects= $unified_object->getPageObjects($page, $ptype, 'date', $username,  null);

if (isset($page_objects[0])){
    for($i=0; $i<count($page_objects);$i++){
       if ($page_objects[$i]['promoted'] != '0000-00-00 00:00:00') {
            $type = 0;
       } else {
            $type = 1;
       }
       $middle .= $unified_object->CreateObjectHTML($page_objects[$i], $type);  
    }

    $pageCount = (int)ceil($user->getUPlusLinkCount($uid) / 27);
} else {
    $middle .= "This user hasn't plus'd anything yet";
}
if ($ptype == 2){
    $plink = 'submitted';
    $sublinks = $user->getSubmittedLinks($uid, $page);
    if (isset($sublinks[0])){
        for($i=0; $i<count($sublinks);$i++){
            if ($sublinks[$i]['promoted'] != '0000-00-00 00:00:00') {
                $type = 0;
           } else {
                $type = 1;
           }
           $middle .= $link->drawBox($sublinks[$i], $type);
        }
        $pageCount = (int)ceil(count($sublinks) / 27);
    } else {
        $middle .= "This user hasn't submitted anything yet";
    }
}
$middle .= "<div style='margin-left:auto;margin-right:auto;margin-bottom:25px;width:".($pageCount * 40) ."px;'>";

for ($i=1;$i<=$pageCount;$i++){
    $middle .= "<a class='pageNumber";
    if ($i == $page){
        $middle .= " thisPage";
    }
    $middle .= " ' href='/users/$username/$plink/$i'>$i</a>";
}
$middle .=  "</div>";

require_once('code/footer.php');

?>
