<?php
/*
 * Created on 11 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
?>
<form id="edit_comment" method="post" action="/edit_comment/<?= $m_stash->comment_id ?>/">

<?php
include_once(SYS_PATH . '/js/fckeditor/fckeditor.php') ;
$oFCKeditor = new FCKeditor("comment_edit_{$m_stash->comment_id}");
$oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
$oFCKeditor->ToolbarSet = 'lulz';
$oFCKeditor->Width = '98%';
$oFCKeditor->Height = '300px';
$oFCKeditor->Config["CustomConfigurationsPath"] = "/sys/script/fckconfig.js";
$oFCKeditor->Config['EnterMode'] = 'br';
$oFCKeditor->Value = $m_stash->comment;

$oFCKeditor->Create();
?>

<input type="submit" id="submit_edit" value='Edit'><input type="submit" id="delete_comment" name="delete_comment" value='Delete Comment'>
</form>