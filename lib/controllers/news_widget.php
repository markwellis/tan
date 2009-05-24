<?php
require_once('../header.php');

$m_stash->overlay = true;


$m_widget = load_model('m_news_widget');

$m_stash->links = $m_widget->recent();

load_template('lib/open_page');

load_template('news_widget');

load_template('lib/close_page');
?>
