<?php
require_once('../config.php');
require_once(OLD_CODE_PATH . '/header.php');

global $user;
if (!$user){
    require_once(OLD_CODE_PATH . '/user.php');
    $user = &new user();
}

if (!$user->isLoggedIn()){
    header('location: /');
    exit();
}

$user_id = $user->getUserId();

if ($_SERVER['REQUEST_METHOD']==='POST') {
    if ($user->isLoggedIn()){
        if ($_FILES['avatar']){
            require_once(MODEL_PATH . '/m_image_upload.php');
            $user_id = $user->getUserId();
            $avatar = &new m_image_upload($_FILES['avatar'], PROFILE_PICTURE_UPLOAD_PATH . "/{$user_id}.jpg");
            $avatar->types = array('image/jpeg', 'image/pjpeg');
            $res = $avatar->upload();
            if($res === true){
    	       $middle .= "<h1>Your new avatar has been uploaded</h1><br />";
            }else{
                $middle .= "<h1>{$res}</h1>";
            }
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
require_once(OLD_CODE_PATH . '/footer.php');
?>
