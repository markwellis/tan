<?php
header("Cache-Control: no-cache, must-revalidate"); 
header("Expires: Mon, 26 Jul 1997 05:00:00 GMT");

$time = microtime();
$time = explode(" ", $time);
$time = $time[1] + $time[0];
$start = $time;

$function = (int)$_GET['function'];

/* function is the page to dispaly
 0 = links,     1 = viewlink,  2 = picture
 3 = viewpic,   4 = blog,      5 = login
 6 = logout,    7 = submit,    8 = irc
 9 = shop,      10 = profile,  11 = sitemap
 12 = viewblog, 13 = tagcloud, 14 = tagthumbs
 15 = error404
*/

/* Old code, used to make the thumb box bar
    $middle .= "<div id='thumbs'>";

    require_once("code/picture.php");
    $picture = new picture();
    $thumbs = $picture->getPlusThumbs(1, $type, 5);

    $middle .= "<a href='/picture/$type/1/' id='seeAllThumbs'>";
    if ($type == 0){
        $middle .= "Top 5 Pictures - click to see the rest";
    } else if ($type == 1){
        $middle .= "Newest pictures - click to see the rest";
    }
    $middle .= "</a>";

    for ($i=0, $count=count($thumbs); $i<$count; ++$i){
        $plus = & $thumbs[$i]['plus'];
        $minus =& $thumbs[$i]['minus'];
        $pmyminus = & $thumbs[$i]['meminus'];
        $pmyplus = & $thumbs[$i]['meplus'];
        $comments = & $thumbs[$i]['comments'];
        $middle .= "<div class='imgDiv' id='imgdiv$i'>
            <a href='/viewpic/".$thumbs[$i]['picture_id']."/".stripslashes(str_replace(array(' ','%'),array('_',''),$thumbs[$i]['title']))."'>
            <img alt='".$thumbs[$i]['title']."' class='Imgnormal' id='thumb$i' 
            src='/thumb/".$thumbs[$i]['picture_id']."/150/'
            onmouseover=\"popupBox(".$i.")\" onmouseout=\"unpopup(".$i.")\"
            onclick=\"className='Imgnormal';\"/></a>
            <div style='background-color:#FBFDFF;opacity:0.8;filter:alpha(opacity=80);display:none;position:relative;top:-40px;height:45px;width:150px;' id='popup$i' 
            onmouseover=\"popupBox($i)\" onmouseout=\"unpopup($i)\">
            <div class='plus' id='tplus".$thumbs[$i]['picture_id']."' style='float:left;'>$plus<a class='addPlus";
            if ($pmyplus){
                $middle .= " pselected";
            }
            $middle .= "' href='#' onclick=\"javascript:taddPlus(".$thumbs[$i]['picture_id'].", 'picture', 
                'tplus".$thumbs[$i]['picture_id']."');return false;\">+</a></div>
                <div style='float:left;width:40px;margin-top:10px;'>
                <a style='display:block' href='/viewpic/".$thumbs[$i]['picture_id']."/".stripslashes(str_replace(array(' ','%'),array('_',''),$thumbs[$i]['title'])) ."#comments'>
                <img src='/sys/images/comment.png' style='float:left;' alt=' ' /> ". $comments ."</a></div>
                <div class='minus' id='tminus".$thumbs[$i]['picture_id']."' style='float:right;margin-top:0px'>$minus<a class='addMinus";
            if ($pmyminus){
               $middle .= " mselected";
            }
            $middle .= "' href='#' onclick=\"javascript:taddMinus(".$thumbs[$i]['picture_id'].", 'picture', 
                'tminus".$thumbs[$i]['picture_id']."');return false;\">-</a></div></div>";
            $middle .= "</div>";
    }
    $middle .= "</div>";
  */  


$middle = '';
$where = 'all';
$extraHeader = '';
$title = 'Welcome home';

switch($function){
    case 0:  //link
        $where = 'link';
        require_once('code/unified.php');

        $link = new unified('link');

        $page = (int)$_GET['page'];
        $type = (int)$_GET['type'];
        $sort = (int)$_GET['sortby'];

        if ($type > 1){ $type = 1; }
        if ($page===0) { $page = 1; }

        $middle .= $link->CreateSortBoxHTML($type, $page, $sort);
        $links = $link->getPageObjects($page, $type, $link->sort_by[$sort]);
        
        foreach ($links as $linkdetails){
            if ($linkdetails['link_id'] != 0){
                $middle .= $link->CreateObjectHTML($linkdetails, $type);
            }
        }

        $pageCount = (int)ceil($link->getPlusMinusCount($type, 1) / 27);
        $middle .= $link->CreatePageBoxHTML($pageCount, $page, $type, $sort);
        break;

    case 1:  //viewlink
        $where = 'link';
        require_once('code/unified.php');

        $link = new unified('link');

        $link_id = (int)$_GET['link'];
        $details = $link->getPageObjects(null, null, null, null, $link_id);
        $details = $details[0];

        if (sizeOf($details)>1){
            if ($details['promoted'] != '0000-00-00 00:00:00') {
                $typeo = 0;
            } else {
                $typeo = 1;
            }
            $title = $details['title'];
            $middle .= $link->CreateObjectHTML($details, $typeo, 1);
            $middle .= $link->CreateCommentHTML($link->getComments($details['link_id']), $details['link_id']);
        } else {
            $middle .= $link->error404();
        } 
        break;

    case 2:  //picture
        $where = 'picture';
        require_once('code/unified.php');
        $picture = new unified('picture');

        $page = (int)$_GET['page'];
        $type = (int)$_GET['type'];
        $sort = (int)$_GET['sortby'];

        $title = 'Pictures';

        if ($type > 1){ $type = 1; }
        if ($page==0) { $page = 1; }

        $middle .= $picture->CreateSortBoxHTML($type, $page, $sort);
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

    case 3:  //viewpic
        $where = 'picture';
        require_once('code/unified.php');
        $picture = new unified('picture');

        $picture_id = (int)$_GET['pic'];
        $details = $picture->getPageObjects(null, null, null, null, $picture_id);
        $details = $details[0];
        $title = stripslashes($details['title']);

        if (sizeOf($details)>1){
            $comments = $picture->getComments($details['picture_id']);
            $middle .= $picture->CreateObjectHTML($details, 0, 1);
            $middle .= $picture->CreateCommentHTML($comments, $details['picture_id']);
        } else {
            $middle .= $picture->error404();
        }
        $where = 'picture';
        break;

    case 4:  //blog
        $where = 'blog';
        require_once('code/unified.php');

        $blog = new unified('blog');

        $page = (int)$_GET['page'];
        $type = (int)$_GET['type'];
        $sort = (int)$_GET['sortby'];

        if ($type > 1){ $type = 1; }
        if ($page==0) { $page = 1; }

        $middle .= $blog->CreateSortBoxHTML($type, $page, $sort);
        $blogs = $blog->getPageObjects($page, $type, $blog->sort_by[$sort]);

        foreach ($blogs as $blogdetails){
            if ($blogdetails['blog_id'] != 0){
                $middle .= $blog->CreateObjectHTML($blogdetails, $type);
            }
        }

        $pageCount = (int)ceil($blog->getPlusMinusCount($type, 1) / 27);
        $middle .= $blog->CreatePageBoxHTML($pageCount, $page, $type, $sort);
        break;

    case 5:  //login
        require_once('code/user.php');
        $user = new user();
        if(!$user->isLoggedIn()){
            require_once('code/recaptchalib.php');
            $publickey = "6LfOtQIAAAAAAKjR5kiq9YLFjG80_bLST2fB696F";
            $errorCap = null;
            $title = 'Login/Register';
            $error= (int)$_GET['error'];
            $errorCodes = Array("-6" => "Please complete the form",
                "-5" => "Passwords do not match",
                "-4" => "Username can only contain letters or numbers",
                "-3" => "Username already exists",
                "-2" => "Password needs to be a minium of 6 characters",
                "-1" => "Thats not a valid email address",
                "-7" => "Email address already asscoiated with username",
                "-8" => "Captcha words incorrect");

            if ($error != 0) {
                $middle .= "<h2>".$errorCodes[$error]."</h2>";
            }

            $middle .= "<hr />
                <div class='news'>
                <h1>Sign In</h1>
                <img class='newsImg' src='/sys/images/login.png' alt='Login' />
                <form action='/code/dologin.php' id='loginform' method='post'>
                <input class='textInput' id='ref' name='ref' type='hidden' value='".$_SERVER['HTTP_REFERER']."' />
                <p><label style='width:70px;' for='username'>Username </label><input class='textInput' id='username' name='username' type='text'/></p>
                <p><label style='width:70px;' for='password'>Password </label><input class='textInput' id='password' name='password' type='password'/></p>
                <p><input type='submit' value='Login'/></p>
                </form>
                </div>
                <hr />
                <div class='news'>
                <h1>Register</h1>
                <img class='newsImg' src='/sys/images/register.png' alt='Register' />
                <form action='/code/doregister.php' id='regform' method='post'>
                <input class='textInput' id='rref' name='rref' type='hidden' value='".$_SERVER['HTTP_REFERER']."' />
                <p><label style='width:70px;' for='rusername'>Username </label><input class='textInput' id='rusername' name='rusername' type='text'";
            if ($_GET['username'] != '') {
                $middle .= "value='" . strip_tags($_GET['username']) . "'";
            } 
            $middle .= "/></p><p><label style='width:70px;' for='email'>Email address </label><input class='textInput' id='email' name='email' type='text'";
            if ($_GET["email"] != '') {
                $middle .= "value='" . strip_tags($_GET["email"]) . "'";
            } 
            $middle .= "/></p>
                <p><label style='width:70px;' for='rpassword0'>Password </label><input class='textInput' id='rpassword0' name='rpassword0' type='password'/></p>
                <p><label style='width:70px;' for='rpassword1'>Password again </label><input class='textInput' id='rpassword1' name='rpassword1' 
                type='password'/></p>
                <script type='text/javascript'>
                document.getElementById('regform').setAttribute(\"autocomplete\", \"off\"); 
                </script>
                <div style='margin-left:200px;margin-top:10px;'>";
                $middle .= recaptcha_get_html($publickey, $errorCap);
                $middle .= "</div><br />
                    <p><input type='submit' value='Register'/></p>
                    </form></div>";
        } else {
            $middle .= "<h1>You are already logged in!</h1>";
        }
        break;

    case 6:  //logout
        include_once("code/user.php");

        $user = new user;
        $user->logout();
        if ($_SERVER['HTTP_REFERER'] != ''){
            header("Location: ".$_SERVER['HTTP_REFERER']);
        } else {
            header("location: /");
        }
        break;

    case 7:  //submit
        $where = 'submit';
        require_once("code/user.php");
        $user = new user();
        if (!$user->isLoggedIn()) {
            header('location: /login');
            exit();
        }

        $error = strip_tags($_GET['error']);
        if ($error){
            $middle .= "<h1>$error</h1>";
        }

        $title = 'Submit';

        if ($_GET['swhat'] === 'link') { $swhat = 0; }
        if ($_GET['swhat'] === 'picture') { $swhat = 1; }
        if ($_GET['swhat'] === 'blog') { $swhat = 2; }
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
                <div id='thumbtags' style='width:700px;overflow:visible;margin-left:auto;margin-right:auto;'></div><br/>
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
            $oFCKeditor = new FCKeditor('blogmain');
            $oFCKeditor->BasePath = '/sys/js/fckeditor/' ;
            $oFCKeditor->Value = '' ;
            $oFCKeditor->ToolbarSet = 'lulz';
            $oFCKeditor->Width = 750;
            $oFCKeditor->Height = 450;
            $oFCKeditor->Config['EnterMode'] = 'br';
            $middle .= $oFCKeditor->CreateHTML() ;
            $middle .= "<br /><br /><label for='tags' style='width:540px;'>Type some relevant tags (simple words that describe the blog), separated by a space. 
                Then pictures will appear, click the one you want to appear next to your blog</label><br /><br />
                <input class='textInput' size='55' type='text' name='tags' id='tags' onkeyup='drawTagImages((event))' />
                <a href='#' onclick='updateThumbs();return false;'>Update</a><br />
                <div id='thumbtags' style='width:700px;overflow:visible;margin-left:auto;margin-right:auto;'></div><br/>
                <input type='submit' value='Submit Blog'/>
                </form></div>";
        }
        break;

    case 8:  //irc
        require_once("code/user.php");
        $user = new user();
        $title = 'webchat';

        $uname = $user->getUserName();
        if ($uname === ''){
            $uname = 'n00b';
        } 

        $middle .= '<div style="text-align:center;">
            <iframe width=720 height=400 scrolling=no style="border:0" 
            src="http://embed.mibbit.com/?server=irc.abjects.net&channel=%23thisaintnews&settings=8a8a5ac18a22e7eecd04026233c3df93t&nick='.$uname.'">
            </iframe></div>';
        break;

    case 9:  //shop
        $title = 'WebShop';
        $middle = "<iframe src='http://www.cafepress.com/thisaintnews' style='border:0px;height:1000px;width:100%;'/>";
        break;

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

    case 11:  //sitemap
        require_once("code/unified.php"); 
        $type = (int)$_GET['type'];
        header ("content-type: text/xml");
        $output = '<?xml version="1.0" encoding="UTF-8"?>
            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <url>
            <loc>http://thisaintnews.com/</loc>
            <priority>1.00</priority>
            <changefreq>daily</changefreq>
            </url>
            <url>
            <loc>http://thisaintnews.com/link/0/1/0/</loc>
            <priority>0.80</priority>
            <changefreq>daily</changefreq>
            </url>
            <url>
            <loc>http://thisaintnews.com/link/1/1/0/</loc>
            <priority>0.80</priority>
            <changefreq>daily</changefreq>
            </url>
            <url>
            <loc>http://thisaintnews.com/blog/0/1/0/</loc>
            <priority>0.80</priority>
            <changefreq>daily</changefreq>
            </url>
            <url>
            <loc>http://thisaintnews.com/blog/1/1/0/</loc>
            <priority>0.80</priority>
            <changefreq>daily</changefreq>
            </url>
            <url>
            <loc>http://thisaintnews.com/picture/0/1/0/</loc>
            <priority>0.80</priority>
            <changefreq>daily</changefreq>
            </url>
            <url>
            <loc>http://thisaintnews.com/picture/1/1/0/</loc>
            <priority>0.80</priority>
            <changefreq>daily</changefreq>
            </url>';
        $links = unified::getAllObjects('link_details');
        $pictures = unified::getAllObjects('picture_details');
        $blogs = unified::getAllObjects('blog_details');
        foreach ($links as $linkdetails){
            $output .= "<url>
                <loc>http://thisaintnews.com/viewlink/{$linkdetails['link_id']}/".
                user::cleanTitle($linkdetails['title'])."/</loc>
                <priority>0.80</priority>
                <changefreq>always</changefreq>
                </url>";
        }
        foreach ($blogs as $blogdetails){
            $output .= "<url>
                <loc>http://thisaintnews.com/viewblog/{$blogdetails['blog_id']}/".
                user::cleanTitle($blogdetails['title'])."/</loc>
                <priority>0.80</priority>
                <changefreq>always</changefreq>
                </url>";
        }
        foreach ($pictures as $picdetails){
            $output .= "<url>
                <loc>http://thisaintnews.com/viewpic/{$picdetails['picture_id']}/".
                user::cleanTitle($picdetails['title'])."/</loc>
                <priority>0.80</priority>
                <changefreq>always</changefreq>
                </url>";
        }

        $output .= "</urlset>";
        print $output;
        $noPage = 1;
        break;

    case 12:  //viewblog
        $where='blog';
        require_once('code/unified.php');

        $blog = new unified('blog');

        $blog_id = (int)$_GET['blog'];
        $details = $blog->getPageObjects(null, null, null, null, $blog_id);
        $details = $details[0];

        if (sizeOf($details)>1){
            $title = stripslashes($details['title']);

            if ($details['promoted'] != '0000-00-00 00:00:00') {
                $typeo = 0;
            } else {
                $typeo = 1;
            }
            
            $middle .= $blog->CreateObjectHTML($details, $typeo, 1);
            $middle .= $blog->CreateCommentHTML($blog->getComments($details['blog_id']), $details['blog_id']);
        } else {
            $middle .= $link->error404();
        }
        break; 

    case 13:  //tagcloud
        require_once('code/tag.php');
        $tag = new tag();
        $cloud = $tag->createCloud('all');
        $title = 'Tag Cloud';
        $middle = "<div class='tagholder'>".$cloud."</div>";
        break;

    case 14:  //tagthumbs
        require_once('code/tag.php');
        require_once('code/picture.php');
        $tag = new tag();
        $picture = new picture();

        $noPage = 1;

        $tagss = urldecode($_GET['tags']);
        $res = $tag->getMatchingObjects('picture', $tagss);
        $alreadydone = array();
        foreach ($res as $tagrow){
            foreach ($tagrow as $picid){
                if (!in_array($picid['picture_id'], $alreadydone)){
                    $details = $picture->getPicDetails($picid['picture_id']);
                    $images .="<img id='pic{$picid['picture_id']}' 
                        style='height:50px;width:50px;cursor:pointer;vertical-align:middle;margin-top:15px;' 
                        src='/thumb/{$details['picture_id']}/100/' alt={$picid['picture_id']} 
                        onclick=\"selectImage(this.id);return false;\" />\n";
                    $alreadydone[] = $picid['picture_id'];
                }
            }
        }
        print $images;
        exit();
        break;

    case 15:  //error404
        require_once('code/unified.php');
        $middle .= unified::error404();
        break;
}
//  bottom 

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
}
?>
