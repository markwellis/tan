<?php
/**
 * Created on 11 Jan 2009
 *
 * Copyright 2009 - mark
 * License is in the root directory, entitled LICENSE
 * @package package_name
 */
?>
<div id='picture'>
<form onsubmit="return checkForm('picture');" enctype='multipart/form-data' action='/code/dosubmit.php' method='post'>
    <input type='hidden' name='MAX_FILE_SIZE' value='2000000' />
    <input type='hidden' id='type5' name='type' value='picture' />
    <label for='pic'>Select an image file</label>
    <br />
    
    <input class='textInput' size='55' type='file' name='pic' id='pic' />
    <br />
    <br />
    
    <label for='pictitle'>Choose a title for the picture</label>
    <br />
    
    <input class='textInput'  size='55'  type='text' name='title' id='pictitle' />
    <br />
    <br />
    
    <label for='picdescription'>Write a short discription of the picture (optional)</label>
    <br />
    <br />
    
    <textarea rows='10' cols='70' name='description' id='picdescription' ></textarea>
    <br />
    <br />
    
    <label for='pictags' size='55'>Type some relevant tags (simple words that describe the picture)</label>
    <br />
    
    <input class='textInput' size='55' type='text' name='tags' id='pictags' />
    <br />
    <br />
    
    <input type='submit' value='Submit Picture'/>
</form>
</div>