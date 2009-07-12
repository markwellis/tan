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
        All User-generated content is licensed under a <a href="http://creativecommons.org/" rel='external nofollow'>Creative Commons Public Domain license</a><br />
        Version <?php echo VERSION ?>
        <?php
            load_template('/lib/ads/bottom');
        ?>
    </div>
</div>
        <script type="text/javascript"> 
        //<![CDATA[
            window.addEvent("domready", function() {
                var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
                new Asset.javascript(gaJsHost + "google-analytics.com/ga.js", {
                    onload: function() {
                        var pageTracker = _gat._getTracker("UA-5148406-3"); // your id here
                        pageTracker._initData();
                        pageTracker._trackPageview();
                    }
                });
            });
        //]]>
        </script>
    </body>