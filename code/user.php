<?php
    require_once("validator.php");
    require_once("sql.php");
    class user {

        public function __construct() {
            $time = 60*60*24*90;
            $name = 'thisaintnews';
            session_name($name);

			if ($_SERVER['HTTP_HOST'] === 'web01.hub01.howmanykillings.com'){
			    $domain = 'howmanykillings.com';
			} else {
			    $domain = 'thisaintnews.com';
			}

            session_set_cookie_params($time, '/', $domain);
            ini_set("session.gc_maxlifetime", $time);
            session_cache_expire($time);
            session_start();
            if (isset($_COOKIE[$name])){
                setcookie($name, $_COOKIE[$name], time() + $time, "/");
            }
        }

        public function isLoggedIn() {
            if (isset($_SESSION['username']) && isset($_SESSION['time'])) {
                return true;
            } else {
                return false;
            }
        }
        
        public function getUsername() { 
            return $_SESSION['username'];
        }

        public function getUserId() {
            return $_SESSION['user_id'];
        }

        public function userid2username($userid) {
            $sql = new sql();
            $query = "select username from user_details where user_id=$userid;";
            return $sql->query($query, 'row');
        }
        
        public function usernameToId($username){
            $sql = new sql();
            $query = "select user_id from user_details where username='$username';";
            return $sql->query($query, 'row');
        }

        public function getPlusLinks($uid,$page){
            $sql = new sql();
            $page = ($page * 27);
            $limit = $page - 27;
        $muid = -1;
        if (isset($_SESSION['user_id'])){
            $muid = $_SESSION['user_id'];
        }
        $query = "select *,(SELECT count(*) from plus where plus.link_id = link_details.link_id) as plus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id) as minus,
                (SELECT count(*) from comments WHERE comments.link_id = link_details.link_id) as comments,
                (select filename from picture_details where picture_details.picture_id = link_details.category) as catimg,
                (SELECT count(*) from plus where plus.link_id = link_details.link_id and plus.user_id=$muid) as meplus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id and minus.user_id=$muid) as meminus
                from link_details inner join plus on link_details.link_id = plus.link_id where plus.user_id=$uid order by plus.date desc limit $limit, $page;";
//            $query = "select t1.* from link_details as t1 inner join plus t2 on t1.link_id = t2.link_id where t2.user_id=$uid order by t2.date desc limit $limit, $page;";
            return $sql->query($query, 'array');
        }

        public function getUPlusLinkCount($uid){
            $sql = new sql();
            $query = "select count(*) from link_details where link_id=ANY(select link_id from plus where user_id=$uid);";
            $res = $sql->query($query, 'row');
            return $res[0];
        }

        public function getMinusLinks($uid, $page){
            $muid = -1;
            if (isset($_SESSION['user_id'])){
                $muid = $_SESSION['user_id'];
            }
            $sql = new sql();
            $page = ($page * 27);
            $limit = $page - 27;
            $query = "select *,(SELECT count(*) from plus where plus.link_id = link_details.link_id) as plus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id) as minus,
                (SELECT count(*) from comments WHERE comments.link_id = link_details.link_id) as comments,
                (select filename from picture_details where picture_details.picture_id = link_details.category) as catimg,
                (SELECT count(*) from plus where plus.link_id = link_details.link_id and plus.user_id=$muid) as meplus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id and minus.user_id=$muid) as meminus
                from link_details inner join minus on link_details.link_id = minus.link_id where minus.user_id=$uid order by minus.date desc limit $limit, $page;";
            return $sql->query($query, 'array');
        }

        public function getUMinusLinkCount($uid){
            $sql = new sql();
            $query = "select count(*) from link_details where link_id=ANY(select link_id from minus where user_id=$uid);";
            $res = $sql->query($query, 'row');
            return $res[0];
        }

        public function getSubmittedLinks($uid, $page){
            $sql = new sql();
            $page = ($page * 27);
            $limit = $page - 27;
        $muid = -1;
        if (isset($_SESSION['user_id'])){
            $muid = $_SESSION['user_id'];
        }

            $query = "select *,(SELECT count(*) from plus where plus.link_id = link_details.link_id) as plus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id) as minus,
                (SELECT count(*) from comments WHERE comments.link_id = link_details.link_id) as comments,
                (select filename from picture_details where picture_details.picture_id = link_details.category) as catimg,
                (SELECT count(*) from plus where plus.link_id = link_details.link_id and plus.user_id=$muid) as meplus,
                (SELECT count(*) from minus where minus.link_id = link_details.link_id and minus.user_id=$muid) as meminus
                from link_details where user_id=$uid order by date desc limit $limit, $page;";
            return $sql->query($query, 'array');
        }

        public function getJoinDate($userid) {
            $sql = new sql();
            $query = "select DATE_FORMAT(join_date, '%D %M %Y') from user_details where user_id=$userid";
            return $sql->query($query, 'row');
        }

        public function getTotalComments($userid) {
            $sql = new sql();
            $query = "select * from comments where user_id=$userid";
            return $sql->query($query, 'count');
        }

        public function login($username, $password) { 
            if (!$this->isLoggedIn()) {
                $sql = new sql();
                $encPassword = hash('sha512',$password);
                $query = "SELECT * FROM user_details WHERE username='$username';";
                $row = $sql->query($query, 'row');
                if ($row['password'] === $encPassword) {
                    $_SESSION['time'] = time();
                    $_SESSION['username'] = $username;
                    $_SESSION['user_id'] = $row['user_id'];

                    $query = "update user_details set last_date=NOW() where user_id=".$row['user_id'].";";
                    $sql->query($query, 'none');
                    return true;
                } else { return false; }
            } else { return false; }
        }

        public function logout() {
            if ($this->isLoggedIn()) {
                $_SESSION = array();
                session_set_cookie_params(-3600);
                return session_destroy();
            } else { return false; }
        }

        public function register($username, $password0, $password1, $email){
            $validator = new validator();
            $retval = $validator->validate($username, $password0, $password1, $email); 
            if ($retval == 1) {
                $sql = new sql();
                $encPassword = hash('sha512',$password0);
                $query = "INSERT INTO user_details VALUES ('', '$username',  NOW(),  NOW(), '$email', '$encPassword');";
                return $sql->query($query, 'none');
            } else { return $retval; } 
        }

        function cleanTitle($text){
            return preg_replace("/[^a-zA-Z0-9_]/", "", str_replace(' ','_', html_entity_decode(trim($text),ENT_QUOTES,'UTF-8')));
        }

    }
?>
