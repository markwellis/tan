<?php
require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/HTMLPurifier.includes.php');
require_once ($_SERVER['DOCUMENT_ROOT'] . '/lib/3rdparty/htmlpurifier/HTMLPurifier.auto.php');

class purifier{
    
    function __construct(){
        $this->config = HTMLPurifier_Config::createDefault();
        $this->config->set('Core', 'Encoding', 'UTF-8');
        $this->config->set('HTML', 'Doctype', 'XHTML 1.0 Strict');
        $this->config->set('HTML', 'ForbiddenAttributes', 'rel');
        $this->purifier = new HTMLPurifier($this->config);
    }

    function purify($text){
        return $this->purifier->purify($text);
    }
}
?>
