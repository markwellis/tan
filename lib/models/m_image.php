<?php

class m_image {
    function __construct(){
        global $m_sql;
        $this->m_sql = &$m_sql;
    }
    
    function get_by_filename($filename){
        $query = "SELECT picture_id, title FROM picture_details WHERE filename LIKE ?";
        $row = $this->m_sql->query($query, 's', array("%/images/pics/{$filename}"));
        return $row[0];
    }
    
    function get_by_id($id){
        $query = "SELECT picture_id, title FROM picture_details WHERE picture_id LIKE ?";
        $row = $this->m_sql->query($query, 'i', array($id));
        return $row[0];
    }
}

?>
