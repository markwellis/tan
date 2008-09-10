<?php
require_once('user.php');
require_once("sql.php");
require_once("category.php");

class linkobj {
    private $threashold = 3;
    private $UploadFilename;

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

    function drawBox($thumbArray, $type, $article = 0){
        $rep = array(" ","%");
        $middle .= "<div class='news'>";
        $comments = $thumbArray['comments'];
        $plus = $thumbArray['plus'];
        $minus = $thumbArray['minus'];
        $myplus = $thumbArray['meplus'];
        $myminus = $thumbArray['meminus'];

        $middle .= "<img src='/thumb/".$thumbArray['category']."/100/' alt='".$thumbArray['category']."' class='newsImg'/>
            <div class='plusminus'>
                <div class='plus' id='plus".$thumbArray['link_id']."'>$plus<a class='addPlus";
        if ($myplus){
            $middle .= " pselected";
        }
        $middle .= "' href='#' onclick=\"javascript:addPlus(".$thumbArray['link_id'].", 'link',
             'plus".$thumbArray['link_id']."');return false;\">+</a></div>
            <div class='minus' id='minus".$thumbArray['link_id']."'>$minus<a class='addMinus";
        if ($myminus){
           $middle .= " mselected";
        }
        $middle .= "' href='#' onclick=\"javascript:addMinus(".$thumbArray['link_id']."
            , 'link', 'minus".$thumbArray['link_id']."');return false;\">-</a></div></div>";
        if ($article == 0){
            $middle .= "<h1 style='display:inline;font-weight:normal;'><a class='title' href='/viewlink/".$thumbArray['link_id']."/". user::cleanTitle($thumbArray['title'])."'
            >".stripslashes($thumbArray['title'])."</a></h1><br/>";
        } else {
            $middle .= "<h1 style='display:inline;font-weight:normal;'><a class='title' href='".stripslashes($thumbArray['url'])."'
            >".stripslashes($thumbArray['title'])."</a></h1><br/>";
        }

        if (file_exists("sys/users/avatar/".$thumbArray['user_id'].".jpg")){
            $middle .= "\n<img class='avatar' src='/sys/users/avatar/".$thumbArray['user_id'].".jpg'
                alt='".$thumbArray['username']."' />";
        } else { $middle .= "\n<img class='avatar' src='/sys/images/_user.png' alt='".$thumbArray['username']."' />"; }

        $middle .= "Posted by <a class='user' href='/users/".$thumbArray['username']."/plus/1'>" . $thumbArray['username']."</a>";

        if ($type == 0) {
            $middle .= " promoted on " .$thumbArray['promoted'];
        } elseif ($type == 1) {
            $middle .= " on ". $thumbArray['date'];
        }
        $ratio = $this->plusTominus($plus, $minus);
        $middle .= "<br /><a href='/viewlink/".$thumbArray['link_id']."/". user::cleanTitle($thumbArray['title'])."/#comments'>
            <img src='/sys/images/comment.png' style='height:15px;width:15px' alt=' ' /> ". $comments ."</a> | ".$thumbArray['views']." views";

        if ($ratio != 0) {
            $middle .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
        }

        $middle .= "<br /><p>".nl2br(stripslashes($thumbArray['description']))."</p></div>";
        if ($article == 1){
            $middle .= "<a style='margin-right:70px;float:right;font-size:1.5em;' href='".stripslashes($thumbArray['url'])."'>View Link</a><br/><br/>";
        }
        $middle .= "<hr />";
        return $middle;
    }

    function isValid($url, $title, $description){
        $sql = new sql();
        $user = new user();
        $title_min = 5;
        $desc_min = 5;
        $title_max = 100;
        $desc_max = 1000;
        $errorCodes = array( 0 => 'Title cannont be blank',
                    1 => 'Description cannot be blank',
                    2 => "Title cannot be over $title_max characters",
                    3 => "Discription cannot be over $desc_max characters",
                    4 => "Title must be over $title_min characters",
                    5 => "Discription must be over $desc_min characters",
                    6 => 'Url is invalid',
                    7 => 'This link has already been submitted');

        if ($title == '') { return $errorCodes[0]; }
        if ($description == '') { return $errorCodes[1]; }
        if (strlen($title) > $title_max) { return $errorCodes[2]; }
        if (strlen($description) > $desc_max) { return $errorCodes[3]; }
        if (strlen($title) < $title_min) { return $errorCodes[4]; }
        if (strlen($description) < $desc_min) { return $errorCodes[5]; }
        if (!preg_match('/^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i', $url)) { return $errorCodes[6]; }
        $query = "select * from link_details where url='$url';";
        $res = $sql->query($query, 'array');
        if (isset($res[0])){
            return $errorCodes[7];
        }

        if (!$user->isLoggedIn()){
            return "User not logged in";
        }
        return null;
    }

    function addtoDatabase($url, $title, $description, $cat){
        $sql = new sql();
        $user = new user();
        $query = "INSERT INTO link_details VALUES ('', '$title',  '$description',".$user->getUserId().",'". $user->getUserName() ."', NOW(), '', '$url', '', $cat, '', '', '');";
        $retval = $sql->query($query, 'none');
        $query = "select link_id from link_details where title='$title' and description='$description';";
        $retval = $sql->query($query, 'row');
        return $retval[0];
    }

    function getComments($id){
        $sql = new sql();
        $query = "SELECT *, (select join_date from user_details where user_details.user_id=t2.user_id) as join_date, (select count(*) from comments as t1 where t1.user_id=t2.user_id) as total_comments from comments as t2 WHERE link_id=$id;";
        return $sql->query($query, 'array');
    }

    function leaveComment($id, $comment){
        $sql = new sql();
        $user = new user();
        $query = "INSERT INTO comments VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '$comment', '', '', $id);";
        return $sql->query($query, 'none');
    }

    function addPlus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from plus where user_id=".$user->getUserId()." and link_id=$id";
        $count = $sql->query($query, 'row');
        if (!$count){
            $query = "INSERT INTO plus VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '', '', $id);";
            $res = $sql->query($query, 'none');
            $count = $this->getPlus($id);
            if ($count == $this->threashold){
                $sql1 = new sql();
                $query = "update link_details set promoted=now() where link_id=$id;";
                $sql1->query($query, 'none');
            }
            return $res;
        } else {
            $query = "delete from plus where user_id=".$user->getUserId()." and link_id=$id;";
            $res = $sql->query($query, 'none');
            $count = $this->getPlus($id);
            if ($count == $this->threashold -1){
                $sql1 = new sql();
                $query = "update link_details set promoted='' where link_id=$id;";
                $sql1->query($query, 'none');
            }
            return $res;
        }
    }

    function getPlus($id){
        $sql = new sql();
        $query = "SELECT * FROM plus where link_id = $id;";
        $count = $sql->query($query, 'count');
        return $count;
    }

    function addMinus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from minus where user_id=".$user->getUserId()." and link_id=$id";
        $count = $sql->query($query, 'row');
        if (!$count){
            $query = "INSERT INTO minus VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '', '', $id);";
            return $sql->query($query, 'none');
        } else {
            $query = "delete from minus where user_id=".$user->getUserId()." and link_id=$id;";
            return $sql->query($query, 'none');
        }
    }

    function getMinus($id){
        $sql = new sql();
        $query = "select * from minus where link_id=$id;";
        $count = $sql->query($query, 'count');
        return $count;
    }

    function getAllThumbs(){
        $sql = new sql();
        $query = "select * from link_details;";
        return $sql->query($query, 'array');
    }

    function getLinkThumbs($page, $below){
        $sql = new sql();
        $page = ($page * 27) -27;
        $limit = 27;
        if ($below == 0) {
            $oper = '>=';
        //            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) >= ".$this->threashold." union select * from blog_details where (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) >= ".$this->threashold." order by date desc limit $page, $limit;";
//            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) >=".$this->threashold." order by promoted desc limit $limit, $page;";
        } else if ($below == 1){
            $oper = '<';
        }

//            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) < ".$this->threashold." union select * from blog_details where (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) < ".$this->threashold." order by date desc limit $page, $limit;";
//           $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) < ".$this->threashold." order by date desc limit $limit, $page;";
        if (isset($oper)) { 
            $uid = -1;
            if (isset($_SESSION['user_id'])){
                $uid = $_SESSION['user_id'];
            }
            $query = "select *,(SELECT count(*) from plus where plus.link_id = link_details.link_id) as plus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id) as minus,
                (SELECT count(*) from comments WHERE comments.link_id = link_details.link_id) as comments,
                (select filename from picture_details where picture_details.picture_id = link_details.category) as catimg,
                (SELECT count(*) from plus where plus.link_id = link_details.link_id and plus.user_id=$uid) as meplus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id and minus.user_id=$uid) as meminus
                from link_details HAVING plus $oper ".$this->threashold." order by date desc limit $page, $limit;";
            return $sql->query($query, 'array');
        }
        return -1;
    }

    function getPlusLinkCount($below){
        $sql = new sql();
        if ($below == 0) {
            $query = "select count(*) as count from link_details where (SELECT count(link_id) from plus where plus.link_id = link_details.link_id) >=".$this->threashold.";";
        } else if ($below == 1){
            $query = "select count(*) as count from link_details where (SELECT count(link_id) from plus where plus.link_id = link_details.link_id) <".$this->threashold.";";
        }
        if (isset($query)) {
            $res = $sql->query($query, 'row');
            return $res['count'];
        } else { return 0; }
    }
    
    function getLinkDetails($link_id){
        $sql = new sql();
        $query = " update link_details set views=(link_details.views) + 1 where link_id=$link_id;";
        @$sql->query($query, 'none');
//        $query = "select * from link_details where link_id=$link_id;";
        $uid = -1;
        if (isset($_SESSION['user_id'])){
            $uid = $_SESSION['user_id'];
        }
        $query = "select *,(SELECT count(*) from plus where plus.link_id = link_details.link_id) as plus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id) as minus,
                (SELECT count(*) from comments WHERE comments.link_id = link_details.link_id) as comments,
                (select filename from picture_details where picture_details.picture_id = link_details.category) as catimg,
                (SELECT count(*) from plus where plus.link_id = link_details.link_id and plus.user_id=$uid) as meplus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id and minus.user_id=$uid) as meminus
                from link_details where link_id=$link_id;;";
        return $sql->query($query, 'row');
    }

//upto here in the great grand unifaction of everything 28.08.2008

    function ihavePlus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from plus where user_id=".$user->getUserId()." and link_id=$id";
        return $sql->query($query, 'count');
    }

    function getAllMyPlus(){
        $sql = new sql();
        $user = new user();
        if ($user->isLoggedIn()){
            $query = "select link_id from plus where user_id=".$user->getUserId()." and link_id!=0;";
            return $sql->query($query, 'array1');
        }
        return array();
    }

    function ihaveMinus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from minus where user_id=".$user->getUserId()." and link_id=$id";
        return $sql->query($query, 'count');
    }
    
    function getAllMyMinus(){
        $sql = new sql();
        $user = new user();
        if ($user->isLoggedIn()){
            $query = "select link_id from minus where user_id=".$user->getUserId()." and link_id!=0;";
            return $sql->query($query, 'array1');
        }
        return array();
    }

    function getRandom(){
        $sql = new sql();
        $query = "SELECT * FROM link_details ORDER BY RAND() limit 1;";
        return $sql->query($query, 'row');
    }
}

?>
