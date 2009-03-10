<?php
/*
 * Created on 3 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package user_info
 */
require_once('code/header.php');

/**
 * THIS SHOULD NOT BE HERE!
 */

define('MAX_UPLOADED_PICTURE_SIZE', 2000000);
define('PROFILE_PICTURE_UPLOAD_PATH', "{$_SERVER['DOCUMENT_ROOT']}/sys/users/avatar");

/**
 * END OF NAUGHTY CODE
 */
 
 // $this->uploaded_file = PROFILE_PICTURE_UPLOAD_PATH . "/{$user->getUserId()}.jpg";

global $user;
if (!$user){
    require_once("code/user.php");
    $user = new user();
}

if (!$user->isLoggedIn()){
    header('location: /');
    exit();
}


//$user_name = htmlentities(strip_tags(strtolower($_GET["username"])),ENT_QUOTES,'UTF-8');
//if (!$user_name){
    $user_id = $user->getUserId();
//} else {
//    $user_id = $user->usernameToId(mysql_escape_string($user_name));
//}

if ($_SERVER['REQUEST_METHOD']==='POST') {
    if ($user->isLoggedIn()){
        if ($_FILES['avatar']){
            require_once("code/m_image_upload.php");
            $avatar = &new m_image_upload($_FILES['avatar'], PROFILE_PICTURE_UPLOAD_PATH . "/{$user->getUserId()}.jpg");
            $avatar->upload();
	    $middle .= "<h1>Your new avatar has been uploaded</h1><br />";
        }
    }
}

$middle .= "<span>Current avatar</span>";
$avatar_image = "sys/users/avatar/{$user_id}.jpg";
if (file_exists($avatar_image)){
	$avatar_mtime = filemtime($avatar_image);
    $middle .= "<img class='avatar' src='/{$avatar_image}?m={$avatar_mtime}' alt='{$user_id}' />";
} else { 
    $middle .= "<img class='avatar' src='/sys/images/_user.png' alt='{$user_id}' />"; 
}
ob_start();
?>
<br />
<br />
<br />

<div>
    <form enctype='multipart/form-data' method='post'>
        <input type='hidden' name='MAX_FILE_SIZE' value='2000000' />
        <label for='avatar'>Select an image file to upload (jpgs only)</label>
        <br />
        <input class='textInput' size='55' type='file' name='avatar' id='avatar' />
        <br />
        <input type='submit' value='Upload Avatar'/>
    </form>
</div>
<?php
$middle .= ob_get_contents();
ob_clean();
require_once('code/footer.php');
?>