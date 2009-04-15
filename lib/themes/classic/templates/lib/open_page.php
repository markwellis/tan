<?php
    load_template('lib/xhtml_head');
    load_template('lib/top');
    $messages = $m_stash->flash('message');
    if ($messages){
        foreach ($messages as $message){
    ?>
            <span class='message'><?php echo $message ?></span>
    <?php
        }
    }
?>