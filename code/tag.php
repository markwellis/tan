<?php
include_once("sql.php");

class tag{
    private $control_tags = 'all';

    function isExisting($tag){
        /* checks to see if its an existing tag
        returns tag_id if existing
        returns false if not */

        $tag = mysql_escape_string($tag);
        $sql = new sql();
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
        $sql = new sql();
        $query0 = "insert into tags (tag_id, tag) values ('','$tag');";
        $query1 = "select tag_id from tags where tag='$tag';";
        $sql->query($query0, 'none');
        $res = $sql->query($query1, 'row');
        return $res['tag_id'];
    }

    function isTagged($type, $id, $tagid){
    /* Check if something is tagged */
        $sql = new sql();
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
        $user = new user();
        $userid = $user->getUserId();
        $username = $user->getUsername();
        $tags = $this->getTagIds($tags);
        $id = (int)$id;
        foreach ($tags as $tag){
            $res = $this->isTagged($type, $id, $tag);
            if (!$res){
                $sql = new sql();
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
        $sql = new sql();
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
                $sqlstr = 'link_id!=0 AND picture_id=0 AND blog_id=0';
                break;
            case 'picture':
                $sqlstr0 = 'DISTINCT picture_id';
                $conds = 'AND';
                $sqlstr = 'link_id=0 AND picture_id!=0 AND blog_id=0';
                break;
            case 'blog':
                $sqlstr0 = 'DISTINCT blog_id';
                $conds = 'AND';
                $sqlstr = 'link_id=0 AND picture_id=0 AND blog_id!=0';
                break;
        }
        $res = array();
        if (preg_match('/^all$/', $tagstr)){
            $sql = new sql();
            $query = "SELECT $sqlstr0 FROM tag_details WHERE $sqlstr;";
            $ret = $sql->query($query, 'array');
            $res[] = $ret; 
        } else {
            $tags = explode(' ', trim($tagstr));
            foreach ($tags as $tag){
                $tag = $this->normalize($tag);
                $existing = $this->isExisting($tag);
                if ($existing){
                    $sql = new sql();
                    $query = "SELECT $sqlstr0 FROM tag_details WHERE tag_id=$existing $conds $sqlstr;";
                    $ret = $sql->query($query, 'array');
                    if ($ret){
                        $res[] = $ret;
                    }
                }
            }
            $sql0 = new sql();
            $query = "SELECT $sqlstr0 FROM tag_details order by rand() limit 20;";
            $ret = $sql0->query($query, 'array');
            if ($ret){
                $res[] = $ret;
            }
        }
        return $res;
    }

    function totalTagCount($type, $max = 100){
        $sql = new sql();
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

//doTag('link', 105, 'medicine operation science health german arms', 1, 'mrbig4545');
//doTag('link', 98, 'medicine exercise drug health science', 1, 'mrbig4545');
?>
