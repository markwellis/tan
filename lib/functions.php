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
        $margs = implode(', ', $args);
        return new $model($margs);
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
    $memcache = new Memcache;
    $memcache_key = "recent_comments";
    @$memcache->connect('127.0.0.1', 11211);
    $cached = @$memcache->get($memcache_key);
        
    if (!$cached){
        global $m_sql;
        $sql = &$m_sql;
        $query = "SELECT details, comment_id, username, UNIX_TIMESTAMP(date) as date, blog_id, link_id, picture_id FROM comments WHERE deleted='N' ORDER BY date DESC LIMIT 20";
        $recent_comments = $sql->query($query, null, array(null));
        @$memcache->set($memcache_key, $recent_comments, false, 10);
        return $recent_comments;
    }
    return $cached;
}

function check_referer(){
    return preg_match('/' . addslashes($_SERVER['HTTP_HOST']) . '/', $_SERVER['HTTP_REFERER']);
}

?>
