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
        global $m_sql;
        $this->m_sql = &$m_sql;
    }

    private function create_random_token(){
        $token0 = mt_rand();
        $token1 = $token0 * time();
        $token0 = hash('sha512',"{$token0}.{$token1}");
        return $token0;
    }

    private function store_token($user_id, $token, $type){
        $user_id = (int)$user_id; 
        $token = $token;
        $query = "SELECT user_id FROM user_tokens WHERE type = ?";
        if ($this->m_sql->query($query, 's', array($type), 'count')){
            $query = "DELETE FROM user_tokens WHERE type = ?";
            $this->m_sql->query($query, 's', array($type), 'insert');
        }
        $query = "INSERT INTO user_tokens (token, user_id, expires, type) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 5 DAY), ?)";
        return $this->m_sql->query($query, 'sis', array($token, $user_id, $type), 'insert');
    }

    private function get_token($user_id, $type = 'reg'){
        $user_id = (int)$user_id;
        $query = "SELECT token FROM user_tokens WHERE user_id= ? AND type = ? AND expires > NOW() LIMIT 1";
        $row = $this->m_sql->query($query, 'is', array($user_id, $type));
        if ($row){
            return $row[0]['token'];
        }
        return false;
    }

    public function setup_token($user_id, $type = 'reg'){
        $this->token = $this->create_random_token();
        if ($this->store_token($user_id, $this->token, $type)){
            return $this->token;
        }
        return false;
    }

    private function encode_password($password){
        $password = hash('sha512',$password);
        return $password;
    }

    private function create_user($username, $email_address, $password){
        $query = "INSERT INTO user_details (username, join_date, last_date, email, password) VALUES (?,  NOW(),  NOW(), ?, ?)";
        return $this->m_sql->query($query, 'sss', array($username, $email_address, $password), 'insert');
    }

    public function new_user($username, $password0, $password1, $email_address){
        $valid = $this->validate($username, $password0, $password1, $email_address);
        if ($valid === null){
            $password0 = $this->encode_password($password0);
            $this->user_id = $this->create_user($username, $email_address, $password0);
            $this->setup_token($this->user_id);
        }
        return $valid;
    }

    public function confirm($user_id){
        $query = "UPDATE user_details SET confirmed = 'Y' WHERE user_id = ?";
        $retval = $this->m_sql->query($query, 'i', array($user_id), 'insert');
        return $this->clean_tokens($user_id);
    }
    
    private function clean_tokens($user_id){
        $query = "DELETE FROM user_tokens WHERE user_id = ? OR expires < NOW()";
        return $this->m_sql->query($query, 'i', array($user_id), 'insert');
    }

    public function compare_token($user_id, $user_token, $type = 'reg'){
        $db_token = $this->get_token($user_id, $type);
        if ($user_token === $db_token){
            return true;
        }
        return false;
    }
    
    function validate($username, $password0, $password1, $email){
        if (!$this->validate_email($email)) {
            return 'Not an valid email address';
        }
        
        if ($password0 == '' || $password1 == '' || $email == '' || $username == '') {
            return 'Please complete the form';
        }
        if (!$this->validate_passwords_match($password0, $password1)) {
            return 'Passwords do not match';
        }
        if (!$this->validate_password_length($password0)) {
            return 'Password needs to be atleast 6 letters';
        }
        
        if (preg_match("/[^a-zA-Z0-9]/", $username)) {
            return 'Username can only contain letters or numbers';
        }
        if ($this->check_user($username)) {
            return 'Username already exists';
        }
        if ($this->check_email($email)) {
            return 'Email address alreay exists';
        }
        return null;
    }
    
    public function validate_password_length($password){
        if (strlen($password) >= 6) {
            return true;
        }
        return false;
    }
    
    public function validate_passwords_match($password0, $password1){
        if ($password0 === $password1) {
            return true;
        }
        return false;
    }

    public function validate_email($email){
        return preg_match("/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i", $email);
    }

    private function check_user($username){
        $query = "SELECT user_id FROM user_details WHERE LOWER(username) = ?";
        $result = $this->m_sql->query($query, 's', array($username));
        return $result;
    }
    
    public function check_email($email){
        $query = "SELECT user_id FROM user_details WHERE LOWER(email) = ?";
        $result = $this->m_sql->query($query, 's', array($email));
        return $result[0]['user_id'];
    }
    
    public function change_password($user_id, $password){
        $user_id = (int)$user_id;
        $password = $this->encode_password($password);
        $query = "UPDATE user_details SET password = ?, confirmed = 'Y' WHERE user_id = ?";
        $this->clean_tokens($user_id);
        return $this->m_sql->query($query, 'si', array($password, $user_id), 'insert');
    }
}
?>
