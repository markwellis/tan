<?php
/*
 * Created on 18 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
 
/**
 * TODO
 * MOVE FROM HERE
 */

define('BASE_PATH', $_SERVER['DOCUMENT_ROOT']);
define('SYS_PATH', BASE_PATH . '/sys');
define('LIB_PATH', BASE_PATH . '/lib');
define('MODEL_PATH', LIB_PATH . '/models');
define('TEMPLATE_PATH', LIB_PATH .'/templates');

/**
 * END TODO
 */
require_once(BASE_PATH . '/code/header.php');
require_once(MODEL_PATH . '/m_registration.php');
require_once(BASE_PATH . '/code/sql.php');

global $sql;
$sql = &new sql();
#global $user;
#$user = &new user();
$m_registration = &new m_registration();

$username = 'testtest';
$email_address = 'blob@blob.com';
$password = 'password';
print $m_registration->new_user($username, $email_address, $password);

?>
