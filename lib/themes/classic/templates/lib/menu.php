<?php
$m_stash->recent_comments = get_recent_comments();
$current_menu = array($m_stash->location => 'style="display:block;"');
$current_tab = array($m_stash->location => ' tab_selected');
$current_option = array($m_stash->location => array($m_stash->sub_location => 'class="navmenu_option_selected"' ));
?>
<div id="navmenu_holder">
    <span class='tab <?php echo $current_tab['link'] ?>' title='link' id='link_tab'>Links</span><span class='tab <?php echo $current_tab['blog'] ?>' title='blog' id='blog_tab'>Blogs</span><span class='tab <?php echo $current_tab['picture'] ?>' title='picture' id='picture_tab'>Pictures</span>
        <div id="navmenu_contents">
        <div id='link_menu' <?php echo $current_menu['link'] ?>>
            <ul>
                <li class='navmenu_option'><a href='/submit/link/' <?php echo $current_option['link'][2] ?>>Submit</a></li>
                <li class='navmenu_option'><a href='/random/link/'>Random</a></li>
                <li class='navmenu_option'><a href='/link/0/1/' <?php echo $current_option['link'][0] ?>>Promoted</a></li>
                <li class='navmenu_option'><a href='/link/1/1/' <?php echo $current_option['link'][1] ?>>Upcoming</a></li>
            </ul>
        </div>
        <div id='blog_menu' <?php echo $current_menu['blog'] ?>>
            <ul>
                <li class='navmenu_option'><a href='/submit/blog/' <?php echo $current_option['blog'][2] ?>>Submit</a></li>
                <li class='navmenu_option'><a href='/random/blog/'>Random</a></li>
                <li class='navmenu_option'><a href='/blog/0/1/' <?php echo $current_option['blog'][0] ?>>Promoted</a></li>
                <li class='navmenu_option'><a href='/blog/1/1/' <?php echo $current_option['blog'][1] ?>>Upcoming</a></li>
            </ul>
        </div>
        <div id='picture_menu' <?php echo $current_menu['picture'] ?>>
            <ul>
                <li class='navmenu_option'><a href='/submit/picture/' <?php echo $current_option['picture'][2] ?>>Submit</a></li>
                <li class='navmenu_option'><a href='/random/picture/'>Random</a></li>
                <li class='navmenu_option'><a href='/picture/0/1/' <?php echo $current_option['picture'][0] ?>>Promoted</a></li>
                <li class='navmenu_option'><a href='/picture/1/1/' <?php echo $current_option['picture'][1] ?>>Upcoming</a></li>
            </ul>
        </div>
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