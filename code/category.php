<?php

require_once('sql.php');

class category {
   
    function getMainSub() {
    // returns array (main0 => array(sub0, sub1, ...), main1  => array(sub0, sub1, ...) , ...)
        $sql = new sql();
        $query = "select distinct main from category_details;";
        $main = $sql->query($query, 'array1');
        $all = array();
        for ($i=0;$i<count($main);$i++){
            $query = "select sub,category_id from category_details where main='".$main[$i]."';";
            $all[$main[$i]] = $sql->query($query, 'array');
        }
        return $all;
    }

    function idToCategory($id){
        $sql = new sql();
        $query = "select * from category_details where category_id=$id;";
        $cat = $sql->query($query, 'row');
        return $cat['main'] . "/" . $cat['sub'];
    }
   
}

?>
