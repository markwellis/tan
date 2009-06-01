<?php
class m_tag{
   function __construct($location){
        if (!$location){
            die('no location');
        }
        $this->location = $location;

        global $m_sql;
        $this->m_sql = &$m_sql;
    }
    
    function existing($tag){
        $query = "SELECT tag_id FROM tags WHERE tag = ?";
        $row = $this->m_sql->query($query, 's', array($tag));
        if ($row){
            return $row[0]['tag_id'];
        } else {
            return false;
        }
    }

    function normalize($tag){
        $tag = preg_replace('/[^a-zA-Z0-9]/', '', $tag);
        return strtolower($tag);
    }
    
    function tag($tags, $id, $user_id, $username) {
        $tags = $this->tags_to_ids($tags);
        foreach ($tags as $tag_id){
            $tagged = $this->tagged($id, $tag_id);
            if (!$tagged){
                $query = "INSERT INTO tag_details (tag_id, user_id, username, {$this->location}_id, date) VALUES (?, ?, ?, ?,NOW());";
                $this->m_sql->query($query, 'iisi', array($tag_id, $user_id, $username, $id), 'insert');
            }
        }
    }
    
    function tagged($id, $tagid){
        $query = "SELECT tag_id FROM tag_details WHERE {$this->location}_id = ? AND tag_id = ?";
        $res = $this->m_sql->query($query, 'ii', array($id, $tagid), 'count');
        return $res;
    }
    
    function tags_to_ids($tagstr){
        $tags = explode(' ', trim($tagstr));
        $res = array();
        foreach ($tags as $tag){
            $tag = $this->normalize($tag);
            if ($tag){
                $existing = $this->existing($tag);
                if ($existing){
                    $res[] = $existing;
                } elseif ($tag !== 'all' && $tag !== '') {
                    $tag_id = $this->add_tag($tag);
                    if ($tag_id){
                        $res[] = $tag_id;
                    }
                }
            }
        }
        return $res;
    }
    
    function add_tag($tag){
        $query = 'INSERT INTO tags (tag) VALUES (?)';
        $res = $this->m_sql->query($query, 's', array($tag), 'insert');
        return $res;
    }
    
    function thumbs_tags($tagstr){
        $tag_ids = array();
        $tags = explode(' ', trim($tagstr));
        
        //this is here so that if there are no tags, the array merge for random tags still works
        $res = array();

        foreach ($tags as $tag){
            $tag = $this->normalize($tag);
            if ($tag){
                $existing = $this->existing($tag);
                if ($existing){
                    $tag_ids[] = $existing;
                }
            }
        }

        if ($tag_ids){
            $tag_id = implode(' OR tag_id=',$tag_ids);
            $tag_id = "{$tag_id})";
    
            if ($tag_id){
                $query = "SELECT DISTINCT picture_id, (SELECT NSFW FROM picture_details WHERE picture_details.picture_id=t2.picture_id) AS NSFW FROM tag_details AS t2 WHERE (tag_id={$tag_id} AND picture_id > 0 HAVING NSFW='N'";
                $res = $this->m_sql->query($query, null, array(null));
            }
        }

        $query = "SELECT DISTINCT picture_id, (SELECT NSFW FROM picture_details WHERE picture_details.picture_id=t2.picture_id) AS NSFW FROM tag_details AS t2 HAVING NSFW='N' ORDER BY RAND() LIMIT 20";
        $ret = $this->m_sql->query($query, null, array(null));
        if ($ret){
            $res = array_merge($res, $ret);
        }
        return $res;
    }
}
?>
