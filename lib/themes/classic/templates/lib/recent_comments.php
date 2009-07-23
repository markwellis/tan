<div style="overflow:hidden;">
    <span>Recent Comments</span>
    <ul style="list-style:none;margin:0px;padding:0px;">

    <?php
        foreach ($m_stash->recent_comments as $comment){
            if ($comment['blog_id']) {
                $comment_type = 'blog';
                $comment_id = $comment['blog_id'];
            } elseif ($comment['link_id']) {
                $comment_type = 'link';
                $comment_id = $comment['link_id'];
            } elseif ($comment['picture_id']){
                $comment_type = 'pic';
                $comment_id = $comment['picture_id'];
            }

            $comment['ndetails'] = preg_replace("/\[quote\ user=[\"'](.+?)[\"']\](.*?)\[\/quote\]/miUs", '', $comment['details']);
            $comment['ndetails'] = strip_tags(html_entity_decode($comment['ndetails'], ENT_QUOTES, 'UTF-8'));
            if ($comment['NSFW'] === 'Y'){
                $comment['ndetails'] = '[NSFW] ' . $comment['ndetails'];
            }

            $comment['short'] = htmlentities(mb_substr($comment['ndetails'], 0, 50, 'UTF-8'),ENT_QUOTES,'UTF-8');
            $comment['long'] = htmlentities(mb_substr($comment['ndetails'], 0, 400, 'UTF-8'),ENT_QUOTES,'UTF-8');
            $comment['date'] = date( 'H:i:s', $comment['date']);
            if ( $comment['short'] !== $comment['ndetails'] ){
                   $comment['short'] .= '...';
            }
            if ( $comment['long'] !== $comment['ndetails'] ) {
                $comment['long'] .= '...';
            }
            
            $tip_title = "{$comment['username']}@{$comment['date']}::{$comment['long']}";
    ?>
        <li>
            <a style='margin:0px;padding:3px;' class='recent_comment recent_comments' title='<?php echo "{$comment['username']}@{$comment['date']}::{$comment['long']}" ?>' href='/view<?php echo $comment_type ?>/<?php echo $comment_id ?>/#comment<?php echo $comment['comment_id'] ?>'><?php echo $comment['short'] ?></a>
        </li>
    <?php
        }
    ?>
    </ul>
</div>