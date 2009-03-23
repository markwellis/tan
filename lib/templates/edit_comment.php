<?php
/*
 * Created on 11 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
?>
<form id="edit_comment" method="post" action="/edit_comment/<?= $comment_id ?>/">

<?php
include_once(SYS_PATH . '/js/fckeditor/fckeditor.php') ;
$oFCKeditor = new FCKeditor("comment_edit_{$comment_id}");
$oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
$oFCKeditor->ToolbarSet = 'lulz';
$oFCKeditor->Width = '98%';
$oFCKeditor->Config["CustomConfigurationsPath"] = "/sys/script/fckconfig.js";
$oFCKeditor->Config['EnterMode'] = 'br';
$oFCKeditor->Value = $comment;

$oFCKeditor->Create() 
?>

<input type="submit" id="submit_edit">
</form>