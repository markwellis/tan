<?php
class m_admin{
    function __construct(){
        global $m_sql;
        $this->m_sql = &$m_sql;
    }

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
        $user_info = $this->m_sql->query($query, 's', array($username));
        return isset($user_info[0]) ? $user_info[0] : null;
    }
    
    function ban_user($user_id){
        # delete session_id(s)
        # update user_detail table set banned
        $query = "SELECT ip, session_id FROM pi WHERE user_id = ? GROUP BY session_id";
        $session_info = $this->m_sql->query($query, 'i', array($user_id));

        $session_store = ini_get('session.save_path');

        if ( isset($session_info) ){
            #user_id is there
            $temp_ip_hash = (array)null;

            #delete user sessions (if existing) to force logout
            foreach ($session_info as $info){
                if ( file_exists( "{$session_store}/sess_{$info['session_id']}") ){
                    unlink("{$session_store}/sess_{$info['session_id']}");
                }
                $temp_ip_hash[$info['ip']] = 1;
            }
            #ban all ips associated with user
            foreach ($temp_ip_hash as $ip => $one){
                $query = "INSERT INTO banned_ips (user_id, ip) VALUES (?, ?)";
                $this->m_sql->query($query, 'is', array($user_id, $ip), 'insert');
            }
            #mark user as deleted
            $query = "UPDATE user_details SET deleted = 'Y' WHERE user_id = ?";
            $retval = $this->m_sql->query($query, 'i', array($user_id), 'insert');

            $query = "UPDATE comments SET deleted = 'Y' WHERE user_id = ?";
            $retval = $this->m_sql->query($query, 'i', array($user_id), 'insert');
        }

        return $session_info;
    }
}
?>
