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

#log stuff
    function add_to_log($user_id, $id, $type, $reason) {
        $query = "INSERT INTO admin_log (user_id, id, type, reason, date, what) VALUES (?, ?, ?, ?, NOW(), 'deleted')";
        $this->m_sql->query($query, 'iiss', array($user_id, $id, $type, $reason), 'insert');
    }
}
?>
