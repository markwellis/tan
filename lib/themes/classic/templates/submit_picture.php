<div class='news' style='padding-right:20px'>
    <form action='/submit/picture/' enctype='multipart/form-data' id='submit_form' method='post'>
        <fieldset>
            <input type='hidden' name='MAX_FILE_SIZE' value='2000000' />
            <ul>
                <li>
                    <label for='title'>Title</label>
                </li>
                <li>
                    <input type='text' name='title' id='title' class='text_input full_width'/>
                </li>

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
                <li>
                    <label for='pdescription'>Description (optional)</label>
                </li>
                <li>
                    <textarea cols='1' rows='5' name='pdescription' id='pdescription' class='text_input full_width'></textarea>
                </li>
                <li>
                    <label for='nsfw'>Not Safe for Work?</label>
                </li>
                <li>
                    <input type='checkbox' name='nsfw' id='nsfw'/>
                </li>
            </ul>
            <?php load_template('/lib/tag_thumb_browser'); ?>
            <input type='submit' value='Submit Picture'/>
        </fieldset>
    </form>
</div>
