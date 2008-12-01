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

if ($where) {
    $unified_object = new unified($where);

    $page = (int)$_GET['page'];
    if ($page==0) { $page = 1; }
    $username = mysql_escape_string(
        htmlentities(
            strip_tags(
                stripslashes(
                    $_GET['username']
                )
            )
        ,ENT_QUOTES,'UTF-8')
    );

    if ($_GET['ptype'] === 'plus'){ $ptype = 0;}
    if ($_GET['ptype'] === 'minus'){ $ptype = 1;}
    if ($_GET['ptype'] === 'comments'){ $ptype = 3;}

	if (isset($ptype)){
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
	
	    if ($ptype === 2){
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
	    } else {
	        if (isset($page_objects[0])){
		        for($i=0; $i<count($page_objects);$i++){
		           if ($page_objects[$i]['promoted'] != '0000-00-00 00:00:00') {
		                $type = 0;
		           } else {
		                $type = 1;
		           }
	
		           if($where === 'picture') {
						$middle .= "<div class='thumbLine'>";
				        for ($i=0, $max=count($page_objects);$i<$max;++$i){
				            if (isset($page_objects[$i]['picture_id'])) {
				                $middle .= "<div class='thumbCell'>
				                    <div class='thumbHolder'>";
				                $middle .= $unified_object->CreateObjectHTML($page_objects[$i], $type);
				                $middle .= "</div></div>";
				            }
				            if ((($i +1) % 3 == 0) && ($i>0)) {
				                $middle .= "</div>";
				                if (($i+3 <27)) { $middle .= "<div class='thumbLine'>"; }
				            } 
				        }
						if ($i<27) { $middle .= "</div>";  }
					} else {
						$middle .= $unified_object->CreateObjectHTML($page_objects[$i], $type);  
		           	}
				}
		        $pageCount = (int)ceil($user->get_plus_minus_count($uid, $where, $ptype) / 27);
		    } else {
		        $middle .= "This user hasn't plus'd anything yet";
		    }
	    }
		$middle .= $unified_object->CreatePageBoxHTML($pageCount, $page, $_GET['ptype'], $username, $where);
	} else {
	    header("location: /error404/");
		exit();
	} 
} else {
    header("location: /error404/");
	exit();
}
require_once('code/footer.php');
?>
