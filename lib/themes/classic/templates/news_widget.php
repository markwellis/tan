<?php
$count = 0;
?>
<body>
<style type='text/css'>
body{
    padding:0px;
    margin:0px;
    background:#fff;
}

#link{
    font-size:12px;
    font-family:tahoma,verdana,arial,sans-serif;
    font-weight:bold;
    background-color:#fff;
}

a{
    color:#0000ff;
    text-decoration:none;
}

a:visited{
    color:#000;
}

a:hover{
    color:#ff0000;
}

#container{
    border:1px solid #000;
    height:52px;
    width:236px;
    background-image:url(<?php echo $m_stash->theme_settings['image_path'] ?>/logo_240.png);
    background-repeat:no-repeat;
    text-align:center;
    overflow:hidden;
}
</style>
    <?php load_template('lib/js_includes'); ?>
    <ul style='display:none' id='links'>
    <?php foreach ($m_stash->links as $link){ 
        $link['title'] = trim(html_entity_decode(strip_tags(stripslashes($link['title'])),ENT_QUOTES,'UTF-8'));
        $link['description'] = trim(html_entity_decode(strip_tags(stripslashes($link['description'])),ENT_QUOTES,'UTF-8'));
    ?>
        <li id='<?php echo ++$count ?>'><a href='http://<?php echo $_SERVER['HTTP_HOST'] ?>/view<?php echo $link['type'] ?>
/<?php echo $link['id'] ?>/<?php echo url_title($link['title']) ?>/' title='<?php echo htmlentities($link['title'],ENT_QUOTES,'UTF-8')?> - <?php echo htmlentities($link['description'],ENT_QUOTES,'UTF-8') ?>'>
<?php echo htmlentities($link['title'],ENT_QUOTES,'UTF-8') ?> [<?php echo $link['type'] ?>]</a></li> 
    <?php } ?>
    </ul>
    <div id='container'>
        <span id='link'></span>
    </div>
    <script type='text/javascript'>
        var current = 1;
        var delay = 3000;

        function change_link(){
            if (current > 10) {
                current = 1;
            }

            $('link').set('html', $(current.toString()).innerHTML);
            $('link').get('tween', {property: 'opacity', duration: 'long'}).start(0,1);

            ++current;
            change_link.delay(delay);
        }

        window.addEvent('domready', function() {
            change_link();
            change_link.delay(delay);
        });
    </script>
</body>
