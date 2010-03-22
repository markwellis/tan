<?php
if (defined('MAGIC')) {
    class m_user {

        public function __construct() {
            $this->init();
            
            global $m_sql;
            $this->m_sql = &$m_sql;
        }

        private function init(){
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
        }

        public function banned_ip(){
            $query = "SELECT * FROM banned_ips WHERE ip = ?";
            $banned = $this->m_sql->query($query, 's', array($_SERVER['REMOTE_ADDR']));
            if ( isset($banned[0]['ip']) ){
                $this->logout();

                #we want to set a flash message, so reinit session
                $this->init();

                global $m_stash;
                $m_stash->add_message('This ip is banned');
                header('location: /');
                exit();
            }
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
            if ( isset($_SESSION['user_id']) ){
                return $_SESSION['user_id'];
            }
            return null;
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

        public function admin(){
            $user_id = $this->user_id();
            $username = $this->username();

            if ( ($user_id === 1) && ($username === 'mrbig4545') ){
            #me
                return 1;
            }

            if ( ($user_id === 17) && ($username === 'Scobiewan') ){
            #scobie
                return 1;
            }

            if ( ($user_id === 144) && ($username === 'AntiPsi') ){
            #anti
                return 1;
            }

            if ( ($user_id === 21) && ($username === 'psidust42') ){
            #psidust42
                return 1;
            }

            if ( ($user_id === 47) && ($username === 'ConeOfSilence') ){
            #ConeOfSilence
                return 1;
            }

            return 0;
        }

        public function total_comments($user_id) {
            $query = "SELECT comment_id FROM comments WHERE user_id = ?";
            return $this->m_sql->query($query, 'i', array($user_id), 'count');
        }

        public function login($username, $password) {
            $this->banned_ip();
            
            if (!$this->logged_in()) {
                $enc_password = hash('sha512',$password);
                $query = "SELECT * FROM user_details WHERE lower(username) = ?";
                $row = $this->m_sql->query($query, 's', array($username));
                if (isset($row[0]['password']) && $row[0]['password'] === $enc_password){
                    if ($row[0]['confirmed'] === 'N'){
                        return null;
                    }
                    if ($row[0]['deleted'] === 'Y'){
                        global $m_stash;
                        $m_stash->add_message('User is banned');
                        header('location: /');
                        exit;
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
