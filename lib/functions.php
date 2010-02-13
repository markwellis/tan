<?php

function load_template($template, $once = null){
    global $m_stash;

    if ($once){
        include_once(TEMPLATE_PATH . "/{$template}.php");
    } else {
        include(TEMPLATE_PATH . "/{$template}.php");
    }
}

function load_model($model, $args = null){
    include_once(MODEL_PATH . "/{$model}.php");
    
    if ($args){
        $rc = &new ReflectionClass($model);
        return $rc->newInstanceArgs($args);
    }
    return new $model();
}

function debug($data){
    error_log($data);
}

function debug_r($data){
    debug(print_r($data, 1));
}

function dump_stash(){
    global $m_stash;
    debug_r($m_stash);
}

function error($error){
    error_log($error);
}

function get_recent_comments(){
    global $m_cache;
    $memcache_key = "menu_recent_comments";
    $cached = $m_cache->get($memcache_key);
    if (!$cached){
        global $m_sql;
        $sql = &$m_sql;
        $query = "SELECT details, comment_id, username, UNIX_TIMESTAMP(date) as date, blog_id, link_id, picture_id, "
            ."(SELECT NSFW FROM picture_details WHERE comments.picture_id = picture_details.picture_id) AS NSFW "
            ."FROM comments WHERE deleted='N' ORDER BY date DESC LIMIT 20";
        $recent_comments = $sql->query($query, null, array(null));
        $m_cache->set($memcache_key, $recent_comments, 10);
        return $recent_comments;
    }
    return $cached;
}

function check_referer(){
    return preg_match('/' . addslashes($_SERVER['HTTP_HOST']) . '/', $_SERVER['HTTP_REFERER']);
}

function url_title($text){
    return preg_replace("/[^a-zA-Z0-9_]/", "", str_replace(' ','_', html_entity_decode(trim($text),ENT_QUOTES,'UTF-8')));
}

function print_json($data){
    header("Cache-Control: no-cache, must-revalidate");
    header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
    header ("Pragma: no-cache");
    header('Content-type: application/json');

    print json_encode($data);
    exit();
}

?>
