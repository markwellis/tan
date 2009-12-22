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

	    public $sort_by = array('date', 'comments', 'plus', 'minus', 'views1');
	
	/*  cutoff for promoted stuff */
	    private $promoted_threashold = 10;
	
	    function __construct($kind){
	        if (in_array($kind, $this->kinds_of_objects, TRUE)){
	            $this->kind_of_object = $kind;
	            $this->rootimagedir = $this->rootdir .'/images';
                global $user;
                if (!$user){
                    $user = &new user();
                }
                global $sql;
                if (!$sql){
                    $sql = &new sql();
                }
                $this->sql = &$sql;
                $this->user = &$user;
                
	        } else {
	            header("Location: /");
	            die("Error 404");
	        }
            
            // $_SESSION['nsfw'] is inverse, 1 means filter is off...
            $this->nsfw = $_SESSION['nsfw'] ? 0 : 1;
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
	            $sql = &$this->sql;
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
	        $sql = &$this->sql;
	        $query = "SELECT * FROM {$this->kind_of_object}_details ORDER BY RAND() limit 1;";
	        return $sql->query($query, 'row');
	    }
        
        function bbcode_to_html($text){
            #[quote name="mrbig4545"]blah blah[/quote]
            $quote_replace = "/\[quote\ user=[\"'].+?[\"']\](.*?)\[\/quote\]/miUs";
            $quote_match = "/\[quote\ user=[\"'](?<name>.+?)[\"']\](?<quote>.*?)\[\/quote\]/miUs";

            $text = $this->purifier->purify($text);
            $string_array = split('\[\/quote\]', $text);

            foreach ($string_array as $string){
                $string .= '[/quote]';
                preg_match($quote_match, $string, $matches);
                if ($matches['name']){
                    $quoted_username = trim($matches['name']);
                    $quoted_username = split(' ', $quoted_username);
                    $quoted_username = $quoted_username[0];
                    $quote = $matches['quote'];
                    $string = preg_replace($quote_replace, "<div class='quote_holder'><span class='quoted_username'>$quoted_username wrote:</span><div class='quote'>$quote</div></div>", $string);
                }
                $new_string .= $string;
            }
            if ($new_string){
                $new_string = str_replace('[/quote]', '', $new_string);
                $text = $new_string;
            };
            unset($matches);
            unset($new_string);

            //youtube
            preg_match("/\[youtube\](?<id>.+?)\[\/youtube\]/", $text, $matches);

            $string_array = split('\[\/youtube\]', $text);
            
            foreach ($string_array as $string){
                $string .= '[/youtube]';
                preg_match("/\[youtube\](?<id>.+?)\[\/youtube\]/", $string, $matches);
                if ($matches['id']){
                    $youtube_id = trim($matches['id']);
                    $youtube_id = split(' ', $youtube_id);
                    $youtube_id = $youtube_id[0];
                    //test for full url 
                    preg_match('/v=(.*)\&/', "{$youtube_id}&", $matches);
                    if ($matches[1]){
                        $youtube_id = $matches[1];
                    }
                    $string = preg_replace("/\[youtube\].+?\[\/youtube\]/", "<object type='application/x-shockwave-flash' style='width:425px; height:350px;' data='http://www.youtube.com/v/{$youtube_id}'><param name='wmode' value='transparent' /><param name='movie' value='http://www.youtube.com/v/{$youtube_id}' /></object>", $string);
                }
                $new_string .= $string;
            }
            if ($new_string){
                $new_string = str_replace('[/youtube]', '', $new_string);
                $text = $new_string;
            };
            unset($matches);
            unset($new_string);
            
            //gcast
            preg_match("/\[gcast\](?<id>.+?)\[\/gcast\]/", $text, $matches);
            if ($matches['id']){
                $gcast_id = trim($matches['id']);
                $gcast_id = split(' ', $gcast_id);
                $gcast_id = $gcast_id[0];
                $text = preg_replace("/\[gcast\](.+?)\[\/gcast\]/", "<embed src='http://www.gcast.com/go/gcastplayer?xmlurl=http://www.gcast.com/u/{$gcast_id}/main.xml&autoplay=no&repeat=yes&colorChoice=3' type='application/x-shockwave-flash' quality='high' pluginspage='http://www.macromedia.com/go/getflashplayer' width='145' height='155'></embed>", $text);
            }
            unset($matches);
            $text = str_replace('<a ', '<a rel="external nofollow" ', $text);
            return $text;
        }
	
	    function isValid($data, $title, $description){
	/*   Does a few checks on whats being submitted */
	        $sql = &$this->sql;
	        $user = &$this->user;
	        switch ($this->kind_of_object) {
	            case 'link':
                    if (!$user->isLoggedIn()){ return "Please login"; }
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
	                $res = $sql->query($query, 'count'); 
	                if ($res){ return $link_error_codes[7]; }

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
	
	        $sql = &$this->sql;
	        $user = &$this->user;
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
                    if (!$ised){
                        $ised = 'N';
                    }
	                $columns = "(picture_id, title, description, user_id, date, promoted, filename, views, category, username, x, y, size, nsfw)";
	                $values = "('', '$title',  '$description', $userid, NOW(), '', '$data', '', $cat, '$username', {$meta[1][0]}, {$meta[1][1]}, {$meta[0]}, '{$ised}')";
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
			$memcache_key = $this->kind_of_object . ":comment:{$id}:count:{$det['comments']}:l{$det['last']}:p:{$det['plus']}:m:{$det['minus']}";
			@$memcache->connect('127.0.0.1', 11211);
			$cached = @$memcache->get($memcache_key);
			
			if (!$cached){
		        $sql = &$this->sql;
		        switch ($this->kind_of_object){
		            case 'link':
		                $condtions = "WHERE link_id=$id AND deleted='N' ORDER BY date";
		                break;
		            case 'blog':
		                $condtions = "WHERE blog_id=$id AND deleted='N' ORDER BY date";
		                break;
		            case 'picture':
		                $condtions = "WHERE picture_id=$id AND deleted='N' ORDER BY date";
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
	        $sql = &$this->sql;
	        $user = &$this->user;
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
			$sql = &$this->sql;
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
	        $sql = &$this->sql;
	        $user = &$this->user;
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
	                    if ( ($count['count'] == $this->promoted_threashold) && (!$count['promoted']) ){
	                        $sql1 = &$this->sql;
	                        $query = "UPDATE $dtable SET promoted=NOW() WHERE $conditions;";
	                        $sql1->query($query, 'none');
	                        $this->add_to_log($username, $userid, $id, 'promoted');
	                    }
	                }
	                return $res;
	            } else {
	                $query = "DELETE FROM $table WHERE user_id={$user->getUserId()} AND $conditions;";
	                $res = $sql->query($query, 'none');
	                return $res;
	            }
	        }
	    }
	
	    function getPlusMinus($id, $plus){
	        $sql = &$this->sql;
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
	            $user = &$this->user;
	            $uid = $user->getUserId();
	            if (!$uid){ $uid = -1; }
	
	            $query = "SELECT count({$table}_id) as count, "
	                ."(SELECT COUNT(*) FROM plus WHERE plus.{$object_id} = {$id} and plus.user_id=$uid) AS meplus, "
	                ."(SELECT COUNT(*) FROM minus WHERE minus.{$object_id} = {$id} and minus.user_id=$uid) AS meminus, "
                    ."(SELECT UNIX_TIMESTAMP(promoted) FROM {$this->kind_of_object}_details WHERE {$this->kind_of_object}_details.{$object_id} = {$id}) AS promoted "
	                ."FROM $table WHERE $conditions;";
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
	        
			$sql = &$this->sql;
			$query = "SELECT COUNT($id) as comments,MAX(edited) as last, (SELECT COUNT($id) FROM plus WHERE $id=$oid) as plus, "
				."(SELECT COUNT($id) FROM minus WHERE $id=$oid) as minus FROM comments where $id = $oid;";
			$res = $sql->query($query, 'row');
			return $res;
		}
	
	    function getAllObjects($table){
	        $sql = &$this->sql;
	        $query = "SELECT * FROM $table;";
	        return $sql->query($query, 'array');
	    }
	
	    function getPageObjects($page, $below, $order, $username = null, $specific = null, $limit = null, $random = null){
	/* Old code, but has union select, will be needed later on for all!
	            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) >= ".$this->threashold." 
	            union select * from blog_details where (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) >= ".$this->threashold." 
	            order by date desc limit $page, $limit;"; */
            require_once('code/user.php');
            $user = &$this->user;
            $uid = $user->getUserId();

	        $cache_time = 30;
	        $memcache = new Memcache;
	        if ($specific) {
	        	$min = $this->get_details_count($specific);
	        	$cache_time = 45;
	        }

            /* massive hack alert */
            $sql = &$this->sql;



            $sql_args = array(
                'ip' => isset($_SERVER['REMOTE_ADDR']) ? "'" . mysql_escape_string($_SERVER['REMOTE_ADDR']) . "'" : 'NULL',
                'ua' => isset($_SERVER['HTTP_USER_AGENT']) ? "'" . mysql_escape_string($_SERVER['HTTP_USER_AGENT']) . "'" : 'NULL',
                'url' => isset($_SERVER['REQUEST_URI']) ? "'" . mysql_escape_string($_SERVER['REQUEST_URI']) . "'" : 'NULL',
                'referer' => isset($_SERVER['HTTP_REFERER']) ? "'" . mysql_escape_string($_SERVER['HTTP_REFERER']) . "'" : 'NULL',
                'id' => isset($specific) ? (int)$specific : 'NULL',
                'type' => isset($this->kind_of_object) ? "'" . $this->kind_of_object . "'" : 'NULL',
                'session_id' => "'" . session_id() . "'",
                'user_id' => isset($uid) ? (int)$uid : 'NULL'
            );

            $query = "INSERT INTO pi (ip, ua, url, referer, id, type, session_id, user_id, date) VALUES ({$sql_args['ip']}, {$sql_args['ua']}, {$sql_args['url']}, "
                ."{$sql_args['referer']}, {$sql_args['id']}, {$sql_args['type']}, {$sql_args['session_id']}, {$sql_args['user_id']}, NOW())";

            $sql->query($query, 'none');
	        
			$memcache_key = $this->kind_of_object . ":p:{$page}:b:{$below}:o:{$order}:u:{$username}:s:{$specific}:c:{$min['comments']}:p:{$min['plus']}:m:{$min['minus']}:l:{$limit}:r:{$random}";
			$cached = 0;
            
            if (!$uid){
			    @$memcache->connect('127.0.0.1', 11211);
                $cached = @$memcache->get($memcache_key);
            }
			
			if (!$cached){
		        $page = ($page * 27) -27;
		        if (!$limit) {
		            $limit = 27;
		        }
		
		        if ($below === 0 && $order==='date'){
		            $order = 'promoted';
		        }
		        
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
                        if ( $this->nsfw ){
                            $conditions = " WHERE NSFW='N' ";
                        } 
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
		                $conditions .= "HAVING plus $oper {$this->promoted_threashold}";
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
		            $conditions = "INNER JOIN {$ptable} ON ( {$table}.{$id} = {$ptable}.{$id} ) WHERE {$ptable}.user_id={$suserid} ";
		            $order = "{$ptable}.date";
		        }
                
                $uid = isset($uid) ? $uid : -1;

		        if ($specific){
		            $conditions = "WHERE {$table}.{$id} = $specific";
		            $page = 0;
		            $limit = 1;
		            $order = 'date';
		        }
		        if ($random) {$order = 'RAND()';}

                if ($specific === null && $this->kind_of_object === 'link' && !$below){
    /* this is naughty
     but what needs to be needs to be done
    */

/* Old code, but has union select, will be needed later on for all!
	            $query = "select * from link_details where (SELECT count(*) from plus where plus.link_id = link_details.link_id) >= ".$this->threashold." 
	            union select * from blog_details where (SELECT count(*) from plus where plus.blog_id = blog_details.blog_id) >= ".$this->threashold." 
	            order by date desc limit $page, $limit;"; */
                    $query = "SELECT *, (SELECT COUNT(*) FROM plus WHERE plus.link_id = link_details.link_id) AS plus, "
                        ."(SELECT COUNT(*) FROM minus WHERE minus.link_id = link_details.link_id) AS minus, "
                        ."(SELECT COUNT(*) FROM comments WHERE comments.link_id = link_details.link_id AND deleted='N') AS comments, "
                        ."(SELECT COUNT(*) FROM plus WHERE plus.link_id = link_details.link_id and plus.user_id=$uid) AS meplus, "
                        ."(SELECT filename FROM picture_details WHERE picture_details.picture_id = link_details.category) AS catimg,  "
                        ."(SELECT COUNT(*) FROM minus WHERE minus.link_id = link_details.link_id and minus.user_id=$uid) AS meminus "
#                        ."(SELECT COUNT(DISTINCT(session_id)) FROM pi WHERE pi.id = link_details.link_id AND type = 'link') as views1 "
                        ."FROM link_details "

                        ."UNION SELECT *, (SELECT COUNT(*) FROM plus WHERE plus.blog_id = blog_details.blog_id) AS plus, "
                        ."(SELECT COUNT(*) FROM minus WHERE minus.blog_id = blog_details.blog_id) AS minus, "
                        ."(SELECT COUNT(*) FROM comments WHERE comments.blog_id = blog_details.blog_id AND deleted='N') AS comments, "
                        ."(SELECT COUNT(*) FROM plus WHERE plus.blog_id = blog_details.blog_id and plus.user_id=$uid) AS meplus, "
                        ."(SELECT filename FROM picture_details WHERE picture_details.picture_id = blog_details.category) AS catimg,  "
                        ."(SELECT COUNT(*) FROM minus WHERE minus.blog_id = blog_details.blog_id and minus.user_id=$uid) AS meminus "
#                        ."(SELECT COUNT(DISTINCT(session_id)) FROM pi WHERE pi.id = blog_details.blog_id AND type = 'blog') as views1 "
                        ."FROM blog_details "

                        
                        ."$conditions ORDER BY $order DESC LIMIT $page, $limit;";
                } else {
                    $query = "SELECT *, (SELECT COUNT(*) FROM plus WHERE plus.$id = {$table}.{$id}) AS plus, "
                        ."(SELECT COUNT(*) FROM minus WHERE minus.$id = {$table}.{$id}) AS minus, "
                        ."(SELECT COUNT(*) FROM comments WHERE comments.{$id} = {$table}.{$id} AND deleted='N') AS comments, "
                        ."(SELECT COUNT(*) FROM plus WHERE plus.{$id} = {$table}.{$id} and plus.user_id=$uid) AS meplus, "
                        ."{$extraSql}  "
                        ."(SELECT COUNT(*) FROM minus WHERE minus.{$id} = {$table}.{$id} and minus.user_id=$uid) AS meminus, "
                        ."(SELECT COUNT(DISTINCT(session_id)) FROM pi WHERE pi.id = {$table}.{$id} AND type = '{$this->kind_of_object}') as views1 "
                        ."FROM $table $conditions ORDER BY $order DESC LIMIT $page, $limit;";

                }

                $sql1 = &$this->sql;
                $ret = $sql1->query($query, 'array');
                if ($uid != 1){
                    @$memcache->set($memcache_key, $ret, false, $cache_time);
                }
                return $ret;
            }
			return $cached;
	    }
        
        function get_thumb_pics($below, $limit = 5){
            $sql = &$this->sql;
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
                if ($this->nsfw){
                    $nsfw = "WHERE NSFW='N'";
                }
                $query = "SELECT *,(SELECT count(*) from plus where plus.picture_id = picture_details.picture_id) as plus, "
                    ."(SELECT count(*) from minus where minus.picture_id = picture_details.picture_id) as minus, "
                    ."(SELECT count(*) from comments WHERE comments.picture_id = picture_details.picture_id) as comments, "
                    ."(SELECT count(*) from plus where plus.picture_id = picture_details.picture_id and plus.user_id=$uid) as meplus, "
                    ."(SELECT count(*) from minus where minus.picture_id = picture_details.picture_id and minus.user_id=$uid) as meminus, "
                    ."(SELECT COUNT(DISTINCT(ip)) FROM pi WHERE pi.id = picture_details.picture_id AND type = 'picture') as views1 "
                    ."FROM picture_details {$nsfw} HAVING plus $oper {$this->promoted_threashold} order by ($orderby) desc limit $limit;";
                return $sql->query($query, 'array');
            }
            return -1;
        }
	
	    function getPlusMinusCount($below, $plus){
	        $sql = &$this->sql;
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
            if ($objectDetails['link_id']){
                $objectid = & $objectDetails['link_id'];
                $kind = 'link';
            } else if ($objectDetails['blog_id']){
                $objectid = & $objectDetails['blog_id'];
                $kind = 'blog';
            } else if ($objectDetails['picture_id']){
                $ispic = true;
                $kind = 'picture';
            }
	        
	        if (!$ispic){
	            $plusminusbox .= $this->CreatePlusMinusHTML($objectDetails[$kind.'_id'], $objectDetails['plus'],
	            $objectDetails['minus'], $objectDetails['meplus'], $objectDetails['meminus'], null, $kind);
	
	            $output .= "<div class='news'>";
                
                $output .= "<div style='background-image:url(/images/cache/resize/{$objectDetails['category']}/100);' class='newsImg' >"
                    ."<img src='/images/cache/resize/{$objectDetails['category']}/100' alt='{$objectDetails['category']}' style='display:none;'/>"
                    ."</div>";
                $output .= "{$plusminusbox}</div>";
	            if ($article === 0){
	                $output .= "<h1 style='display:inline;font-weight:normal;'>
	                    <a class='title' href='/view{$kind}/{$objectid}/".$this->urlTitle($objectDetails['title'])."/'
	                >".stripslashes($objectDetails['title'])."</a></h1><br/>";
	            } else {
	                $output .= "<h1 style='display:inline;font-weight:normal;'><a class='title' rel='external nofollow' href='".stripslashes($objectDetails['url'])."'
	                >".stripslashes($objectDetails['title'])."</a></h1><br/>";
	            }
	            $avatar_image = "sys/users/avatar/{$objectDetails['user_id']}.jpg";
	            if (file_exists("{$_SERVER['DOCUMENT_ROOT']}/{$avatar_image}")){
                        $avatar_mtime = filemtime($avatar_image);
	                $output .= "<img class='avatar' src='/{$avatar_image}?m={$avatar_mtime}'
	                    alt='{$objectDetails['username']}' />";
	            } else { 
	                $output .= "<img class='avatar' src='/sys/images/_user.png' alt='{$objectDetails['username']}' />"; 
	            }
	
	            $output .= "Posted by <a class='user' href='/user/{$objectDetails['username']}/1/'>{$objectDetails['username']}</a>";
	
	            if ($type == 0) {
	                $output .= " promoted on {$objectDetails['promoted']}";
	            } elseif ($type == 1) {
	                $output .= " on {$objectDetails['date']}";
	            }
	            $ratio = $this->plus_to_minus_ratio($objectDetails['plus'], $objectDetails['minus']);
	            $output .= "<br /><a href='/view{$kind}/{$objectDetails[$kind.'_id']}/". $this->urlTitle($objectDetails['title'])."/#comments'>
	                <img src='/sys/images/comment.png' style='height:15px;width:15px' alt=' ' /> {$objectDetails['comments']}</a>";
                    
                if ($article){
                    $output .= " | {$objectDetails['views1']} views";
                }
	
	            if ($ratio) {
	                $output .= " | Ratio " . $ratio[0] . ":" . $ratio[1];
	            }

                $output .= " - <span class='object_type'>[${kind}]</span>";
                
                if (($this->user->getUserId() == $objectDetails['user_id']) || $this->user->admin()){
                    $output .= " | <a href='/esubmit/{$this->kind_of_object}/{$objectDetails[$this->kind_of_object . '_id']}/'>Edit</a>";
                }
	
	            $output .= "<br /><p>".nl2br(stripslashes($objectDetails['description']))."</p>";
	            if ($article && $kind === 'link'){
                    $matches = (array)null;
                    //preg_match('/http\:\/\/www\.youtube\.com\/watch\?v=(.*?)(\&.*)?/', $objectDetails['url'], &$matches);
                    preg_match('/http\:\/\/www\.youtube\.com\/watch\?v=(.*?)\&/', "{$objectDetails['url']}&", &$matches);

                    if ($matches[1]){
                        $youtube_id = $matches[1];
                        $output .= "<object type='application/x-shockwave-flash' style='width:425px; height:350px;' "
                            ."data='http://www.youtube.com/v/{$youtube_id}'><param name='wmode' value='transparent' />"
                            ."<param name='movie' value='http://www.youtube.com/v/{$youtube_id}' /></object>";
                    } else {
    	                $output .= "<a style='margin-right:70px;float:right;font-size:1.5em;' rel='external nofollow' href='".stripslashes($objectDetails['url'])."'>View Link</a><br/><br/>";
                    }
	            } elseif ($article && $kind === 'blog'){
	            	$output .= "</div>";

                    require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/loader.php');
                    $this->purifier = &new purifier();
                    
                    $objectDetails['details'] = $this->bbcode_to_html($objectDetails['details']);
	                $output .= "<div id='blog_wrapper' class='comment_wrapper'>{$objectDetails['details']}";
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

                if ($objectDetails['NSFW'] == 'Y'){
                    $nsfw = ' - <strong>NSFW</strong>';
                }

	            $output .= "{$divholder}<a class='Pictitle'
	                href='/images/pics/".basename($objectDetails['filename']). "'>".stripslashes($objectDetails['title'])."</a>{$nsfw}<br />";
                    $avatar_image = "sys/users/avatar/{$objectDetails['user_id']}.jpg";
	            if (file_exists("{$_SERVER['DOCUMENT_ROOT']}/{$avatar_image}")){
                        $avatar_mtime = filemtime($avatar_image);
	                $output .= "\n<img class='avatar' style='margin-left:5px;'
	                    src='/{$avatar_image}?m={$avatar_mtime}' alt='".stripslashes($objectDetails['username'])."' />";
	            } else {
	                $output .= "\n<img class='avatar' style='margin-left:5px;' src='/sys/images/_user.png'
	                    alt='{$objectDetails['username']}' />";
	            }

	            $output .= "<a class='user' href='/user/{$objectDetails['username']}/1/'>{$objectDetails['username']}</a> "
	                ."<a href='/viewpic/{$objectDetails['picture_id']}/".user::cleanTitle($objectDetails['title']) ."/#comments'>"
	                ."<img src='/sys/images/comment.png' alt=' ' />  {$objectDetails['comments']}</a>"
	                ."| {$objectDetails['views1']} views";
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

                    if (($this->user->getUserId() == $objectDetails['user_id']) || $this->user->admin()){
                        $size .= " | <a href='/esubmit/{$this->kind_of_object}/{$objectDetails[$this->kind_of_object . '_id']}/'>Edit</a>";
                    }

	                $output .=" | {$meta[1][0]}x{$meta[1][1]} | {$size}{$plusminusbox}</div><div class='thumbPlace'><a href='/images/pics/".stripslashes(htmlentities(basename($objectDetails['filename']),ENT_QUOTES,'UTF-8'))."'>
	                    <img class='picThumb' src='/images/cache/resize/{$objectDetails['picture_id']}/400'
	                    alt='".stripslashes($objectDetails['title'])."'/></a>
	                    </div>".stripslashes($objectDetails['description'])."</div>";
	            } else {
	                $output .= "</div>
	                    <div class='thumbPic' style='background-image:url(\"/images/cache/resize/".$objectDetails['picture_id']."/160\");background-repeat:no-repeat;background-position:center center;'><a style='display:block;height:100%;width:100%;' href='/viewpic/{$objectDetails['picture_id']}/". user::cleanTitle($objectDetails['title']) ."/'></a></div></div>$plusminusbox";
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
            

            require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/loader.php');
            $this->purifier = &new purifier();

	        $user = &$this->user;
ob_start();
?>
<script type="text/javascript">//<![CDATA[
var spellcheck_complete = 0;

window.addEvent('domready', function(){

    $$('.comment_edit').addEvent('click', function(e) {
        var href = this.href;
        var comment_id = href.replace(/.*\/(\d+)\//g, "$1");
        var ts = new Date().getTime();

        var req = new Request.HTML({url:href + '/' + ts, 
   
            onFailure: function() {
                $('comment' + comment_id).set('text', 'The request failed.');
            },
            update: 'comment' + comment_id,
            noCache: true
        }).get();

        return false;
    });

    $$('.quote_link').addEvent('click', function(e) {
        var title = this.title.split('::');
        var username = title[0]; 
        var comment_id = title[1]; 
        var comment_name = 'actual_comment' + comment_id;
        var comment = $(comment_name);
        var src;

        comment.getElements('.boob_blocked').each(function(el) {
            src = el.getProperty('src');
            el.setProperty('src', el.retrieve('original_image').src);
        });

        var quote = $(comment_name).get('html');

        comment.getElements('.boob_blocked').each(function(el) {
            el.setProperty('src', src);
        });

        comment = '[quote user="' + username + '"]' + quote + '[/quote]' + "\n<br /><br />";

        FCKeditorAPI.GetInstance('comment').InsertHtml(comment);
        return false;
    });
    
    <? if ($user->isLoggedIn()){ ?>
    
    
    $('submit_comment').addEvent('click', function(e) {
        var oEditor = FCKeditorAPI.GetInstance('comment');
        var comment = oEditor.GetHTML();
        comment = comment.trim();
        if (comment.length < 4){
            alert('Please enter a comment');
            e.stop();
            return false;
        }
        return true;
    });
    
    
    $('submit_comment_spell').addEvent('click', function(e) {
        var oEditor = FCKeditorAPI.GetInstance('comment');
	var ret = oEditor.Commands.GetCommand('SpellCheck').Execute();
    });
    
    <?php } ?>

});
//]]>
</script>
<?
$output .= ob_get_contents();
ob_clean();
	        $output .= "<div id='comment_wrapper' class='comment_wrapper'>";
	        if ($comments){
	        	$output .= "<h2 id='comments'>Comments</h2>";
	        }
	        foreach($comments as $comment){    
                $output .= "<div style='margin-left:5px;' id='comment{$comment['comment_id']}'>";
                    $avatar_image = "sys/users/avatar/{$comment['user_id']}.jpg";
	            if (file_exists("{$_SERVER['DOCUMENT_ROOT']}/{$avatar_image}")){
                    $avatar_mtime = filemtime($avatar_image);
	                $output .= "<img class='avatar' style='height:64px;width:64px;margin-left:10px;'
	                    src='/{$avatar_image}?m={$avatar_mtime}' alt='{$comment['username']}' />";
	            } else {
	                $output .= "\n<img class='avatar' style='height:64px;width:64px;margin-left:10px;'
	                    src='/sys/images/_user.png' alt='{$comment['username']}' />";
	            }
	            $output .= "<div style='font-size:.8em;'>{$comment['username']}, on {$comment['date']}<br />
	                Total Comments: {$comment['total_comments']}, Joined on: {$comment['join_date']}
                    </div>
                    <div class='comment'>
	                <div id='actual_comment{$comment['comment_id']}'>";
                $comment['details'] = $this->bbcode_to_html($comment['details']);

	            $output .= $comment['details'] . "<br/></div>";

                $user_id = (int)$user->getUserId();
                $comment_user_id = (int)$comment['user_id'];

                $output .= "<span style='display:block;float:right;'>"; 
                $output .= "<a href='#comment{$comment['comment_id']}'>Link</a>";
                if ($user->isLoggedIn()){
                    $output .= " | <a onclick='return false;' href='#' class='quote_link' title='{$comment['username']}::{$comment['comment_id']}'>Quote</a>";
                }

                if ($user->isLoggedIn() && ($user_id === $comment_user_id) ){
                    $output .= " | <a class='comment_edit' href='/edit_comment/{$comment['comment_id']}/'>Edit Comment</a>";
                }

                $output .= "</span>";
	            $output .= "</div></div><div id='nsfw_blocker_containter'></div><br />";
	        }

            $output .= "<script type='text/javascript'>var nsfw = {$this->nsfw};</script>";
            $output .= '<script type="text/javascript" src="/sys/js/nsfw_comments.js?r=25"></script>';
            
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
                $oFCKeditor->Config["CustomConfigurationsPath"] = "/sys/script/fckconfig.js";
                $oFCKeditor->Height = '300px';
	            $oFCKeditor->Config['EnterMode'] = 'br';
	            $output .= $oFCKeditor->CreateHTML() 
	            
					."<br/><input type='submit' value='Comment' id='submit_comment'/>"
                    ."<input type='button' value='Check Spelling' id='submit_comment_spell'/>"
                    .'<a href="#top" style="float:right;margin-right:20px;">Back to top</a>'
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
            return;
//	    	$memcache = new Memcache;
//			$memcache_key = $this->kind_of_object . ":b:{$below}w:{$where}";
//			@$memcache->connect('127.0.0.1', 11211);
//			$cached = @$memcache->get($memcache_key);
//			if (!$cached){
//	    		$sql = new sql();
//		    	#Massive sql statement due to ORDER BY RAND() being VERY slow
//	            $query = "(SELECT title, picture_id as id, 'pic' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.picture_id = a.picture_id) AS comments FROM picture_details AS a JOIN (SELECT FLOOR(MAX(picture_id) * RAND()) AS ID FROM  picture_details) AS x ON a.picture_id >= x.ID LIMIT 1)"
//					."UNION (SELECT title, picture_id as id, 'pic' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.picture_id = a.picture_id) AS comments FROM picture_details AS a JOIN (SELECT FLOOR(MAX(picture_id) * RAND()) AS ID FROM  picture_details) AS x ON a.picture_id >= x.ID LIMIT 1)"
//					."UNION (SELECT title, blog_id as id, 'blog' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.blog_id = a.blog_id) AS comments FROM blog_details AS a JOIN (SELECT FLOOR(MAX(blog_id) * RAND()) AS ID FROM blog_details) AS x ON a.blog_id >= x.ID LIMIT 1)"
//					."UNION (SELECT title, blog_id as id, 'blog' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.blog_id = a.blog_id) AS comments FROM blog_details AS a JOIN (SELECT FLOOR(MAX(blog_id) * RAND()) AS ID FROM blog_details) AS x ON a.blog_id >= x.ID LIMIT 1)"
//					."UNION (SELECT title, link_id as id, 'link' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.link_id = a.link_id) AS comments FROM link_details AS a JOIN (SELECT FLOOR(MAX(link_id) * RAND()) AS ID FROM link_details) AS x ON a.link_id >= x.ID LIMIT 1)"
//					."UNION (SELECT title, link_id as id, 'link' as type, (SELECT COUNT(comment_id) FROM comments WHERE comments.link_id = a.link_id) AS comments FROM link_details AS a JOIN (SELECT FLOOR(MAX(link_id) * RAND()) AS ID FROM link_details) AS x ON a.link_id >= x.ID LIMIT 1);";
//		    	$res = $sql->query($query,'array');
//		    	@$memcache->set($memcache_key, $res, false, 10);
//		    	return $res;
//			}
//			return $cached;
	    }
	
	    function CreateRandomHTML ($details) {
//	        $output .= "<br/><div style='margin-top:15px;'>See also<br/>";
//	
//	        foreach ($details as $detail){
//	            $output .= "<a href='/view{$detail['type']}/{$detail['id']}/".$this->urlTitle($detail['title'])."/' class='top_selection'>"
//	                . stripslashes($detail['title']).", {$detail['comments']}</a>";
//	        }
//	        $output .= "</div>";
//	        return $output;
            return;
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
	            <option value='2' $selected_array[2]>IsNews</option>
	            <option value='3' $selected_array[3]>AintNews</option>
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
            
            $output .= "<div id='pageNoHolder' style='margin-left:auto;margin-right:auto;margin-bottom:25px;width:700px;'>";
            if ($lower != 1) {
                $output .= "<a class='pageNumber' href='/{$location}/{$upcoming}/1/'>1</a>"
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
	
	    function CreatePlusMinusHTML($objectid, $plus, $minus, $meplus, $meminus, $style, $type = null){
            if ($type === null){
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
            }
	        $output = "<div class='plusminus' style='$style'>
	            <div class='plus' id='plus{$objectid}'>{$plus}
	            <a class='addPlus ";
	        if ($meplus){
	            $output .= "pselected ";
	        }
	        $output .= "' href='#' onclick=\"javascript:addPlus({$objectid}, '$type',
	            'plus{$objectid}');return false;\">IsNews</a></div>
	            <div class='minus' id='minus{$objectid}'
	            >{$minus}<a class='addMinus ";
	        if ($meminus){
	           $output .= " mselected ";
	        }
	        $output .= "' href='#' onclick=\"javascript:addMinus({$objectid}, '$type',
	            'minus{$objectid}');return false;\">AintNews</a></div>";
	        return $output;
	    }
	} // end of class!
} else {
		header('Location: /error404/');
		exit;
}
?>
