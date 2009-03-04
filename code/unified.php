<?php
/* Last modified  

New uninified class for getting stuff out of the database
assign like so $link = new unified('link') // see $kinds_of_objects for more types


ToDo:
1. Finsh adding unfied code,
2. Adjust pictures table to match schema of link_details and blog_details (for the front page)
3. Fine tune (optimize for speed!)
4. Add options so can sort by comments/date/plus/minus etc
5. ???
6. Profit

*/


if (defined('MAGIC')) {
	require_once("user.php");
	require_once("sql.php");
	
	class unified{
	    static $kind_of_object;
	
	    private $kinds_of_objects = array("link", "picture", "blog");
	    private $rootdir = '/var/www/thisaintnews.com';
	    private $rootimagedir;
	    private $title_min = 5;
	    private $desc_min = 5;
	    private $title_max = 100;
	    private $desc_max = 1000;
	    private $max_picture_size = 2000000;
	    private $blog_min = 20;
	
	    public $sort_by = array('date', 'comments', 'plus', 'minus', 'views');
	
	/*  cutoff for promoted stuff */
	    private $promoted_threashold = 8;
	
	    function __construct($kind){
	        if (in_array($kind, $this->kinds_of_objects, TRUE)){
	            $this->kind_of_object = $kind;
	            $this->rootimagedir = $this->rootdir .'/images';
	        } else {
	            header("Location: /");
	            die("Error 404");
	        }
	    }
	
	    function move_uploaded($kindofpicture){
	        if ($this->kind_of_object === 'picture'){
	            if ($kindofpicture === 'picture'){
	                $uploaddir = $this->rootimagedir .'/pics/';
	            }
	            $now = time();
	            $newname = strtolower(preg_replace("/[^a-zA-Z0-9\.]/", "_", $_FILES['pic']['name']));
	            while(file_exists($this->uploadFilename = $uploaddir.$now.'-'.$newname)) {
	                $now++;                                                                                }
	            if (!move_uploaded_file($_FILES['pic']['tmp_name'], $this->uploadFilename)) {
	                return 'receiving directory insuffiecient permission';
	            }
	            return array(null, $this->uploadFilename);
	        }
	        return -1;
	    }
	
	    function plus_to_minus_ratio($plus, $minus){
	/*      creates a plus to minus ratio   */
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
	
	    function get_image_properties($id, $filename){
	        if ($this->kind_of_object === 'picture'){
	            $sql = new sql();
	            $query = "SELECT x, y, size FROM picture_details WHERE picture_id=$id;";
	            $res = $sql->query($query, 'row');
	            if (!$res['x'] || !$res['y'] || !$res['size']){
	                //check size and update the db
	                $res = @getimagesize($this->rootimagedir . '/pics/' .basename($filename));
	                $size = (@filesize($this->rootimagedir . '/pics/' .basename($filename))) / 1024;
	                $query = "UPDATE picture_details SET x={$res[0]}, y={$res[1]}, size=$size WHERE picture_id=$id;";
	                $sql->query($query, 'none');
	                return array($size, array($res[0], $res[1]));
	            } else {
	                return array($res['size'], array($res['x'], $res['y']));
	            }
	        } else {
	            return null;
	        }
	    }
	
	    function getRandom(){
	        $sql = new sql();
	        $query = "SELECT * FROM {$this->kind_of_object}_details ORDER BY RAND() limit 1;";
	        return $sql->query($query, 'row');
	    }
	
	    function isValid($data, $title, $description){
	/*   Does a few checks on whats being submitted */
	        $sql = new sql();
	        $user = new user();
	        switch ($this->kind_of_object) {
	            case 'link':
	                $link_error_codes = array(0 => 'Title cannont be blank',
	                    1 => 'Description cannot be blank',
	                    2 => "Title cannot be over {$this->title_max} characters",
	                    3 => "Description cannot be over {$this->desc_max} characters",
	                    4 => "Title must be over {$this->title_min} characters",
	                    5 => "Description must be over {$this->desc_min} characters",
	                    6 => 'Url is invalid',
	                    7 => 'This link has already been submitted');
	                if ($title === '') { return $link_error_codes[0]; }
	                if ($description === '') { return $link_error_codes[1]; }
	                if (strlen($title) > $this->title_max) { return $link_error_codes[2]; }
	                if (strlen($description) > $this->desc_max) { return $link_error_codes[3]; }
	                if (strlen($title) < $this->title_min) { return $link_error_codes[4]; }
	                if (strlen($description) < $this->desc_min) { return $link_error_codes[5]; }
	                if (!preg_match('/^(http|https|ftp):\/\/([A-Z0-9][A-Z0-9_-]*(?:\.[A-Z0-9][A-Z0-9_-]*)+):?(\d+)?\/?/i', $data)) { return $link_error_codes[6]; }
	
	                $query = "SELECT link_id FROM link_details WHERE url='$data';";
	                $res = $sql->query($query, 'array'); //could this be count? slight speed increase possible, Sat Aug 23 02:34:15 BST 2008
	                if (isset($res['link_id'])){ return $this->link_error_codes[7]; }
	                if (!$user->isLoggedIn()){ return "Please login"; }
	                return null;
	                break;
	            case 'picture':
	                $picture_error_codes = array(0 => 'Only image uploads are allowed',
	                    1 => 'Filesize exceeded1',
	                    2 => 'Filesize exceeded',
	                    3 => 'File upload was only partial',
	                    4 => 'No file attached',
	                    5 => 'Filesize exceeded5',
	                    6 => 'Form not completed');
	                if ($_FILES['pic']['size'] > $this->max_picture_size){ return $picture_error_codes[2]; }
	                if ($title === '') { return $picture_error_codes[6]; }
	                if ($_FILES['pic']['error'] !== 0) { return $picture_error_codes[$_FILES['pic']['error']]; }
	                if (!@is_uploaded_file($_FILES['pic']['tmp_name'])){ return $picture_error_codes[5]; }
	                $res = @getimagesize($_FILES['pic']['tmp_name']);
	                if (!$res){ return $picture_error_codes[0]; }
	                if (!$user->isLoggedIn()){ return "Please login"; }
	                return array(null, ($_FILES['pic']['size'] / 1024), array($res[0], $res[1]));
	                break;
	            case 'blog':
	                $blog_error_codes = array(0 => 'Title cannont be blank',
	                    1 => 'Description cannot be blank',
	                    2 => "Title cannot be over {$this->title_max} characters",
	                    3 => "Description cannot be over {$this->desc_max} characters",
	                    4 => "Title must be over {$this->title_min} characters",
	                    5 => "Description must be over {$this->desc_min} characters",
	                    6 => "Blog must be over {$this->blog_min} characters");
	                if ($title === '') { return $blog_error_codes[0]; }
	                if ($description === '') { return $blog_error_codes[1]; }
	                if (strlen($title) > $this->title_max) { return $blog_error_codes[2]; }
	                if (strlen($description) > $this->desc_max) { return $blog_error_codes[3]; }
	                if (strlen($title) < $this->title_min) { return $blog_error_codes[4]; }
	                if (strlen($description) < $this->desc_min) { return $blog_error_codes[5]; }
	                if (strlen($data) < $this->blog_min) { return $blog_error_codes[6]; }
	                if (!$user->isLoggedIn()){ return "Please login"; }
	                return null;
	                break;
	        } 
	    }
	
	    function addtoDatabase($data, $title, $description, $cat, $meta = null, $ised = 0){
	/*      Adds stuff to the database
	/*      $data should be the url, blog text, image filename etc
	/*      returns the newly added objects id */
	
	        $sql = new sql();
	        $user = new user();
	        $userid = $user->getUserId();
	        $username = $user->getUserName();
	        switch ($this->kind_of_object) {
	            case 'link':
	                $idtype = "link_id";
	                $table = "link_details";
	                $columns = "(link_id, title, description, user_id, username, date, promoted, url, views, category, blog_id, ised, details)";
	                $values = "('', '$title',  '$description', $userid,'$username', NOW(), '', '$data', '', $cat, '', '', '')";
	                break;
	            case 'blog':
	                $idtype = "blog_id";
	                $table = "blog_details";
	                $columns = "(link_id, title, description, user_id, username, date, promoted, url, views, category, blog_id, ised, details)";
	                $values = "('', '$title', '$description', $userid, '$username', NOW(),'','', '', $cat,'', $ised, '$data')";
	                break;
	            case 'picture':
	                $idtype = "picture_id";
	                $table = "picture_details";
	                $columns = "(picture_id, title, description, user_id, date, promoted, filename, views, category, username, x, y, size)";
	                $values = "('', '$title',  '$description', $userid, NOW(), '', '$data', '', $cat, '$username', {$meta[1][0]}, {$meta[1][1]}, {$meta[0]})";
	                break;
	        }
	        if ($idtype && $user->isLoggedIn()){ 
	            $query = "INSERT INTO $table $columns VALUES {$values};";
	            $retval = $sql->query($query, 'none');
	            $retval = $sql->query(null, 'id');
	            $this->add_to_log($username, $userid, $retval, 'submitted');
	        } else {
	            $retval = -1;
	        }
	        return $retval;
	    }
	
	    function getComments($id){
	    	$memcache = new Memcache;
	    	$det = $this->get_details_count($id);
			$memcache_key = $this->kind_of_object . ":comment:{$id}:count:{$det['comments']}:p:{$det['plus']}:m:{$det['minus']}";
			@$memcache->connect('127.0.0.1', 11211);
			$cached = @$memcache->get($memcache_key);
			
			if (!$cached){
		        $sql = new sql();
		        switch ($this->kind_of_object){
		            case 'link':
		                $condtions = "WHERE link_id=$id ORDER BY date";
		                break;
		            case 'blog':
		                $condtions = "WHERE blog_id=$id ORDER BY date";
		                break;
		            case 'picture':
		                $condtions = "WHERE picture_id=$id ORDER BY date";
		                break;
		        }
		        $query = "SELECT *, (SELECT join_date FROM user_details WHERE user_details.user_id=t2.user_id) AS join_date, 
		            (SELECT COUNT(*) FROM comments AS t1 WHERE t1.user_id=t2.user_id) AS total_comments FROM comments AS t2 $condtions;";
		        $ret = $sql->query($query, 'array');
		        @$memcache->set($memcache_key, $ret, false, 20);
    			return $ret;
			}
			return $cached;
	    }
	
	    function leaveComment($id, $comment){
	        $sql = new sql();
	        $user = new user();
	        $userid = $user->getUserId();
	        $username = $user->getUserName();
	        $picture_id = 0;
	        $blog_id = 0;
	        $link_id = 0;
	        switch ($this->kind_of_object){
	            case 'link':
	                $link_id = $id;
	                break;
	            case 'blog':
	                $blog_id = $id;
	                break;
	            case 'picture':
	                $picture_id = $id;
	                break;
	        }
	        $query = "INSERT INTO comments (username, user_id, date, details, picture_id, blog_id, link_id) 
	            VALUES ('$username', $userid, NOW(), '$comment', $picture_id, $blog_id, $link_id);";
	        $retval = $sql->query($query, 'none');
	        $retval = $sql->query(null, 'id');
	        if ($retval>0) {
	        	$this->add_to_log($username, $userid, $id, 'comment', $retval);
	        }
	        return $retval;
	    }
	
        function add_to_log($username, $userid, $id, $type, $comment_id = null) {
			$sql = new sql();
			$link_id = 0;
			$blog_id = 0;
			$picture_id = 0;

			switch ($this->kind_of_object){
	            case 'link':
	                $link_id = $id;
	                break;
	            case 'blog':
	                $blog_id = $id;
	                break;
	            case 'picture':
	                $picture_id = $id;
	                break;
	        }
            if ($comment_id==null){
                $comment_id=0;
            }
			$query = "INSERT INTO log (username, user_id, date, link_id, blog_id, picture_id, type, comment_id) VALUES ('$username', $userid, NOW(), $link_id, $blog_id, $picture_id, '$type', $comment_id)";
			$sql->query($query, 'none');
			return null;
		}
	
	    function addPlusMinus($id, $plus){
	        $sql = new sql();
	        $user = new user();
	        $picture_id = 0; 
	        $blog_id = 0; 
	        $link_id = 0;
	        if ($plus === 1) {
	            $table = 'plus';
	        } elseif ($plus === -1) {
	            $table = 'minus';
	        }
	        if ($table){
	            switch ($this->kind_of_object){
	                case 'link':
	                    $link_id=$id;
	                    $dtable = 'link_details';
	                    $conditions = "link_id=$id";
	                    break;
	                case 'blog':
	                    $blog_id=$id;
	                    $dtable = 'blog_details';
	                    $conditions = "blog_id=$id";
	                    break;
	                case 'picture':
	                    $picture_id=$id;
	                    $dtable = 'picture_details';
	                    $conditions = "picture_id=$id";
	                    break;
	            }
	            $userid = $user->getUserId();
	            $username = $user->getUsername();
	            $query = "SELECT {$table}_id FROM $table WHERE user_id={$userid} AND $conditions;";
	            $count = $sql->query($query, 'count');
	            if (!$count){
	                $query = "INSERT INTO $table ({$table}_id, user_id, date, picture_id, blog_id, link_id) 
	                    VALUES ('', {$userid}, NOW(), $picture_id, $blog_id, $link_id);";
	                $res = $sql->query($query, 'none');
	                if ($table === 'plus'){
	                $count = $this->getPlusMinus($id, 1);
	                    if ($count['count'] == $this->promoted_threashold){
	                        $sql1 = new sql();
	                        $query = "UPDATE $dtable SET promoted=NOW() WHERE $conditions;";
	                        $sql1->query($query, 'none');
	                        $this->add_to_log($username, $userid, $id, 'promoted');
	                    }
	                }
	                return $res;
	            } else {
	                $query = "DELETE FROM $table WHERE user_id={$user->getUserId()} AND $conditions;";
	                $res = $sql->query($query, 'none');
	                if ($table === 'plus'){
	                $count = $this->getPlusMinus($id, -1);
	                    if ($count['count'] == $this->promoted_threashold -1){
	                        $sql1 = new sql();
	                        $query = "UPDATE $dtable SET promoted='' WHERE $conditions;";
	                        $sql1->query($query, 'none');
	                        $this->add_to_log($username, $userid, $id, 'demoted');
	                    }
	                }
	                return $res;
	            }
	        }
	    }
	
	    function getPlusMinus($id, $plus){
	        $sql = new sql();
	        if ($plus === 1) {
	            $table = 'plus';
	        } elseif ($plus === -1) {
	            $table = 'minus';
	        }
	        if ($table) {
	            switch ($this->kind_of_object){
	                case 'link':
	                    $conditions = "link_id=$id";
	                    $object_id = 'link_id';
	                    break;
	                case 'blog':
	                    $conditions = "blog_id=$id";
	                    $object_id = 'blog_id';
	                    break;
	                case 'picture':
	                    $conditions = "picture_id=$id";
	                    $object_id = 'picture_id';
	                    break;
	            }
	            $user = new user();
	            $uid = $user->getUserId();
	            if (!$uid){ $uid = -1; }
	
	            $query = "SELECT count({$table}_id) as count,
	                (SELECT COUNT(*) FROM plus WHERE plus.{$object_id} = {$id} and plus.user_id=$uid) AS meplus, 
	                (SELECT COUNT(*) FROM minus WHERE minus.{$object_id} = {$id} and minus.user_id=$uid) AS meminus 
	                FROM $table WHERE $conditions;";
	            $count = $sql->query($query, 'row');
	            return $count;
	        }
	    }
	
		function get_details_count($oid){
			switch ($this->kind_of_object){
	            case 'link':
	                $id ='link_id';
	                break;
	                
	            case 'blog':
	                $id ='blog_id';
	                break;
	                
	            case 'picture':
	                $id ='picture_id';
                break;
	        }
	        
			$sql = new sql();
			$query = "SELECT COUNT($id) as comments, (SELECT COUNT($id) FROM plus WHERE $id=$oid) as plus, "
				."(SELECT COUNT($id) FROM minus WHERE $id=$oid) as minus FROM comments where $id = $oid;";
			$res = $sql->query($query, 'row');
			return $res;
		}
	
	    function getAllObjects($table){
	        $sql = new sql();
	        $query = "SELECT * FROM $table;";
	        return $sql->query($query, 'array');
	    }
	
	    function getPageObjects($page, $below, $order, $username = null, $specific = null, $limit = null, $random = null){
	/* Old code, but has union select, will be needed later on for all!
	            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) >= ".$this->threashold." 
	            union select * from blog_details where (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) >= ".$this->threashold." 
	            order by date desc limit $page, $limit;"; */
	        $cache_time = 2;
	        $memcache = new Memcache;
	        if ($specific) {
	        	$min = $this->get_details_count($specific);
	        	$cache_time = 45;
	        }
	        
			$memcache_key = $this->kind_of_object . ":p:{$page}:b:{$below}:o:{$order}:u:{$username}:s:{$specific}:c:{$min['comments']}:p:{$min['plus']}:m:{$min['minus']}:l:{$limit}:r:{$random}";
			@$memcache->connect('127.0.0.1', 11211);
			$cached = @$memcache->get($memcache_key);
			
			if (!$cached){
		        $sql = new sql();
		        $page = ($page * 27) -27;
		        if (!$limit) {
		            $limit = 27;
		        }
		
		        if ($below === 0 && $order==='date'){
		            $order = 'promoted';
		        }
		        
		        require_once('code/user.php');
		        $user = new user();
		        
		        switch ($this->kind_of_object){
		            case 'link':
		                $table = 'link_details';
		                $id ='link_id';
		                $extraSql ="(SELECT filename FROM picture_details WHERE picture_details.picture_id = {$table}.category) AS catimg,";
		                break;
		            case 'blog':
		                $table = 'blog_details';
		                $id ='blog_id';
		                $extraSql ="(SELECT filename FROM picture_details WHERE picture_details.picture_id = {$table}.category) AS catimg,";
		                break;
		            case 'picture':
		                $table = 'picture_details';
		                $id ='picture_id';
		                $extraSql ='';
		                break;
		        }
		        if ($username === null){
		            if ($below === 0) {
		                $oper = '>=';
		                if ($order !== 'promoted'){
		                    $order .= ' DESC, promoted ';
		                }
		            } elseif ($below === 1){
		                $oper = '<';
		                if ($order !== 'date'){
		                    $order .= ' DESC, date ';
		                }
		            }
		            if (!$random){
		                $conditions = "HAVING plus $oper {$this->promoted_threashold}";
		            }
		        } else {
		            $conditions = "WHERE username = '$username'";
		            if ($below === 0) {
		            	$ptable = 'plus';
		            } elseif ($below === 1) {
		            	$ptable = 'minus';
		            } elseif ($below === 3) {
	                    $ptable = 'comments';
	                }
		            $suserid = $user->usernameToId($username);
		            $conditions = "INNER JOIN {$ptable} ON ( {$table}.{$id} = {$ptable}.{$id} ) WHERE {$ptable}.user_id={$suserid}";
		            $order = "{$ptable}.date";
		        }
		
		
		        $uid = $user->getUserId();
		        if (!$uid){ $uid = -1; }
		        if ($specific){
		            $conditions = "WHERE {$table}.{$id} = $specific";
		            $page = 0;
		            $limit = 1;
		            $order = 'date';
		            $query = "UPDATE {$table} SET views=({$table}.views) + 1 WHERE {$table}.{$id} = $specific";
		            $sql->query($query, 'none');
		        }
		        if ($random) {$order = 'RAND()';}
		        $query = "SELECT *,(SELECT COUNT(*) FROM plus WHERE plus.$id = {$table}.{$id}) AS plus,
		            (SELECT COUNT(*) FROM minus WHERE minus.$id = {$table}.{$id}) AS minus,
		            (SELECT COUNT(*) FROM comments WHERE comments.{$id} = {$table}.{$id}) AS comments,
		            (SELECT COUNT(*) FROM plus WHERE plus.{$id} = {$table}.{$id} and plus.user_id=$uid) AS meplus,
		            $extraSql
		            (SELECT COUNT(*) FROM minus WHERE minus.{$id} = {$table}.{$id} and minus.user_id=$uid) AS meminus
		            FROM $table $conditions ORDER BY $order DESC LIMIT $page, $limit;";
		        $sql1 = new sql();
		        $ret = $sql1->query($query, 'array');
		        @$memcache->set($memcache_key, $ret, false, $cache_time);
				return $ret;
			}
			return $cached;
	    }
        
        function get_thumb_pics($below, $limit = 5){
            $sql = new sql();
            $page = ($page * 27) - 27;
            if ($below == 0) {
                $oper = '>=';
                $orderby = 'promoted';
            } else if ($below == 1){
                $oper = '<';
                $orderby = 'date';
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
                    from picture_details HAVING plus $oper ".$this->promoted_threashold." order by ($orderby) desc limit $limit;";
                return $sql->query($query, 'array');
            }
            return -1;
        }
	
	    function getPlusMinusCount($below, $plus){
	        $sql = new sql();
	        switch ($this->kind_of_object){
	            case 'link':
	                $table = 'link_details';
	                $id ='link_id';
	                break;
	            case 'blog':
	                $table = 'blog_details';
	                $id ='blog_id';
	                break;
	            case 'picture':
	                $table = 'picture_details';
	                $id ='picture_id';
	                break;
	        }
	        if ($below === 0) {
	            $oper = '>=';
	        } elseif ($below === 1){
	            $oper = '<';
	        }
	        if ($plus === 1) {
	            $ptable = 'plus';
	        } elseif ($plus === 0) {
	            $ptable = 'minus';
	        }
	        if ($oper) {
	            $query = "SELECT COUNT($id) AS count FROM $table WHERE (SELECT COUNT($id) FROM $ptable WHERE plus.{$id} = {$table}.{$id}) $oper {$this->promoted_threashold};";
	            $res = $sql->query($query, 'row');
	            return $res['count'];
	        } else { return 0; }
	    }
	
	    function CreateObjectHTML($objectDetails, $type, $article = 0){
	        switch($this->kind_of_object){
	            case 'link':
	                $objectid = & $objectDetails['link_id'];
	                $kind = 'link';
	                break;
	            case 'blog':
	                $objectid = & $objectDetails['blog_id'];
	                $kind = 'blog';
	                break;
	            case 'picture':
	                $ispic = true;
	                break;
	        }
	        
	        if (!$ispic){
	            $plusminusbox .= $this->CreatePlusMinusHTML($objectDetails[$kind.'_id'], $objectDetails['plus'],
	            $objectDetails['minus'], $objectDetails['meplus'], $objectDetails['meminus'], null);
	
	            $output .= "<div class='news'><div style='background-image:url(/thumb/{$objectDetails['category']}/100/);'
	                 class='newsImg' ><img src='/thumb/{$objectDetails['category']}/100/' alt='{$objectDetails['category']}' style='display:none;'/></div>$plusminusbox</div>";
	            if ($article === 0){
	                $output .= "<h1 style='display:inline;font-weight:normal;'>
	                    <a class='title' href='/view{$kind}/{$objectid}/".$this->urlTitle($objectDetails['title'])."/'
	                >".stripslashes($objectDetails['title'])."</a></h1><br/>";
	            } else {
	                $output .= "<h1 style='display:inline;font-weight:normal;'><a class='title' href='".stripslashes($objectDetails['url'])."'
	                >".stripslashes($objectDetails['title'])."</a></h1><br/>";
	            }
	
	            if (file_exists("{$_SERVER['DOCUMENT_ROOT']}/sys/users/avatar/{$objectDetails['user_id']}.jpg")){
	                $output .= "<img class='avatar' src='/sys/users/avatar/{$objectDetails['user_id']}.jpg'
	                    alt='{$objectDetails['username']}' />";
	            } else { 
	                $output .= "<img class='avatar' src='/sys/images/_user.png' alt='{$objectDetails['username']}' />"; 
	            }
	
	            $output .= "Posted by <span class='user'>{$objectDetails['username']}</span>";
	
	            if ($type == 0) {
	                $output .= " promoted on {$objectDetails['promoted']}";
	            } elseif ($type == 1) {
	                $output .= " on {$objectDetails['date']}";
	            }
	            $ratio = $this->plus_to_minus_ratio($objectDetails['plus'], $objectDetails['minus']);
	            $output .= "<br /><a href='/view{$kind}/{$objectDetails[$kind.'_id']}/". $this->urlTitle($objectDetails['title'])."/#comments'>
	                <img src='/sys/images/comment.png' style='height:15px;width:15px' alt=' ' /> {$objectDetails['comments']}</a> | {$objectDetails['views']} views";
	
	            if ($ratio) {
	                $output .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
	            }
	
	            $output .= "<br /><p>".nl2br(stripslashes($objectDetails['description']))."</p>";
	            if ($article && $kind === 'link'){
	                $output .= "<a style='margin-right:70px;float:right;font-size:1.5em;' href='".stripslashes($objectDetails['url'])."'>View Link</a><br/><br/>";
	            } elseif ($article && $kind === 'blog'){
	            	$output .= "</div>";
	                $output .= "<div class='comment_wrapper'>{$objectDetails['details']}";
	            }
	            $output .= "</div>";
	        } else if ($ispic){
	///////////////////
	//****Picture****//
	///////////////////
	            if ($article){
	                $style = 'margin-top:50px;margin-right:25px;';
	                $divholder = "<div id='picHolder'>";
	            } else {
	                $divholder = "<div style='text-align:left;width:230px;'>";
	                $style = 'float:right;margin-top:60px;margin-right:2%;';
	            }
	            $plusminusbox .= $this->CreatePlusMinusHTML($objectDetails['picture_id'], $objectDetails['plus'],
	                $objectDetails['minus'], $objectDetails['meplus'], $objectDetails['meminus'], $style);
	
	            $output .= "{$divholder}<a class='Pictitle'
	                href='/images/pics/".basename($objectDetails['filename']). "'>".stripslashes($objectDetails['title']).'</a><br />';

	            if (file_exists("{$_SERVER['DOCUMENT_ROOT']}/sys/users/avatar/{$objectDetails['user_id']}.jpg")){
	                $output .= "\n<img class='avatar' style='margin-left:5px;'
	                    src='/sys/users/avatar/{$objectDetails['user_id']}.jpg' alt='".stripslashes($objectDetails['username'])."' />";
	            } else {
	                $output .= "\n<img class='avatar' style='margin-left:5px;' src='/sys/images/_user.png'
	                    alt='{$objectDetails['username']}' />";
	            }
	            $output .= "<a class='user' href='/users/{$objectDetails['username']}/plus/1/'>{$objectDetails['username']}</a> 
	                <a href='/viewpic/{$objectDetails['picture_id']}/".user::cleanTitle($objectDetails['title']) ."/#comments'>
	                <img src='/sys/images/comment.png' alt=' ' />  {$objectDetails['comments']}</a>
	                | {$objectDetails['views']} views";
	            $ratio = $this->plus_to_minus_ratio($objectDetails['plus'], $objectDetails['minus']);
	            if ($article){
	                if ($ratio) {
	                    $output .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
	                }
	                $meta = $this->get_image_properties($objectDetails['picture_id'], $objectDetails['filename']);
	                if ($meta[0] > 1024){
	                    $size = number_format(($meta[0] / 1024), 2) . 'MB';
	                } else {
	                    $size = number_format($meta[0], 2) . 'KB';
	                }
	                $output .=" | {$meta[1][0]}x{$meta[1][1]} | {$size}{$plusminusbox}</div><div class='thumbPlace'><a href='/images/pics/".stripslashes(htmlentities(basename($objectDetails['filename']),ENT_QUOTES,'UTF-8'))."'>
	                    <img class='picThumb' src='/thumb/{$objectDetails['picture_id']}/400/'
	                    alt='".stripslashes($objectDetails['title'])."'/></a>
	                    </div>".stripslashes($objectDetails['description'])."</div>";
	            } else {
	                $output .= "</div>
	                    <div class='thumbPic' style='background-image:url(\"/thumb/".$objectDetails['picture_id']."/160/\");background-repeat:no-repeat;background-position:center center;'><a style='display:block;height:100%;width:100%;' href='/viewpic/{$objectDetails['picture_id']}/". user::cleanTitle($objectDetails['title']) ."/'></a></div></div>$plusminusbox";
	            }
	        }else {
	        	header('Location: /');
	        	exit();	
	        }
	        return $output;
	    }
	
	    function urlTitle($text){
	        return preg_replace("/[^a-zA-Z0-9_]/", "", str_replace(' ','_', html_entity_decode(trim($text),ENT_QUOTES,'UTF-8')));
	    }
	
	    function getImageFilename($id){
	        $sql = new sql;
	        $query = "select filename from picture_details where picture_id=$id;";
	        $fn = $sql->query($query, 'row');
	        return $fn['filename'];
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
	
	    function resizeImage($id, $newx){
	        $newx = abs($newx);
	    	$allowed_sizes = array(100, 150, 160, 200, 250, 300, 400, 500);
	    	if (in_array($newx, $allowed_sizes, TRUE)){
		        $cacheimg = $this->rootdir."/images/cache/resize/$id/$newx.jpg";

		        if (file_exists($cacheimg)){
		            $usecache = 1;
		        }else {
	                $basefile = $this->getImageFilename($id);
		            $filename = $this->rootdir.'/images/pics/' . basename($basefile);
		            $usecache = 0;
		        }
		        if (!$usecache && $basefile){
		            $srcSize = @getimagesize($filename);
		            $srcImg = $this->imagecreatefromfile($filename, $srcSize);
		            
		            if ($srcSize[0] !=0){
		                $rat = abs($srcSize[1] / $srcSize[0]);
		                $dstImg = imagecreatetruecolor($newx, $newx*$rat);
		
		                $bg = imagecolorallocate($dstImg, 249, 248, 248);
		                imagefilledrectangle($dstImg, 0, 0, $newx, $newx*$rat, $bg);
		                imagecopyresampled($dstImg, $srcImg, 0, 0, 0, 0, $newx, $newx*$rat,$srcSize[0],$srcSize[1]);
		                $image = imagejpeg($dstImg, NULL, 75);
		                @mkdir(dirname($cacheimg));
		                $wcache = @imagejpeg($dstImg, $cacheimg, 75);
		                @imagedestroy($dstImg);
		                @imagedestroy($srcImg);
		            }
		        }else {
	                if (file_exists($cacheimg)){
		                $last_modified_time = filemtime($cacheimg);
	                    $etag = '"'.$last_modified_time.'"';
	                    $expires_time= time()+(60*60*24*365);
	        
	                    header("Last-Modified: ".gmdate("D, d M Y H:i:s", $last_modified_time)." GMT");
	                    header("Etag: $etag");
	                    header("Expires: ".gmdate("D, d M Y H:i:s", $expires_time)." GMT");
	                    header('Cache-Control: maxage='.(60*60*24*365*10).', public');
	                    if (@strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']) == $last_modified_time ||
	                    	trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
		                        header("HTTP/1.1 304 Not Modified");
		                        exit;
	                    }
	                    $handle = fopen($cacheimg, "rb");
	                    $image = fread($handle, filesize($cacheimg));
	                    fclose($handle);
	                } else {
	                    exit();
	                }
		        }
		        return $image;
		    } else {
	                exit();
		    }
		    
	    }
	
	    function CreateCommentHTML($comments, $id){
	        switch($this->kind_of_object){
	            case 'link':
	                $type = 'link';
	                break;
	            case 'blog':
	                $type = 'blog';
	                break;
	            case 'picture':
	                $type = 'picture';
	                break;
	        }
	        require_once('user.php');
	        $user = new user();
	        $output .= "<div class='comment_wrapper'>";
	        if ($comments){
	        	$output .= "<h2 id='comments'>Comments</h2>";
	        }
	        foreach($comments as $comment){    
	            $output .= "<div style='margin-left:5px;' id='comment{$comment['comment_id']}'>";
	            if (file_exists("{$_SERVER['DOCUMENT_ROOT']}/sys/users/avatar/{$comment['user_id']}.jpg")){
	                $output .= "<img class='avatar' style='height:30px;width:30px;margin-left:10px;'
	                    src='/sys/users/avatar/{$comment['user_id']}.jpg' alt='{$comment['username']}' />";
	            } else {
	                $output .= "\n<img class='avatar' style='height:30px;width:30px;margin-left:10px;'
	                    src='/sys/images/_user.png' alt='{$comment['username']}' />";
	            }
	            $output .= "<div style='font-size:.8em;'>{$comment['username']}, on {$comment['date']}<br />
	                Total Comments: {$comment['total_comments']}, Joined on: {$comment['join_date']}</div>
	                <div class='comment'>";
	            $output .= stripslashes($comment['details']) . "<br/>";
//	            $output .= "<a style='display:block;float:right;' class='comment_edit' >Edit Comment</a>";
	            $output .= "</div>
	                </div><br />";
	        }
	        if ($user->isLoggedIn()){
	            $output .= "<h2 id='lcomments'>Leave your comments</h2>"
	                .'<form style="margin-left:15px;" action="/comment" method="post"><p>'
	                ."<input name='id' type='hidden' value='$id' />"
	            	."<input name='type' type='hidden' value='$type' />";
	            include_once("sys/js/fckeditor/fckeditor.php") ;
	            $oFCKeditor = new FCKeditor('comment');
	            $oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
	            $oFCKeditor->Value = '' ;
	            $oFCKeditor->ToolbarSet = 'lulz';
	            $oFCKeditor->Width = '98%';
	            $oFCKeditor->Config['EnterMode'] = 'br';
	            $output .= $oFCKeditor->CreateHTML() 
	            
					."<br/><input type='submit' value='Comment' onclick=\"if(FCKeditorAPI.GetInstance('comment').GetHTML().length < 7) " 
						."{alert('Please enter a comment');return false;}return true;\" "
					.'/> '
	                .'</p></form> ';
	        } else {
	            $output .="<span style='font-size:1.2em;padding-bottom:15px;display:block;'>" 
					."<br />Please <a href='/login/'>login/register</a> to leave comments</span>";
	        }
	        $output .= "</div>";
	        return $output;
	    }
	
	    function error404(){
	        header("HTTP/1.1 404 Not Found");
	        header("Status: 404 Not Found");
	        return "<h1>Error 404 : File not found</h1>";
	    }
	
	    function create_top_random($below = null, $where = null){
	    	$memcache = new Memcache;
			$memcache_key = $this->kind_of_object . ":b:{$below}w:{$where}";
			@$memcache->connect('127.0.0.1', 11211);
			$cached = @$memcache->get($memcache_key);
			if (!$cached){
	    		$sql = new sql();
		    	#Massive sql statement due to ORDER BY RAND() being VERY slow
	            $query = "(SELECT title, picture_id as id, 'pic' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.picture_id = a.picture_id) AS comments FROM picture_details AS a JOIN (SELECT FLOOR(MAX(picture_id) * RAND()) AS ID FROM  picture_details) AS x ON a.picture_id >= x.ID LIMIT 1)"
					."UNION (SELECT title, picture_id as id, 'pic' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.picture_id = a.picture_id) AS comments FROM picture_details AS a JOIN (SELECT FLOOR(MAX(picture_id) * RAND()) AS ID FROM  picture_details) AS x ON a.picture_id >= x.ID LIMIT 1)"
					."UNION (SELECT title, blog_id as id, 'blog' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.blog_id = a.blog_id) AS comments FROM blog_details AS a JOIN (SELECT FLOOR(MAX(blog_id) * RAND()) AS ID FROM blog_details) AS x ON a.blog_id >= x.ID LIMIT 1)"
					."UNION (SELECT title, blog_id as id, 'blog' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.blog_id = a.blog_id) AS comments FROM blog_details AS a JOIN (SELECT FLOOR(MAX(blog_id) * RAND()) AS ID FROM blog_details) AS x ON a.blog_id >= x.ID LIMIT 1)"
					."UNION (SELECT title, link_id as id, 'link' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.link_id = a.link_id) AS comments FROM link_details AS a JOIN (SELECT FLOOR(MAX(link_id) * RAND()) AS ID FROM link_details) AS x ON a.link_id >= x.ID LIMIT 1)"
					."UNION (SELECT title, link_id as id, 'link' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.link_id = a.link_id) AS comments FROM link_details AS a JOIN (SELECT FLOOR(MAX(link_id) * RAND()) AS ID FROM link_details) AS x ON a.link_id >= x.ID LIMIT 1);";
		    	$res = $sql->query($query,'array');
		    	@$memcache->set($memcache_key, $res, false, 10);
		    	return $res;
			}
			return $cached;
	    }
	
	    function CreateRandomHTML ($details) {
	        $output .= "<br/><div style='margin-top:15px;'>See also<br/>";
	
	        foreach ($details as $detail){
	            $output .= "<a href='/view{$detail['type']}/{$detail['id']}/".$this->urlTitle($detail['title'])."/' class='top_selection'>"
	                . stripslashes($detail['title']).", {$detail['comments']}</a>";
	        }
	        $output .= "</div>";
	        return $output;
	    }
	
	    function CreateSortBoxHTML($type, $page, $sort){
	        switch($this->kind_of_object){
	            case 'link':
	                $where = 'link';
	                break;
	            case 'blog':
	                $where = 'blog';
	                break;
	            case 'picture':
	                $where = 'picture';
	                break;
	        }
	        $sort_by = &$this->sort_by;
	        $selected_array = array();
	
	        for($i=0, $max=count($sort_by);$i<$max;++$i){
	            if ($i === $sort){
	                $selected_array[] = ' selected="selected"';
	            } else {
	                $selected_array[] = '';
	            }
	        }
	
	        $output = "<select name='sort_by' id='sort_by' onchange='dosort(this.value)'>
	            <option value='0' $selected_array[0]>Date</option>
	            <option value='1' $selected_array[1]>Comments</option>
	            <option value='2' $selected_array[2]>Plus</option>
	            <option value='3' $selected_array[3]>Minus</option>
	            <option value='4' $selected_array[4]>Views</option>
	            </select>";
	        return $output;
	    }
	
	    function CreatePageBoxHTML($total_pages, $current_page, $upcoming, $username = null, $swhere = null){
	        switch($this->kind_of_object){
	            case 'link':
	                $location = 'link';
	                break;
	            case 'blog':
	                $location = 'blog';
	                break;
	            case 'picture':
	                $location = 'picture';
	                break;
	        }

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
                $output .= "<a class='pageNumber' href='/{$location}/{$upcoming}>/1/'>0</a>"
                ."<span class='pageNumber'>...</span>";
            }
            
            for ($i=$lower; $i<=$max; ++$i){
                $output .= "<a class='pageNumber";
                if ($i === $current_page){
                    $output .= " thisPage";
                }
                $output .= "' href='/{$location}/{$upcoming}/{$i}/'>{$i}</a>";
            }
            
            if ($max != $total_pages){
                $output .= "<span class='pageNumber'>...</span>"
                ."<a class='pageNumber' href='/{$location}/{$upcoming}/{$total_pages}/'>{$total_pages}</a>";
            }
            $output .= "</div>";

	        return $output;
	    }
	
	    function CreatePlusMinusHTML($objectid, $plus, $minus, $meplus, $meminus, $style){
	        switch($this->kind_of_object){
	            case 'link':
	                $type = 'link';
	                break;
	            case 'blog':
	                $type = 'blog';
	                break;
	            case 'picture':
	                $type = 'picture';
	                break;
	        }
	        $output = "<div class='plusminus' style='$style'>
	            <div class='plus' id='plus{$objectid}'>{$plus}
	            <a class='addPlus ";
	        if ($meplus){
	            $output .= "pselected ";
	        }
	        $output .= "' href='#' onclick=\"javascript:addPlus({$objectid}, '$type',
	            'plus{$objectid}');return false;\">+</a></div>
	            <div class='minus' id='minus{$objectid}'
	            >{$minus}<a class='addMinus ";
	        if ($meminus){
	           $output .= " mselected ";
	        }
	        $output .= "' href='#' onclick=\"javascript:addMinus({$objectid}, '$type',
	            'minus{$objectid}');return false;\">-</a></div>";
	        return $output;
	    }
	} // end of class!
} else {
		header('Location: /error404/');
		exit;
}
?>
