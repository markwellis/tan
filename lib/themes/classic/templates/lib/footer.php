<?php
    $time = microtime();
    $time = explode(" ", $time);
    $time = $time[1] + $time[0];
    $totaltime = number_format(($time - $m_stash->start_time), 4);
    load_template('lib/sidebar');

    $query = $m_stash->query_count();
    if ($query !== 1){
        $query = "{$query} queries";
    } else {
        $query = "{$query} query";
    }
?>
    <div id="bottom">
        Page processed in <?= $totaltime ?> seconds, with <?php echo $query ?><br />
        All User-generated content is licensed under a <a href="http://creativecommons.org/" rel='external nofollow'>Creative Commons Public Domain license</a>
   </div>
</div>