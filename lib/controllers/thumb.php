<?php
/*
 * Created on 5 Apr 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
require_once('../header.php');

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
    
$newimg = load_model('m_image_resize');

$image = $newimg->resize($id, $x);

if ($image){
    header("Content-type: image/{$image[1]}");
    echo $image[0];
}
exit();
?>
