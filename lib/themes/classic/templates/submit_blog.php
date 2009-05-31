<div class='news' style='padding-right:20px'>
    <form action='/submit/blog/' id='submit_form' method='post'>
        <fieldset>
            <ul>
                <li>
                    <input type='hidden' id='cat' name='cat' value='' />
                </li>
                <li>
                    <label for='title'>Title</label>
                </li>
                <li>
                    <input type='text' name='title' id='title' class='text_input full_width'/>
                </li>
                <li>
                    <label for='description'>Description</label>
                </li>
                <li>
                    <textarea cols='1' rows='5' name='description' id='description' class='text_input full_width'></textarea><br/>
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
        
                    $oFCKeditor->Value = $m_stash->comment;
                    
                    $oFCKeditor->Create();
                    ?>
                </li>
            </ul>
            <?php load_template('/lib/tag_thumb_browser'); ?>
            <input type='submit' value='Submit Blog'/>
        </fieldset>
    </form>
</div>