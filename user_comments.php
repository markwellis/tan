<?php
/*
 * Created on 8 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package profile
 */

require_once('code/header.php');
require_once('code/m_profile.php');
require_once('code/sql.php');
require_once('code/user.php');

/**
 * TODO
 * THIS SHOULD NOT BE HERE
 */
define('OBJECT_LIMIT', 27);

/**
 * strips non alpha numeric chars from a string
 */
function url_title($text){
    return preg_replace("/[^a-zA-Z0-9_]/", "", str_replace(' ','_', html_entity_decode(trim($text),ENT_QUOTES,'UTF-8')));
}

/**
 * END TODO
 */

$current_page = (int)$_GET['page'];
if (!$current_page) { $current_page = 1; }
$search = 'comments';
$username = mysql_escape_string(htmlentities(strip_tags(stripslashes($_GET['username'])),ENT_QUOTES,'UTF-8'));

if (!$username){
    die('missing param');
}

global $sql;
$sql = &new sql();

global $user;
$user = &new user();
$user_id = $user->usernameToId($username);
$m_profile = &new m_profile($user_id);
$results = $m_profile->get_comments($current_page);

ob_start();
?>
<style type='text/css'>
.profile_comment{
    padding:5px;
    border:#000 solid 1px;
    color:#fff;
}

.comment_details{
    padding-left:15px;
    display:block;
    color:#fff;
}

.comment_details:hover{
    padding-left:15px;
    display:block;
    color:#000;
    background-color:#cccccc;
}
</style>
<?php
$total_pages = $results['total_rows'];
unset($results['total_rows']);

foreach ($results as $object){
    if (file_exists("sys/users/avatar/{$object['user_id']}.jpg")){ 
        $avatar = "<img class='avatar' src='/sys/users/avatar/{$object['user_id']}.jpg' alt='{$object['username']}' />";
    } else {
        $avatar = "<img class='avatar' src='/sys/images/_user.png' alt='{$object['username']}' /> ";
    }


    if ($search === 'comments'){
        $object['date'] = date( 'd F Y H:i', $object['date']);
        $object['last'] = date( 'd F Y H:i', $object['last']);
        include('lib/templates/profile_comments.php');
    }

}
$middle .= ob_get_contents();

$total_pages = (int)$total_pages;
$show_this_many = 6;

$lower=$current_page - $show_this_many;
$max=$current_page + $show_this_many;

if ($lower <= 1) {
    $lower = 1;
    $max = $max + $show_this_many;
}

if ($max >= $total_pages) {
    $lower = $total_pages - (2 * $show_this_many);
    if ($lower <= 1) { $lower = 1; }
    $max = $total_pages;
}

$output .= "<div id='pageNoHolder' style='margin-left:auto;margin-right:auto;margin-bottom:25px;width:".($total_pages * 40) ."px;'>";
if ($lower != 1) {
    $output .= "<a class='pageNumber' href='/user/{$username}/1/'>1</a>"
    ."<span class='pageNumber'>...</span>";
}

for ($i=$lower; $i<=$max; ++$i){
    $output .= "<a class='pageNumber";
    if ($i === $current_page){
        $output .= " thisPage";
    }
    $output .= "' href='/user/{$username}/{$i}/'>{$i}</a>";
}

if ($max != $total_pages){
    $output .= "<span class='pageNumber'>...</span>"
    ."<a class='pageNumber' href='/user/{$username}/{$total_pages}/'>{$total_pages}</a>";
}
$output .= "</div>";
$middle .= $output;
ob_clean();
require_once('code/footer.php');
?>
