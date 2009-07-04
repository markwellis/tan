<?php

class m_image {
    function __construct(){
        global $m_sql;
        $this->m_sql = &$m_sql;
    }
    
    function get_by_filename($filename){
        $query = "SELECT picture_id, title FROM picture_details WHERE filename = ?";
        $row = $this->m_sql->query($query, 's', array(PICTURE_PATH . "/{$filename}"));
        return $row[0];
    }
}

?>
