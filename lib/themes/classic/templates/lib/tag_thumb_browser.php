<?php
if ($m_stash->location !== 'picture'){
    array_push($m_stash->js_includes, $m_stash->theme_settings['js_path'] . '/tag_thumbs.js?2=3');
}
?>
<label for='tags'>Tags</label>
<input type='text' name='tags' id='tags' class='text_input full_width' value='<?php echo isset($m_stash->details['tags']) ? "{$m_stash->details['tags']}' disabled='disabled" : '' ?>'/>
<?php if ($m_stash->location !== 'picture'){ ?>
    <a href='#' class='refresh_thumbs'>Refresh</a>
<?php } ?>
<br />
<div id='thumb_tags'>
    e.g.
    <ul style='margin-left:25px'> 
        <li>nasa moon space</li>
        <li>car mini cooper classic</li>
    </ul>
</div>
<?php if(isset($m_stash->details)) { ?>
<script type="text/javascript">
get_thumbs( $('cat').value );
</script>
<?php } ?>
