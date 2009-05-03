<?php
    $time = microtime();
    $time = explode(" ", $time);
    $time = $time[1] + $time[0];
    $totaltime = number_format(($time - $m_stash->start_time), 4);

    $query = $m_stash->query_count();
    if ($query !== 1){
        $query = "{$query} queries";
    } else {
        $query = "{$query} query";
    }
?>
<br />
    <div id="bottom">
        Page processed in <?= $totaltime ?> seconds, with <?php echo $query ?><br />
        Version <?php echo VERSION ?>
    </div>