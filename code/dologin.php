<?php
if($_SERVER['REQUEST_METHOD']==='POST') {
	define('MAGIC', true);
    include_once("user.php");

    $password = mysql_escape_string(strip_tags($_POST["password"]));
    $username = mysql_escape_string(htmlentities(strip_tags(strtolower($_POST["username"])),ENT_QUOTES,'UTF-8'));
    global $user;
    $user = &new user;
    
    if ($user->login($username, $password)) {
        
        if ($_SESSION["ref"] == '' || $_SESSION['ref'] === '/login/'){
            header("Location: /");
            exit();
        }else{
            header("Location: ".  $_SESSION["ref"]);
            exit();
        }
    } else { 
    	$_SESSION['login_error'] = 'check username/password';
        header("Location: /login/");
        exit();
    }
} else {
    header("Location: /error404/");
    exit();
}
?>
