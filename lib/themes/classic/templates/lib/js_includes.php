<?php
    foreach ($m_stash->js_includes as $js_include){
        echo "<script type='text/javascript' src='{$js_include}'></script>\n";
    }
?>