<?php
/*
 * Created on 9 Mar 2009
 *
 * Copyright 2009 - mark@thisaintnews.com
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
 
if ($object['link_id']){
    $object['type'] = 'link';
    $object['id'] = $object['link_id'];
} elseif ($object['picture_id']){
    $object['type'] = 'pic';
    $object['id'] = $object['picture_id'];
} elseif ($object['blog_id']){
    $object['type'] = 'blog';
    $object['id'] = $object['blog_id'];
} 

?>
<div class='profile_comment'>
<span><?= $avatar ?><?= $object['username'] ?> wrote on <?= $object['date'] ?></span>
<a class='comment_details' href='/view<?= $object['type'] ?>/<?= $object['id'] ?>/#comment<?= $object['comment_id'] ?>'><?= strip_tags($object['details']) ?></a>
</div>