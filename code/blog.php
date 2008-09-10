<?php
require_once('user.php');
require_once('sql.php');

class blog{
    private $threashold = 3;

    function getRandom(){
        $sql = new sql();
        $query = "SELECT * FROM blog_details ORDER BY RAND() limit 1;";
        return $sql->query($query, 'row');
    }

    function addtoDatabase($main, $title, $description, $cat, $ised = 0){
        $sql = new sql();
        $user = new user();
        $query = "insert into blog_details values ('', '$title', '$description', ".$user->getUserId().", '".$user->getUsername()."',
        now(),'','', '', $cat,'', $ised, '$main');";
        $retval = $sql->query($query, 'none');
        $query = "select blog_id from blog_details where title='$title' and description='$description';";
        $retval = $sql->query($query, 'row');
        return $retval[0];
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
                <div class='plus' id='plus".$thumbArray['blog_id']."'>$plus<a class='addPlus";
        if ($myplus){
            $middle .= " pselected";
        }
        $middle .= "' href='#' onclick=\"javascript:addPlus(".$thumbArray['blog_id'].", 'blog',
             'plus".$thumbArray['blog_id']."');return false;\">+</a></div>
            <div class='minus' id='minus".$thumbArray['blog_id']."'>$minus<a class='addMinus";
        if ($myminus){
           $middle .= " mselected";
        }
        $middle .= "' href='#' onclick=\"javascript:addMinus(".$thumbArray['blog_id']."
            , 'blog', 'minus".$thumbArray['blog_id']."');return false;\">-</a></div></div>";
        if ($article == 0){
            $middle .= "<h1 style='display:inline;font-weight:normal;'><a class='title' href='/viewblog/".$thumbArray['blog_id']."/". user::cleanTitle($thumbArray['title'])."'
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
        $middle .= " - <span style='color:#008000;font-weight:bold;'>Blog</span><br />
            <a href='/viewblog/".$thumbArray['blog_id']."/". user::cleanTitle($thumbArray['title'])."/#comments'>
            <img src='/sys/images/comment.png' style='height:15px;width:15px' alt=' ' /> ". $comments ."</a> | ".$thumbArray['views']." views";

        if ($ratio != 0) {
            $middle .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
        }

        $middle .= "<br /><p>".nl2br(stripslashes($thumbArray['description']))."</p></div>";
        if ($article) {
            $middle .= "<div style='margin:15px;padding-top:25px;'>".stripslashes($thumbArray['details'])."</div>";
        }
        $middle .= "<hr />";
        return $middle;
    }

    function getPlusBlogCount($below){
        $sql = new sql();
        if ($below == 0) {
            $query = "select count(*) as count from blog_details where (SELECT count(blog_id) from plus where plus.blog_id = blog_details.blog_id) >=".$this->threashold.";";
        } else if ($below == 1){
            $query = "select count(*) as count from blog_details where (SELECT count(blog_id) from plus where plus.blog_id = blog_details.blog_id) <".$this->threashold.";";
        }
        if (isset($query)) {
            $res = $sql->query($query, 'row');
            return $res['count'];
        } else { return 0; }
    }

    function getAllMyPlus(){
        $sql = new sql();
        $user = new user();
        if ($user->isLoggedIn()){
            $query = "select blog_id from plus where user_id=".$user->getUserId()." and blog_id!=0;";
            return $sql->query($query, 'array1');
        }
        return array();
    }

    function ihavePlus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from plus where user_id=".$user->getUserId()." and blog_id=$id";
        return $sql->query($query, 'count');
    }

    function ihaveMinus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from minus where user_id=".$user->getUserId()." and blog_id=$id";
        return $sql->query($query, 'count');
    }

    function getAllMyMinus(){
        $sql = new sql();
        $user = new user();
        if ($user->isLoggedIn()){
            $query = "select blog_id from minus where user_id=".$user->getUserId()." and blog_id!=0;";
            return $sql->query($query, 'array1');
        }
        return array();
    }

    function getComments($id){
        $sql = new sql();
        $query = "SELECT * from comments WHERE blog_id=$id;";
        return $sql->query($query, 'array');
    }

    function getAllThumbs(){
        $sql = new sql();
        $query = "select * from blog_details;";
        return $sql->query($query, 'array');
    }

    function getBlogDetails($blog_id){
        $sql = new sql();
        $query = " update blog_details set views=(blog_details.views) + 1 where blog_id=$blog_id;";
        @$sql->query($query, 'none');
//        $query = "select * from blog_details where blog_id=$blog_id;";
        $uid = -1;
        if (isset($_SESSION['user_id'])){
            $uid = $_SESSION['user_id'];
        }
        $query = "select *,(SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) as plus,
            (SELECT count(*) from minus where minus.blog_id = blog_details.blog_id) as minus,
            (SELECT count(*) from comments WHERE comments.blog_id = blog_details.blog_id) as comments,
            (select filename from picture_details where picture_details.picture_id = blog_details.category) as catimg,
            (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id and plus.user_id=$uid) as meplus,
            (SELECT count(*) from minus where minus.blog_id = blog_details.blog_id and minus.user_id=$uid) as meminus
            from blog_details where blog_id=$blog_id;";
        return $sql->query($query, 'row');
    }

    function leaveComment($id, $comment){
        $sql = new sql();
        $user = new user();
        $query = "INSERT INTO comments VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '$comment', '', $id,'');";
        return $sql->query($query, 'none');
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

    function addPlus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from plus where user_id=".$user->getUserId()." and blog_id=$id";
        $count = $sql->query($query, 'row');
        if (!$count){
            $query = "INSERT INTO plus VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '',  $id, '');";
            $res = $sql->query($query, 'none');
            $count = $this->getPlus($id);
            if ($count == $this->threashold){
                $sql1 = new sql();
                $query = "update blog_details set promoted=now() where blog_id=$id;";
                $sql1->query($query, 'none');
            }
            return $res;
        } else {
            $query = "delete from plus where user_id=".$user->getUserId()." and blog_id=$id;";
            $res = $sql->query($query, 'none');
            $count = $this->getPlus($id);
            if ($count == $this->threashold -1){
                $sql1 = new sql();
                $query = "update blog_details set promoted='' where blog_id=$id;";
                $sql1->query($query, 'none');
            }
            return $res;
        }
    }

    function getBlogThumbs($page, $below){
        $sql = new sql();
        $page = ($page * 27) -27;
        $limit = 27;
        if ($below == 0) {
            $oper = '>=';
        } else if ($below == 1){
            $oper = '<';
        }

        if (isset($oper)) {
            $uid = -1;
            if (isset($_SESSION['user_id'])){
                $uid = $_SESSION['user_id'];
            }
            $query = "select *,(SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) as plus,
                (SELECT count(*) from minus where minus.blog_id = blog_details.blog_id) as minus,
                (SELECT count(*) from comments WHERE comments.blog_id = blog_details.blog_id) as comments,
                (select filename from picture_details where picture_details.picture_id = blog_details.category) as catimg,
                (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id and plus.user_id=$uid) as meplus,
                (SELECT count(*) from minus where minus.blog_id = blog_details.blog_id and minus.user_id=$uid) as meminus
                from blog_details HAVING plus $oper ".$this->threashold." order by date desc limit $page, $limit;";
            return $sql->query($query, 'array');
        }
        return -1;
    }

    function getPlus($id){
        $sql = new sql();
        $query = "SELECT * FROM plus where blog_id = $id;";
        $count = $sql->query($query, 'count');
        return $count;
    }

    function addMinus($id){
        $sql = new sql();
        $user = new user();
        $query = "select * from minus where user_id=".$user->getUserId()." and blog_id=$id";
        $count = $sql->query($query, 'row');
        if (!$count){
            $query = "INSERT INTO minus VALUES ('', '".$user->getUsername()."', ".$user->getUserId().", NOW(), '',  $id, '');";
            return $sql->query($query, 'none');
        } else {
            $query = "delete from minus where user_id=".$user->getUserId()." and blog_id=$id;";
            return $sql->query($query, 'none');
        }
    }

    function getMinus($id){
        $sql = new sql();
        $query = "select * from minus where blog_id=$id;";
        $count = $sql->query($query, 'count');
        return $count;
    }
}

?>
