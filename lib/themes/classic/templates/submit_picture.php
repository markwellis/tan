<div class='news' style='padding-right:20px'>
    <form action='<?php echo $_SERVER['REQUEST_URI'] ?>' enctype='multipart/form-data' id='submit_form' method='post'>
        <fieldset>
            <input type='hidden' name='MAX_FILE_SIZE' value='2000000' />
            <ul>
                <li>
                    <label for='title'>Title</label>
                </li>
                <li>
                    <input type='text' name='title' id='title' class='text_input full_width' value='<?php echo isset($m_stash->details['title']) ? $m_stash->details['title'] : '' ?>'/>
                </li>

                <?php if (isset($m_stash->details)) { ?>
                    <li>
                        <img src="/images/cache/resize/<?php echo $m_stash->details['picture_id'] ?>/600" style="margin:auto;display:block;" alt="image" />
                    </li>
                <?php } else { ?>
                    <li>
                        <label for='pic'>Upload File</label>
                    </li>
                    <li>
                        <input type='file' name='pic' id='pic' class='text_input full_width'/>
                    </li>
                    <li>
                        <label for='pic_url'>Remote Upload</label>
                    </li>
                    <li>
                        <input type='input' name='pic_url' id='pic_url' class='text_input full_width'/>
                    </li>
                <?php } ?>
                <li>
                    <label for='pdescription'>Description (optional)</label>
                </li>
                <li>
                    <textarea cols='1' rows='5' name='pdescription' id='pdescription' class='text_input full_width'><?php echo isset($m_stash->details['description']) ? $m_stash->details['description'] : '' ?></textarea>
                </li>
                <li>
                    <label for='nsfw'>Not Safe for Work?</label>
                </li>
                <li>
                    <input type='checkbox' name='nsfw' id='nsfw' <?php echo (isset($m_stash->details['NSFW']) && $m_stash->details['NSFW'] === 'Y') ? 'checked="checked"' : '' ?>/>
                </li>
            </ul>
            <?php load_template('/lib/tag_thumb_browser'); ?>
            <input type='submit' value='Submit Picture'/>
        </fieldset>
    </form>
</div>
