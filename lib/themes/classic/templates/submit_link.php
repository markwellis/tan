<div class='news' style='padding-right:20px'>
    <form action='/submit/link/' id='submit_form' method='post'>
        <fieldset>
            <ul>
                <li>
                    <input type='hidden' id='cat' name='cat' value='' />
                </li>
                <li>
                    <label for='url'>Title</label>
                </li>
                <li>
                    <input type='text' name='title' id='title' class='text_input full_width'/>
                </li>
                <li>
                    <label for='url'>Url</label>
                </li>
                <li>
                    <input type='text' name='url' id='url' class='text_input full_width'/>
                </li>
                <li>
                    <label for='description'>Description</label>
                </li>
                <li>
                    <textarea cols='1' rows='5' name='description' id='description' class='text_input full_width'></textarea><br/>
                </li>
            </ul>   
            <?php load_template('/lib/tag_thumb_browser'); ?>

            <input type='submit' value='Submit Link'/>
        </fieldset>
    </form>
</div>
