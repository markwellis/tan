<?php

class m_stash{
    function __construct(){
        global $m_user;
        $this->m_user = $m_user;
    }
    
    function flash($key, $value = null){
        if ($value){
            if (!isset($_SESSION['flash'])){
                $_SESSION['flash'] = array();
            }
            $_SESSION['flash'][$key] = $value;
        } else {
            if (isset($_SESSION['flash'][$key])){
                $value = $_SESSION['flash'][$key];
                unset($_SESSION['flash'][$key]);
                return $value;
            }
            return null;
        }
    }

    function add_message($value){
        if (!is_array($_SESSION['flash']['message'])){
            $_SESSION['flash']['message'] = array($value);
        } else {
            array_push($_SESSION['flash']['message'], $value);
        }
    }
    
    function query_count(){
        global $m_sql;
        return $m_sql->query_count;
    }
}

?>
