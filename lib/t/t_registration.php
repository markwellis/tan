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

global $m_registration;
$m_registration = &load_model('m_registration');

class tm_registration extends UnitTestCase {

    function __construct(){
        $this->UnitTestCase('tm_user');

        global $m_registration;
        $this->m_registration = $m_registration;
    }
    
    function test_begin(){
        $this->assertEqual($this->m_registration->new_user('tetstsman', 'passwrod', 'password', 'm@mtestsetestset.com'), 'Passwords do not match');
        $this->assertEqual($this->m_registration->new_user('tetstsman', 'pass', 'pass', 'm@mtestsetestset.com'), 'Password needs to be atleast 6 letters');
        $this->assertEqual($this->m_registration->new_user('tetstsman', 'password', 'password', 'm@mtes::@SDF:Sdf.zxcctsfdg.etestset.comfld;fd'), 'Not an valid email address');
        $this->assertEqual($this->m_registration->new_user('mrbig4545', 'password', 'password', 'm@mtestsetestset.com'), 'Username already exists');
        $this->assertEqual($this->m_registration->new_user('tetstsman', 'password', 'password', 'mrbig4545@howmanykillings.com'), 'Email address alreay exists');
        $this->assertNull($this->m_registration->new_user('tetstsman', 'password', 'password', 'm@mt45etteet.com'));

        $this->assertIsA($this->m_registration->user_id, 'integer');
        $user_id = $this->m_registration->user_id;
        $this->assertIsA($this->m_registration->token, 'string');
        $token = $this->m_registration->token;

        $this->assertTrue($this->m_registration->compare_token($user_id, $token));
        $this->assertFalse($this->m_registration->confirm($user_id));
        $this->cleanup($user_id);
    }
    
    function cleanup($user_id){
        global $m_sql;
        $query = 'DELETE FROM user_details WHERE user_id = ?';
        return $m_sql->query($query, 'i', array($user_id), 'insert');

    }
}

$tm_registration = &new tm_registration();

ob_start();
    $tm_registration->run(new HTMLReporter());
ob_end_flush();

?>
