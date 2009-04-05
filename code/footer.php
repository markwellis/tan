<?php

$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$totaltime = number_format(($time - $start), 4);
if (!isset($type)){
    $type = -1;
}
if ($middle){
    require_once($_SERVER['DOCUMENT_ROOT'] . '/code/page.php');
    $pageobj = new page();
    $html = $pageobj->createPage("ThisAintNews.com :: $title",$extraScript, $middle,
                "Page processed in $totaltime seconds" , $where, $type, $sort_by, $description);
    echo $html;
}

exit();
?>
