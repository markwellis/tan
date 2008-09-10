<?php

$positive = (int)$_GET['positive'];

if ($_GET['type'] === 'picture'){
    header("location:  /picture/$positive/1/");
}
if ($_GET['type'] == 'main'){
    header("location:  /main/$positive/1/");
}



?>
