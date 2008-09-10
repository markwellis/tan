<?php
require_once('user.php');
require_once("sql.php");

class picture {
    private $threashold = 3;
    private $UploadFilename;
    private $rootdir = '/var/www/thisaintnews.com/images';

    function isValid($title){
        $user = new user();
        $max_size = 800000;
        $errorCodes = array( 0 => 'Only image uploads are allowed',
                    1 => 'Filesize exceeded',
                    2 => 'Filesize exceeded',
                    3 => 'File upload was only partial',
                    4 => 'No file attached',
                    5 => 'Filesize exceeded',
                    6 => 'Form not completed');

        if ($_FILES['pic']['size'] > $max_size){
            return $errorCodes[2];
        }

        if ($title == '') { return $errorCodes[6]; }

        if ($_FILES[$fieldname]['error'] != 0) {
            return $errorCodes[$_FILES['pic']['error']];
        }
        if (!@is_uploaded_file($_FILES['pic']['tmp_name'])){
            return $errorCodes[5];
        }
        if (!@getimagesize($_FILES['pic']['tmp_name'])){
            return $errorCodes[0];
        }
        if (!$user->isLoggedIn()){
            return "User not logged in";
        }
        return null;
    }

    function moveUploaded(){
        $uploaddir = $this->rootdir .'/pics/';
        $now = time();

        while(file_exists($this->uploadFilename = $uploaddir.$now.'-'.$_FILES['pic']['name']))
        {
            $now++;
        }
        if (!move_uploaded_file($_FILES['pic']['tmp_name'], $this->uploadFilename)) {
            return 'receiving directory insuffiecient permission';
        }
        return null;
    }

    function addtoDatabase($title, $description, $cat){
        $sql = new sql();
        $user = new user();
        $query = "INSERT INTO picture_details VALUES ('', '$title',  '$description',".$user->getUserId().", NOW(), '', '".$this->uploadFilename."', '', $cat, '".$user->getUsername()."');";
        $retval = $sql->query($query, 'none');
        $query = "select picture_id from picture_details where title='$title' and filename='".$this->uploadFilename."';";
        $retval = $sql->query($query, 'row');
        return $retval[0];
    }

    function getComments($id){
        $sql = new sql();
        $query = "SELECT *, (select join_date from user_details where user_details.user_id=t2.user_id) as join_date, (select count(*) from comments as t1 where t1.user_id=t2.user_id) as total_comments from comments as t2 WHERE picture_id=$id;";
        return $sql->query($query, 'array');
    }

    function leaveComment($id, $comment){
        $sql = new sql();
        $user = new user();
        $query = "INSERT INTO comments VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '$comment', $id, '', '');";
        return $sql->query($query, 'none');
    }

    function addPlus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from plus where user_id=".$user->getUserId()." and picture_id=$id";
        $count = $sql->query($query, 'row');
        if (!$count){
            $query = "INSERT INTO plus VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), $id, '', '');";
            $res = $sql->query($query, 'none');
//            $query = "update picture_details set picture_details.plus = (SELECT COUNT(*) FROM plus where plus.picture_id = $id) where picture_details.picture_id = $id;";
//            @$sql->query($query, 'none');
            $count = $this->getPlus($id);
            if ($count == $this->threashold){
                $sql1 = new sql();
                $query = "update picture_details set promoted=now() where picture_id=$id;";
                $sql1->query($query, 'none');
            }
            return $res;
        } else {
            $query = "delete from plus where user_id=".$user->getUserId()." and picture_id=$id;";
            $res = $sql->query($query, 'none');
//            $query = "update picture_details set picture_details.plus = (SELECT COUNT(*) FROM plus where plus.picture_id = $id) where picture_details.picture_id = $id;";
//            $sql->query($query, 'none');
            $count = $this->getPlus($id);
            if ($count == $this->threashold -1){
                $sql1 = new sql();
                $query = "update picture_details set promoted='' where picture_id=$id;";
                $sql1->query($query, 'none');
            }
            return $res;
        }
    }

    function getPlus($id){
        $sql = new sql();
        $query = "SELECT * FROM plus where picture_id = $id;";
        $count = $sql->query($query, 'count');
        return $count;
    }

    function addMinus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from minus where user_id=".$user->getUserId()." and picture_id=$id";
        $count = $sql->query($query, 'row');
        if (!$count){
            $query = "INSERT INTO minus VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), $id, '', '');";
            return $sql->query($query, 'none');
        } else {
            $query = "delete from minus where user_id=".$user->getUserId()." and picture_id=$id;";
            return $sql->query($query, 'none');
        }
    }

    function getMinus($id){
        $sql = new sql();
        $query = "select * from minus where picture_id=$id;";
        $count = $sql->query($query, 'count');
        return $count;
    }

    function getAllThumbs(){
        $sql = new sql();
        $query = "select * from picture_details;";
        return $sql->query($query, 'array');
    }

    function getPlusThumbs($page, $below, $limit = 27){
        $sql = new sql();
        $page = ($page * 27) - 27;
        if ($below == 0) {
            $oper = '>=';
//            $query = "select * from picture_details where (SELECT count(*) from plus where plus.picture_id = picture_details.picture_id) >=".$this->threashold." order by promoted desc limit $page, $limit;";
        } else if ($below == 1){
            $oper = '<';
//             $query = "select * from picture_details where (SELECT count(*) from plus where plus.picture_id = picture_details.picture_id) < ".$this->threashold." order by date desc limit $page, $limit;";
//print $query;
        }
        if (isset($oper)) { 
            $uid = -1;
            if (isset($_SESSION['user_id'])){
                $uid = $_SESSION['user_id'];
            }
            $query = "select *,(SELECT count(*) from plus where plus.picture_id = picture_details.picture_id) as plus,
                (SELECT count(*) from minus where minus.picture_id = picture_details.picture_id) as minus,
                (SELECT count(*) from comments WHERE comments.picture_id = picture_details.picture_id) as comments,
                (SELECT count(*) from plus where plus.picture_id = picture_details.picture_id and plus.user_id=$uid) as meplus,
                (SELECT count(*) from minus where minus.picture_id = picture_details.picture_id and minus.user_id=$uid) as meminus
                from picture_details HAVING plus $oper ".$this->threashold." order by date desc limit $page, $limit;";
            return $sql->query($query, 'array');
        }
        return -1;
    }

    function getPlusPicCount($below){
        $sql = new sql();
        if ($below == 0) {
            $query = "select count(*) as count from picture_details where (SELEcT count(picture_id) from plus where plus.picture_id = picture_details.picture_id) >=".$this->threashold.";";
        } else if ($below == 1){
            $query = "select count(*) as count from picture_details where (SELEcT count(picture_id) from plus where plus.picture_id = picture_details.picture_id) <".$this->threashold.";";
        }
        if (isset($query)) {
            $res = $sql->query($query, 'row');
            return $res['count'];
        } else { return 0; }
    }
    
    function getPicDetails($picture_id){
        $sql = new sql();
        $query = " update picture_details set views=(picture_details.views) + 1 where picture_id=$picture_id;";
        @$sql->query($query, 'none');
//        $query = "select * from picture_details where picture_id=$picture_id;";
        $uid = -1;
        if (isset($_SESSION['user_id'])){
            $uid = $_SESSION['user_id'];
        }
        $query = "select *,(SELECT count(*) from plus where plus.picture_id = picture_details.picture_id) as plus,
            (SELECT count(*) from minus where minus.picture_id = picture_details.picture_id) as minus,
            (SELECT count(*) from comments WHERE comments.picture_id = picture_details.picture_id) as comments,
            (SELECT count(*) from plus where plus.picture_id = picture_details.picture_id and plus.user_id=$uid) as meplus,
            (SELECT count(*) from minus where minus.picture_id = picture_details.picture_id and minus.user_id=$uid) as meminus
            from picture_details where picture_id=$picture_id;";
        return $sql->query($query, 'row');
    }

    function ihavePlus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from plus where user_id=".$user->getUserId()." and picture_id=$id";
        return $sql->query($query, 'count');
    }

    function getAllMyPlus(){
        $sql = new sql();
        $user = new user();
        if ($user->isLoggedIn()){
            $query = "select picture_id from plus where user_id=".$user->getUserId()." and picture_id!=0;";
            return $sql->query($query, 'array1');
        }
        return array();
    }

    function ihaveMinus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from minus where user_id=".$user->getUserId()." and picture_id=$id";
        return $sql->query($query, 'count');
    }
    
    function getAllMyMinus(){
        $sql = new sql();
        $user = new user();
        if ($user->isLoggedIn()){
            $query = "select picture_id from minus where user_id=".$user->getUserId()." and picture_id!=0;";
            return $sql->query($query, 'array1');
        }
        return array();
    }
    
    function getRandom(){
        $sql = new sql();
        $query = "SELECT * FROM picture_details ORDER BY RAND() limit 1;";
        return $sql->query($query, 'row');
    }

    function plusTominus($plus, $minus){
        $x = $plus;
        $y = $minus;
        if ($x == 0 | $y == 0){return array(0 => ($x), 1 => ($y));}
        while ($y != 0) {
            $w = $x % $y;
            $x = $y;
            $y = $w;
        }
        return array(0 => ($plus / $x), 1 => ($minus / $x));
    }
    
    function imagecreatefromfile($path, $info = ''){
        if(!$info){
            return false;
        }

        $functions = array(IMAGETYPE_GIF => 'imagecreatefromgif',
            IMAGETYPE_JPEG => 'imagecreatefromjpeg',
            IMAGETYPE_PNG => 'imagecreatefrompng',
            IMAGETYPE_WBMP => 'imagecreatefromwbmp',
            IMAGETYPE_XBM => 'imagecreatefromwxbm');

        if(!$functions[$info[2]]) {
            return false;
        }

        if(!function_exists($functions[$info[2]])) {
            return false;
        }

        return $functions[$info[2]]($path);
    }

    function getImageFilename($id){
        $sql = new sql;
        $query = "select filename from picture_details where picture_id=$id;";
        $fn = $sql->query($query, 'row');
        return $fn['filename'];
    }

    function resizeImage($id, $newx){
        $cacheimg = $this->rootdir."/cache/resize/$id/$newx.jpg";
        if (file_exists($cacheimg)){
            $usecache = 1;
        }else {
            $filename = $this->rootdir.'/pics/' . basename($this->getImageFilename($id));
            $usecache = 0;
        }
        if (!$usecache){
            $srcSize = @getimagesize($filename);
            $srcImg = $this->imagecreatefromfile($filename, $srcSize);
            
            if ($srcSize[0] !=0){
                $rat = $srcSize[1] / $srcSize[0];
                $dstImg = imagecreatetruecolor($newx, $newx*$rat);

                $bg = imagecolorallocate($dstImg, 249, 248, 248);
                imagefilledrectangle($dstImg, 0, 0, $newx, $newx*$rat, $bg);
                imagecopyresampled($dstImg, $srcImg, 0, 0, 0, 0, $newx, $newx*$rat,$srcSize[0],$srcSize[1]);
                $image = imagejpeg($dstImg, NULL, 75);
                @mkdir(dirname($cacheimg));
                $wcache = @imagejpeg($dstImg, $cacheimg, 75);
                @imagedestroy($dstImg);
                @imagedestroy($scrImg);
            }
        }else {
            $last_modified_time = filemtime($cacheimg);
            $etag = '"'.md5_file($cacheimg).'"';
            $expires_time= time()+(60*60*24*365*10);

            header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
            header("Etag: $etag");
            header("Expires: ".gmdate("D, d M Y H:i:s", $expires_time)." GMT");
            header('Cache-Control: maxage='.(60*60*24*365*10).', public');
            header("Content-Type: image/jpeg");
            if (@strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $last_modified_time ||
                trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
                header("HTTP/1.1 304 Not Modified");
                exit;
            }
            $handle = fopen($cacheimg, "rb");
            $image = fread($handle, filesize($cacheimg));
            fclose($handle);
        }
        return $image;
    }
}

?>
