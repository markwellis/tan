<?php
/*
 * Created on 24 Dec 2008
 *
 * Cache abstraction layer
 * @package cache
 */

class m_cache {
	static $memcache;
	
	function __construct(){
		$this->memcache = new Memcache;
		@$this->memcache->connect(MEMCACHE_HOST, MEMCACHE_PORT);
	}
	
	function delete($memcache_key){
		@$this->memcache->delete($memcache_key);
	}
	
	function get($memcache_key){
		return $this->memcache->get($memcache_key);
	}
	
	function set($memcache_key, $object, $cache_time){
		return @$this->memcache->set($memcache_key, $object, null, $cache_time);
	}
	
	function flush(){
		return @$this->memcache->flush();
	}
}
?>
