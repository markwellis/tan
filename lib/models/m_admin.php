<?php
class m_admin{
    function __construct(){
        global $m_sql;
        $this->m_sql = &$m_sql;
    }

#get
    function get_object($id, $type){
        $query = "SELECT * FROM {$type}_details WHERE {$type}_id = ?";
        $object_info = $this->m_sql->query($query, 'i', array($id));
        return isset($object_info[0]) ? $object_info[0] : null;
    }

#get user
    function get_user($username){
        # load all the shit bout the user
        #  registered on
        #  links, pics, blogs, comment count etc

        $query = "SELECT username, user_id, join_date, confirmed, deleted, "
            ."(SELECT COUNT(link_id) FROM link_details WHERE link_details.user_id = user_details.user_id) AS links, "
            ."(SELECT COUNT(blog_id) FROM blog_details WHERE blog_details.user_id = user_details.user_id) AS blogs, "
            ."(SELECT COUNT(picture_id) FROM picture_details WHERE picture_details.user_id = user_details.user_id) AS pictures, "
            ."(SELECT COUNT(comment_id) FROM comments WHERE comments.user_id = user_details.user_id AND deleted='N') AS comments "
            ."FROM user_details WHERE username LIKE lower(?)";
        $user_info = $this->m_sql->query($query, 's', array("${username}%"));
        return isset($user_info[0]) ? $user_info[0] : null;
    }

#delete
    function delete_object($id, $type){
        #delete object
        $query = "DELETE FROM {$type}_details WHERE {$type}_id = ?";

        $this->m_sql->query($query, 'i', array($id), 'insert');

        #delete plus
        $query = "DELETE FROM plus WHERE {$type}_id = ?";
        $this->m_sql->query($query, 'i', array($id), 'insert');

        #delete minus
        $query = "DELETE FROM minus WHERE {$type}_id = ?";
        $this->m_sql->query($query, 'i', array($id), 'insert');

        #delete comments
        $query = "DELETE FROM comments WHERE {$type}_id = ?";
        $this->m_sql->query($query, 'i', array($id), 'insert');

        #delete tag_details
        $query = "DELETE FROM tag_details WHERE {$type}_id = ?";
        $this->m_sql->query($query, 'i', array($id), 'insert');

        #deted pi
        $query = "DELETE FROM pi WHERE id = ? AND type = ?";
        $this->m_sql->query($query, 'is', array($id, $type), 'insert');
    }

#delete user :(
    function ban_user($user_id, $delete_comments, $delete_objects){
        # delete session_id(s)
        # update user_detail table set banned
        $query = "SELECT ip, session_id FROM pi WHERE user_id = ? GROUP BY session_id";
        $session_info = $this->m_sql->query($query, 'i', array($user_id));

        $session_store = ini_get('session.save_path');

        if ( isset($session_info) ){
        #user_id's session(s) found in pi table
            $temp_ip_hash = (array)null;

            foreach ($session_info as $info){
            #delete user sessions (if existing) to force logout
                if ( file_exists( "{$session_store}/sess_{$info['session_id']}") ){
                    unlink("{$session_store}/sess_{$info['session_id']}");
                }
                $temp_ip_hash[$info['ip']] = 1;
            }
            foreach ($temp_ip_hash as $ip => $one){
            #ban all ips associated with user
                $query = "INSERT INTO banned_ips (user_id, ip) VALUES (?, ?)";
                $this->m_sql->query($query, 'is', array($user_id, $ip), 'insert');
            }
        }
        #mark user as deleted
        $query = "UPDATE user_details SET deleted = 'Y' WHERE user_id = ?";
        $retval = $this->m_sql->query($query, 'i', array($user_id), 'insert');

        if ( $delete_comments === 1 ){        
        #delete users comments
            $query = "UPDATE comments SET deleted = 'Y' WHERE user_id = ?";
            $retval = $this->m_sql->query($query, 'i', array($user_id), 'insert');
        }

        if ( $delete_objects === 1 ){
        #remove user submitted objects

        #links
            $query = "DELETE FROM link_details WHERE user_id = ?";
            $this->m_sql->query($query, 'i', array($user_id), 'insert');
        #blogs
            $query = "DELETE FROM blog_details WHERE user_id = ?";
            $this->m_sql->query($query, 'i', array($user_id), 'insert');
        #pics
            $query = "DELETE FROM picture_details WHERE user_id = ?";
            $this->m_sql->query($query, 'i', array($user_id), 'insert');
        }

        return $session_info;
    }

#log stuff
    function add_to_log($user_id, $id, $type, $reason) {
        $query = "INSERT INTO admin_log (user_id, id, type, reason, date, what) VALUES (?, ?, ?, ?, NOW(), 'deleted')";
        $this->m_sql->query($query, 'iiss', array($user_id, $id, $type, $reason), 'insert');
    }
}
?>
