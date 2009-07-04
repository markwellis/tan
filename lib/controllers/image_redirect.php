<?php
require_once('../header.php');

$filename = isset($_GET['filename']) ? $_GET['filename'] : null;
$id = isset($_GET['id']) ? $_GET['id'] : null;

$m_image = load_model('m_image');

if (isset($filename)){
    $details = $m_image->get_by_filename($filename);

    $details['title'] = url_title($details['title']);
    $url = "http://{$_SERVER['HTTP_HOST']}/viewpic/{$details['picture_id']}/{$details['title']}/";

    header("location: {$url}"); 
}

if (isset($id)){
    $details = $m_image->get_by_id($id);

    $details['title'] = url_title($details['title']);
    $url = "http://{$_SERVER['HTTP_HOST']}/viewpic/{$details['picture_id']}/{$details['title']}/";

    header("location: {$url}"); 
}
?>
