<?php
header("Cache-Control: no-cache, must-revalidate");
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT");
header ("Pragma: no-cache");

define('MAGIC', true);
require_once('code/tag.php');
require_once('code/unified.php');
$tag = new tag();
$picture = new unified('picture');

$noPage = 1;

$tagss = urldecode($_GET['tags']);
$res = $tag->getMatchingObjects('picture', $tagss);
$alreadydone = array();
foreach ($res as $tagrow){
    foreach ($tagrow as $picid){
        if (!in_array($picid['picture_id'], $alreadydone)){
            $images .="<img id='pic{$picid['picture_id']}' 
                style='height:50px;width:50px;cursor:pointer;vertical-align:middle;margin-top:15px;' 
                src='/thumb/{$picid['picture_id']}/100/' alt={$picid['picture_id']} 
                onclick=\"selectImage(this.id);return false;\" />\n";
            $alreadydone[] = $picid['picture_id'];
        }
    }
}
print $images;
exit();
?>
