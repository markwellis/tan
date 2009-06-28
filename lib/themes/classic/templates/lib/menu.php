<?php
$m_stash->recent_comments = get_recent_comments();
$current_menu = array($m_stash->location => 'style="display:block;"');
$current_tab = array($m_stash->location => ' tab_selected');
if (isset($m_stash->sub_location)){
    $current_option = array($m_stash->location => array($m_stash->sub_location => 'class="navmenu_option_selected"' ));
}
?>
<div id="navmenu_holder">
<?php foreach (array('Links' => 'link', 'Pictures' => 'picture', 'Blogs' => 'blog') as $key => $value) { ?>
<span class='tab <?php echo isset($current_tab[$value]) ? $current_tab[$value] : '' ?>' title='<?php echo $value ?>' id='<?php echo $value ?>_tab'><?php echo $key ?></span><?php //null ?>
<?php } ?>
    <div id="navmenu_contents">
    <?php foreach (array('Links' => 'link', 'Pictures' => 'picture', 'Blogs' => 'blog') as $value) { ?>
        <div id='<?php echo $value ?>_menu' <?php echo isset($current_option[$value]) ? $current_option[$value] : '' ?>>
            <ul>
                <li class='navmenu_option'><a href='/submit/<?php echo $value ?>/' <?php echo isset($current_option[$value][2]) ? $current_option[$value][2] : '' ?>>Submit</a></li>
                <li class='navmenu_option'><a href='/random/<?php echo $value ?>/'>Random</a></li>
                <li class='navmenu_option'><a href='/<?php echo $value ?>/0/1/' <?php echo isset($current_option[$value][0]) ? $current_option[$value][0] : '' ?>>Promoted</a></li>
                <li class='navmenu_option'><a href='/<?php echo $value ?>/1/1/' <?php echo isset($current_option[$value][1]) ? $current_option[$value][1] : '' ?>>Upcoming</a></li>
            </ul>
        </div>
    <?php } ?> 
    </div>
</div>
<?php if ($m_stash->location) { ?>
    <script type='text/javascript'>
    //<![CDATA[
        $('<?php echo $m_stash->location ?>_menu').style.display='block';
        last_menu = '<?php echo $m_stash->location ?>_menu';
        last_tab = $('<?php echo $m_stash->location ?>_tab');
    //]]>
    </script>
<?php } ?>