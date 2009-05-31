<?php
$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];

include_once('config.php');
include_once('functions.php');

global $m_sql;
$m_sql = load_model('m_sql');

global $m_user;
$m_user = load_model('m_user');

global $m_stash;
$m_stash = load_model('m_stash');

global $m_cache;
$m_cache = load_model('m_cache');

include_once(THEME_PATH . '/' . THEME_NAME . '/' . THEME_NAME . '.php');

//populate the stash with defaults
$m_stash->js_includes = array(
    'http://ajax.googleapis.com/ajax/libs/mootools/1.2.1/mootools-yui-compressed.js', 
    '/sys/script/mootools-1.2-more.js',
    $m_stash->theme_settings['js_path'] . '/clientside.js',
);

$m_stash->page_title = 'ThisAintNews :: Social News For Pirates';
$m_stash->page_meta_description = 'Social News For Pirates';
$m_stash->page_keywords = 'strange pirate news community comments english social fun jokes videos pictures share sharing lol lolz funny humour humor';
$m_stash->location = 'link';

$m_stash->start_time = $time;
?>
