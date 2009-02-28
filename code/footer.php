<?php

$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$totaltime = number_format(($time - $start), 4);
if (!isset($type)){
    $type = -1;
}
if ($middle){
    require_once('code/page.php');
    $pageobj = new page();
    $html = $pageobj->createPage("ThisAintNews.com :: $title",$extraScript, $middle,
                "Page processed in $totaltime seconds" , $where, $type, $sort_by, $description);
#    $html = $pageobj->minify($html);
#    $etag = '"'.md5($middle).'"';
#    header("Etag: $etag");
#    if (trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
#        header("HTTP/1.1 304 Not Modified");
#        exit;
#    }

	ob_start();
    print $html;
    ob_end_flush();
}
exit();
?>
