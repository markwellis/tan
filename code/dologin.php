<?php
if($_SERVER['REQUEST_METHOD']==='POST') { 
    include_once("user.php");

    $password = mysql_escape_string(strip_tags($_POST["password"]));
    $username = mysql_escape_string(htmlentities(strip_tags($_POST["username"]),ENT_QUOTES,'UTF-8'));

    $user = new user;
    if ($user->login($username, $password)) {
        if ($_POST["ref"] == ''){
            header("Location: /");
        }else{
            header("Location: ".$_POST["ref"]);
        }
    } else { 
        header("Location: ../login/");
        exit();
    }
} else { die('error'); }
?>
