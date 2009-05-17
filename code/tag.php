<?php
if (defined('MAGIC')) {
	include_once("sql.php");

	class tag{
	    private $control_tags = 'all';
	
        function __construct(){
            global $sql;
            if (!$sql){
                $sql = &new sql();
            }
            $this->sql = &$sql;
        }
    
	    function isExisting($tag){
	        /* checks to see if its an existing tag
	        returns tag_id if existing
	        returns false if not */
	
	        $tag = mysql_escape_string($tag);
	        $sql = &$this->sql;
	        $query = "select tag_id from tags where tag='$tag';";
	        $row = $sql->query($query, 'row');
	        if ($row){
	            return $row['tag_id'];
	        } else {
	            return false;
	        }
	    }
	
	    function normalize($tag){
	        $normalized_tag = preg_replace("/[^a-zA-Z0-9]/", "", $tag);
	        return strtolower($normalized_tag);
	    }
	
	    function getTagIds($tagstr){
	        /* Wow this is a cool function :D
	           It explodes a string filled with tags
	           then checks to see if they already exist,
	           if they do, it adds that tag id to an array
	           (the tag data is nolonger important)
	           if not it adds the tag to the tags table,
	           then adds its id to the array
	
	           Returns an array filled with the tag ids */
	
	        $tags = explode(' ', trim($tagstr));
	        $res = array();
	        foreach ($tags as $tag){
	            $tag = $this->normalize($tag);
	            $existing = $this->isExisting($tag);
	            if ($existing){
	                $res[] = $existing;
	            } elseif ($tag !== 'all') {
	                $add2db = $this->addTag2DB($tag);
	                if ($add2db){
	                    $res[] = $add2db;
	                }
	            }
	        }
	        return $res;
	    }
	
	    function addTag2DB($tag){
	    /*  adds a new tag to the tags table
	        returns new tags id */
	
	        $tag = mysql_escape_string($tag);
	        $sql = &$this->sql;
	        $query0 = "insert into tags (tag_id, tag) values ('','$tag');";
	        $query1 = "select tag_id from tags where tag='$tag';";
	        $sql->query($query0, 'none');
	        $res = $sql->query($query1, 'row');
	        return $res['tag_id'];
	    }
	
	    function isTagged($type, $id, $tagid){
	    /* Check if something is tagged */
	        $sql = &$this->sql;
	        $id = (int)$id; 
	        $tagid = (int)$tagid;
	        if ($type == 'picture'){
	            $query = "select * from tag_details where picture_id=$id and tag_id=$tagid;";
	        }
	        if ($type == 'link'){
	            $query = "select * from tag_details where link_id=$id and tag_id=$tagid;";
	        }
	        if ($type == 'blog'){
	            $query = "select * from tag_details where blog_id=$id and tag_id=$tagid;";
	        }
	        $res = $sql->query($query, 'row');
	        return $res;
	    }
	
	    function doTag($type, $id, $tags) {
	    /* tags something */
	        require_once('user.php');
            global $user;
            if (!$user){
	           $user = &new user();
            }
	        $userid = $user->getUserId();
	        $username = $user->getUsername();
	        $tags = $this->getTagIds($tags);
	        $id = (int)$id;
	        foreach ($tags as $tag){
	            $res = $this->isTagged($type, $id, $tag);
	            if (!$res){
	                $sql = &$this->sql;
	                if ($type == 'picture'){
	                    $query = "insert into tag_details (td_id,tag_id, user_id, username, picture_id, blog_id, link_id, date) values ('',$tag, $userid, '$username', $id, '','', NOW());";
	                }
	                if ($type == 'link'){
	                    $query = "insert into tag_details (td_id,tag_id, user_id, username, picture_id, blog_id, link_id, date) values ('',$tag, $userid, '$username', '', '',$id, NOW());";
	                }
	                if ($type == 'blog'){
	                    $query = "insert into tag_details (td_id,tag_id, user_id, username, picture_id, blog_id, link_id, date) values ('',$tag, $userid, '$username', '', $id,'', NOW());";
	                }
	                
	                $sql->query($query, 'none');
	            }
	        }
	    }
	
	    function getTags($type, $id){
	        $sql = &$this->sql;
	        $id = (int)$id;
	        if ($type === 'picture'){
	            $query = "select * from tag_details inner join tags on tag_details.tag_id = tags.tag_id where picture_id=$id;";
	        }
	        if ($type === 'link'){
	            $query = "select * from tag_details inner join tags on tag_details.tag_id = tags.tag_id where link_id=$id;";
	        }
	        if ($type === 'blog'){
	            $query = "select * from tag_details inner join tags on tag_details.tag_id = tags.tag_id where blog_id=$id;";
	        }
	    }
	
	    function getMatchingObjects($type, $tagstr){
	        switch ($type){
	            case 'all':
	                $sqlstr0 = '*';
	                $sqlstr = '1=1';
	                $conds = '';
	                break;
	            case 'link':
	                $sqlstr0 = 'DISTINCT link_id';
	                $conds = 'AND';
	                $sqlstr = 'link_id > 0';
                    $where = '';
	                break;
	            case 'picture':
	                $sqlstr0 = 'DISTINCT picture_id, (SELECT NSFW FROM picture_details WHERE picture_details.picture_id=t2.picture_id) AS NSFW';
	                $conds = 'AND';
	                $sqlstr = 'picture_id > 0';
                    $extra_conditions = " AS t2 ";
                    $where = 'HAVING NSFW="N"';
	                break;
	            case 'blog':
	                $sqlstr0 = 'DISTINCT blog_id';
	                $conds = 'AND';
	                $sqlstr = 'blog_id > 0';
                    $where = '';
	                break;
	        }
	        $res = array();
    		$tags = explode(' ', trim($tagstr));
            $sql = &$this->sql;

            foreach ($tags as $tag){
        		$tag = $this->normalize($tag);
                $tmp_tag_id = $this->isExisting($tag);
                if ($tmp_tag_id){
                    $tag_ids[] = $tmp_tag_id;
                }
            }

            if (is_array($tag_ids)){
                $tag_id = implode(' OR tag_id=',$tag_ids);
                $tag_id = "{$tag_id})";
        
        		if ($tag_id){
        			$query = "SELECT {$sqlstr0} FROM tag_details {$extra_conditions} WHERE (tag_id={$tag_id} {$conds} {$sqlstr} {$where};";
            			$ret = $sql->query($query, 'array');
        			if ($ret){
                        $res = array_merge($res, $ret);
        			}
        		}
            }

    		$query = "SELECT {$sqlstr0} FROM tag_details {$extra_conditions} {$where} order by rand() limit 20;";
    		$ret = $sql->query($query, 'array');
    		if ($ret){
                $res = array_merge($res, $ret);
    		}
	        return $res;
	    }
	
	    function totalTagCount($type, $max = 100){
	        $sql = &$this->sql;
	        switch($type){
	            case 'all':
	                $conditions = '';
	                break;
	            case 'link':
	                $conditions = 'WHERE link_id != 0';
	                break;
	            case 'picture':
	                $conditions = 'WHERE picture_id != 0';
	                break;
	            case 'blog':
	                $conditions = 'WHERE blog_id != 0';
	                break;
	        }
	        $query = "SELECT tag, COUNT(tag_details.tag_id) AS count FROM tag_details INNER JOIN tags ON tag_details.tag_id = tags.tag_id 
	            $conditions GROUP BY tag ORDER BY tag LIMIT 0, $max;";
	        $res = $sql->query($query, 'array');
	        return $res;
	    }
	
	    function createCloud($type, $fontmax = 9, $fontmin = 1, $colour = '#11ccee'){
	        $cloud = $this->totalTagCount($type, 1000);
	
	        if (count($cloud)){
	            $carray = array();
	            foreach ($cloud as $tagg){
	                $carray[] = $tagg['count'];
	            }
	            $high = max(array_values($carray));
	            $low = min(array_values($carray));
	            $diff = $high - $low;
	            if ($diff == 0 ){ $diff = 1; }
	            $step = ($fontmax - $fontmin)/($diff);
	            $output = array();
	            foreach ($cloud as $tag){
	                $size = $fontmin + ($tag['count'] - $low) * $step;
	                $tcolour = dechex(hexdec($colour) + ($size*53));
	                $tcolour = str_pad($tcolour, 6, '0');
	                $output[] = "<a class='tag' style='color:#{$tcolour};font-size:{$size}em' title='{$tag['count']}' href='#'>".htmlspecialchars(stripslashes($tag['tag'])).'</a>';
	            }
	            return join("\n ", $output);
	        } else {
	            return '';
	        }
	    }
	}
} else {
		header('Location: /error404/');
		exit;
}
?>
