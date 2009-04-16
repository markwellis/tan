<?php
header("Cache-Control: no-cache, must-revalidate");
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
header ("Pragma: no-cache");
include('../header.php');

if (! defined('SIMPLE_TEST')) {
    define('SIMPLE_TEST', 'simpletest/');
}
require_once(SIMPLE_TEST . 'unit_tester.php');
require_once(SIMPLE_TEST . 'reporter.php');

global $m_sql;
$m_sql = &load_model('m_sql');

global $m_user;
$m_user = &load_model('m_user');
if ($m_user->logged_in()){
    $m_user->logout();
}
class tm_user extends UnitTestCase {

    function __construct(){
        $this->UnitTestCase('tm_user');

        global $m_user;
        $this->m_user = $m_user;
    }
    
    function test_begin(){
        $this->assertFalse($this->m_user->logged_in());
        $this->assertFalse($this->m_user->username());
        $this->assertFalse($this->m_user->user_id());
        $this->assertFalse($this->m_user->login('mrbig4545', '12'));
        
        $this->assertTrue($this->m_user->login('mrbig4545', 'un2por7'));
        $this->assertTrue($this->m_user->logged_in());
        $this->assertEqual($this->m_user->username(), 'mrbig4545');
        $this->assertEqual($this->m_user->user_id(), 1);
        $this->assertIsA($this->m_user->total_comments(1), 'integer');
        $this->assertTrue($this->m_user->join_date(1));
        $this->assertEqual($this->m_user->username_to_user_id('mrbig4545'), 1);
        $this->assertEqual($this->m_user->user_id_to_username(1), 'mrbig4545');
        $this->assertTrue($this->m_user->logout());
        
        
        $this->assertFalse($this->m_user->logged_in());
        $this->assertFalse($this->m_user->username());
        $this->assertFalse($this->m_user->user_id());
        $this->assertFalse($this->m_user->login('mrbig4545', '12'));
        
        $this->assertFalse($this->m_user->logged_in());
        $this->assertFalse($this->m_user->username());
        $this->assertFalse($this->m_user->user_id());
        $this->assertFalse($this->m_user->login('mrbig4545', '12'));
        
        
        $this->assertTrue($this->m_user->login('mrbig4545', 'un2por7'));
        $this->assertTrue($this->m_user->logged_in());
        $this->assertEqual($this->m_user->username(), 'mrbig4545');
        $this->assertEqual($this->m_user->user_id(), 1);
        $this->assertTrue($this->m_user->total_comments(1));
        $this->assertTrue($this->m_user->join_date(1));
        $this->assertEqual($this->m_user->username_to_user_id('mrbig4545'), 1);
        $this->assertEqual($this->m_user->user_id_to_username(1), 'mrbig4545');
    }
}

$tm_user = &new tm_user();

ob_start();
    $tm_user->run(new HTMLReporter());
ob_end_flush();

?>
