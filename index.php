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
 0 = links,     1 = viewlink,  2 = picture
 3 = viewpic,   4 = blog,      5 = login
 6 = logout,    7 = submit,    8 = irc
 9 = shop,      10 = profile,  11 = sitemap
 12 = viewblog, 13 = tagcloud, 14 = tagthumbs
 15 = error404
*/

// Old code, used to make the thumb box bar

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
                src='/thumb/".$thumbs[$i]['picture_id']."/150/' /></a>
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
<script type="text/javascript">
        window.addEvent('domready', function(){
    // The slider
    $('thumbs').addEvents({
        'mouseenter': function(){
            // Always sets the duration of the tween to 1000 ms and a bouncing transition
            // And then tweens the height of the element
            this.set('tween', {
                duration: 1000,
                transition: Fx.Transitions.Linear // This could have been also 'bounce:out'
            }).tween('height', '190px');
        },
        'mouseleave': function(){
            // Resets the tween and changes the element back to its original size
            this.set('tween', {}).tween('height', '19px');
        }
    });
    
    
    // this thumbnails
    $$('.imgDiv').addEvents({
        'mouseenter': function(){
            // Always sets the duration of the tween to 1000 ms and a bouncing transition
            // And then tweens the height of the element
            var id = this.id.substr(6);
            $('thumb' + id).morph({'max-width': '150px', 'height' : '130px'});
            $('popup'+id).style.display='block';
        },
        'mouseleave': function(){
            // Resets the tween and changes the element back to its original size
            var id = this.id.substr(6);
            $('thumb' + id).morph({'max-width': '100px', 'height' : '80px'});
            $('popup'+id).style.display='none';
        }
    });
});
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
            if ($linkdetails['link_id'] != 0){
                $middle .= $link->CreateObjectHTML($linkdetails, $type);
            }
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

    case 7:  //submit
        $where = 'submit';
        require_once("code/user.php");
        global $user;
        $user = &new user();
        if (!$user->isLoggedIn()) {
            header('location: /login/');
            exit();
        }

        $error = strip_tags($_GET['error']);
        if ($error){
            $middle .= "<h1>$error</h1>";
        }

        $title = 'Submit';

        if ($_GET['swhat'] === 'link') { $swhat = 0; $where='link'; }
        if ($_GET['swhat'] === 'picture') { $swhat = 1;$where='picture'; }
        if ($_GET['swhat'] === 'blog') { $swhat = 2;$where='blog'; }
        if ($_GET['swhat'] === 'editorial') { $swhat = 3; }
        // 0 = link
        // 1 = pic
        // 2 = blog
        // 3 = ed
        $message = strip_tags($_GET['message']);
        if ($message != null){
            $middle .= "<h1>$message</h1>";
        }
        //link
        if ($swhat == 0) {
            $type = 0;
            $middle .= "<div id='link'>
                <form action='/code/dosubmit.php' onsubmit=\"return checkForm('link');\" method='post'>
                <input type='hidden' id='type4' name='type' value='link' />
                <input type='hidden' id='cat' name='cat' value='' />
                <label for='url'>Page Url</label><br />
                <input class='textInput' size='55' type='text' name='url' id='url' /><br /><br />
                <label for='title'>Choose a title for the link</label><br />
                <input class='textInput' size='55'  type='text' name='title' id='title' /><br /><br />
                <label for='description'>Write a short discription of the link</label><br />
                <textarea rows='10' cols='70' name='description' id='description' ></textarea><br /><br />
                <label for='tags' style='width:540px;'>Type some relevant tags (simple words that describe the link), separated by a space. Then pictures will appear, click the one you want to appear next to the link.</label><br /><br />
                <input class='textInput' size='55' type='text' name='tags' id='tags' onkeyup='drawTagImages((event))' />
                <a href='#' onclick='updateThumbs();return false;'>Update</a><br />
                <div id='thumbtags'></div><br/>
                <br /><input type='submit' value='Submit Link'/>
                </form></div>";
        }
        //pic
        elseif ($swhat == 1){
            $type=1;
            $middle .= "<div id='picture'>
                <form onsubmit=\"return checkForm('picture');\" enctype='multipart/form-data' action='/code/dosubmit.php' method='post'>
                <input type='hidden' name='MAX_FILE_SIZE' value='2000000' />
                <input type='hidden' id='type5' name='type' value='picture' />
                <label for='pic'>Select an image file</label><br />
                <input class='textInput' size='55' type='file' name='pic' id='pic' /><br /><br />
                <label for='pictitle'>Choose a title for the picture</label><br />
                <input class='textInput'  size='55'  type='text' name='title' id='pictitle' /><br /> <br />
                <label for='picdescription'>Write a short discription of the picture (optional)</label><br /><br />
                <textarea rows='10' cols='70' name='description' id='picdescription' ></textarea><br /><br />
                <label for='pictags' size='55'>Type some relevant tags (simple words that describe the picture)</label><br />
                <input class='textInput' size='55' type='text' name='tags' id='pictags' /><br /><br />
                <input type='submit' value='Submit Picture'/>
                </form></div>";
        }
        //blog
        elseif ($swhat == 2){
            $type = 2;
            $middle .= "<div id='blog'><form action='/code/dosubmit.php' onsubmit=\"return checkForm('blog');\" method='post'>
                <input type='hidden' id='type6' name='type' value='blog' />
                <input type='hidden' id='cat' name='cat' value='' />
                <label for='blogtitle' size='55'>Choose a title for your blog</label><br />
                <input class='textInput' size='55' type='text' name='title' id='blogtitle' /><br /><br />
                <label for='blogdescription' size='55'>Write a short discription of your blog here</label><br /><br />
                <textarea rows='10' cols='70' name='description' id='blogdescription'></textarea><br /><br />
                <label for='blogmain' size='55'>Write your blog here</label><br /><br />";
            include_once("sys/js/fckeditor/fckeditor.php") ;
            $oFCKeditor = &new FCKeditor('blogmain');
            $oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
            $oFCKeditor->Value = '' ;
            $oFCKeditor->ToolbarSet = 'lulz';
            $oFCKeditor->Width = '98%';
            $oFCKeditor->Height = 450;
            $oFCKeditor->Config['EnterMode'] = 'br';
            $oFCKeditor->Config["CustomConfigurationsPath"] = "/sys/script/fckconfig.js";
            $middle .= $oFCKeditor->CreateHTML() ;
            $middle .= "<br /><br /><label for='tags' style='width:540px;'>Type some relevant tags (simple words that describe the blog), separated by a space. 
                Then pictures will appear, click the one you want to appear next to your blog</label><br /><br />
                <input class='textInput' size='55' type='text' name='tags' id='tags' onkeyup='drawTagImages((event))' />
                <a href='#' onclick='updateThumbs();return false;'>Update</a><br />
                <div id='thumbtags'></div><br/>
                <input type='submit' value='Submit Blog'/>
                </form></div>";
        }
        break;

/* disabled for the time being
    case 10:  //profile
        require_once('code/sql.php');
        require_once('code/user.php');
        require_once('code/link.php');
        $user = new user();
        $sql = new sql();
        $link = new linkobj();

        $page = (int)$_GET['page'];
        if ($page==0) { $page = 1; }
        $username = mysql_escape_string(strip_tags($_GET['username']));
        if ($_GET['ptype'] === 'plus'){ $ptype = 0;}
        if ($_GET['ptype'] === 'minus'){ $ptype = 1;}
        if ($_GET['ptype'] === 'submitted'){ $ptype = 2;}

        $uid = $user->usernameToId($username);
        $uid = $uid['user_id'];
       
        $title = "$username&#039;s profile";
     
        $middle .= "<h1>$username&#039;s profile</h1>";
        $middle .= "<span style='margin-left:15px;'>
            <a class='profLink' href='/users/$username/plus/$page/'>Plus</a> 
            <a class='profLink' href='/users/$username/minus/$page/'>Minus</a> 
            <a class='profLink' href='/users/$username/submitted/$page/'>Submitted</a><br/><br/></span>";

        if ($ptype == 0){
            $plink = 'plus';
            $pluslinks= $user->getPlusLinks($uid, $page);
            if (isset($pluslinks[0])){
                for($i=0; $i<count($pluslinks);$i++){
                   if ($pluslinks[$i]['promoted'] != '0000-00-00 00:00:00') {
                        $type = 0;
                   } else {
                        $type = 1;
                   }
                   $middle .= $link->drawBox($pluslinks[$i], $type);  
                }

                $pageCount = (int)ceil($user->getUPlusLinkCount($uid) / 27);
            } else {
                $middle .= "This user hasn't plus'd anything yet";
            }
        }
        if ($ptype == 1){
            $plink = 'minus';
            $minuslinks= $user->getMinusLinks($uid, $page);
            if (isset($minuslinks[0])){
                for($i=0; $i<count($minuslinks);$i++){
                   if ($minuslinks[$i]['promoted'] != '0000-00-00 00:00:00') {
                        $type = 0;
                   } else {
                        $type = 1;
                   }
                   $middle .= $link->drawBox($minuslinks[$i], $type);  
                }

                $pageCount = (int)ceil($user->getUMinusLinkCount($uid) / 27);
            } else {
                $middle .= "This user hasn't minus'd anything yet";
            }
        }
        if ($ptype == 2){
            $plink = 'submitted';
            $sublinks = $user->getSubmittedLinks($uid, $page);
            if (isset($sublinks[0])){
                for($i=0; $i<count($sublinks);$i++){
                    if ($sublinks[$i]['promoted'] != '0000-00-00 00:00:00') {
                        $type = 0;
                   } else {
                        $type = 1;
                   }
                   $middle .= $link->drawBox($sublinks[$i], $type);
                }
                $pageCount = (int)ceil(count($sublinks) / 27);
            } else {
                $middle .= "This user hasn't submitted anything yet";
            }
        }
        $middle .= "<div style='margin-left:auto;margin-right:auto;margin-bottom:25px;width:".($pageCount * 40) ."px;'>";

        for ($i=1;$i<=$pageCount;$i++){
            $middle .= "<a class='pageNumber";
            if ($i == $page){
                $middle .= " thisPage";
            }
            $middle .= " ' href='/users/$username/$plink/$i'>$i</a>";
        }
        $middle .=  "</div>";
        break;
*/

    case 13:  //tagcloud
        require_once('code/tag.php');
        $tag = &new tag();
        $cloud = $tag->createCloud('all');
        $title = 'Tag Cloud';
        $middle = "<div class='tagholder'>".$cloud."</div>";
        break;

}
//  bottom 
include('code/footer.php');
/*
$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$totaltime = number_format(($time - $start), 4);
if (!isset($type)){
    $type = -1;
}
if (!isset($noPage)){
    require_once('code/page.php');
    $pageobj = new page();
    $html = $pageobj->createPage("ThisAintNews.com :: $title",$extraScript, $middle, "Page processed in $totaltime seconds" , $where, $type);
    $html = $pageobj->minify($html);
    $etag = '"'.md5($middle).'"';
    header("Etag: $etag");
    if (trim($_SERVER['HTTP_IF_NONE_MATCH']) == $etag) {
        header("HTTP/1.1 304 Not Modified");
        exit;
    }
    print $pageobj->compress($html);
}*/
?>
