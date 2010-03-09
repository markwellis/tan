<?php
require_once('code/header.php');
/*header("Cache-Control: no-cache, must-revalidate"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$start = $time;
*/
$function = (int)$_GET['function'];

/* function is the page to dispaly
 0 = links,     2 = picture,   4 = blog
*/

switch($function){
    case 0:  //link
        $where = 'link';
        require_once('code/unified.php');
        global $user;
        $user = &new user();
        
        $page = (int)$_GET['page'];
        $type = (int)$_GET['type'];
        

        $link = &new unified('link');

        $middle .= "<div id='thumbs'>";
        $thumbs = $link->get_thumb_pics($type, 4);
        $middle .= "<a href='/picture/$type/1/' id='seeAllThumbs'>";
        if ($type == 0){
            $middle .= "Promoted Pictures - click to see the rest";
        } else if ($type == 1){
            $middle .= "Upcoming pictures - click to see the rest";
        }
        $middle .= "</a>";
    
        for ($i=0, $count=count($thumbs); $i<$count; ++$i){
            $plus = & $thumbs[$i]['plus'];
            $minus =& $thumbs[$i]['minus'];
            $pmyminus = & $thumbs[$i]['meminus'];
            $pmyplus = & $thumbs[$i]['meplus'];
            $comments = & $thumbs[$i]['comments'];
            $middle .= "<div class='imgDiv' id='imgdiv{$i}'>
                <a href='/viewpic/".$thumbs[$i]['picture_id']."/".stripslashes(str_replace(array(' ','%'),array('_',''),$thumbs[$i]['title']))."'>
                <img alt='".$thumbs[$i]['title']."' class='Imgnormal' id='thumb$i' 
                src='/images/cache/resize/".$thumbs[$i]['picture_id']."/150' /></a>
                <div style='background-color:#FBFDFF;opacity:0.8;filter:alpha(opacity=80);display:none;position:relative;top:-40px;height:45px;width:150px;' id='popup$i' >
                <div class='plus' id='tplus".$thumbs[$i]['picture_id']."' style='float:left;'>$plus<a class='addPlus";
                if ($pmyplus){
                    $middle .= " pselected";
                }
                $middle .= "' href='#' onclick=\"javascript:taddPlus(".$thumbs[$i]['picture_id'].", 'picture', 
                    'tplus".$thumbs[$i]['picture_id']."');return false;\">IsNews</a></div>
                    <div style='float:left;width:40px;margin-top:10px;'>
                    <a style='display:block' href='/viewpic/".$thumbs[$i]['picture_id']."/".stripslashes(str_replace(array(' ','%'),array('_',''),$thumbs[$i]['title'])) ."#comments'>
                    <img src='/sys/images/comment.png' style='float:left;' alt=' ' /> ". $comments ."</a></div>
                    <div class='minus' id='tminus".$thumbs[$i]['picture_id']."' style='float:right;margin-top:0px'>$minus<a class='addMinus";
                if ($pmyminus){
                   $middle .= " mselected";
                }
                $middle .= "' href='#' onclick=\"javascript:taddMinus(".$thumbs[$i]['picture_id'].", 'picture', 
                    'tminus".$thumbs[$i]['picture_id']."');return false;\">AintNews</a></div></div>";
                $middle .= "</div>";
        }
        $middle .= "</div>";
        ob_start();
?>
<script type="text/javascript">//<![CDATA[
        window.addEvent('domready', function(){
    $('thumbs').addEvents({
        'mouseenter': function(){
            this.set('tween', {
                duration: 1000,
                transition: Fx.Transitions.Linear 
            }).tween('height', '190px');
        },
        'mouseleave': function(){
            this.set('tween', {}).tween('height', '19px');
        }
    });
    
    $$('.imgDiv').addEvents({
        'mouseenter': function(){
            var id = this.id.substr(6);
            $('thumb' + id).morph({'max-width': '150px', 'height' : '130px'});
            $('popup'+id).style.display='block';
        },
        'mouseleave': function(){
            var id = this.id.substr(6);
            $('thumb' + id).morph({'max-width': '100px', 'height' : '80px'});
            $('popup'+id).style.display='none';
        }
    });
});
//]]>
</script>
<?php
        $middle .= ob_get_contents();
        ob_end_clean();

        $sort = (int)$_SESSION['sortby'];

        if ($type > 1){ $type = 1; }
        if ($page===0) { $page = 1; }

        $sort_by = $link->CreateSortBoxHTML($type, $page, $sort);
        $res = $link->create_top_random($type, $where);
        $sort_by .= $link->CreateRandomHTML($res);
        $links = $link->getPageObjects($page, $type, $link->sort_by[$sort]);

        foreach ($links as $linkdetails){
#            if ($linkdetails['link_id'] != 0){
                $middle .= $link->CreateObjectHTML($linkdetails, $type);
#            }
        }

        $pageCount = (int)ceil($link->getPlusMinusCount($type, 1) / 27);
        $middle .= $link->CreatePageBoxHTML($pageCount, $page, $type, $sort);
        break;

    case 2:  //picture
        $where = 'picture';
        require_once('code/unified.php');
        $picture = &new unified('picture');

        $page = (int)$_GET['page'];
        $type = (int)$_GET['type'];
        global $user;
        $user = &new user();
        $sort = (int)$_SESSION['sortby'];

        $title = 'Pictures';

        if ($type > 1){ $type = 1; }
        if ($page==0) { $page = 1; }

        $sort_by = $picture->CreateSortBoxHTML($type, $page, $sort);
        $res = $picture->create_top_random($type, $where);
        $sort_by .= $picture->CreateRandomHTML($res);
        $thumbs = $picture->getPageObjects($page, $type, $picture->sort_by[$sort]);

        $middle .= "<div class='thumbLine'>";
        for ($i=0, $max=count($thumbs);$i<$max;++$i){
            if (isset($thumbs[$i]['picture_id'])) {
                $middle .= "<div class='thumbCell'>
                    <div class='thumbHolder'>";
                $middle .= $picture->CreateObjectHTML($thumbs[$i], $type);
                $middle .= "</div></div>";
            }
            if ((($i +1) % 3 == 0) && ($i>0)) {
                $middle .= "</div>";
                if (($i+3 <27)) { $middle .= "<div class='thumbLine'>"; }
            } 
        }
        if ($i<27) { $middle .= "</div>";  }

        $pageCount = (int)ceil($picture->getPlusMinusCount($type, 1) / 27);
        $middle .= $picture->CreatePageBoxHTML($pageCount, $page, $type, $sort);
        break;

    case 4:  //blog
        $where = 'blog';
        require_once('code/unified.php');

        $blog = &new unified('blog');

        $page = (int)$_GET['page'];
        $type = (int)$_GET['type'];
        global $user;
        $user = &new user();
        $sort = (int)$_SESSION['sortby'];

        if ($type > 1){ $type = 1; }
        if ($page==0) { $page = 1; }

        $sort_by = $blog->CreateSortBoxHTML($type, $page, $sort);
        $blogs = $blog->getPageObjects($page, $type, $blog->sort_by[$sort]);
        $res = $blog->create_top_random($type, $where);
        $sort_by .= $blog->CreateRandomHTML($res);

        foreach ($blogs as $blogdetails){
            if ($blogdetails['blog_id'] != 0){
                $middle .= $blog->CreateObjectHTML($blogdetails, $type);
            }
        }

        $pageCount = (int)ceil($blog->getPlusMinusCount($type, 1) / 27);
        $middle .= $blog->CreatePageBoxHTML($pageCount, $page, $type, $sort);
        break;
}
//  bottom 
include_once('code/footer.php');
?>
