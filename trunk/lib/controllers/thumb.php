<?php
/*
 * Created on 5 Apr 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */

require_once('../config.php');

require_once(OLD_CODE_PATH . '/sql.php');
require_once(MODEL_PATH . '/m_image_resize.php');
global $sql;
$sql = &new sql();

$id = (int)$_GET['id'];
$x = (int)$_GET['x'];
    
$newimg = &new image_resize();
$image = $newimg->resize($id, $x);

if ($image){
    header("Content-type: image/{$image[1]}");
    echo $image[0];
}
exit();
?>
