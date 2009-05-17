<?php
array_push($m_stash->js_includes, $m_stash->theme_settings['js_path'] . '/tag_thumbs.js');
?>
<div>
    Type some relevant tags below (simple words that describe the blog). E.g.
    <ul> 
        <li>plant nature flower</li>
        <li>nasa moon space</li>
        <li>car mini cooper classic</li>
    </ul>
</div>
<input type='text' name='tags' id='tags' class='text_input'/><a href='#' class='refresh_thumbs'>Refresh</a>
<div id='thumb_tags'>Select a picture<br /></div>
<br/>
