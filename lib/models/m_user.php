<?php
if (defined('MAGIC')) {
    class m_user {

        public function __construct() {
            $time = 60*60*24*90;

            if ( !isset( $_SESSION ['ready'] ) ) {
                session_name(SESSION_NAME);
                ini_set("session.gc_maxlifetime", $time);
                session_cache_expire($time);
                session_set_cookie_params($time, '/');
                session_start ();
                $_SESSION ['ready'] = TRUE;
             }
            
            if (isset($_COOKIE[SESSION_NAME])){
                @setcookie(SESSION_NAME, $_COOKIE[SESSION_NAME], time() + $time, "/");
            }
            
            global $m_sql;
            $this->m_sql = &$m_sql;

        }

        public function logged_in() {
            if (isset($_SESSION['username']) && isset($_SESSION['time']) && isset($_SESSION['user_id'])) {
                return true;
            } else {
                return false;
            }
        }
        
        public function username() { 
            return isset($_SESSION['username']) ? $_SESSION['username'] : null;
        }

        public function user_id() {
            return $_SESSION['user_id'];
        }
        
        public function user_id_to_username($user_id) {
            $query = "SELECT username FROM user_details WHERE user_id = ?";
            $username = $this->m_sql->query($query, 'i', array($user_id));
            return $username[0]['username'];
        }
        
        public function username_to_user_id($username){
            $query = "SELECT user_id FROM user_details WHERE username = ?";
            $user_id = $this->m_sql->query($query, 's', array($username));
            return $user_id[0]['user_id'];
        }

        public function join_date($user_id) {
            $query = "SELECT DATE_FORMAT(join_date, '%D %M %Y') AS join_date FROM user_details WHERE user_id = ?";
            $join_date = $this->m_sql->query($query, 'i', array($user_id));
            return $join_date[0]['join_date'];
        }

        public function total_comments($user_id) {
            $query = "SELECT comment_id FROM comments WHERE user_id = ?";
            return $this->m_sql->query($query, 'i', array($user_id), 'count');
        }

        public function login($username, $password) { 
            if (!$this->logged_in()) {
                $enc_password = hash('sha512',$password);
                $query = "SELECT * FROM user_details WHERE lower(username) = ?";
                $row = $this->m_sql->query($query, 's', array($username));
                if (isset($row[0]['password']) && $row[0]['password'] === $enc_password){
                    if ($row[0]['confirmed'] === 'N'){
                        return null;
                    }
                    $_SESSION['time'] = time();
                    $_SESSION['username'] = $row[0]['username'];
                    $_SESSION['user_id'] = $row[0]['user_id'];
                    @session_regenerate_id(true);
                    $query = "UPDATE user_details SET last_date=NOW() WHERE user_id = ?";
                    $this->m_sql->query($query, 'i', array($row[0]['user_id']), 'insert');
                    return true;
                } else {
                    return false; 
                }
            }
            return false; 
        }

        public function logout() {
            $_SESSION = array();
            session_set_cookie_params(-3600);
            return @session_destroy();
        }

        public function __destruct(){
            if (isset($_SESSION['ready'])){
                unset ( $_SESSION['ready'] );
            }
        }
    }
} else {
        header('Location: /error404/');
        exit;
}
?>