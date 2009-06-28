<div class='news' style='padding-right:20px'>
    <form action='<?php echo $_SERVER['REQUEST_URI'] ?>' id='submit_form' method='post'>
        <fieldset>
            <ul>
                <li>
                    <input type='hidden' id='cat' name='cat' value='<?php echo isset($m_stash->details['category']) ? $m_stash->details['category'] : '' ?>' />
                </li>
                <li>
                    <label for='title'>Title</label>
                </li>
                <li>
                    <input type='text' name='title' id='title' class='text_input full_width' value='<?php echo isset($m_stash->details['title']) ? $m_stash->details['title'] : '' ?>' />
                </li>
                <li>
                    <label for='description'>Description</label>
                </li>
                <li>
                    <textarea cols='1' rows='5' name='description' id='description' class='text_input full_width' ><?php echo isset($m_stash->details['description']) ? $m_stash->details['description'] : '' ?></textarea><br/>
                </li>
                <li>
                    <label for='blogmain'>Blog</label>
                </li>
                <li>
                    <?php
                    include_once(SYS_PATH . '/js/fckeditor/fckeditor.php') ;
                    $oFCKeditor = new FCKeditor("blogmain");
                    $oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
                    $oFCKeditor->ToolbarSet = 'lulz';
                    $oFCKeditor->Width = '100%';
                    $oFCKeditor->Height = '600px';
                    $oFCKeditor->Config["CustomConfigurationsPath"] = "/sys/script/fckconfig.js";
                    $oFCKeditor->Config['EnterMode'] = 'br';
                    
                    $oFCKeditor->Value = isset($m_stash->details['details']) ? $m_stash->details['details'] : '';
                    $oFCKeditor->Create();
                    ?>
                </li>
            </ul>
            <?php load_template('/lib/tag_thumb_browser'); ?>
            <input type='submit' value='Submit Blog'/>
        </fieldset>
    </form>
</div>