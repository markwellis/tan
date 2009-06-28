<?php
/*
 * Created on 24 Dec 2008
 *
 * Cache abstraction layer
 * @package cache
 */

class m_object {
	private $memcache;
	
	function __construct($location){
        if (!$location){
            die('no location');
        }
        $this->location = $location;
        
        global $m_sql;
        $this->m_sql = &$m_sql;
	}
	
	function get($id){
        $query = "SELECT * from {$this->location}_details WHERE {$this->location}_id = ?";
        $details = $this->m_sql->query($query, 'i', array($id));
        return $details[0];
	}
}
?>
