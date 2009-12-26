<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
    <head> 
        <title><? echo $m_stash->page_title ?></title>
        <meta name='Description' content='<? echo $m_stash->page_meta_description ?>'/>
        <meta name="keywords" content='<? echo $m_stash->page_keywords ?>'/>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <?php if (!isset($m_stash->overlay)) { ?>
            <link rel="stylesheet" type="text/css" title="default" href="<?php echo $m_stash->theme_settings['css_path'] ?>/default.css?1=13" />
        <?php } ?>
        <link rel="shortcut icon" href="/favicon.ico" /> 
    </head>
