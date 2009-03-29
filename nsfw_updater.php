<?php
/*
 * Created on 28 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
 
DEFINE('MAGIC', 12);
require_once('code/user.php');
require_once('code/sql.php');

global $user;
global $sql;

$sql = &new sql();
$user = &new user();

if ( $user->isLoggedIn() && ($user->getUsername() == 'mrbig4545') ){
    if ($_SERVER['REQUEST_METHOD'] == 'POST'){
        foreach ($_POST['nsfw'] as $nsfw){
            $nsfw = (int)$nsfw;
        }
        $conditions = implode(' OR picture_id=', $_POST['nsfw']);
        
        $query= "UPDATE picture_details SET NSFW = 'Y' WHERE picture_id={$conditions}";
error_log($query);
        $sql->query($query, 'none');
    }
    
    $query = "SELECT * FROM picture_details WHERE NSFW='N' ORDER BY date";
    $pics = $sql->query($query, 'array');
    
    $i = 0;
    echo '<form method="post">';
    foreach ($pics as $pic){
        echo "<img src='/thumb/{$pic['picture_id']}/200/' onclick='document.getElementById(\"c{$pic['picture_id']}\").checked=true'/>";
        echo "<input type='checkbox' value='{$pic['picture_id']}' name='nsfw[]' id='c{$pic['picture_id']}' />";
        ++$i;
        
        if ( $i % 5 === 1 ){
            echo '<br />';
        }
    }
    echo "<input type='submit' value='Update'/>";
    echo '</form>';
}



?>


