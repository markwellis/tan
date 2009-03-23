<?php
/*
 * Created on 18 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package m_registration
 */

class m_registration{
    function __construct(){
        global $sql;
        $this->m_sql = &$sql;
    }
    
    private function create_random_token(){
        $token0 = mt_rand();
        $token1 = $token0 * time();
        $token0 = hash('sha512',"{$token0}.{$token1}");
        return $token0;
    }
    
    private function store_token($user_id, $token){
        $user_id = (int)$user_id; 
        $token = mysql_escape_string($token);
        $query = "INSERT INTO user_tokens (token, user_id, expires) VALUES ('$token', $user_id, DATE_ADD(NOW(), INTERVAL 1 DAY))";
        return $this->m_sql->query($query, 'none');
    }
    
    private function get_token($user_id){
        $user_id = (int)$user_id;
        $query = "SELECT token FROM user_tokens WHERE user_id={$user_id} AND expires > NOW() LIMIT 1";
        $row = $this->m_sql->query($query, 'row');
        return $row['token'];
    }
    
    private function setup_token($user_id){
        $token = $this->create_random_token();
        $this->store_token($user_id, $token);
        return $token;
    }
    
    private function encode_password($password){
        $password = hash('sha512',$password);
        return $password;
    }
    
    private function create_user($username, $email_address, $password){
        $query = "INSERT INTO user_details (username, join_date, last_date, email, password) VALUES ('{$username}',  NOW(),  NOW(), '{$email_address}', '{$password}')";
        $this->m_sql->query($query, 'none');
        return $this->m_sql->query(null, 'id');
    }
    
    public function new_user($username, $email_address, $password){
        $password = $this->encode_password($password);
        $user_id = $this->create_user($username, $email_address, $password);
        $this->setup_token($user_id);
    }
    
    public function compare_token($user_id, $user_token){
        $db_token = $this->get_token($user_id);
        if ($user_token === $db_token){
            return true;
        }
        return false;
    }
    
    public function email_token($email){
        require_once("Mail.php");
        
    }
    
}
?>
