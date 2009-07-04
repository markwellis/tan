<?php
require_once('../header.php');

$filename = isset($_GET['filename']) ? $_GET['filename'] : null;

if (isset($filename)){
    $m_image = load_model('m_image');
    $details = $m_image->get_by_filename($filename);

    $details['title'] = url_title($details['title']);
    $url = "http://{$_SERVER['HTTP_HOST']}/viewpic/{$details['picture_id']}/{$details['title']}/";

    header("location: {$url}"); 
}
?>
