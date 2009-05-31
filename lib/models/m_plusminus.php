<?php
class m_plusminus{
    function __construct($location){
        if (!$location){
            die('no location');
        }
        $this->location = $location;

        global $m_sql;
        $this->m_sql = &$m_sql;
    }
    
    function add_plus($user_id, $id){
        $query = "INSERT INTO plus (user_id, date, {$this->location}_id) VALUES (?, NOW(), ?)";
        $id = $this->m_sql->query($query, 'ii', array($user_id, $id), 'insert');
        return $id;
    }

    function add_minus($user_id, $id){
        $query = "INSERT INTO minus (user_id, date, {$this->location}_id) VALUES (?, NOW(), ?)";
        $id = $this->m_sql->query($query, 'ii', array($user_id, $id), 'insert');
        return $id;
    }
}
?>
