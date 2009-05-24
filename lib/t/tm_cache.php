<?php
/*
 * Created on 27 Jan 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
if (!$is_index){
    header("Cache-Control: no-cache, must-revalidate"); 
    header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");
}

if (! defined('SIMPLE_TEST')) {
    define('SIMPLE_TEST', 'simpletest/');
}
require_once(SIMPLE_TEST . 'unit_tester.php');
require_once(SIMPLE_TEST . 'reporter.php');

require_once('../config.php');
require_once(MODEL_PATH . '/m_cache.php');

class tm_cache extends UnitTestCase {

    private $key = "testCache";
    static $memcache;
    
    function __construct(){
        $this->UnitTestCase('tm_cache');
        $this->memcache = &new m_cache();
    }
    
    function test_general(){
        $m_cache = &$this->memcache;
        $this->assertTrue( $m_cache->set($this->key, "testtesttest", 1) );
        $this->assertEqual( $m_cache->get($this->key), "testtesttest" );
        $this->assertFalse( $m_cache->get("im not real") );
        sleep(1);
        $this->assertFalse( $m_cache->get($this->key) );
    }
    
    function test_flush(){
        $m_cache = &$this->memcache;
        $this->assertTrue( $m_cache->set($this->key, "testtesttest", 5) );
        $this->assertEqual( $m_cache->get($this->key), "testtesttest" );
        $this->assertTrue( $m_cache->flush() );
        $this->assertFalse( $m_cache->get($this->key) );
    }
    
    function test_delete(){
        $m_cache = &$this->memcache;
        $this->assertTrue( $m_cache->set($this->key, "testtesttest", 5) );
        $this->assertEqual( $m_cache->get($this->key), "testtesttest" );
        $this->assertFalse( $m_cache->delete($this->key) );
        $this->assertFalse( $m_cache->get($this->key) );
    }
    
    function __destruct(){
        $m_cache = &$this->memcache;
        $this->assertTrue( $m_cache->flush() );
    }
}

if ($is_index){
    $time = microtime();
    $time = explode(" ", $time);
    $time = $time[1] + $time[0];
    $start = $time;
}

$tm_cache = &new tm_cache();

if ($is_index){
    $tm_cache->run(new TextReporter());
    $time = microtime();
    $time = explode(" ", $time);
    $time = $time[1] + $time[0];
    $totaltime = number_format(($time - $start), 2);
    $mem_use = number_format(((memory_get_usage() / 1024) / 1024), 2);
    print ", Time: {$totaltime}s, Mem: {$mem_use}MB";
} else {
    $tm_cache->run(new HTMLReporter());
}
?>
